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

import os, time, re, base64, datetime, requests
from typing import Optional, List, Tuple
import cv2
import numpy as np
import easyocr

# ---------- Utils ----------
def _to_b64_jpeg(img_bgr: np.ndarray) -> Optional[str]:
    ok, buf = cv2.imencode(".jpg", img_bgr)
    return base64.b64encode(buf).decode("utf-8") if ok else None

def _normalize_text(t: str) -> str:
    return re.sub(r"[^A-Z0-9]", "", t.upper())

def _open_capture(source_str: str) -> cv2.VideoCapture:
    src = int(source_str) if str(source_str).isdigit() else source_str
    try:
        cap = cv2.VideoCapture(src, cv2.CAP_AVFOUNDATION) if isinstance(src, int) else cv2.VideoCapture(src)
        if not cap.isOpened():
            cap = cv2.VideoCapture(src)
    except:
        cap = cv2.VideoCapture(src)
    return cap

# chequea que haya borde oscuro y centro claro (placa blanca con marco)
def _border_interior_check(gray_roi: np.ndarray, border_frac: float = 0.08) -> bool:
    h, w = gray_roi.shape[:2]
    bw = max(2, int(min(w, h) * border_frac))
    interior = gray_roi[bw:h-bw, bw:w-bw] if h>2*bw and w>2*bw else gray_roi
    if interior.size == 0:
        return False
    border_mask = np.ones_like(gray_roi, dtype=np.uint8)
    border_mask[bw:h-bw, bw:w-bw] = 0
    border = gray_roi.copy()
    border[border_mask == 0] = 0

    m_int = float(np.mean(interior))
    m_bor = float(np.mean(border[border_mask == 1])) if np.count_nonzero(border_mask) else 255.0

    # interior claro, borde oscuro
    return (m_int >= 130.0) and (m_bor + 15.0 < m_int)

# texto oscuro en fondo claro (blackhat)
def _has_text_signal(gray_roi: np.ndarray) -> bool:
    k = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))
    bh = cv2.morphologyEx(gray_roi, cv2.MORPH_BLACKHAT, k)
    # binariza puntos “oscuros” relevantes
    _, thr = cv2.threshold(bh, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    ratio = float(np.count_nonzero(thr)) / thr.size
    return ratio > 0.01  # >=1% de pixeles con “texto oscuro”

# ---------- Core ----------
def run_plates_cascade(
    video_source: str,
    rpi_api_url: str,
    ocr_langs: str = "en",
    plate_regex: str = r"[A-Z0-9]{5,8}",
    min_chars: int = 5,
    draw_overlay: bool = True,
    send_cooldown_s: float = 3.0,
    read_every_n_frames: int = 2,
    scaleFactor: float = 1.1,
    minNeighbors: int = 5,
    minSize: Tuple[int,int] = (60, 20),
    aspect_min: float = 2.3,
    aspect_max: float = 5.8,
) -> None:
    """
    Detector de placas con Haar-cascade + validaciones visuales + OCR en el recorte.
    Sin entrenamiento. Multiprocessing-friendly (solo args simples).
    """
    cap = _open_capture(video_source)
    if not cap.isOpened():
        print(f"[plates-cv] ERROR: no se pudo abrir VIDEO_SOURCE={video_source}")
        return
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    cap.set(cv2.CAP_PROP_FPS, 30)

    # Haar cascade (incluido con opencv-python)
    cascade_path = os.path.join(cv2.data.haarcascades, "haarcascade_russian_plate_number.xml")
    if not os.path.exists(cascade_path):
        print("[plates-cv] ERROR: no se encontró haarcascade_russian_plate_number.xml")
        print("Instala opencv-python adecuado o coloca el xml en tu proyecto y actualiza la ruta.")
        return
    plate_cascade = cv2.CascadeClassifier(cascade_path)

    # OCR una sola instancia
    reader = easyocr.Reader(ocr_langs.split(","), gpu=False)
    regex = re.compile(plate_regex)

    def _is_plate_text(t: str) -> bool:
        t2 = _normalize_text(t)
        return len(t2) >= min_chars and bool(regex.fullmatch(t2))

    def _post_plate(texto: str, frame_bgr: np.ndarray, conf_ocr: float):
        payload = {
            "tipo": "placa",
            "subtipo": "N/A",
            "meta": {
                "conf": float(conf_ocr),
                "texto": _normalize_text(texto),
                "timestamp": datetime.datetime.utcnow().isoformat(),
                "ubicacion": "zona1_camara_1",
            },
            "img_b64": _to_b64_jpeg(frame_bgr),
        }
        try:
            requests.post(rpi_api_url, json=payload, timeout=3)
        except Exception as e:
            print("[plates-cv] WARN POST:", e)

    last_sent_text = ""
    last_sent_t = 0.0

    print(f"[plates-cv] iniciado. fuente={video_source} → POST {rpi_api_url}")
    frame_id = 0
    while True:
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.05); continue
        frame_id += 1

        if frame_id % read_every_n_frames != 0:
            if draw_overlay:
                cv2.imshow("Plates (Haar + OCR)", frame)
                if cv2.waitKey(1) & 0xFF == 27: break
            continue

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.equalizeHist(gray)  # mejora contraste global

        # 1) Detección de candidatos con Haar
        rects = plate_cascade.detectMultiScale(
            gray,
            scaleFactor=scaleFactor,
            minNeighbors=minNeighbors,
            minSize=minSize
        )

        detections = []
        for (x, y, w, h) in rects:
            if h <= 0 or w <= 0:
                continue
            aspect = w / float(h)
            if aspect < aspect_min or aspect > aspect_max:
                continue

            roi = frame[y:y+h, x:x+w]
            if roi.size == 0:
                continue

            # 2) Validaciones visuales: borde/interior y señal de texto
            gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
            if not _border_interior_check(gray_roi, border_frac=0.08):
                continue
            if not _has_text_signal(gray_roi):
                continue

            # 3) OCR en ROI binarizado suave
            den = cv2.fastNlMeansDenoising(gray_roi, None, 7, 7, 21)
            thr = cv2.adaptiveThreshold(den, 255, cv2.ADAPTIVE_THRESH_MEAN_C,
                                        cv2.THRESH_BINARY, 31, 5)
            thr_rgb = cv2.cvtColor(thr, cv2.COLOR_GRAY2BGR)

            results = reader.readtext(thr_rgb)  # [(bbox, text, conf)]
            best = None
            for _, text, conf in results:
                tnorm = _normalize_text(text)
                if _is_plate_text(tnorm):
                    if (best is None) or (conf > best[1]):
                        best = (tnorm, float(conf))

            if best:
                detections.append((best[0], best[1], (x,y,w,h)))

        # 4) Overlay + POST (debounce)
        for texto, conf_ocr, (x,y,w,h) in detections:
            if draw_overlay:
                cv2.rectangle(frame, (x,y), (x+w,y+h), (0,255,255), 2)
                cv2.putText(frame, f"{texto} {conf_ocr:.2f}", (x, max(0, y-8)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,255), 2)

            now = time.time()
            if texto != last_sent_text or (now - last_sent_t) > send_cooldown_s:
                print(f"[plates-cv] detectada: {texto} (ocr={conf_ocr:.2f})")
                _post_plate(texto, frame, conf_ocr)
                last_sent_text, last_sent_t = texto, now

        if draw_overlay:
            cv2.imshow("Plates (Haar + OCR)", frame)
            if cv2.waitKey(1) & 0xFF == 27:  # ESC
                break

    cap.release()
    cv2.destroyAllWindows()
