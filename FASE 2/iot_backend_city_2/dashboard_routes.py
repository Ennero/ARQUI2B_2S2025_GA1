# dashboard_routes.py
from flask import Blueprint, jsonify
from datetime import datetime, timedelta, timezone
from statistics import mean
import os

# Ajusta el import según tu proyecto
from db_mongo import MongoDBConnection

bp = Blueprint("dashboard", __name__, url_prefix="/api/dashboard")

DB_NAME = os.getenv("MONGO_DB", "iotcity")
COLL = "snapshots"
BUS_CIRCUIT_MAX = float(os.getenv("BUS_CIRCUIT_MAX", "100"))   # unidades del circuito antes de volver a 0
BUS_UNIT_PER_KM = float(os.getenv("BUS_UNIT_PER_KM", "1000"))  # cuántas unidades = 1km
TOKEN = os.getenv("INGEST_TOKEN")  # opcional seguridad

def _col():
    return MongoDBConnection().get_collection(DB_NAME, COLL)

def _now_utc():
    return datetime.now(timezone.utc)

def _range_today():
    now = _now_utc()
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    end = start + timedelta(days=1)
    return start, end

def _range_days(n:int):
    end = _now_utc().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    start = end - timedelta(days=n)
    return start, end

def _range_weeks(n:int):
    # n semanas hasta hoy (inclusive)
    end = _now_utc().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    start = end - timedelta(weeks=n)
    return start, end

def _iter_docs(start, end):
    return _col().find(
        {"ts": {"$gte": start, "$lt": end}},
        projection={
            "ts":1,
            "environment.pm1":1, "environment.pm2":1,
            "environment.sismo":1, "environment.inc1":1, "environment.inc2":1,
            "panic":1, "infractions":1,
            "buses.bus1":1, "buses.bus2":1
        }
    ).sort("ts", 1)

def _pm_value(doc):
    env = (doc.get("environment") or {})
    pm1 = env.get("pm1")
    pm2 = env.get("pm2")
    vals = [v for v in (pm1, pm2) if isinstance(v, (int, float))]
    return mean(vals) if vals else None

def _is_critical(doc):
    env = (doc.get("environment") or {})
    if env.get("sismo") == 1 or env.get("inc1") == 1 or env.get("inc2") == 1:
        return True
    pa = (doc.get("panic") or {})
    if any(pa.get(f"panico{i}") == 1 for i in range(1,6)):
        return True
    inf = (doc.get("infractions") or {})
    if any(inf.get(k) == 1 for k in ["infraa","infrab","infrac","infrad"]):
        return True
    return False

def _sum_distance_with_wrap(values):
    """
    values: lista de lecturas consecutivas del bus (posiciones en el circuito).
    Suma deltas positivos; si hay wrap (v_actual < v_anterior) suma (CIRCUIT_MAX - v_anterior) + v_actual.
    Devuelve kilómetros (aplica conversión BUS_UNIT_PER_KM).
    """
    if not values:
        return 0.0
    total_units = 0.0
    last = None
    for v in values:
        if not isinstance(v, (int, float)):
            last = v
            continue
        if last is None:
            last = v
            continue
        if v >= last:
            delta = v - last
        else:
            # wrap
            delta = (BUS_CIRCUIT_MAX - last) + v
        if delta > 0:
            total_units += delta
        last = v
    km = total_units / BUS_UNIT_PER_KM
    return round(km, 1)

# ---------- /api/dashboard/today ----------
@bp.get("/today")
def dashboard_today():
    start, end = _range_today()
    docs = list(_iter_docs(start, end))

    # Summary
    pm_values = [v for v in (_pm_value(d) for d in docs) if v is not None]
    calidad = round(mean(pm_values), 1) if pm_values else 0.0
    criticas = sum(1 for d in docs if _is_critical(d))
    bus1_series = [ (d.get("buses") or {}).get("bus1") for d in docs ]
    bus2_series = [ (d.get("buses") or {}).get("bus2") for d in docs ]
    transmetro_km = _sum_distance_with_wrap(bus1_series)
    transurbano_km = _sum_distance_with_wrap(bus2_series)

    # Gráfico por hora (0..23) de calidad de aire
    buckets = {h: [] for h in range(24)}
    for d in docs:
        val = _pm_value(d)
        if val is None: 
            continue
        h = d["ts"].hour
        buckets[h].append(val)
    points = [{"hour": h, "value": round(mean(v),1) if v else 0.0} for h, v in buckets.items()]

    out = {
      "summary": {
        "recorridoTransmetro": transmetro_km,
        "recorridoTransurbano": transurbano_km,
        "calidadAirePromedio": calidad,
        "alertasCriticas": criticas
      },
      "airQualityChart": {
        "label": "Calidad del Aire (Hoy)",
        "dataPoints": points
      }
    }
    return jsonify(out)

