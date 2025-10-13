# api/router.py
from fastapi import APIRouter, Body, HTTPException
from models.detection import PlateDetection, PersonDetection, WeaponDetection

router = APIRouter()

@router.get("/")
def root():
    return {"status": "IA Coordinator API is running"}

@router.post("/api/info")
async def save_ia_detection(payload: dict = Body(...)):
    print(f"Received request on /api/info: {payload}")

    detection_type = payload.get("tipo")
    data = payload.get("data")

    if not detection_type or not data:
        raise HTTPException(status_code=400, detail="Payload must include 'tipo' and 'data' fields.")

    try:
        if detection_type == "plates":
            detection = PlateDetection(**data)
        elif detection_type == "persons":
            detection = PersonDetection(**data)
        elif detection_type == "weapons":
            detection = WeaponDetection(**data)
        else:
            raise HTTPException(status_code=400, detail=f"Unknown detection type: {detection_type}")

        await detection.insert()
        print(f"Successfully saved {detection_type} detection to the database.")

        return {"status": "success", "message": f"Detection of type '{detection_type}' stored successfully."}

    except Exception as e:
        print(f"Error saving detection to database: {e}")
        raise HTTPException(status_code=500, detail="Internal error while storing detection.")