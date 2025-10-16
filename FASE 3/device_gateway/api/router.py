from fastapi import APIRouter, Body, HTTPException
from models.detection import PlateDetection, PersonDetection, WeaponDetection, Event, EventData
from services.serial_controller import SerialController

router = APIRouter()
serial_controller = SerialController()

LOCATION_TO_BUZZER_MAP = {
    "camara_entrada": 1,
    "camara_patio": 2,
    "camara_bodega": 3,
}

@router.post("/api/info", status_code=201)
async def save_and_alert_on_detection(payload: dict = Body(...)):
    detection_type = payload.get("type")
    subtype = payload.get("subtype")
    meta = payload.get("meta", {})
    image_b64 = payload.get("img_b64")
    location = meta.get("location")

    if not detection_type or not meta:
        raise HTTPException(status_code=400, detail="Payload must include 'type' and 'meta' fields.")
    
    try:
        event_severity = "low"
        event_details = "Unknown detection event."

        if detection_type == "vehicle":
            detection = PlateDetection(
                plate_text=meta.get("texto"),
                source="ia-cam-plates",
                subtype=subtype,
                location=location,
                image_b64=image_b64,
                det_confidence=meta.get("det_conf"),
                ocr_confidence=meta.get("ocr_conf")
            )
            event_severity = "low"
            event_details = f"Placa de vehículo detectada: '{meta.get('texto')}'."

        elif detection_type == "person":
            detection = PersonDetection(
                person_id=meta.get("name"),
                source="ia-cam-persons",
                subtype=subtype,
                location=location,
                image_b64=image_b64,
                confidence=meta.get("conf"),
                distance=meta.get("dist")
            )
            event_severity = "medium"
            event_details = f"Persona en lista negra detectada: '{meta.get('name')}' con confianza {meta.get('conf'):.2f} a {meta.get('dist'):.2f}m."

        elif detection_type == "weapon":
            detection = WeaponDetection(
                weapon_type=meta.get("name"),
                source="ia-cam-weapons",
                subtype=subtype,
                location=location,
                image_b64=image_b64,
                confidence=meta.get("conf")
            )
            event_severity = "critical"
            event_details = f"Arma detectada: '{meta.get('name')}' con confianza {meta.get('conf'):.2f}."
        else:
            raise HTTPException(status_code=400, detail=f"Unknown detection type: '{detection_type}'")

        await detection.insert()
        print(f"Successfully saved {detection_type} detection.")

        if location in LOCATION_TO_BUZZER_MAP:
            buzzer = LOCATION_TO_BUZZER_MAP[location]
            
            serial_controller.send_alert(detection_type, buzzer)

            event_data = EventData(
                button=f"PANICO{buzzer}",
                location=location,
                details=event_details
            )
            new_event = Event(
                source="ia-detection-system",
                severity=event_severity,
                data=event_data
            )
            
            await new_event.insert()
            print(f"Successfully saved 'panic' event with severity '{event_severity}'.")

        return {"status": "success", "message": f"Detection and event processed for location '{location}'."}

    except Exception as e:
        print(f"Error processing detection: {e}")
        raise HTTPException(status_code=500, detail="Internal error while processing detection.")