'''
MIT License

Copyright (c) 2025 Marcos Bonifasi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''
from fastapi import APIRouter, Query, Depends, HTTPException
from typing import List, Dict, Any, Optional
from datetime import datetime, date, time, timedelta, timezone
from motor.motor_asyncio import AsyncIOMotorDatabase
from config.database import get_db

router = APIRouter(prefix="/analytics", tags=["analytics"])

# --- helpers de tiempo ---
GT_TZ = timezone(timedelta(hours=-6))  # America/Guatemala (sin DST; ajusta si usas pytz/zoneinfo)

def parse_iso_dt(v: Any) -> Optional[datetime]:
    if isinstance(v, datetime):
        return v
    if isinstance(v, str):
        try:
            # Soporta 'Z' y offsets
            if v.endswith("Z"):
                return datetime.fromisoformat(v.replace("Z", "+00:00"))
            return datetime.fromisoformat(v)
        except Exception:
            return None
    return None

def day_range_utc(day: date) -> tuple[datetime, datetime]:
    """Convierte un día local (Guatemala) al rango UTC [start, end)."""
    start_local = datetime.combine(day, time.min, tzinfo=GT_TZ)
    end_local = start_local + timedelta(days=1)
    return (start_local.astimezone(timezone.utc), end_local.astimezone(timezone.utc))

# --- extracción de PM ---
def extract_pm_values(doc: Dict[str, Any]) -> list[tuple[datetime, float]]:
    """
    Devuelve lista de (ts, value) para PM. Soporta varias formas:
    - doc["frame"] con PM1/PM2
    - doc["data"] lista de objetos con metric/value, sensor_id/value, o {PM1: 155}
    - ts preferente: doc["ts"], luego created_at
    """
    out: list[tuple[datetime, float]] = []

    # Escoger ts
    ts = parse_iso_dt(doc.get("ts")) or parse_iso_dt(doc.get("created_at"))
    if ts is None:
        ts = datetime.now(timezone.utc)

    # A) frame
    frame = doc.get("frame")
    if isinstance(frame, dict):
        for key in ("PM1", "PM2"):
            if key in frame and frame[key] not in (None, ""):
                try:
                    out.append((ts, float(frame[key])))
                except Exception:
                    pass

    # B) data (lista)
    data = doc.get("data")
    if isinstance(data, list):
        for item in data:
            # i) {"metric":"pm", "value":...}
            if isinstance(item, dict) and item.get("metric") == "pm" and "value" in item:
                try:
                    out.append((parse_iso_dt(item.get("ts")) or ts, float(item["value"])))
                except Exception:
                    pass
                continue
            # ii) {"sensor_id":"PM1","value":...}
            if isinstance(item, dict) and item.get("sensor_id", "").upper().startswith("PM") and "value" in item:
                try:
                    out.append((parse_iso_dt(item.get("ts")) or ts, float(item["value"])))
                except Exception:
                    pass
                continue
            # iii) {"PM1": 155} o similar
            if isinstance(item, dict):
                for k, v in item.items():
                    if isinstance(k, str) and k.upper().startswith("PM"):
                        try:
                            out.append((ts, float(v)))
                        except Exception:
                            pass

    return out

# --- conteo de alertas críticas ---
def is_critical_event(ev: Dict[str, Any]) -> bool:
    return (ev.get("severity") or "").lower() == "critical"

# --- conteo de "recorridos" ---
def is_bus_arrival(ev: Dict[str, Any], route_name: str) -> bool:
    """
    Cuenta eventos de llegada de bus por ruta.
    Preferimos type='bus_arrival' con data.route='transmetro'/'transurbano'.
    Si no hay data.route, tratamos de inferir por sensor_id (BUS1->transmetro, BUS2->transurbano) como fallback.
    """
    if (ev.get("type") or "").lower() != "bus_arrival":
        return False
    data = ev.get("data") or {}
    route = (data.get("route") or "").lower()
    if route:
        return route == route_name.lower()
    # fallback simple
    sid = (data.get("sensor_id") or "").upper()
    if route_name.lower() == "transmetro":
        return sid == "BUS1"
    if route_name.lower() == "transurbano":
        return sid == "BUS2"
    return False

@router.get("/daily")
async def analytics_daily(
    day: Optional[str] = Query(default=None, description="YYYY-MM-DD in local time (America/Guatemala)"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    """
    Devuelve:
    {
      "summary": {
        "recorridoTransmetro": int,
        "recorridoTransurbano": int,
        "calidadAirePromedio": float,
        "alertasCriticas": int
      },
      "airQualityChart": {
        "label": "Calidad del Aire (Hoy|YYYY-MM-DD)",
        "dataPoints": [ { "hour": 0, "value": float }, ... cada 2 h ]
      }
    }
    """
    # 1) rango de día en UTC
    if day:
        try:
            y, m, d = map(int, day.split("-"))
            day_obj = date(y, m, d)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid 'day' format. Use YYYY-MM-DD.")
    else:
        day_obj = datetime.now(GT_TZ).date()

    start_utc, end_utc = day_range_utc(day_obj)

    # 2) cargar events del día
    events_cur = db.events.find({
        "created_at": {"$gte": start_utc.isoformat(), "$lt": end_utc.isoformat()}
    })
    events: list[Dict[str, Any]] = [e async for e in events_cur]

    # 3) cargar readings del día
    readings_cur = db.readings.find({
        # usa ts si existe; si no, created_at
        "$or": [
            {"ts": {"$gte": start_utc.isoformat(), "$lt": end_utc.isoformat()}},
            {"created_at": {"$gte": start_utc.isoformat(), "$lt": end_utc.isoformat()}},
        ]
    })
    readings: list[Dict[str, Any]] = [r async for r in readings_cur]

    # 4) calidad del aire promedio (promedio simple de todos los PM)
    pm_values: list[float] = []
    pm_by_hour: dict[int, list[float]] = {h: [] for h in range(0, 24, 2)}  # 0,2,...,22

    for doc in readings:
        pairs = extract_pm_values(doc)
        for ts, val in pairs:
            try:
                # normaliza ts a UTC
                if ts.tzinfo is None:
                    ts = ts.replace(tzinfo=timezone.utc)
                ts_utc = ts.astimezone(timezone.utc)
                if start_utc <= ts_utc < end_utc:
                    pm_values.append(val)
                    # bucket de 2 en 2 horas
                    hour_even = (ts_utc.hour // 2) * 2
                    pm_by_hour[hour_even].append(val)
            except Exception:
                continue

    calidad_prom = round(sum(pm_values) / len(pm_values), 2) if pm_values else 0.0

    # 5) alertas críticas
    alertas_criticas = sum(1 for e in events if is_critical_event(e))

    # 6) recorridos (conteo de eventos bus_arrival); si no existen, quedarán 0
    recorrido_transmetro = sum(1 for e in events if is_bus_arrival(e, "transmetro"))
    recorrido_transurbano = sum(1 for e in events if is_bus_arrival(e, "transurbano"))

    # 7) chart por hora (cada 2 h: 0..22)
    datapoints = []
    for h in range(0, 24, 2):
        vals = pm_by_hour.get(h, [])
        v = round(sum(vals) / len(vals), 1) if vals else 0.0
        datapoints.append({"hour": h, "value": v})

    label = "Calidad del Aire (Hoy)" if day is None else f"Calidad del Aire ({day_obj.isoformat()})"

    return {
        "summary": {
            "recorridoTransmetro": int(recorrido_transmetro),
            "recorridoTransurbano": int(recorrido_transurbano),
            "calidadAirePromedio": calidad_prom,
            "alertasCriticas": int(alertas_criticas),
        },
        "airQualityChart": {
            "label": label,
            "dataPoints": datapoints,
        },
    }
