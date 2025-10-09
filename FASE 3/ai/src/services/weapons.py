# MIT License

# Bondel Technologies S. A.

# Copyright (c) 2025, all rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# For more information, contact https://github.com/marcosbondel

# · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
# · 

import time
import cv2
from ultralytics import YOLO
from typing import List

WEAPONS_MODEL_PATH = "yolov8s_weapons.pt"

TARGET_WEAPONS = ["Knife", "Pistol", "rifle"]

def run_weapons(video_source: str, conf_weapon: float, target_classes: List[str] = TARGET_WEAPONS):
    source = 0 if str(video_source).isdigit() else video_source

    if isinstance(source, int):
        cap = cv2.VideoCapture(source)
    else:
        cap = cv2.VideoCapture(source)

    if not cap.isOpened():
        print(f"[ERR] Could not open VIDEO_SOURCE: {video_source}")
        return

    # >>> CAMBIO CLAVE 1: Cargar el modelo de detección de armas <<<
    try:
        model = YOLO(WEAPONS_MODEL_PATH)
    except Exception as e:
        print(f"[ERR] Could not load YOLO model: {WEAPONS_MODEL_PATH}. Check if the file exists and is valid. Error: {e}")
        return

    last_sent = 0.0
    while True:
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.05)
            continue

        results = model.predict(source=frame, verbose=False)
        for r in results:
            for b in r.boxes:
                cls_id = int(b.cls[0])
                name = r.names[cls_id]
                conf = float(b.conf[0])
                
                # >>> CAMBIO CLAVE 2: Comprobar si el nombre de la clase está en la lista de objetivos <<<
                if name in target_classes and conf >= conf_weapon:
                    print(f"[{name} detected] confidence: {conf:.2f}")

                    # Lógica de dibujo del bounding box
                    x1,y1,x2,y2 = map(int, b.xyxy[0].tolist())
                    
                    # Color rojo (0,0,255) para advertencia
                    color = (0, 0, 255)
                    
                    cv2.rectangle(frame, (x1,y1), (x2,y2), color, 2)
                    cv2.putText(frame, f"{name} {conf:.2f}", (x1, y1-8),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
                    
                    # Lógica de notificación (descomentar si tienes post_event)
                    # now = time.time()
                    # if now - last_sent > 2.0:
                    #     post_event(frame, conf, name) # podrías pasar el tipo de arma
                    #     last_sent = now

        # El título de la ventana ahora es más general
        cv2.imshow("Detección de Armas", frame) 
        if cv2.waitKey(1) & 0xFF == 27:  # ESC para salir
            break

    cap.release()
    cv2.destroyAllWindows()


# ---
# La clase de servicio (opcionalmente)
class WeaponsService:
    # Se actualiza el parámetro para usar target_classes
    def __init__(self, video_source: str, conf_weapon: float, target_classes: List[str] = TARGET_WEAPONS):
        self.video_source = video_source
        self.conf_weapon = conf_weapon
        self.target_classes = target_classes

# Ejemplo de uso:
# Si quisieras ejecutarlo directamente:
# run_weapons("ruta/a/tu/video.mp4", conf_weapon=0.5) 
# run_weapons(0, conf_weapon=0.5, target_classes=["knife", "pistol", "rifle"])