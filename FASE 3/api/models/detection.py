'''
MIT License

Copyright (c) 2025 Enner :)
'''

from pydantic import BaseModel, Field
from typing import Dict, Any, Optional
from datetime import datetime, timezone

def utcnow() -> datetime:
    return datetime.now(timezone.utc)

class VehiclePlateDetectionIn(BaseModel):
    plate_text: str = Field(..., description="Texto de la placa detectada")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto (ej. '16 Av. Zona 1')")
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)
    deleted_at: Optional[datetime] = None

class PersonDetectionIn(BaseModel):
    person_id: str = Field(..., description="ID de la persona (vinculado a una lista negra)")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto")
    image_url: Optional[str] = Field(default=None, description="URL de la imagen del rostro detectado")
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)
    deleted_at: Optional[datetime] = None

class WeaponDetectionIn(BaseModel):
    weapon_type: str = Field(..., description="Tipo de arma blanca detectada")
    source: str = Field(..., description="ID de la cámara o fuente que hizo la detección")
    location: Optional[str] = Field(default=None, description="Ubicación como texto")
    image_url: Optional[str] = Field(default=None, description="URL de la imagen del arma detectada")
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)
    deleted_at: Optional[datetime] = None