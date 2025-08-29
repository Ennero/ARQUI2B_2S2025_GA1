from sqlalchemy import select, func
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
from app.models import SensorReading

class SensorsRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_history(self,
                    type_: Optional[str] = None,
                    zone: Optional[str] = None,
                    source: Optional[str] = None,
                    dt_from: Optional[datetime] = None,
                    dt_to: Optional[datetime] = None,
                    page: int = 1, page_size: int = 50):
        filters = []
        if type_:
            filters.append(SensorReading.type == type_)
        if zone:
            filters.append(SensorReading.zone == zone)
        if source:
            filters.append(SensorReading.source == source)
        if dt_from:
            filters.append(SensorReading.ts >= dt_from)
        if dt_to:
            filters.append(SensorReading.ts <= dt_to)

        total = self.db.execute(
            select(func.count()).select_from(SensorReading).where(*filters)
        ).scalar()

        stmt = (select(SensorReading)
                .where(*filters)
                .order_by(SensorReading.ts.desc())
                .offset((page-1)*page_size).limit(page_size))
        items = self.db.execute(stmt).scalars().all()
        return total or 0, items
