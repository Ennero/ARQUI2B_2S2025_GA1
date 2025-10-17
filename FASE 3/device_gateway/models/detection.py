from typing import Optional, Annotated, Dict, Any
from pymongo import DESCENDING
from beanie import Document, Indexed
from pydantic import Field, BaseModel
from datetime import datetime, timezone

def iso_utcnow_string() -> str:
    return datetime.now(timezone.utc).isoformat()

class BaseDetectionSchema(BaseModel):
    type: str
    subtype: Optional[str] = None
    meta: Dict[str, Any]
    img_b64: Optional[str] = None
    created_at: Annotated[str, Indexed(index_type=DESCENDING)] = Field(default_factory=iso_utcnow_string)
    updated_at: str = Field(default_factory=iso_utcnow_string)
    deleted_at: Optional[str] = None


class PlateDetection(Document, BaseDetectionSchema):
    class Settings:
        name = "plate_detections"

class PersonDetection(Document, BaseDetectionSchema):
    class Settings:
        name = "person_detections"

class WeaponDetection(Document, BaseDetectionSchema):
    class Settings:
        name = "weapon_detections"


class EventData(BaseModel):
    button: Optional[str] = None
    location: Optional[str] = None
    details: Optional[str] = None

class Event(Document):
    source: Annotated[str, Indexed()]
    type: Annotated[str, Indexed()]
    severity: Annotated[str, Indexed()]
    data: EventData
    created_at: Annotated[str, Indexed(index_type=DESCENDING)] = Field(default_factory=iso_utcnow_string)
    updated_at: str = Field(default_factory=iso_utcnow_string)
    deleted_at: Optional[str] = None
    
    class Settings:
        name = "events"