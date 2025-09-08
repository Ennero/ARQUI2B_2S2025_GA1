# ingest_routes.py
from flask import Blueprint, request, jsonify
from datetime import datetime, timezone
from db_mongo import MongoDBConnection

bp = Blueprint("ingest", __name__, url_prefix="/api")

DB_NAME = "ARQUI2B_2S2025_GA1"
COLL = "snapshots"

def _col():
    return MongoDBConnection().get_collection(DB_NAME, COLL)

def parse_mqtt_line(line: str) -> dict:
    """
    Convierte la cadena cruda de MQTT en un dict con las categorías:
    SEM1=VERDE;BUS1=120;PM1=155;PANICO1=0;INFRAA=1;...
    """
    parts = [p.strip() for p in line.split(";") if p.strip()]
    data = {"semaphores":{}, "buses":{}, "environment":{}, "panic":{}, "infractions":{}}

    for part in parts:
        if "=" not in part:
            continue
        k,v = part.split("=",1)
        k,v = k.strip().lower(), v.strip()

        # try numeric
        try:
            v = int(v)
        except ValueError:
            try:
                v = float(v)
            except ValueError:
                pass

        if k.startswith("sem"):
            data["semaphores"][k] = v
        elif k.startswith("bus") or k.startswith("dist"):
            data["buses"][k] = v
        elif k.startswith("pm") or k in ("sismo","inc1","inc2"):
            data["environment"][k] = v
        elif k.startswith("panico"):
            data["panic"][k] = v
        elif k.startswith("infra"):
            data["infractions"][k] = v
        else:
            data[k] = v

    data["ts"] = datetime.now(timezone.utc)
    return data

@bp.post("/ingest")
def ingest():
    payload = request.get_json(force=True)
    line = payload.get("line")
    if not line:
        return jsonify({"error":"missing 'line'"}), 400

    doc = parse_mqtt_line(line)
    _col().insert_one(doc)
    return jsonify({"status":"ok", "inserted": doc})