# ---------- /api/dashboard/last7days ----------
@bp.get("/last7days")
def dashboard_last7days():
    start, end = _range_days(7)
    docs = list(_iter_docs(start, end))

    # Agrupa por día relativo (0..6)
    day0 = start.date()
    day_buckets = {i: [] for i in range(7)}
    for d in docs:
        idx = (d["ts"].date() - day0).days
        if 0 <= idx < 7:
            day_buckets[idx].append(d)

    def day_label(i): return f"Día {i+1}"

    series_tm, series_tu, series_pm, series_alert = [], [], [], []
    for i in range(7):
        ds = day_buckets[i]
        bus1_series = [ (d.get("buses") or {}).get("bus1") for d in ds ]
        bus2_series = [ (d.get("buses") or {}).get("bus2") for d in ds ]
        tm_km = _sum_distance_with_wrap(bus1_series)
        tu_km = _sum_distance_with_wrap(bus2_series)
        pms = [v for v in (_pm_value(d) for d in ds) if v is not None]
        pm_avg = round(mean(pms), 1) if pms else 0.0
        alert_cnt = sum(1 for d in ds if _is_critical(d))

        series_tm.append({"label": day_label(i), "value": tm_km})
        series_tu.append({"label": day_label(i), "value": tu_km})
        series_pm.append({"label": day_label(i), "value": pm_avg})
        series_alert.append({"label": day_label(i), "value": round(float(alert_cnt), 1)})

    # Summary del periodo completo
    pm_values = [v for v in (_pm_value(d) for d in docs) if v is not None]
    calidad = round(mean(pm_values), 1) if pm_values else 0.0
    criticas = sum(1 for d in docs if _is_critical(d))
    tm_total = _sum_distance_with_wrap([ (d.get("buses") or {}).get("bus1") for d in docs ])
    tu_total = _sum_distance_with_wrap([ (d.get("buses") or {}).get("bus2") for d in docs ])

    out = {
      "summary": {
        "recorridoTransmetro": tm_total,
        "recorridoTransurbano": tu_total,
        "calidadAirePromedio": calidad,
        "alertasCriticas": round(float(criticas), 1)
      },
      "detailedMetrics": [
        {"title": "Recorrido Transmetro (km)", "timeSeries": series_tm},
        {"title": "Recorrido Transurbano (km)", "timeSeries": series_tu},
        {"title": "Calidad del Aire (PM)", "timeSeries": series_pm},
        {"title": "Alertas Críticas", "timeSeries": series_alert}
      ]
    }
    return jsonify(out)

# ---------- /api/dashboard/last4weeks ----------
@bp.get("/last4weeks")
def dashboard_last4weeks():
    start, end = _range_weeks(4)
    docs = list(_iter_docs(start, end))

    # Buckets semanales 0..3 (cada 7 días desde start)
    week_buckets = {i: [] for i in range(4)}
    for d in docs:
        days = (d["ts"].date() - start.date()).days
        idx = min(3, max(0, days // 7))
        week_buckets[idx].append(d)

    def week_label(i): return f"Semana {i+1}"

    series_tm, series_tu, series_pm, series_alert = [], [], [], []
    for i in range(4):
        ds = week_buckets[i]
        bus1_series = [ (d.get("buses") or {}).get("bus1") for d in ds ]
        bus2_series = [ (d.get("buses") or {}).get("bus2") for d in ds ]
        tm_km = _sum_distance_with_wrap(bus1_series)
        tu_km = _sum_distance_with_wrap(bus2_series)
        pms = [v for v in (_pm_value(d) for d in ds) if v is not None]
        pm_avg = round(mean(pms), 1) if pms else 0.0
        alert_cnt = sum(1 for d in ds if _is_critical(d))

        series_tm.append({"label": week_label(i), "value": tm_km})
        series_tu.append({"label": week_label(i), "value": tu_km})
        series_pm.append({"label": week_label(i), "value": pm_avg})
        series_alert.append({"label": week_label(i), "value": round(float(alert_cnt), 1)})

    # Summary del periodo
    pm_values = [v for v in (_pm_value(d) for d in docs) if v is not None]
    calidad = round(mean(pm_values), 1) if pm_values else 0.0
    criticas = sum(1 for d in docs if _is_critical(d))
    tm_total = _sum_distance_with_wrap([ (d.get("buses") or {}).get("bus1") for d in docs ])
    tu_total = _sum_distance_with_wrap([ (d.get("buses") or {}).get("bus2") for d in docs ])

    out = {
      "summary": {
        "recorridoTransmetro": tm_total,
        "recorridoTransurbano": tu_total,
        "calidadAirePromedio": calidad,
        "alertasCriticas": round(float(criticas), 1)
      },
      "detailedMetrics": [
        {"title": "Recorrido Transmetro (km)", "timeSeries": series_tm},
        {"title": "Recorrido Transurbano (km)", "timeSeries": series_tu},
        {"title": "Calidad del Aire (PM)", "timeSeries": series_pm},
        {"title": "Alertas Críticas", "timeSeries": series_alert}
      ]
    }
    return jsonify(out)

