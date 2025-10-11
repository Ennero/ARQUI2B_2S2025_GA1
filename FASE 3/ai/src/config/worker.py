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

# worker.py

from multiprocessing import Process
from services.weapons import run_weapons, WeaponsService
# Asegúrate de importar la nueva función y clase de servicio
from services.plates import run_plates_yolo, PlateService
from services.faces import run_faces
from config.settings import settings

class Worker:
    def __init__(self):
        # 1. Configuración del Servicio de Armas (Sin cambios)
        self.weapons_service = WeaponsService(
            video_source=settings.video_source,
            conf_weapon=settings.conf_weapon,
            target_classes=["Knife", "handgun", "Pistol", "rifle", "Grenade"]
        )
        self.weapons_pt_process = Process(
            target=run_weapons,
            args=(self.weapons_service.video_source,
                  self.weapons_service.conf_weapon,
                  ["Knife", "Pistol", "rifle"])
        )
        self.weapons_pt_process.daemon = True

        # 2. >>> IMPLEMENTACIÓN DEL SERVICIO DE PLACAS YOLO (NUEVO) <<<
        # Usamos PlateService para configurar el proceso
        self.plates_service = PlateService(
            video_source=settings.video_source,
            # Asegúrate de añadir conf_plate a tus settings o definirlo aquí
            conf_plate=settings.conf_plate, 
            target_classes=["license_plate", "plate"] # Nombres de clases de tu modelo
        )
        self.plates_process = Process(
            target=run_plates_yolo, # Usamos la nueva función
            args=(self.plates_service.video_source, 
                  self.plates_service.conf_plate,
                  self.plates_service.target_classes)
        )
        self.plates_process.daemon = True

        # 3. Configuración del Servicio de Rostros (Sin cambios)
        self.faces_process = Process(
            target=run_faces,
            args=(settings.video_source, settings.api_url, "models/blacklist_lbph.yml", "models/blacklist_labels.json")
        )
        self.faces_process.daemon = True

    def perform(self):
        # ... (La lógica de ejecución del proceso sigue igual) ...
        if settings.perform_algorithm_for == 'weapons':
            if not self.weapons_pt_process.is_alive():
                self.weapons_pt_process.start()
        elif settings.perform_algorithm_for == 'plates':
            if not self.plates_process.is_alive():
                self.plates_process.start()
        elif settings.perform_algorithm_for == 'faces':
            if not self.faces_process.is_alive():
                self.faces_process.start()

    def stop(self):
        # ... (La lógica de detención del proceso sigue igual) ...
        if settings.perform_algorithm_for == 'weapons':
            if self.weapons_pt_process and self.weapons_pt_process.is_alive():
                self.weapons_pt_process.terminate()
                self.weapons_pt_process.join(timeout=2)
        elif settings.perform_algorithm_for == 'plates':
            if self.plates_process and self.plates_process.is_alive():
                self.plates_process.terminate()
                self.plates_process.join(timeout=2)
        elif settings.perform_algorithm_for == 'faces':
            if self.faces_process and self.faces_process.is_alive():
                self.faces_process.terminate()
                self.faces_process.join(timeout=2)