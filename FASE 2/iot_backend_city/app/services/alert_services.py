from sqlalchemy.orm import Session
from app.repositories.alerts_repo import AlertsRepository

class AlertsService:
    def __init__(self, db: Session):
        self.repo = AlertsRepository(db)

    def recent(self, limit: int = 50):
        items = self.repo.get_recent(limit)
        def to_dict(x):
            return dict(id=x.id, category=x.category, payload=x.payload, severity=x.severity, ack=x.ack, ts=str(x.ts))
        return {"items": [to_dict(i) for i in items]}

    def ack(self, alert_id: int):
        ok = self.repo.ack(alert_id)
        return ok
