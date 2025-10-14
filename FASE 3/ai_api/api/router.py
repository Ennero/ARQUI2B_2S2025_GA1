# ia_api/api/router.py

from fastapi import APIRouter, Body, HTTPException
from models.detection import PlateDetection, PersonDetection, WeaponDetection

router = APIRouter()

@router.post("/api/info")
async def save_ia_detection(payload: dict = Body(...)):
    """
    Receives detection data from AI laptops and stores it directly in MongoDB.
    """
    print(f"Received request on /api/info: {payload.get('type')}")

    detection_type = payload.get("type")
    meta = payload.get("meta", {})
    image_b64 = payload.get("img_b64")

    if not detection_type or not meta:
        raise HTTPException(status_code=400, detail="Payload must include 'type' and 'meta' fields.")

    try:
        if detection_type == "vehicle":
            detection = PlateDetection(
                plate_text=meta.get("texto"),
                source="ia-cam-plates",
                location=meta.get("location"),
                image_b64=image_b64
            )
        elif detection_type == "person":
            detection = PersonDetection(
                person_id=meta.get("name"),
                source="ia-cam-persons",
                location=meta.get("location"),
                image_b64=image_b64
            )
        elif detection_type == "weapon":
            detection = WeaponDetection(
                weapon_type=meta.get("name"),
                source="ia-cam-weapons",
                location=meta.get("location"),
                image_b64=image_b64
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unknown detection type: '{detection_type}'")

        await detection.insert()
        print(f"Successfully saved {detection_type} detection to the database.")

        return {"status": "success", "message": f"Detection of type '{detection_type}' stored successfully."}

    except Exception as e:
        print(f"Error saving detection to database: {e}")
        raise HTTPException(status_code=500, detail="Internal error while storing detection.")