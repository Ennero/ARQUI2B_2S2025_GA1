# device_gateway/services/mqtt_publisher.py
import os
import random
from paho.mqtt import client as mqtt_client
from dotenv import load_dotenv

load_dotenv()

class MQTTPublisher:
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(MQTTPublisher, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        self._broker = os.getenv('MQTT_BROKER')
        self._port = int(os.getenv('MQTT_PORT'))
        self._topic_prefix = os.getenv('MQTT_TOPIC_PREFIX')
        self._client_id = f"device_gateway_publisher-{random.randint(0, 1000)}"
        self._client = mqtt_client.Client(client_id=self._client_id)
        
        self.events_topic = f"{self._topic_prefix}/gt/zone1/events"
        self.readings_topic = f"{self._topic_prefix}/gt/zone1/readings"

    def connect(self):
        try:
            self._client.connect(self._broker, self._port, keepalive=60)
            self._client.loop_start()
            print("MQTTPublisher connected successfully.")
        except Exception as e:
            print(f"Error connecting MQTTPublisher: {e}")

    def publish(self, topic: str, payload: str):
        result = self._client.publish(topic, payload, qos=1)
        if result.rc != mqtt_client.MQTT_ERR_SUCCESS:
            print(f"Failed to publish to topic {topic}")

    def disconnect(self):
        self._client.loop_stop()
        self._client.disconnect()
        print("MQTTPublisher disconnected.")