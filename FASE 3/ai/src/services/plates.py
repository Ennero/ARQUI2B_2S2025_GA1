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

import os, re, cv2, time, base64, datetime, requests, math
import numpy as np
from collections import deque, Counter
from typing import List, Tuple, Optional

def _to_b64_jpeg(img_bgr: np.ndarray) -> Optional[str]:
    ok, buf = cv2.imencode(".jpg", img_bgr)
    return base64.b64encode(buf).decode("utf-8") if ok else None

def _normalize_text(t: str) -> str:
    return re.sub(r"[^A-Z0-9]", "", t.upper())

def _open_capture(source_str: str) -> cv2.VideoCapture:
    # macOS: AVFoundation mejora mucho abrir la cámara integrada
    src = int(source_str) if str(source_str).isdigit() else source_str
    try:
        cap = cv2.VideoCapture(src, cv2.CAP_AVFOUNDATION) if isinstance(src, int) else cv2.VideoCapture(src)
        if not cap.isOpened():
            cap = cv2.VideoCapture(src)
    except:
        cap = cv2.VideoCapture(src)
    return cap

def _order_quad(pts: np.ndarray) -> np.ndarray:
    rect = np.zeros((4, 2), dtype="float32")
    s = pts.sum(axis=1)
    diff = np.diff(pts, axis=1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]
    return rect

def _four_point_warp(image: np.ndarray, pts: np.ndarray, out_w: int = 320, out_h: int = 96) -> np.ndarray:
    rect = _order_quad(pts.astype("float32"))
    dst = np.array([[0,0],[out_w-1,0],[out_w-1,out_h-1],[0,out_h-1]], dtype="float32")
    M = cv2.getPerspectiveTransform(rect, dst)
    warped = cv2.warpPerspective(image, M, (out_w, out_h))
    return warped

def _rectangularity(cnt: np.ndarray) -> float:
    area = cv2.contourArea(cnt)
    x,y,w,h = cv2.boundingRect(cnt)
    rect_area = float(w*h) if w*h>0 else 1.0
    return area/rect_area

def _border_interior_check(gray_roi: np.ndarray, border_frac: float = 0.08) -> bool:
    """placa clara con marco oscuro suele funcionar bien"""
    h, w = gray_roi.shape[:2]
    bw = max(2, int(min(w, h) * border_frac))
    interior = gray_roi[bw:h-bw, bw:w-bw] if h>2*bw and w>2*bw else gray_roi
    if interior.size == 0:
        return False
    mask = np.ones_like(gray_roi, dtype=np.uint8)
    mask[bw:h-bw, bw:w-bw] = 0
    border_vals = gray_roi[mask == 1]
    m_int = float(np.mean(interior))
    m_bor = float(np.mean(border_vals)) if border_vals.size else 255.0
    return (m_int >= 120.0) and (m_bor + 15.0 < m_int)

