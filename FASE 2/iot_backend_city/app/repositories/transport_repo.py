from sqlalchemy import select, func
from sqlalchemy.orm import Session
from app.models import BusPosition

class TransportRepository:
    def __init__(self, db: Session):
        self.db = db

    def latest_by_bus(self):
        sub = select(BusPosition.bus_id, func.max(BusPosition.ts).label("m"))
        sub = sub.group_by(BusPosition.bus_id).subquery()
        stmt = select(BusPosition).join(
            sub,
            (BusPosition.bus_id == sub.c.bus_id) & (BusPosition.ts == sub.c.m)
        )
        return self.db.execute(stmt).scalars().all()
