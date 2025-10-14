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
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, date, time, timedelta, timezone
from motor.motor_asyncio import AsyncIOMotorDatabase
from config.database import get_db

router = APIRouter(prefix="/analytics", tags=["analytics"])

# --- Zona horaria: Guatemala (UTC-6, simple sin DST) ---
GT_TZ = timezone(timedelta(hours=-6))

# ---------- Helpers básicos de tiempo ----------
def parse_iso_dt(v: Any) -> Optional[datetime]:
    if isinstance(v, datetime):
        return v
    if isinstance(v, str):
        try:
            if v.endswith("Z"):
                return datetime.fromisoformat(v.replace("Z", "+00:00"))
            return datetime.fromisoformat(v)
        except Exception:
            return None
    return None

def day_range_utc(day_local: date) -> Tuple[datetime, datetime]:
    start_local = datetime.combine(day_local, time.min, tzinfo=GT_TZ)
    end_local = start_local + timedelta(days=1)
    return start_local.astimezone(timezone.utc), end_local.astimezone(timezone.utc)

def week_days_from(day_local: date) -> List[date]:
    # semana lunes..domingo que contiene a day_local
    monday = day_local - timedelta(days=day_local.weekday())
    return [monday + timedelta(days=i) for i in range(7)]

def month_days(year: int, month: int) -> List[date]:
    import calendar
    ndays = calendar.monthrange(year, month)[1]
    return [date(year, month, d) for d in range(1, ndays + 1)]

def split_days_into_weeks(days: List[date]) -> List[List[date]]:
    if not days:
        return []
    weeks: List[List[date]] = []
    bucket: List[date] = []
    for d in days:
        if not bucket:
            bucket = [d]
        else:
            if d == bucket[-1] + timedelta(days=1):
                bucket.append(d)
            else:
                weeks.append(bucket)
                bucket = [d]
        # cerrar al domingo
        if d.weekday() == 6:
            weeks.append(bucket)
            bucket = []
    if bucket:
        weeks.append(bucket)
    return weeks

# ---------- Lectura de Mongo ----------
async def find_events_in_range(db: AsyncIOMotorDatabase, start_utc: datetime, end_utc: datetime) -> List[Dict[str, Any]]:
    # Tus timestamps se guardan como ISO8601 string -> filtramos por string ISO
    cur = db.events.find({
        "created_at": {
            "$gte": start_utc.isoformat(),
            "$lt":  end_utc.isoformat(),
        }
    })
    return [doc async for doc in cur]

async def find_readings_in_range(db: AsyncIOMotorDatabase, start_utc: datetime, end_utc: datetime) -> List[Dict[str, Any]]:
    # algunos podrían tener 'ts', pero seguro tienen 'created_at'
    cur = db.readings.find({
        "created_at": {
            "$gte": start_utc.isoformat(),
            "$lt":  end_utc.isoformat(),
        }
    })
    return [doc async for doc in cur]

# ---------- Extracciones ----------
def extract_pm_values_from_reading(doc: Dict[str, Any]) -> List[float]:
    """
    Retorna los valores de PM (PM1, PM2) si existen en reading.frame.
    Los strings "0" también se convierten a float.
    """
    vals: List[float] = []
    frame = doc.get("frame") or {}
    for key in ("PM1", "PM2"):
        if key in frame:
            try:
                vals.append(float(frame[key]))
            except Exception:
                pass
    return vals

def detect_bus_hits(doc: Dict[str, Any]) -> Tuple[int, int]:
    """
    Aprox. de 'recorridos':
    cuenta 1 si BUS1 != "0" (Transmetro) y 1 si BUS2 != "0" (Transurbano) en esta lectura.
    """
    frame = doc.get("frame") or {}
    tm = 1 if str(frame.get("BUS1", "0")).strip() not in ("", "0", "0.0") else 0
    tu = 1 if str(frame.get("BUS2", "0")).strip() not in ("", "0", "0.0") else 0
    return tm, tu

def is_critical(ev: Dict[str, Any]) -> bool:
    return (ev.get("severity") or "").lower() == "critical"

# ---------- Métrica por DÍA ----------
async def compute_daily(db: AsyncIOMotorDatabase, day_local: date) -> Dict[str, float]:
    start_utc, end_utc = day_range_utc(day_local)

    events  = await find_events_in_range(db, start_utc, end_utc)
    readings = await find_readings_in_range(db, start_utc, end_utc)

    # PM promedio (promedio simple de todos los PM1/PM2 del día)
    pm_vals: List[float] = []
    for r in readings:
        pm_vals.extend(extract_pm_values_from_reading(r))
    pm_avg = round(sum(pm_vals)/len(pm_vals), 1) if pm_vals else 0.0

    # Recorridos (aprox por lectura)
    tm = tu = 0
    for r in readings:
        x, y = detect_bus_hits(r)
        tm += x
        tu += y

    # Alertas críticas
    crit = sum(1 for e in events if is_critical(e))

    return {
        "recorrido_transmetro": float(tm),
        "recorrido_transurbano": float(tu),
        "pm_avg": float(pm_avg),
        "crit_alerts": float(crit),
    }

