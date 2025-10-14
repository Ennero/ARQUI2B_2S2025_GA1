# tools/pick_camera.py
import cv2

def test_index(i):
    cap = cv2.VideoCapture(i, cv2.CAP_AVFOUNDATION)
    ok = cap.isOpened()
    print(("✅" if ok else "❌"), f"Índice {i} {'abierto' if ok else 'no abre'}")
    if ok:
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        for _ in range(60):  # ~2s previo
            ok, frame = cap.read()
            if not ok: break
            cv2.putText(frame, f"Index {i} - ESC para salir",
                        (20,40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,255), 2)
            cv2.imshow(f"Cam {i}", frame)
            if cv2.waitKey(1) & 0xFF == 27:
                break
        cap.release()
        cv2.destroyWindow(f"Cam {i}")

if __name__ == "__main__":
    print("Buscando cámaras (0..5) con AVFoundation...")
    for i in range(6):
        test_index(i)
    print("Listo. Usa el índice que te mostró tu cámara integrada.")
