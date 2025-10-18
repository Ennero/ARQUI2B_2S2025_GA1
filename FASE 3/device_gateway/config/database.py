import os
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from dotenv import load_dotenv

from models.detection import PlateDetection, PersonDetection, WeaponDetection, Event

load_dotenv()

async def init_db():
    mongo_uri = os.getenv("MONGO_URI")
    database_name = os.getenv("MONGODB_NAME")
    
    if not mongo_uri or not database_name:
        raise Exception("MONGO_URI and MONGODB_NAME must be set in the .env file")

    client = AsyncIOMotorClient(mongo_uri)
    
    await init_beanie(
        database=client[database_name],
        document_models=[PlateDetection, PersonDetection, WeaponDetection, Event]
    )
    print("Database connection initialized successfully.")