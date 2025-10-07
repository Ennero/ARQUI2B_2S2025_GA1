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

import os, cv2, numpy as np
from pathlib import Path
import json

def load_db(db_dir="blacklist", size=(128,128)):
    X, y, labels = [], [], {}
    people = sorted([p for p in Path(db_dir).iterdir() if p.is_dir()])
    if not people: raise RuntimeError(f"No hay carpetas en {db_dir}")
    for i, person in enumerate(people):
        labels[i] = person.name
        for imgp in person.glob("*"):
            img = cv2.imread(str(imgp), cv2.IMREAD_GRAYSCALE)
            if img is None: continue
            img = cv2.equalizeHist(cv2.resize(img, size))
            X.append(img); y.append(i)
    if not X: raise RuntimeError("No se cargaron imágenes")
    return X, np.array(y, np.int32), labels

def train(db_dir="blacklist", model_path="models/blacklist_lbph.yml", labels_path="models/blacklist_labels.json"):
    X, y, labels = load_db(db_dir)
    os.makedirs(Path(model_path).parent, exist_ok=True)
    rec = cv2.face.LBPHFaceRecognizer_create(radius=2, neighbors=8, grid_x=8, grid_y=8)
    rec.train(X, y)
    rec.write(model_path)
    with open(labels_path,"w",encoding="utf-8") as f:
        json.dump({str(k):v for k,v in labels.items()}, f, ensure_ascii=False, indent=2)
    print(f"[train] Guardado modelo en {model_path} con {len(labels)} personas")

if __name__ == "__main__":
    train()
