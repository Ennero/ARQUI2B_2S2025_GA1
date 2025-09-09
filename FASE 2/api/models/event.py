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

from typing import Dict, Literal, Optional, Any
from datetime import datetime, timezone
from pydantic import BaseModel, Field

def utcnow() -> datetime:
    return datetime.now(timezone.utc)

class EventIn(BaseModel):
    source: str  # 'arduino-mega-01'
    type: Literal["panic","fire","earthquake","infraction","bus_arrival"]
    severity: Literal['low','medium','high','critical'] = "low"
    data: Dict[str, Any] = {}
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)
    deleted_at: Optional[datetime] = None

class EventOut(EventIn):
    id: str = Field(alias="_id")


# Example of an event data dictionary
# {
#   "_id": ObjectId,
#   "ts": ISODate,
#   "type": "panic" | "fire" | "earthquake" | "infraction",
#   "severity": "low" | "medium" | "high" | "critical",
#   "source": "arduino-mega-01",
#   "data": {
#     "button": "PANICO3",
#     "sensor_id": "INC2",
#     "code": "INFRAB",
#     "details": "red_light_cross"
#   }
# }

