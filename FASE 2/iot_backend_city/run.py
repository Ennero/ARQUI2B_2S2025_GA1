from app import create_app
from app.config import Config

app = create_app()
cfg = Config()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=cfg.API_PORT, debug=(cfg.FLASK_ENV=="development"))
