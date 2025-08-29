import os
from dotenv import load_dotenv
from dataclasses import dataclass

load_dotenv()

@dataclass
class Config:
    FLASK_ENV: str = os.getenv("FLASK_ENV", "development")
    API_PORT: int = int(os.getenv("API_PORT", "8080"))
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
    DB_NAME: str = os.getenv("DB_NAME", "iotcity")
    DB_USER: str = os.getenv("DB_USER", "iotuser")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "changeme")
    CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "*")

    @property
    def SQLALCHEMY_URI(self) -> str:
        return f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
