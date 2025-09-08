# parser.py
from datetime import datetime, timezone

def parse_mqtt_line(line: str) -> dict:
    kv = {}
    for token in line.split(';'):
        token = token.strip()
        if not token or '=' not in token:
            continue
        k, v = token.split('=', 1)
        k = k.strip().upper()
        v = v.strip()
        kv[k] = int(v) if v.isdigit() else v

    doc = {
        "ts": datetime.now(timezone.utc),
        "raw": line,
        "kv": kv,
        "semaphores": {"sem1": kv.get("SEM1"), "sem2": kv.get("SEM2")},
        "buses": {"bus1": kv.get("BUS1"), "bus2": kv.get("BUS2"),
                  "dist1": kv.get("DIST1"), "dist2": kv.get("DIST2")},
        "environment": {"pm1": kv.get("PM1"), "pm2": kv.get("PM2"),
                        "sismo": kv.get("SISMO"), "inc1": kv.get("INC1"), "inc2": kv.get("INC2")},
        "panic": {f"panico{i}": kv.get(f"PANICO{i}") for i in range(1, 6)},
        "infractions": {"infraa": kv.get("INFRAA"), "infrab": kv.get("INFRAB"),
                        "infrac": kv.get("INFRAC"), "infrad": kv.get("INFRAD")},
    }
    return doc
