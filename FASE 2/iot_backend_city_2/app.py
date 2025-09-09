# app.py
import os
from flask import Flask
from dashboard_routes import bp as dashboard_bp
from ingest_routes import bp as ingest_bp



app = Flask(__name__)
app.register_blueprint(dashboard_bp)
app.register_blueprint(ingest_bp)

@app.get("/api/health")
def health():
    return jsonify(status="ok")


if __name__ == "__main__":
    import os
    port = int(os.getenv("API_PORT", "8080"))
    app.run(host="0.0.0.0", port=port, debug=os.getenv("FLASK_ENV")=="development")
