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

import os, cv2, time
from pathlib import Path

CASCADE = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

def main(person_name: str, out_dir="blacklist", video_source="0", max_imgs=30):
    os.makedirs(Path(out_dir)/person_name, exist_ok=True)
    src = int(video_source) if str(video_source).isdigit() else video_source
    cap = cv2.VideoCapture(src)
    if not cap.isOpened():
        raise RuntimeError(f"No se pudo abrir VIDEO_SOURCE={video_source}")

    count = 0
    while count < max_imgs:
        ok, frame = cap.read()
        if not ok: break
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = CASCADE.detectMultiScale(gray, 1.2, 5, minSize=(60,60))
        for (x,y,w,h) in faces:
            face = gray[y:y+h, x:x+w]
            face = cv2.equalizeHist(cv2.resize(face, (128,128)))
            path = Path(out_dir)/person_name/f"{int(time.time()*1000)}.png"
            cv2.imwrite(str(path), face)
            count += 1
            cv2.rectangle(frame,(x,y),(x+w,y+h),(0,255,0),2)
            cv2.putText(frame, f"{person_name} {count}/{max_imgs}", (x,y-8),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7,(0,255,0),2)
            if count >= max_imgs: break

        cv2.imshow("Enroll", frame)
        if cv2.waitKey(1) & 0xFF == 27: break  # ESC para salir

    cap.release(); cv2.destroyAllWindows()
    print(f"[enroll] Guardadas {count} imágenes en {out_dir}/{person_name}")

if __name__ == "__main__":
    import argparse, os
    ap = argparse.ArgumentParser()
    ap.add_argument("--person", required=True, help="Nombre de la persona (carpeta)")
    ap.add_argument("--video_source", default=os.getenv("VIDEO_SOURCE","0"))
    ap.add_argument("--out_dir", default="blacklist")
    ap.add_argument("--max_imgs", type=int, default=30)
    args = ap.parse_args()
    main(args.person, args.out_dir, args.video_source, args.max_imgs)
