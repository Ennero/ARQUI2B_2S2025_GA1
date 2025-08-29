from flask import Blueprint, jsonify
from app.db import get_session
from app.services.transport_service import TransportService

bp = Blueprint("transport", __name__, url_prefix="/api/transport")

@bp.get("/buses")
def buses():
    with get_session() as db:
        svc = TransportService(db)
        return jsonify(svc.buses())