# ---------- /analytics/daily ----------
@router.get("/daily")
async def analytics_daily(
    day: Optional[str] = Query(default=None, description="YYYY-MM-DD en hora local (Guatemala)"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    if day:
        try:
            y, m, d = map(int, day.split("-"))
            dlocal = date(y, m, d)
        except Exception:
            raise HTTPException(status_code=400, detail="Formato de 'day' inválido. Usa YYYY-MM-DD.")
    else:
        dlocal = datetime.now(GT_TZ).date()

    start_utc, end_utc = day_range_utc(dlocal)
    res = await compute_daily(db, dlocal)

    # Gráfica cada 2 horas
    readings = await find_readings_in_range(db, start_utc, end_utc)
    buckets: Dict[int, List[float]] = {h: [] for h in range(0, 24, 2)}
    for r in readings:
        # mejor esfuerzo: usa created_at como ts
        ts = parse_iso_dt(r.get("ts")) or parse_iso_dt(r.get("created_at"))
        if not ts:
            continue
        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=timezone.utc)
        ts_utc = ts.astimezone(timezone.utc)
        if not (start_utc <= ts_utc < end_utc):
            continue
        vals = extract_pm_values_from_reading(r)
        if not vals:
            continue
        hour_even = (ts_utc.hour // 2) * 2
        buckets[hour_even].extend(vals)

    datapoints = []
    for h in range(0, 24, 2):
        v = round(sum(buckets[h])/len(buckets[h]), 1) if buckets[h] else 0.0
        datapoints.append({"hour": h, "value": v})

    label = "Calidad del Aire (Hoy)" if day is None else f"Calidad del Aire ({dlocal.isoformat()})"

    return {
        "summary": {
            "recorridoTransmetro": round(res["recorrido_transmetro"], 1),
            "recorridoTransurbano": round(res["recorrido_transurbano"], 1),
            "calidadAirePromedio": res["pm_avg"],
            "alertasCriticas": round(res["crit_alerts"], 1),
        },
        "airQualityChart": {
            "label": label,
            "dataPoints": datapoints,
        },
    }

# ---------- /analytics/weekly ----------
@router.get("/weekly")
async def analytics_weekly(
    day: Optional[str] = Query(default=None, description="Un día (YYYY-MM-DD) dentro de la semana objetivo, hora local GT"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    if day:
        try:
            y, m, d = map(int, day.split("-"))
            dlocal = date(y, m, d)
        except Exception:
            raise HTTPException(status_code=400, detail="Formato de 'day' inválido. Usa YYYY-MM-DD.")
    else:
        dlocal = datetime.now(GT_TZ).date()

    days = week_days_from(dlocal)
    daily_vals = [await compute_daily(db, d) for d in days]

    # Summary semanal
    sum_tm = sum(x["recorrido_transmetro"] for x in daily_vals)
    sum_tu = sum(x["recorrido_transurbano"] for x in daily_vals)
    pm_days = [x["pm_avg"] for x in daily_vals if x["pm_avg"] > 0]
    pm_week = round(sum(pm_days)/len(pm_days), 1) if pm_days else 0.0
    sum_crit = sum(x["crit_alerts"] for x in daily_vals)

    def mk_series(title: str, key: str) -> Dict[str, Any]:
        return {
            "title": title,
            "timeSeries": [
                {"label": f"Día {i+1}", "value": round(daily_vals[i][key], 1)} for i in range(7)
            ],
        }

    return {
        "summary": {
            "recorridoTransmetro": round(sum_tm, 1),
            "recorridoTransurbano": round(sum_tu, 1),
            "calidadAirePromedio": pm_week,
            "alertasCriticas": round(sum_crit, 1),
        },
        "detailedMetrics": [
            mk_series("Recorrido Transmetro (km)", "recorrido_transmetro"),
            mk_series("Recorrido Transurbano (km)", "recorrido_transurbano"),
            mk_series("Calidad del Aire (PM)", "pm_avg"),
            mk_series("Alertas Críticas", "crit_alerts"),
        ],
    }

# ---------- /analytics/monthly ----------
@router.get("/monthly")
async def analytics_monthly(
    year: Optional[int] = Query(default=None),
    month: Optional[int] = Query(default=None),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    now_local = datetime.now(GT_TZ)
    y = year or now_local.year
    m = month or now_local.month

    days = month_days(y, m)
    weeks = split_days_into_weeks(days)  # semanas del mes (4 o 5 según caiga)

    weekly_vals = []
    for wk in weeks:
        vals = [await compute_daily(db, d) for d in wk]
        tm = sum(x["recorrido_transmetro"] for x in vals)
        tu = sum(x["recorrido_transurbano"] for x in vals)
        pm_days = [x["pm_avg"] for x in vals if x["pm_avg"] > 0]
        pm = round(sum(pm_days)/len(pm_days), 1) if pm_days else 0.0
        crit = sum(x["crit_alerts"] for x in vals)
        weekly_vals.append({
            "recorrido_transmetro": tm,
            "recorrido_transurbano": tu,
            "pm_avg": pm,
            "crit_alerts": crit,
        })

    sum_tm = sum(x["recorrido_transmetro"] for x in weekly_vals)
    sum_tu = sum(x["recorrido_transurbano"] for x in weekly_vals)
    pm_weeks = [x["pm_avg"] for x in weekly_vals if x["pm_avg"] > 0]
    pm_month = round(sum(pm_weeks)/len(pm_weeks), 1) if pm_weeks else 0.0
    sum_crit = sum(x["crit_alerts"] for x in weekly_vals)

    def mk_series(title: str, key: str) -> Dict[str, Any]:
        return {
            "title": title,
            "timeSeries": [
                {"label": f"Semana {i+1}", "value": round(weekly_vals[i][key], 1)} for i in range(len(weekly_vals))
            ],
        }

    return {
        "summary": {
            "recorridoTransmetro": round(sum_tm, 1),
            "recorridoTransurbano": round(sum_tu, 1),
            "calidadAirePromedio": pm_month,
            "alertasCriticas": round(sum_crit, 1),
        },
        "detailedMetrics": [
            mk_series("Recorrido Transmetro (km)", "recorrido_transmetro"),
            mk_series("Recorrido Transurbano (km)", "recorrido_transurbano"),
            mk_series("Calidad del Aire (PM)", "pm_avg"),
            mk_series("Alertas Críticas", "crit_alerts"),
        ],
    }


# ---------- /analytics/infractions-today ----------
@router.get("/infractions-today")
async def analytics_infractions_today(db: AsyncIOMotorDatabase = Depends(get_db)):
    """
    Devuelve las infracciones de semáforo detectadas hoy.
    ASUNCIÓN: El evento de tipo 'infraction' contiene la placa en ev['data']['plate'].
    """
    start_utc, end_utc = day_range_utc(datetime.now(GT_TZ).date())

    q = {
        "type": "infraction",
        "created_at": {
            "$gte": start_utc.isoformat(),
            "$lt": end_utc.isoformat(),
        }
    }
    
    cursor = db.events.find(q).sort("created_at", -1)
    
    infractions = []
    async for ev in cursor:
        data = ev.get("data") or {}
        infractions.append({
            "plate": data.get("plate", "N/A"),
            "timestamp": ev.get("created_at"),
            "ubication": ev.get("source", "Ubicación Desconocida") 
        })
        
    return infractions


# ---------- /analytics/top-weapons ----------
@router.get("/top-weapons")
async def analytics_top_weapons(
    limit: int = Query(10, ge=1, le=50),
    db: AsyncIOMotorDatabase = Depends(get_db)
):
    """
    Devuelve un ranking de los tipos de armas más detectados.
    """
    pipeline = [
        {
            "$group": {
                "_id": "$weapon_type",  # Agrupar por tipo de arma
                "detection_count": {"$sum": 1},  # Contar cuántas veces aparece cada tipo
                "representative_image_url": {"$first": "$image_url"} # Tomar la URL de la primera detección como representativa
            }
        },
        {
            "$sort": {"detection_count": -1} # Ordenar de más a menos detectadas
        },
        {
            "$limit": limit # Limitar al top N
        },
        {
            "$project": {
                "_id": 0, # No incluir el campo _id
                "weapon_type": "$_id",
                "detection_count": "$detection_count",
                "representative_image_url": "$representative_image_url"
            }
        }
    ]
    
    cursor = db.detecciones_armas.aggregate(pipeline)
    return [doc async for doc in cursor]


# ---------- /analytics/top-persons ----------
@router.get("/top-persons")
async def analytics_top_persons(
    limit: int = Query(10, ge=1, le=50),
    db: AsyncIOMotorDatabase = Depends(get_db)
):
    """
    Devuelve un ranking de las personas (IDs) más detectadas.
    """
    pipeline = [
        {
            "$group": {
                "_id": "$person_id", # Agrupar por el ID de la persona
                "detection_count": {"$sum": 1},
                "face_image_url": {"$first": "$image_url"}
            }
        },
        {
            "$sort": {"detection_count": -1}
        },
        {
            "$limit": limit
        },
        {
            "$project": {
                "_id": 0,
                "person_id": "$_id",
                "detection_count": "$detection_count",
                "face_image_url": "$face_image_url"
            }
        }
    ]
    
    cursor = db.detecciones_personas.aggregate(pipeline)
    return [doc async for doc in cursor]
