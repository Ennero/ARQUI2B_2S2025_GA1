'''
MIT License

Copyright (c) 2024 Marcos Bonifasi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''

import time
import random
import json
from paho.mqtt import client as mqtt_client
from datetime import datetime
from dotenv import load_dotenv
import os
# from config.mongodb import mongodb_connection

load_dotenv()

class G1MqttClient(object):

    # Singleton pattern
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(G1MqttClient, cls).__new__(cls)
        return cls.instance


    def __init__(self):
        self._broker = os.getenv("MQTT_BROKER")
        self._port = int(os.getenv("MQTT_PORT"))
        self._client_id = f'{os.getenv("MQTT_CLIENT_ID")}-{int(time.time())}-{random.randint(0, 1000)}'
        self._client = None
        self._connected = False
        self._topic = os.getenv("MQTT_TOPIC_PREFIX")

        self._allowed_topics = [
            # TODO: Define allowed topics
        ]

    def connect(self):
        def on_connect(client, user_data, flags, rc):
            if rc == 0:
                
                print("Successfully connected to MQTT Broker!")
                self._connected = True
                
                # Subscribe to all topics with QoS 1
                result = client.subscribe(self._topic, qos=1)
                if result[0] == mqtt_client.MQTT_ERR_SUCCESS:
                    print(f"Successfully subscribed to topics: {self._topic}")
                else:
                    print(f"Subscribe failed with result code: {result}")
            
            else:
                print(f"Failed to connect, return code {rc}\n")

        def on_message(client, user_data, msg):
            topic = msg.topic
            payload_str = msg.payload.decode()
            # print(f"Received message on [{topic}]")
            # print(f"Payload: {payload_str}")

            # Tries to parse to JSON
            try:
                payload = json.loads(payload_str)
            except json.JSONDecodeError:
                print("Invalid JSON format")
                return


        def on_subscribe(client, user_data, mid, granted_qos):
            print(f"Subscription acknowledged for MID: {mid}")
            print(f"Granted QoS levels: {granted_qos}")

        self._client = mqtt_client.Client(client_id=self._client_id)
        self._client.on_connect = on_connect
        self._client.on_message = on_message
        # self._client.on_subscribe = on_subscribe
        
        # Enable additional logging
        self._client.enable_logger()
        
        # Set last will and testament (optional)
        self._client.will_set("clients/disconnect", payload="Client disconnected abruptly", qos=1)
        
        try:
            self._client.connect(self._broker, self._port, keepalive=60)
        except Exception as e:
            print(f"Connection error: {str(e)}")


    def publish(self, topic: str, message: str, qos: int = 1):
        if not self._connected:
            print("MQTT client is not connected. Cannot publish.")
            return

        if topic not in self._allowed_topics:
            print(f"Topic '{topic}' is not allowed. Allowed topics are: {self._allowed_topics}")
            return

        full_topic = f"{os.getenv('MQTT_TOPIC')}/{topic}"

        result = self._client.publish(full_topic, payload=message, qos=qos)

        if result.rc == mqtt_client.MQTT_ERR_SUCCESS:
            # print(f"Published to {full_topic}: {message}")
            pass
        else:
            print(f"Failed to publish to {full_topic}. Error code: {result.rc}")

    def disconnect(self):
        if self._client:
            print("Disconnecting MQTT client...")
            self._client.disconnect()
            self._connected = False
        else:
            print("MQTT client is not initialized.")

    def run(self):
        if not self._client:
            print("Client not initialized!")
            return
        
        print("Starting MQTT loop...")
        try:
            self._client.loop_forever(retry_first_connection=True)
        except KeyboardInterrupt:
            print("Disconnecting...")
            self._client.disconnect()
            


'''
12:28 p.m.
SEM1=AMARILLO;SEM2=ROJO;BUS1=64;BUS2=12;PM1=267;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=66;BUS2=13;PM1=275;PM2=112;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=68;BUS2=14;PM1=274;PM2=115;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=70;BUS2=15;PM1=289;PM2=107;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=72;BUS2=16;PM1=282;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=74;BUS2=17;PM1=276;PM2=101;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=76;BUS2=18;PM1=264;PM2=103;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=78;BUS2=19;PM1=254;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=80;BUS2=20;PM1=265;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=82;BUS2=21;PM1=255;PM2=104;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=84;BUS2=22;PM1=247;PM2=118;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=86;BUS2=23;PM1=240;PM2=127;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=88;BUS2=24;PM1=249;PM2=140;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=90;BUS2=25;PM1=261;PM2=136;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
'''