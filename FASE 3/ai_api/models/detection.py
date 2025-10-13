from beanie import Document
from pydantic import Field
from typing import Optional
from datetime import datetime, timezone


def utcnow_aware() -> datetime:
    return datetime.now(timezone.utc)

class PlateDetection(Document):
    plate_text: str = Field(..., description="Texto de la placa detectada")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto (ej. '16 Av. Zona 1')")
    created_at: datetime = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None

    class Settings:
        name = "plate_detections"

class PersonDetection(Document):
    person_id: str = Field(..., description="ID de la persona (vinculado a una lista negra)")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto")
    image_url: Optional[str] = Field(default=None, description="URL de la imagen del rostro detectado")
    created_at: datetime = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "person_detections"

class WeaponDetection(Document):
    weapon_type: str = Field(..., description="Tipo de arma blanca detectada")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto")
    image_url: Optional[str] = Field(default=None, description="URL de la imagen del arma detectada")
    created_at: datetime = Field(default_factory=utcnow_aware)
    updated_at: datetime = Field(default_factory=utcnow_aware)
    deleted_at: Optional[datetime] = None
    
    class Settings:
        name = "weapon_detections"