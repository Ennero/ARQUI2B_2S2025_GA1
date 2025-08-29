from flask import Flask
from flask import jsonify
from app.config import Config
from app.routes.health_routes import bp as health_bp
from app.routes.sensors_routes import bp as sensors_bp
from app.routes.alerts_routes import bp as alerts_bp
from app.routes.transport_routes import bp as transport_bp

def create_app() -> Flask:
    app = Flask(__name__)
    cfg = Config()
    app.config["JSON_SORT_KEYS"] = False

    # CORS muy simple (dev)
    @app.after_request
    def add_cors_headers(resp):
        resp.headers["Access-Control-Allow-Origin"] = cfg.CORS_ORIGINS
        resp.headers["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
        resp.headers["Access-Control-Allow-Headers"] = "Content-Type,Authorization"
        return resp

    # Blueprints
    app.register_blueprint(health_bp)
    app.register_blueprint(sensors_bp)
    app.register_blueprint(alerts_bp)
    app.register_blueprint(transport_bp)

    # Raíz
    @app.get("/")
    def root():
        return jsonify(app="IoT City API (Flask)", version="0.1.0")

    return app
