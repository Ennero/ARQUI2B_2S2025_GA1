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
from typing import List, Dict, Any, Optional
from motor.motor_asyncio import AsyncIOMotorDatabase
from datetime import datetime
import hashlib
from config.database import get_db

router = APIRouter(prefix="/notifications", tags=["notifications"])

# ---- helpers ----
def _mk_id(ev: Dict[str, Any]) -> str:
    """
    Genera un id estable tipo alrt_xxxxx a partir de _id/created_at/type/source.
    Si tu documento trae _id de Mongo, lo usamos; si no, hash del contenido.
    """
    raw = str(ev.get("_id") or f"{ev.get('created_at')}-{ev.get('type')}-{ev.get('source')}")
    h = hashlib.md5(raw.encode("utf-8")).hexdigest()[:6]
    return f"alrt_{h}"

def _upper(v: Optional[str]) -> str:
    return (v or "").upper()

def _iso(ts: Any) -> str:
    if isinstance(ts, datetime):
        # asegúrate de que sea ISO con Z si es naive
        if ts.tzinfo is None:
            return ts.isoformat() + "Z"
        return ts.isoformat()
    # muchos de tus eventos guardan created_at como string ISO -> devuélvelo tal cual
    return str(ts or "")

def _title_and_description(ev: Dict[str, Any]) -> (str, str, str):
    """
    Devuelve (TIPO, TITULO, DESCRIPCION) en español según el evento.
    """
    t = _upper(ev.get("type"))
    data = ev.get("data") or {}

    # PERSONA EN LISTA NEGRA
    if t == "PERSON_ON_BLACKLIST":
        return (
            "PERSONA EN LISTA NEGRA DETECTADA",
            "Persona en lista negra detectada",
            "Se detectó una persona con record criminal en la ciudad."
        )
    
    # ARMA BLANCA
    if t == "BLADED_WEAPON":
        return (
            "ARMA BLANCA DETECTADA",
            "Arma blanca detectada",
            "Se detectó un arma blanca en la ciudad."
        )

    # PANICO
    if t == "PANIC":
        btn = _upper(data.get("button"))
        return (
            "PANICO",
            "Botón de Pánico Activado",
            f"Se ha recibido una alerta de pánico desde la fuente {btn or 'PANICO'}."
        )
        
    # INFRACCION
    if t == "INFRACTION":
        code = _upper(data.get("code"))
        return (
            "INFRACCION",
            "Infracción de Semáforo Detectada",
            f"Un vehículo ha cruzado en rojo en el punto de control {code or 'INFRA'}."
        )
        
    # SISMO
    if t == "EARTHQUAKE":
        return (
            "SISMO",
            "Alerta Sísmica",
            "Se ha detectado una vibración anómala. Protocolos de seguridad activados."
        )
        
    # LLEGADA DE BUS (si la usas)
    if t == "BUS_ARRIVAL":
        route = _upper((data.get("route") or "BUS"))
        return (
            "BUS",
            "Arribo de Bus",
            f"Se registró arribo de unidad en la ruta {route}."
        )
        
    # CALIDAD DE AIRE (antes incendio)
    if t == "FIRE":
        return (
            "CALIDAD DE AIRE",
            "Alerta de calidad de aire",
            "La calidad del aire en el entorno no es la adecuada."
        )

    # default genérico
    return (
        t or "ALERTA",
        "Alerta del Sistema",
        "Se ha recibido una notificación del sistema."
    )

@router.get("", response_model=List[Dict[str, Any]])
async def list_notifications(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    since: Optional[str] = Query(None, description="ISO 8601; filtra notificaciones con created_at >= since"),
    severity: Optional[str] = Query(None, description="low|medium|high|critical (opcional)"),
    types: Optional[str] = Query(None, description="lista separada por comas: panic,infraction,earthquake,bus_arrival,fire"),
    source: Optional[str] = Query(None, description="filtrar por source (ej. arduino-mega-01)"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    """
    Devuelve una lista de notificaciones con el formato:
    [
      {"id","tipo","titulo","descripcion","fuente","timestamp"}
    ]
    - Ordenadas por created_at DESC
    - Paginables con limit/offset
    - Filtros opcionales: since, severity, types, source
    """
    q: Dict[str, Any] = {}

    if since:
        # Tus timestamps están como ISO strings → filtramos como string
        q["created_at"] = {"$gte": since}

    if severity:
        q["severity"] = severity.lower()

    if types:
        allowed = [t.strip().lower() for t in types.split(",") if t.strip()]
        if allowed:
            q["type"] = {"$in": allowed}

    if source:
        q["source"] = source

    cursor = db.events.find(q).sort("created_at", -1).skip(offset).limit(limit)
    events = [doc async for doc in cursor]

    out: List[Dict[str, Any]] = []
    for ev in events:
        tipo, titulo, descripcion = _title_and_description(ev)
        data = ev.get("data") or {}
        # Para la 'fuente', extraemos el sensor o usamos el source principal
        fuente = _upper(data.get("sensor") or ev.get("source"))

        out.append({
            "id": _mk_id(ev),
            "tipo": tipo,
            "titulo": titulo,
            "descripcion": descripcion,
            "fuente": fuente,
            "timestamp": _iso(ev.get("created_at")),
        })

    return out