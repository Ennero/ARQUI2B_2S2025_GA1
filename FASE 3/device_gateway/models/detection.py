from typing import Optional, Annotated
from pymongo import DESCENDING
from beanie import Document, Indexed
from pydantic import Field, BaseModel
from datetime import datetime, timezone

def utcnow_aware() -> datetime:
    return datetime.now(timezone.utc)

class PlateDetection(Document):
    plate_text: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    subtype: Optional[str] = None
    location: Optional[str] = None
    image_b64: Optional[str] = None
    det_confidence: Optional[float] = None
    ocr_confidence: Optional[float] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None

    class Settings:
        name = "plate_detections"

class PersonDetection(Document):
    person_id: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    subtype: Optional[str] = None
    location: Optional[str] = None
    image_b64: Optional[str] = None
    confidence: Optional[float] = None
    distance: Optional[float] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "person_detections"

class WeaponDetection(Document):
    weapon_type: Annotated[str, Indexed()]
    source: Annotated[str, Indexed()]
    subtype: Optional[str] = None
    location: Optional[str] = None
    image_b64: Optional[str] = None
    confidence: Optional[float] = None
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "weapon_detections"

class EventData(BaseModel):
    button: Optional[str] = None
    location: Optional[str] = None
    details: Optional[str] = None

class Event(Document):
    source: Annotated[str, Indexed()]
    type: Annotated[str, Indexed()] = Field(default="panic")
    severity: Annotated[str, Indexed()]
    data: EventData
    created_at: Annotated[datetime, Indexed(index_type=DESCENDING)] = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None

    class Settings:
        name = "events"