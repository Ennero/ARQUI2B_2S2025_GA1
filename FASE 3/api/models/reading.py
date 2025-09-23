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

import datetime
from pydantic import BaseModel
from typing import Literal, Optional, Dict, Any

class Reading(BaseModel):
    id: str
    metric: Literal['pm', 'bus_distance', 'traffic_light_state', ] # (Metrics and src devices should be specified in the settings file)
    value: float # For 'pm' it's in µg/m^3, for 'bus_distance' it's in meters, for 'traffic_light_state' it's 0 (red), 1 (yellow), 2 (green)
    unit: Optional[str] = None
    src: str # 'arduino_mega_01' (Metrics and src devices should be specified in the settings file)
    src_device_id: str # e.g., 'PM1', 'BUS1', ... (Metrics and src devices should be specified in the settings file)
    details: str = "" # Additional details about the reading
    created_at: datetime.datetime
    updated_at: datetime.datetime
    deleted_at: datetime.datetime
