from typing import Optional
from datetime import datetime
from sqlalchemy.orm import Session
from app.repositories.sensors_repo import SensorsRepository

class SensorsService:
    def __init__(self, db: Session):
        self.repo = SensorsRepository(db)

    def history(self, type_: Optional[str], zone: Optional[str], source: Optional[str],
                dt_from: Optional[datetime], dt_to: Optional[datetime],
                page: int, page_size: int):
        total, items = self.repo.get_history(type_, zone, source, dt_from, dt_to, page, page_size)
        # Mapea objetos a dicts simples
        def to_dict(x):
            return dict(id=x.id, source=x.source, type=x.type, value=float(x.value) if x.value is not None else None,
                        unit=x.unit, zone=x.zone, ts=str(x.ts))
        return {"items": [to_dict(i) for i in items], "page": page, "page_size": page_size, "total": total}
