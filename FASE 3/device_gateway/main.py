from fastapi import FastAPI
from contextlib import asynccontextmanager
from config.database import init_db

from api.router import router 
from api.router import serial_controller 
from services.mqtt_publisher import MQTTPublisher

mqtt_publisher = MQTTPublisher()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manages all startup and shutdown events for the application.
    This is the main conductor of all services.
    """
    print("API starting up...")
    
    await init_db()
    
    mqtt_publisher.connect()
    
    serial_controller.connect()
    
    serial_controller.start_reading(mqtt_publisher)
    
    yield
    
    print("API shutting down...")
    serial_controller.disconnect()
    mqtt_publisher.disconnect()

app = FastAPI(
    lifespan=lifespan,
    title="Device Gateway API",
    description="Central controller for AI detections and Arduino communication on the Raspberry Pi.",
    version="1.0.0"
)

app.include_router(router)

@app.get("/")
def root():
    """Root endpoint to quickly check if the API is alive."""
    return {"status": "Device Gateway is running"}