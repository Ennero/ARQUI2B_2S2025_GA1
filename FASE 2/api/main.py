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
import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # ← IMPORTANTE: Agregar esto
from contextlib import asynccontextmanager
from fastapi.responses import ORJSONResponse
from config.settings import settings
from config.database import connect_to_mongo, close_mongo
from mqtt.client import run_mqtt
from routers import readings, events, analytics, live, notifications

mqtt_task: asyncio.Task = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global mqtt_task
    
    await connect_to_mongo()
    mqtt_task = asyncio.create_task(run_mqtt()) 
    
    try:
        yield
    finally:
        if mqtt_task:
            mqtt_task.cancel()
            try:
                await asyncio.wait_for(mqtt_task, timeout=3)
            except asyncio.TimeoutError:
                pass
            except asyncio.CancelledError:
                pass
        await close_mongo()

application = FastAPI(
    title=settings.app_name, 
    lifespan=lifespan,
    default_response_class=ORJSONResponse
)

# ⭐⭐ SOLUCIÓN CORS - AGREGAR ESTAS 6 LÍNEAS ⭐⭐
application.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, cambia a dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@application.get("/health")
async def root():
    return {"ok": True}

# Routers
application.include_router(readings.router)
application.include_router(events.router)
application.include_router(analytics.router)
application.include_router(live.router)
application.include_router(notifications.router)