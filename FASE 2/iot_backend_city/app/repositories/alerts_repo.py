from sqlalchemy import select, update
from sqlalchemy.orm import Session
from app.models import Alert

class AlertsRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_recent(self, limit: int = 50):
        stmt = select(Alert).order_by(Alert.ts.desc()).limit(limit)
        return self.db.execute(stmt).scalars().all()

    def ack(self, alert_id: int) -> bool:
        res = self.db.execute(
            update(Alert).where(Alert.id == alert_id).values(ack=True)
        )
        self.db.commit()
        return res.rowcount > 0
