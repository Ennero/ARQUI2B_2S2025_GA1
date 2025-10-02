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

def run_weapons(video_source: str, conf_weapon: float, weapon_type: str = "knife"):
    source = 0 if str(video_source).isdigit() else video_source

    if isinstance(source, int):
        cap = cv2.VideoCapture(source, cv2.CAP_AVFOUNDATION)
    else:
        cap = cv2.VideoCapture(source)

    if not cap.isOpened():
        print(f"[ERR] Could not open VIDEO_SOURCE: {video_source}")
        return

    model = YOLO("yolov8n.pt")

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
                if name == weapon_type and conf >= conf_weapon:
                    print("knife detected", conf)
                    # now = time.time()
                    # if now - last_sent > 2.0:
                    #     post_event(frame, conf)
                    #     last_sent = now

                    x1,y1,x2,y2 = map(int, b.xyxy[0].tolist())
                    cv2.rectangle(frame, (x1,y1), (x2,y2), (0,255,0), 2)
                    cv2.putText(frame, f"{name} {conf:.2f}", (x1, y1-8),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0,255,0), 2)

        cv2.imshow("Armas blancas (knife)", frame)
        if cv2.waitKey(1) & 0xFF == 27:  # ESC for exiting
            break

        # time.sleep(0.02)

    cap.release()


class WeaponsService:
    def __init__(self, video_source: str, conf_weapon: float, weapon_type: str = "knife"):
        self.video_source = video_source
        self.conf_weapon = conf_weapon
        self.weapon_type = weapon_type

