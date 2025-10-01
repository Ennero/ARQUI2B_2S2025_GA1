import cv2
from ultralytics import YOLO

MODEL = YOLO("yolov8n.pt")  # pesos pre-entrenados
SOURCE = 0  # cambia por la URL de video: p.ej. "http://IP_PC_CAM:4747/video"

def main():
    cap = cv2.VideoCapture(SOURCE)
    if not cap.isOpened():
        raise RuntimeError("No se pudo abrir la fuente de video")

    while True:
        ok, frame = cap.read()
        if not ok:
            break

        # Inferencia
        results = MODEL.predict(source=frame, verbose=False)
        for r in results:
            for b in r.boxes:
                cls_id = int(b.cls[0])
                name = r.names[cls_id]
                conf = float(b.conf[0])
                if name == "knife" and conf >= 0.45:
                    print("KNIFE!!!")
                    x1,y1,x2,y2 = map(int, b.xyxy[0].tolist())
                    cv2.rectangle(frame, (x1,y1), (x2,y2), (0,255,0), 2)
                    cv2.putText(frame, f"{name} {conf:.2f}", (x1, y1-8),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0,255,0), 2)

        cv2.imshow("Armas blancas (knife)", frame)
        if cv2.waitKey(1) & 0xFF == 27:  # ESC para salir
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
