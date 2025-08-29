from sqlalchemy.orm import Session
from app.repositories.transport_repo import TransportRepository

class TransportService:
    def __init__(self, db: Session):
        self.repo = TransportRepository(db)

    def buses(self):
        items = self.repo.latest_by_bus()
        def to_dict(x):
            return dict(id=x.id, bus_id=x.bus_id, stop_distance_m=x.stop_distance_m,
                        eta_seconds=x.eta_seconds, ts=str(x.ts))
        return {"items": [to_dict(i) for i in items]}
