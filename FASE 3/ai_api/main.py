# main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
from config.database import init_db
from api.router import router

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("API starting up...")
    await init_db()
    yield
    print("API shutting down...")

app = FastAPI(lifespan=lifespan)
app.include_router(router)