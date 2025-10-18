from fastapi import APIRouter, Body, HTTPException
from models.detection import PlateDetection, PersonDetection, WeaponDetection, Event, EventData
from services.serial_controller import SerialController

router = APIRouter()
serial_controller = SerialController()

LOCATION_TO_BUZZER_MAP = {
    "camara_portal": 5,
    "camara_parque": 2,
    "camara_campero": 4,
}

@router.post("/api/info", status_code=201)
async def save_and_alert_on_detection(payload: dict = Body(...)):
    detection_type = payload.get("type")
    meta = payload.get("meta", {})
    location = meta.get("location")

    if not detection_type or not meta or not location:
        raise HTTPException(status_code=400, detail="Payload must include 'type', 'meta', and a 'location' within meta.")
    
    try:
        detection = None
        event_type = "UNKNOWN"
        event_severity = "low"
        event_details = "Unknown detection event."

        if detection_type == "vehicle":
            detection = PlateDetection(**payload)
            event_type = "PLATE"
            event_severity = "low"
            event_details = f"Placa de vehículo detectada: '{meta.get('texto')}'."

        elif detection_type == "person":
            detection = PersonDetection(**payload)
            event_type = "PERSON_ON_BLACKLIST"
            event_severity = "medium"
            event_details = f"Persona en lista negra detectada: '{meta.get('name')}' a {meta.get('dist'):.2f}m con conf {meta.get('conf'):.2f}."

        elif detection_type == "weapon":
            detection = WeaponDetection(**payload)
            event_type = "BLADED_WEAPON"
            event_severity = "critical"
            event_details = f"Arma detectada: '{meta.get('name')}' con conf {meta.get('conf'):.2f}."

        else:
            raise HTTPException(status_code=400, detail=f"Unknown detection type: '{detection_type}'")

        await detection.insert()
        print(f"Successfully saved detection to collection '{detection.Settings.name}'.")

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
                type=event_type,
                severity=event_severity,
                data=event_data
            )
            await new_event.insert()
            print(f"Successfully saved 'panic' event with severity '{event_severity}'.")

        return {"status": "success", "message": f"{detection_type} detection and event processed for location '{location}'."}

    except Exception as e:
        print(f"Error processing detection: {e}")
        raise HTTPException(status_code=500, detail="Internal error while processing detection.")