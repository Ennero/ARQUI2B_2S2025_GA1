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

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from typing import Optional
from .settings import settings

_client: Optional[AsyncIOMotorClient] = None
_db: Optional[AsyncIOMotorDatabase] = None


async def connect_to_mongo() -> AsyncIOMotorDatabase:
    global _client, _db

    print("Connecting to MongoDB...")

    # If the client is not established yet, do it (SINGLETON)
    if _client is None:
        _client = AsyncIOMotorClient(settings.mongo_uri)
        _db = _client[settings.mongo_db]
        await ensure_indexes(_db)
    return _db


async def close_mongo():
    global _client

    # Close the client connection
    if _client:
        _client.close()
        _client = None


async def get_db() -> AsyncIOMotorDatabase:
    # If the connection is not established yet, do it (SINGLETON)
    if _db is None:
        return await connect_to_mongo()
    return _db


async def ensure_indexes(db: AsyncIOMotorDatabase):
    # readings indexes
    await db.readings.create_index([("device_id", 1), ("ts", -1)], name="device_ts")
    await db.readings.create_index("ts", name="ts")
    # events indexes
    await db.events.create_index([("type", 1), ("ts", -1)], name="type_ts")
    
    '''
    print("Ensuring indexes for detection collections...")
    # Detecciones de placas
    await db.plate_detections.create_index("created_at", name="detection_ts_placas")
    await db.plate_detections.create_index("source", name="detection_source_placas")
    # Detecciones de personas
    await db.person_detections.create_index("created_at", name="detection_ts_personas")
    # Detecciones de armas
    await db.weapon_detections.create_index("created_at", name="detection_ts_armas")
    print("Detection indexes created.")
    '''
