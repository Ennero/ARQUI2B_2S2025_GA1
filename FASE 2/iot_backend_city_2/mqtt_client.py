"""
MIT License - (c) 2025 Marcos Bonifasi
"""

import time
import random
import requests
from paho.mqtt import client as mqtt_client
from dotenv import load_dotenv
import os

load_dotenv()

class G1MqttClient(object):
    # Singleton
    def __new__(cls):
        if not hasattr(cls, "instance"):
            cls.instance = super(G1MqttClient, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        self._broker = os.getenv("MQTT_BROKER", "broker.emqx.io")
        self._port = int(os.getenv("MQTT_PORT", "1883"))

        cid_base = os.getenv("MQTT_CLIENT_ID", "g1-api-bridge")
        self._client_id = f"{cid_base}-{int(time.time())}-{random.randint(0, 1000)}"

        self._client = None
        self._connected = False
        self._topic = os.getenv("MQTT_TOPIC_PREFIX", "fiusac/arqui2/g1/#")

        # Tópicos “funcionales” que vamos a forwardear al API
        self._allowed_topics = [
            "fiusac/arqui2/g1/system/zone1/events",
            "fiusac/arqui2/g1/system/zone1/readings",
        ]

        # API destino (tu backend)
        self._api_base = os.getenv("API_BASE", "http://localhost:8080")
        self._ingest_path = os.getenv("INGEST_PATH", "/api/ingest")
        self._ingest_token = os.getenv("INGEST_TOKEN")

    # ---------- helpers ----------
    def _post_to_api(self, line: str):
        """
        Envía la cadena cruda al endpoint /api/ingest:
        { "line": "<cadena>" }
        """
        url = f"{self._api_base}{self._ingest_path}"
        headers = {"Content-Type": "application/json"}
        if self._ingest_token:
            headers["X-INGEST-TOKEN"] = self._ingest_token

        r = requests.post(url, json={"line": line}, headers=headers, timeout=10)
        r.raise_for_status()
        print("[API] OK:", r.json())

    # ---------- MQTT callbacks ----------
    def _on_connect(self, client, user_data, flags, rc):
        if rc == 0:
            print(f"[MQTT] Connected to {self._broker}:{self._port} (client_id {self._client_id})")
            self._connected = True
            res = client.subscribe(self._topic, qos=1)
            if res[0] == mqtt_client.MQTT_ERR_SUCCESS:
                print(f"[MQTT] Subscribed to: {self._topic}")
            else:
                print(f"[MQTT] Subscribe failed (rc={res[0]})")
        else:
            print(f"[MQTT] Connection failed (rc={rc})")

    def _on_message(self, client, user_data, msg):
        topic = msg.topic
        payload_str = msg.payload.decode("utf-8", errors="ignore").strip()
        print(f"[MQTT] {topic} :: {payload_str}")

        # Tus mensajes NO vienen en JSON, así que NO intentamos json.loads.
        # Solo reenviamos la cadena cruda a la API si pertenece a nuestros tópicos funcionales:
        if topic.endswith("/events") or topic.endswith("/readings"):
            try:
                self._post_to_api(payload_str)
            except requests.RequestException as e:
                print("[API] ERROR:", e)

    def _on_subscribe(self, client, user_data, mid, granted_qos):
        print(f"[MQTT] Subscription ACK MID={mid} QoS={granted_qos}")

    # ---------- API pública ----------
    def connect(self):
        self._client = mqtt_client.Client(client_id=self._client_id, clean_session=True)
        self._client.on_connect = self._on_connect
        self._client.on_message = self._on_message
        # self._client.on_subscribe = self._on_subscribe  # habilita si quieres más logs

        # Last will (opcional)
        self._client.will_set(
            "fiusac/arqui2/g1/system/clients/disconnect",
            payload=f"{self._client_id} disconnected",
            qos=1,
            retain=False,
        )

        # Conexión
        try:
            print(f"[MQTT] Connecting to {self._broker}:{self._port} ...")
            self._client.connect(self._broker, self._port, keepalive=60)
        except Exception as e:
            print(f"[MQTT] Connection error: {str(e)}")

    def publish(self, topic: str, message: str, qos: int = 1):
        if not self._connected:
            print("[MQTT] Not connected. Cannot publish.")
            return

        # Importante: topic debe ser uno de los permitidos (sin el prefijo)
        # Si te pasan 'gt/zone1/events', asegúrate que concuerde con los reales.
        if topic not in self._allowed_topics:
            print(f'[MQTT] Topic "{topic}" not allowed. Allowed: {self._allowed_topics}')
            return

        result = self._client.publish(topic, payload=message, qos=qos)
        if result.rc != mqtt_client.MQTT_ERR_SUCCESS:
            print(f"[MQTT] Publish failed (rc={result.rc})")

    def disconnect(self):
        if self._client:
            print("[MQTT] Disconnecting...")
            self._client.disconnect()
            self._connected = False
        else:
            print("[MQTT] Client not initialized.")

    def run(self):
        if not self._client:
            print("[MQTT] Client not initialized! Call connect() first.")
            return

        print("[MQTT] Loop started. Ctrl+C to stop.")
        try:
            self._client.loop_forever(retry_first_connection=True)
        except KeyboardInterrupt:
            print("[MQTT] Stopping...")
            self._client.disconnect()
