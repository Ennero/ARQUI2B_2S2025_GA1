from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import Config

config = Config()
engine = create_engine(config.SQLALCHEMY_URI, future=True, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)

def get_session():
    return SessionLocal()