def _text_signal(gray_roi: np.ndarray) -> bool:
    """blackhat para resaltar texto oscuro; umbral por porcentaje de pixeles"""
    k = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))
    bh = cv2.morphologyEx(gray_roi, cv2.MORPH_BLACKHAT, k)
    _, thr = cv2.threshold(bh, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    ratio = float(np.count_nonzero(thr)) / thr.size
    return ratio > 0.008  # ~0.8%

def _common_fixes(s: str) -> str:
    # Correcciones típicas OCR: O↔0, I↔1, B↔8, S↔5, Z↔2
    s = s.replace("O", "0") if re.search(r"\d", s) else s  # si hay números, O -> 0
    s = s.replace("I", "1")
    s = s.replace("B", "8")
    s = s.replace("S", "5")
    s = s.replace("Z", "2")
    return s

# ---------- Core ----------
def run_plate_recognizer(
    video_source: str,
    api_url: str,
    ocr_langs: str = "en",
    # patrones válidos (edita estos para TU formato local)
    valid_regexes: List[str] = None,
    draw_overlay: bool = True,
    send_cooldown_s: float = 3.0,
    read_stride: int = 2,          # procesa 1 de cada N frames
    canny_lo: int = 60,
    canny_hi: int = 170,
    min_area: int = 2500,
    max_area: int = 140000,
    min_ratio: float = 2.4,
    max_ratio: float = 6.0,
    approx_eps: float = 0.02,      # aprox poligonal
    vote_window: int = 7,          # N frames para votar
    ocr_conf_min: float = 0.28,    # conf mínima EasyOCR
):
    """
    Pipeline clásico: candidatos por morfología/contornos → deskew → EasyOCR → regex → voting → POST
    """
    # Regex válidos
    if valid_regexes is None:
        # genérico 5–8 alfanum / y 2 ejemplos de formatos tipo "P123ABC" y "ABC1234"
        valid_regexes = [r"^[A-Z0-9]{5,8}$", r"^P[0-9]{3}[A-Z]{3}$", r"^[A-Z]{3}[0-9]{4}$"]
    regex_list = [re.compile(rx) for rx in valid_regexes]

    # OCR
    import easyocr
    reader = easyocr.Reader(ocr_langs.split(","), gpu=False)

    # Video
    cap = _open_capture(video_source)
    if not cap.isOpened():
        print(f"[plates] ERROR: no se pudo abrir VIDEO_SOURCE={video_source}")
        return
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    cap.set(cv2.CAP_PROP_FPS, 30)

    last_sent_text = ""
    last_sent_t = 0.0
    frame_id = 0
    votes = deque(maxlen=vote_window)  # buffer de strings detectados recientemente

    print(f"[plates] iniciado. fuente={video_source} → POST {api_url}")
    while True:
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.03); continue
        frame_id += 1

        if frame_id % read_stride != 0:
            if draw_overlay:
                cv2.imshow("Plates (from scratch)", frame)
                if cv2.waitKey(1) & 0xFF == 27: break
            continue

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        # pre-mejoras
        gray_blur = cv2.bilateralFilter(gray, 7, 50, 50)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        gray_eq = clahe.apply(gray_blur)

        # bordes
        edges = cv2.Canny(gray_eq, canny_lo, canny_hi)
        edges = cv2.dilate(edges, np.ones((3,3), np.uint8), iterations=1)

        # contornos
        contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
        candidates: List[Tuple[np.ndarray, Tuple[int,int,int,int]]] = []

        for cnt in contours:
            x,y,w,h = cv2.boundingRect(cnt)
            area = w*h
            if area < min_area or area > max_area:
                continue
            ratio = w / float(h)
            if ratio < min_ratio or ratio > max_ratio:
                continue

            # rectangularidad
            rectness = _rectangularity(cnt)
            if rectness < 0.60:  # muy “dentado”, descartar
                continue

            peri = cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, approx_eps * peri, True)
            if len(approx) != 4:
                continue

            pts = approx.reshape(-1,2)
            # chequeos visuales adicionales
            roi = frame[y:y+h, x:x+w]
            if roi.size == 0:
                continue
            rgray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
            if not _border_interior_check(rgray, border_frac=0.08):
                continue
            if not _text_signal(rgray):
                continue

            candidates.append((pts, (x,y,w,h)))

        detections = []
        for quad_pts, (x,y,w,h) in candidates:
            try:
                warped = _four_point_warp(frame, quad_pts, out_w=360, out_h=110)
            except:
                warped = frame[y:y+h, x:x+w]
                if warped.size == 0:
                    continue

            # binarización suave (placa clara / letras oscuras)
            wgray = cv2.cvtColor(warped, cv2.COLOR_BGR2GRAY)
            wgray = cv2.fastNlMeansDenoising(wgray, None, 7, 7, 21)
            thr = cv2.adaptiveThreshold(wgray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                        cv2.THRESH_BINARY, 31, 3)
            thr_rgb = cv2.cvtColor(thr, cv2.COLOR_GRAY2BGR)

            results = reader.readtext(thr_rgb)  # [(bbox, text, conf)]
            best = None
            for _, text, conf in results:
                if float(conf) < ocr_conf_min: 
                    continue
                tnorm = _normalize_text(text)
                tnorm = _common_fixes(tnorm)
                # valida contra cualquiera de los regex
                if any(rx.fullmatch(tnorm) for rx in regex_list):
                    if (best is None) or (conf > best[1]):
                        best = (tnorm, float(conf))

            if best:
                detections.append((best[0], best[1], quad_pts))

        # Voting multi-frame
        display_texts = []
        for texto, conf, quad_pts in detections:
            votes.append(texto)
            # pinta
            if draw_overlay:
                cv2.polylines(frame, [quad_pts], True, (0,255,255), 2)
                x0, y0 = quad_pts[0][0], quad_pts[0][1]
                cv2.putText(frame, f"{texto} {conf:.2f}", (x0, max(0, y0-8)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,255), 2)
            display_texts.append(texto)

        if votes:
            # mayoría simple
            c = Counter(votes)
            voted_text, voted_count = c.most_common(1)[0]
            # envía si cambió o si pasó el cooldown
            now = time.time()
            if voted_text and (voted_text != last_sent_text or (now - last_sent_t) > send_cooldown_s):
                # sólo envía si aparece en los últimos 2-3 frames (evita fantasmas antiguos)
                if voted_count >= max(2, vote_window//3):
                    payload = {
                        "tipo": "placa",
                        "subtipo": "N/A",
                        "meta": {
                            "texto": voted_text,
                            "conf_voto": voted_count/float(len(votes)),
                            "timestamp": datetime.datetime.utcnow().isoformat(),
                            "ubicacion": "zona1_camara_1",
                        },
                        "img_b64": _to_b64_jpeg(frame)
                    }
                    # try:
                    #     requests.post(api_url, json=payload, timeout=3)
                    #     print(f"[plates] POST {voted_text} (vote={voted_count}/{len(votes)})")
                    # except Exception as e:
                    #     print("[plates] WARN POST:", e)
                    print(voted_text)
                    last_sent_text, last_sent_t = voted_text, now

        if draw_overlay:
            # opcional: muestra el top vote en overlay
            if votes:
                c = Counter(votes); top, n = c.most_common(1)[0]
                cv2.putText(frame, f"VOTE: {top} ({n}/{len(votes)})",
                            (20,30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,255), 2)
            cv2.imshow("Plates (from scratch)", frame)
            if cv2.waitKey(1) & 0xFF == 27:
                break

    cap.release()
    cv2.destroyAllWindows()
