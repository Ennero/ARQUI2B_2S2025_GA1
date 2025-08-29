from flask import Blueprint, request, jsonify
from datetime import datetime
from app.db import get_session
from app.services.sensors_service import SensorsService

bp = Blueprint("sensors", __name__, url_prefix="/api/sensors")

@bp.get("/history")
def history():
    params = request.args
    type_ = params.get("type")
    zone = params.get("zone")
    source = params.get("source")
    dt_from = params.get("from")
    dt_to = params.get("to")
    page = int(params.get("page", 1))
    page_size = int(params.get("page_size", 50))

    def parse_dt(x):
        if not x: return None
        try: return datetime.fromisoformat(x.replace("Z","+00:00"))
        except: return None

    with get_session() as db:
        svc = SensorsService(db)
        data = svc.history(
            type_, zone, source,
            parse_dt(dt_from), parse_dt(dt_to),
            page, page_size
        )
        return jsonify(data)
