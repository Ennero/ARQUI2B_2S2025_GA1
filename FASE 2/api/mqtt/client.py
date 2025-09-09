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
import aiomqtt
import json
import datetime
from datetime import datetime, timezone
from config.settings import settings
from config.database import get_db
from models.event import EventIn, utcnow


def utcnow_iso() -> str:
    return datetime.now(timezone.utc).isoformat()

async def run_mqtt():
    
    async with aiomqtt.Client(settings.mqtt_broker, settings.mqtt_port) as client:
        print(f"Connected to MQTT broker at {settings.mqtt_broker}:{settings.mqtt_port}")

        # Subscribe to all topics under the specified prefix of our team
        await client.subscribe(f"{settings.mqtt_client_topic_prefix}/#")
        print(f"Subscribed to topics under '{settings.mqtt_client_topic_prefix}/#'")

        # Listen for incoming messages
        async for message in client.messages:
            # We are going to handle only two types of messages: "gt/zone1/events" and "gt/zone1/readings"

            try:
                payload_text = message.payload.decode("utf-8", errors="ignore")
            except Exception:
                payload_text = ""

            if f"{message.topic}".strip() == f"{settings.mqtt_client_topic_prefix}/gt/zone1/events".strip():
                print(f"Event received: {message.payload.decode()}")
                
                try:
                    data = json.loads(payload_text)
                    if not isinstance(data, dict):
                        print("[MQTT] Ignored: event payload is not a JSON object")
                        continue

                    event_document = {
                        "source": data.get("source"),
                        "type": data.get("type"),
                        "severity": data.get("severity", "low"),
                        "data": data.get("data", {}),
                        "created_at": utcnow_iso(),
                        "updated_at": utcnow_iso(),
                        "deleted_at": None
                    }

                    db = await get_db()
                    await db.events.insert_one(event_document)
                    print("[MQTT] Event saved to MongoDB")
                except json.JSONDecodeError:
                    print("[MQTT] Ignored: invalid JSON for event")
                except Exception as e:
                    print(f"[MQTT] Error saving event: {e}")

            elif f"{message.topic}".strip() == f"{settings.mqtt_client_topic_prefix}/gt/zone1/readings".strip():
                print(f"Reading received: {message.payload.decode()}")

                try:
                    data = json.loads(payload_text)
                    if not isinstance(data, dict):
                        print("[MQTT] Ignored: reading payload is not a JSON object")
                        continue

                    reading_document = {
                        "source": data.get("source"),
                        "data": data.get("data", []),
                        "deleted_at": None,
                        "created_at": utcnow_iso(),
                        "updated_at": utcnow_iso()
                    }

                    db = await get_db()
                    await db.readings.insert_one(reading_document)
                    print("[MQTT] Reading saved to MongoDB")
                except json.JSONDecodeError:
                    print("[MQTT] Ignored: invalid JSON for readings")
                except Exception as e:
                    print(f"[MQTT] Error saving readings: {e}")
            else:
                pass
