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

        # (Opcional) auth MQTT
        self._username = os.getenv("MQTT_USERNAME")
        self._password = os.getenv("MQTT_PASSWORD")

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
        try:
            print("[API] OK:", r.json())
        except Exception:
            print("[API] OK (no JSON en respuesta)")

    # ---------- MQTT callbacks ----------
    def _on_connect(self, client, user_data, flags, rc):
        if rc == 0:
            print(f"[MQTT] Connected to {self._broker}:{self._port} (client_id {self._client_id})")
            self._connected = True
            res = client.subscribe(self._topic, qos=1)
            if isinstance(res, tuple):
                rc_sub = res[0]
            else:
                rc_sub = getattr(res, "rc", res)
            if rc_sub == mqtt_client.MQTT_ERR_SUCCESS:
                print(f"[MQTT] Subscribed to: {self._topic}")
            else:
                print(f"[MQTT] Subscribe failed (rc={rc_sub})")
        else:
            print(f"[MQTT] Connection failed (rc={rc})")

    def _on_message(self, client, user_data, msg):
        topic = msg.topic
        payload_str = msg.payload.decode("utf-8", errors="ignore").strip()
        print(f"[MQTT] {topic} :: {payload_str}")

        # Tus mensajes NO vienen en JSON; solo reenviamos si es tópico funcional
        if topic.endswith("/events") or topic.endswith("/readings"):
            try:
                self._post_to_api(payload_str)
            except requests.RequestException as e:
                print("[API] ERROR:", e)

    def _on_subscribe(self, client, user_data, mid, granted_qos):
        print(f"[MQTT] Subscription ACK MID={mid} QoS={granted_qos}")

    # ---------- API pública ----------
    def connect(self):
        # Compatibilidad Paho 1.x y 2.x
        client_kwargs = dict(client_id=self._client_id, clean_session=True)
        if hasattr(mqtt_client, "CallbackAPIVersion"):
            # Solo existe en Paho 2.x
            client_kwargs["callback_api_version"] = mqtt_client.CallbackAPIVersion.VERSION1

        self._client = mqtt_client.Client(**client_kwargs)

        # (Opcional) credenciales
        if self._username:
            self._client.username_pw_set(self._username, self._password)

        # Callbacks
        self._client.on_connect = self._on_connect
        self._client.on_message = self._on_message
        # self._client.on_subscribe = self._on_subscribe  # habilítalo si quieres más logs

        # Logs internos de Paho en consola
        try:
            self._client.enable_logger()
        except Exception:
            pass

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

        if topic not in self._allowed_topics:
            print(f'[MQTT] Topic "{topic}" not allowed. Allowed: {self._allowed_topics}')
            return

        result = self._client.publish(topic, payload=message, qos=qos)
        rc_pub = getattr(result, "rc", result)
        if rc_pub != mqtt_client.MQTT_ERR_SUCCESS:
            print(f"[MQTT] Publish failed (rc={rc_pub})")

    def disconnect(self):
        if self._client:
            print("[MQTT] Disconnecting...")
            try:
                self._client.disconnect()
            finally:
                self._connected = False
        else:
            print("[MQTT] Client not initialized.")

    def run(self):
        if not self._client:
            print("[MQTT] Client not initialized! Call connect() first.")
            return

        print("[MQTT] Loop started. Ctrl+C to stop.")
        try:
            # retry_first_connection existe en 1.6+ y 2.x; si no, ignora el arg.
            try:
                self._client.loop_forever(retry_first_connection=True)
            except TypeError:
                self._client.loop_forever()
        except KeyboardInterrupt:
            print("[MQTT] Stopping...")
            self._client.disconnect()


# --------- Entry point para ejecutar directo ---------
if __name__ == "__main__":
    client = G1MqttClient()
    client.connect()
    client.run()
