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
from config.settings import settings
from utils.net import post_event

# Configuración del modelo y clases
# ASEGÚRATE DE QUE ESTA RUTA Y NOMBRE DE CLASE SEAN CORRECTOS
LICENSE_PLATE_MODEL_PATH = "license_plate_detector.pt" 
TARGET_CLASSES = ["license_plate", "plate"] 


def run_plates_yolo(video_source: str, conf_plate: float, target_classes: List[str]):
    """
    Función de ejecución para la detección de placas usando el modelo YOLO.
    """
    # source = 0 if str(video_source).isdigit() else video_source
    source = int(video_source) if str(video_source).isdigit() else video_source

    cap = cv2.VideoCapture(source)

    if not cap.isOpened():
        print(f"[ERR] Could not open VIDEO_SOURCE: {video_source}")
        return

    try:
        model = YOLO(LICENSE_PLATE_MODEL_PATH)
        print(f"Modelo {LICENSE_PLATE_MODEL_PATH} cargado. Clases: {model.names}")
    except Exception as e:
        print(f"[ERR] Could not load YOLO model: {LICENSE_PLATE_MODEL_PATH}. Error: {e}")
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
                
                try:
                    name = r.names[cls_id]
                except:
                    continue 
                    
                conf = float(b.conf[0])
                
                if name in target_classes and conf >= conf_plate:
                    color = (255, 0, 0) # Azul
                    print(f"[PLACA DETECTADA] Tipo: {name}, Confianza: {conf:.2f}")

                    x1, y1, x2, y2 = map(int, b.xyxy[0].tolist())
                    
                    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                    cv2.putText(frame, f"{name}: {conf:.2f}", (x1, y1 - 8),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
                    
                    # now = time.time()
                    # if now - last_sent > 2.0:

                    #     # Make HTTP request
                    #     post_event(
                    #         settings.api_url,
                    #         'vehicle',
                    #         'license_plate',
                    #         {
                    #             "name": name,
                    #             "conf": conf,
                    #             "location": "zone1_camera1"
                    #         },
                    #         frame[y1:y2, x1:x2]
                    #     )

                    #     last_sent = now

        cv2.imshow("Detección de Placas YOLO", frame) 
        if cv2.waitKey(1) & 0xFF == 27:
            break

    cap.release()
    cv2.destroyAllWindows()


class PlateService:
    """Clase de configuración para el servicio de placas basado en YOLO."""
    def __init__(self, video_source: str, conf_plate: float, target_classes: List[str] = TARGET_CLASSES):
        self.video_source = video_source
        self.conf_plate = conf_plate
        self.target_classes = target_classes