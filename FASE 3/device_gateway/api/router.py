# device_gateway/api/router.py
from fastapi import APIRouter, Body, HTTPException
from models.detection import PlateDetection, PersonDetection, WeaponDetection
from services.serial_sender import SerialController

router = APIRouter()
serial_controller = SerialController()

LOCATION_TO_BUZZER_MAP = {
    "camara_entrada": 1,
    "camara_patio": 2,
    "camara_bodega": 3,
}

@router.post("/api/info", status_code=201)
async def save_and_alert_on_detection(payload: dict = Body(...)):
    """
    Receives detection data, stores it in MongoDB, and sends a corresponding 
    alert to the Arduino via the serial port.
    """
    print(f"Received request on /api/info: {payload.get('type')}")

    detection_type = payload.get("type")
    meta = payload.get("meta", {})
    image_b64 = payload.get("img_b64")
    location = meta.get("location")

    if not detection_type or not meta:
        raise HTTPException(status_code=400, detail="Payload must include 'type' and 'meta' fields.")

    try:
        if detection_type == "vehicle":
            detection = PlateDetection(
                plate_text=meta.get("texto"),
                source="ia-cam-plates",
                location=location,
                image_b64=image_b64
            )
        elif detection_type == "person":
            detection = PersonDetection(
                person_id=meta.get("name"),
                source="ia-cam-persons",
                location=location,
                image_b64=image_b64
            )
        elif detection_type == "weapon":
            detection = WeaponDetection(
                weapon_type=meta.get("name"),
                source="ia-cam-weapons",
                location=location,
                image_b64=image_b64
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unknown detection type: '{detection_type}'")

        await detection.insert()
        print(f"Successfully saved {detection_type} detection to the database.")

        if location in LOCATION_TO_BUZZER_MAP:
            buzzer_to_activate = LOCATION_TO_BUZZER_MAP[location]
            serial_controller.send_alert(detection_type, buzzer_to_activate)
        else:
            print(f"Location '{location}' not found in buzzer map. No alert sent.")

        return {"status": "success", "message": f"Detection stored. Alert dispatched for location '{location}'."}

    except Exception as e:
        print(f"Error processing detection: {e}")
        raise HTTPException(status_code=500, detail="Internal error while processing detection.")