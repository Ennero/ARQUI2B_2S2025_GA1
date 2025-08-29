from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import Integer, String, TIMESTAMP, text
from sqlalchemy.dialects.postgresql import JSONB
from typing import Optional

class Base(DeclarativeBase):
    pass

class SensorReading(Base):
    __tablename__ = "sensor_readings"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    source: Mapped[Optional[str]] = mapped_column(String(40))
    type: Mapped[str] = mapped_column(String(30), index=True)
    value: Mapped[Optional[float]]  # NUMERIC en DB; SQLAlchemy mapea a Decimal/float
    unit: Mapped[Optional[str]] = mapped_column(String(10))
    zone: Mapped[Optional[str]] = mapped_column(String(40))
    ts: Mapped[str] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))

class Alert(Base):
    __tablename__ = "alerts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    category: Mapped[str] = mapped_column(String(30), index=True)
    payload: Mapped[dict] = mapped_column(JSONB)
    severity: Mapped[int] = mapped_column(Integer, default=1)
    ack: Mapped[bool] = mapped_column(default=False)
    ts: Mapped[str] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))

class BusPosition(Base):
    __tablename__ = "bus_positions"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    bus_id: Mapped[str] = mapped_column(String(20), index=True)
    stop_distance_m: Mapped[int]
    eta_seconds: Mapped[int]
    ts: Mapped[str] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))
