# ia_api/models/detection.py

from typing import Optional, Annotated 
from pymongo import ASCENDING, DESCENDING

from beanie import Document, Indexed
from pydantic import Field
from datetime import datetime, timezone

def utcnow_aware() -> datetime:
    return datetime.now(timezone.utc)

class PlateDetection(Document):
    plate_text: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    location: Optional[str] = None
    image_b64: Optional[str] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None

    class Settings:
        name = "plate_detections"

class PersonDetection(Document):
    person_id: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    location: Optional[str] = None
    image_b64: Optional[str] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "person_detections"

class WeaponDetection(Document):
    weapon_type: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    location: Optional[str] = None
    image_b64: Optional[str] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "weapon_detections"