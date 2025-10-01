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

from ultralytics import YOLO
from config.settings import settings
from utils.camera import Camera
import os, time

class WeaponsService:

    def __init__(self):
        self.video_source = 0 if settings.video_source == "0" else settings.video_source
        self.camera = Camera(self.video_source)
        self.self.model = YOLO('yolov8n.pt')
        self.weapon_type = 'knife'
        self.conf_weapon = settings.conf_weapon
        self.running = False


    def perform(self):
        self.running = True

        if not self.camera.isOpened():
            print("[ERR] Could not open self.video_source: ", self.video_source)
            self.running = False
            return

        last_sent = 0.0
        while self.running:
            ok, frame = self.camera.read()
            
            if not ok:
                time.sleep(0.05); continue

            results = self.model.predict(source=frame, verbose=False)

            for r in results:
                for b in r.boxes:
                    cls_id = int(b.cls[0])
                    name = r.names[cls_id]
                    conf = float(b.conf[0])
                    if name == 'knife' and conf >= self.conf_weapon:
                        pass
                        # Enviar 1 evento cada 2 s como máximo (para no spamear)
                        # now = time.time()
                        # if now - last_sent > 2.0:
                        #     post_event(frame, conf)
                        #     last_sent = now

            time.sleep(0.02)

        self.camera.release()