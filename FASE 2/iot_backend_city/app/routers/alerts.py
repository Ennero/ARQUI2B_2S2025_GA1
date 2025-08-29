from flask import Blueprint, request, jsonify, abort
from app.db import get_session
from app.services.alerts_service import AlertsService

bp = Blueprint("alerts", __name__, url_prefix="/api/alerts")

@bp.get("/recent")
def recent():
    limit = int(request.args.get("limit", 50))
    with get_session() as db:
        svc = AlertsService(db)
        return jsonify(svc.recent(limit))

@bp.post("/ack/<int:alert_id>")
def ack(alert_id: int):
    with get_session() as db:
        svc = AlertsService(db)
        if svc.ack(alert_id):
            return ("", 204)
        abort(404, description="Alert not found")
