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

import os, cv2, time, base64, datetime, json, requests
from pathlib import Path
import numpy as np
from utils.net import post_event

CASCADE = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")


def _open(video_source):
    src = int(video_source) if str(video_source).isdigit() else video_source
    cap = cv2.VideoCapture(src)
    if not cap.isOpened(): cap = cv2.VideoCapture(src)  # fallback
    return cap

def _load_model(model_path, labels_path):
    if not Path(model_path).exists(): raise FileNotFoundError(model_path)
    if not Path(labels_path).exists(): raise FileNotFoundError(labels_path)
    rec = cv2.face.LBPHFaceRecognizer_create()
    rec.read(model_path)
    with open(labels_path,"r",encoding="utf-8") as f: labels=json.load(f)
    labels = {int(k):v for k,v in labels.items()}
    return rec, labels

def run_faces(video_source: str,
              api_url: str,
              model_path="models/blacklist_lbph.yml",
              labels_path="models/blacklist_labels.json",
              size=(128,128),
              threshold: float = 65.0,
              draw=True,
              send_cooldown=5.0):
    rec, labels = _load_model(model_path, labels_path)
    cap = _open(video_source)
    if not cap.isOpened(): 
        print(f"[faces] No se pudo abrir VIDEO_SOURCE={video_source}"); return
    cap.set(cv2.CAP_PROP_FRAME_WIDTH,1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT,720)

    last_sent = 0.0

    print("[faces] iniciado.")
    while True:
        ok, frame = cap.read()
        if not ok: time.sleep(0.03); continue
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = CASCADE.detectMultiScale(gray, 1.2, 6, minSize=(80,80))

        for (x,y,w,h) in faces:
            roi = cv2.equalizeHist(cv2.resize(gray[y:y+h, x:x+w], size))
            label_id, dist = rec.predict(roi)  # menor dist = mejor
            person = labels.get(int(label_id), f"id_{label_id}")
            conf = max(0.0, min(1.0, (100.0 - dist)/100.0))  # 0..1 aprox inversa

            matched = dist <= threshold
            color = (0,0,255) if matched else (0,255,0)

            if draw:
                cv2.rectangle(frame,(x,y),(x+w,y+h), color,2)
                cv2.putText(frame, f"{person if matched else 'desconocido'} {dist:.1f}",
                            (x, max(0,y-8)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, color,2)

            if matched:
                print('----------- MATHCHED ----------- ')
                print(f"[faces] ALERTA: {person} conf={conf:.2f} dist={dist:.1f}")


                now = time.time()
                if now - last_sent > 2.0:

                    # Make HTTP request
                    post_event(
                        api_url,
                        'person',
                        'blacklist',
                        {
                            "name": person,
                            "conf": float(conf),
                            "dist": float(dist),
                            "location": "camara_campero"
                        },
                        frame[y:y+h, x:x+w]
                    )

                    last_sent = now

        if draw:
            cv2.imshow("Blacklist (Haar + LBPH)", frame)
            if cv2.waitKey(1) & 0xFF == 27: break

    cap.release(); cv2.destroyAllWindows()
