'''
MIT License

Copyright (c) 2025 Marcos Bonifasi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''
from fastapi import APIRouter, Depends, Query
from typing import Any, Dict, Optional
from motor.motor_asyncio import AsyncIOMotorDatabase
from config.database import get_db

router = APIRouter(prefix="/live", tags=["live"])

def _to_float(v: Any, default: float = 0.0) -> float:
    try:
        if v is None or v == "":
            return default
        return float(v)
    except Exception:
        return default

@router.get("/bus/distances")
async def get_bus_distances(
    source: Optional[str] = Query(default=None, description="Filtrar por source (ej. arduino-mega-01)"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    """
    Devuelve la última DIST1/DIST2 de la colección 'readings' con el formato:
    { "dist1": <float>, "dist2": <float> }
    Lee primero en frame.DIST1 / frame.DIST2 (tu formato actual).
    """
    q: Dict[str, Any] = {}
    if source:
        q["source"] = source

    # Busca la última lectura por created_at (ISO string) en descendente
    doc = await db.readings.find_one(q, sort=[("created_at", -1)])

    if not doc:
        # No hay lecturas aún
        return {"dist1": 0.0, "dist2": 0.0}

    frame = doc.get("frame") or {}

    # INTENTO 1: formato actual (frame con mayúsculas)
    dist1 = _to_float(frame.get("DIST1", frame.get("dist1")))
    dist2 = _to_float(frame.get("DIST2", frame.get("dist2")))

    # INTENTO 2 (opcional): si no vinieron en frame y alguna vez usas 'data' como lista
    if (dist1 == 0.0 and dist2 == 0.0) and isinstance(doc.get("data"), list):
        for item in doc["data"]:
            if isinstance(item, dict):
                if item.get("sensor_id", "").upper() == "DIST1" and "value" in item:
                    dist1 = _to_float(item["value"], dist1)
                if item.get("sensor_id", "").upper() == "DIST2" and "value" in item:
                    dist2 = _to_float(item["value"], dist2)

    return {"dist1": dist1, "dist2": dist2}
