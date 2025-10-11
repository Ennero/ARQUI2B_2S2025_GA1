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

import time, datetime, re, base64
import cv2
import numpy as np
from ultralytics import YOLO
from typing import List, Tuple, Optional

from config.settings import settings
from utils.net import post_event

# === CONFIG ===
LICENSE_PLATE_MODEL_PATH = "license_plate_detector.pt"   # tu .pt de detección de placa
TARGET_CLASSES = ["license_plate", "plate"]               # ajústalo a las clases reales del .pt

# Umbrales OCR/regex (puedes mapearlos a settings)
OCR_LANGS = getattr(settings, "ocr_langs", "en")          # "en", "en,es"
OCR_CONF_MIN = float(getattr(settings, "conf_ocr_min", 0.30))
PLATE_REGEX = getattr(settings, "plate_regex_pattern", r"[A-Z0-9]{5,8}")  # edita a tu formato local
SEND_COOLDOWN_S = 3.0

# =============== UTILIDADES ===============

def _normalize_text(t: str) -> str:
    t = t.upper()
    t = re.sub(r"[^A-Z0-9]", "", t)
    return t

def _common_fixes(s: str) -> str:
    # Correcciones típicas OCR
    s = s.replace("I", "1").replace("B", "8").replace("S", "5").replace("Z", "2")
    # Si hay números, O→0 ayuda a evitar confusiones
    if re.search(r"\d", s):
        s = s.replace("O", "0")
    return s

def _to_b64_jpeg(img_bgr: np.ndarray) -> Optional[str]:
    ok, buf = cv2.imencode(".jpg", img_bgr)
    return base64.b64encode(buf).decode("utf-8") if ok else None

def _preprocess_for_ocr(roi_bgr: np.ndarray) -> np.ndarray:
    """Pequeño preprocesado para mejorar OCR."""
    g = cv2.cvtColor(roi_bgr, cv2.COLOR_BGR2GRAY)
    # Suavizado leve + contraste local
    g = cv2.bilateralFilter(g, 7, 50, 50)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    g = clahe.apply(g)
    # Binarización adaptativa
    thr = cv2.adaptiveThreshold(
        g, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 3
    )
    return cv2.cvtColor(thr, cv2.COLOR_GRAY2BGR)

# =============== OCR (EasyOCR) ===============
# Carga perezosa para evitar costo al importar
_easyocr_reader = None
def _get_reader():
    global _easyocr_reader
    if _easyocr_reader is None:
        import easyocr
        _easyocr_reader = easyocr.Reader(OCR_LANGS.split(","), gpu=False)
    return _easyocr_reader

def _read_plate_text(roi_bgr: np.ndarray) -> Tuple[Optional[str], float]:
    """
    Devuelve (texto_validado, conf) o (None, 0.0)
    """
    reader = _get_reader()
    img = _preprocess_for_ocr(roi_bgr)
    results = reader.readtext(img)  # [(bbox, text, conf), ...]
    best_text, best_conf = None, 0.0

    for _, text, conf in results:
        if float(conf) < OCR_CONF_MIN:
            continue
        t = _normalize_text(text)
        t = _common_fixes(t)
        if re.fullmatch(PLATE_REGEX, t or ""):
            if conf > best_conf:
                best_text, best_conf = t, float(conf)

    return best_text, best_conf

# =============== MAIN LOOP ===============

def run_plates_yolo(video_source: str, conf_plate: float, target_classes: List[str] = TARGET_CLASSES):
    """
    Detección de placa con YOLO + OCR EasyOCR sobre la ROI + validación por regex + POST
    """
    # Fuente de video (0,1,2 o URL)
    source = int(video_source) if str(video_source).isdigit() else video_source
    cap = cv2.VideoCapture(source)
    if not cap.isOpened():
        print(f"[ERR] Could not open VIDEO_SOURCE: {video_source}")
        return

    # Cargar pesos YOLO
    try:
        model = YOLO(LICENSE_PLATE_MODEL_PATH)
        print(f"[plates] Loaded {LICENSE_PLATE_MODEL_PATH}. Classes: {model.names}")
    except Exception as e:
        print(f"[ERR] Could not load YOLO model: {LICENSE_PLATE_MODEL_PATH}. Error: {e}")
        return

    # Mapeo de clases disponibles
    model_names = model.names
    lower_target = {c.lower() for c in target_classes}

    last_sent_text = ""
    last_sent_t = 0.0

    print(f"[plates] started. source={video_source} regex='{PLATE_REGEX}' ocr_conf_min={OCR_CONF_MIN}")
    while True:
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.05)
            continue

        # Detección
        results = model.predict(source=frame, verbose=False)
        detected_any = False

        for r in results:
            for b in r.boxes:
                cls_id = int(b.cls[0])
                name = model_names.get(cls_id, "").lower()
                conf = float(b.conf[0])

                if name in lower_target and conf >= conf_plate:
                    x1, y1, x2, y2 = map(int, b.xyxy[0].tolist())
                    x1, y1 = max(0, x1), max(0, y1)
                    x2, y2 = min(frame.shape[1]-1, x2), min(frame.shape[0]-1, y2)
                    roi = frame[y1:y2, x1:x2].copy()
                    if roi.size == 0:
                        continue

                    # ---- OCR ----
                    plate_text, ocr_conf = _read_plate_text(roi)

                    # Dibujo
                    color = (255, 0, 0)  # azul bbox
                    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                    label = f"{name}:{conf:.2f}"
                    if plate_text:
                        label += f" | {plate_text} ({ocr_conf:.2f})"
                    cv2.putText(frame, label, (x1, max(0, y1 - 8)),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

                    if plate_text is None:
                        continue

                    print(f"[plates] Detected {name} conf={conf:.2f} ocr='{plate_text}' ({ocr_conf:.2f})")

                    # POST (si OCR válido + cooldown)
                    # if plate_text:
                    #     now = time.time()
                    #     if (plate_text != last_sent_text) or (now - last_sent_t > SEND_COOLDOWN_S):
                    #         payload_meta = {
                    #             "texto": plate_text,
                    #             "det_conf": conf,
                    #             "ocr_conf": ocr_conf,
                    #             "timestamp": datetime.datetime.utcnow().isof ormat(),
                    #             "location": "zone1_camera1",
                    #         }
                    #         try:
                    #             post_event(
                    #                 settings.api_url,
                    #                 'vehicle',
                    #                 'license_plate',
                    #                 payload_meta,
                    #                 roi  # recorte de la placa
                    #             )
                    #             print(f"[plates] POST {plate_text} det={conf:.2f} ocr={ocr_conf:.2f}")
                    #         except Exception as e:
                    #             print("[plates] WARN POST:", e)
                    #         last_sent_text, last_sent_t = plate_text, now

                    # detected_any = True

        # Visualización
        win_name = "Detección de Placas YOLO + OCR"
        cv2.imshow(win_name, frame)
        key = cv2.waitKey(1) & 0xFF
        if key == 27:  # ESC
            break

        # Si quieres “pintar” algo cuando no hay nada detectado
        # if not detected_any: ...

    cap.release()
    cv2.destroyAllWindows()


class PlateService:
    """Servicio de placas (YOLO + OCR)."""
    def __init__(self, video_source: str, conf_plate: float, target_classes: List[str] = TARGET_CLASSES):
        self.video_source = video_source
        self.conf_plate = conf_plate
        self.target_classes = target_classes
