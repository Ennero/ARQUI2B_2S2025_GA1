'''
MIT License

Copyright (c) 2025 Marcos Bonifasi

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
import asyncio
import logging
from config.settings import settings
from asyncio_mqtt import Client, MqttError
from typing import Callable

# Configure logging for better visibility
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

mqtt_client = None

class MQTTClient:
    def __init__(self):
        self.broker = settings.mqtt_broker
        self.port = settings.mqtt_port
        self.client_id = settings.mqtt_client_id
        self.client = None
        self.on_message_callback: Callable = None
        self.allowed_topics = []

    async def connect(self):
        self.client = Client(
            hostname=self.broker,
            port=self.port,
            client_id=self.client_id,
            reconnect_on_disconnect=True
        )

        # Set the on_disconnect callback on the underlying paho-mqtt client
        if self.on_disconnect_callback:
            self.client._client.on_disconnect = self.on_disconnect_callback

        try:
            logging.info("Connecting to MQTT broker...")
            await self.client.connect()
            logging.info("Connection successful.")

            # Subscribe to allowed topics after connection
            await self.subscribe("my/device/status", self.on_message)

            await asyncio.Event().wait()  # This will wait indefinitely
            
            logging.info("Client is running. Press CMD+C to exit.")
        except MqttError as e:
            logging.error(f"Failed to connect to MQTT broker: {e}")
            raise
        except asyncio.CancelledError:
            logging.info("MQTT client task was cancelled.")
            raise

    async def disconnect(self):
        if self.client:
            logging.info("Disconnecting from MQTT broker...")
            await self.client.disconnect()
            logging.info("Disconnection successful.")

    async def publish(self, topic: str, payload: str, qos: int = 1):
        if not self.client or not self.client.is_connected:
            logging.warning("Client is not connected. Cannot publish.")
            return
        
        try:
            await self.client.publish(topic, payload, qos)
            logging.info(f"Published to topic '{topic}': '{payload}'")
        except MqttError as e:
            logging.error(f"Failed to publish message: {e}")

    async def subscribe(self, topic: str, on_message: Callable):
        if not self.client or not self.client.is_connected:
            logging.warning("Client is not connected. Cannot subscribe.")
            return

        self.on_message_callback = on_message
        await self.client.subscribe(topic)
        logging.info(f"Subscribed to topic '{topic}'.")

        # Start a background task to handle incoming messages
        asyncio.create_task(self._message_handler(topic))

    async def on_message(self, message):
        """Callback function to process incoming messages."""
        payload = message.payload.decode()
        logging.info(f"Received from '{message.topic}': {payload}")
        # Here you can add logic to process the message data
        # e.g., if payload == "start_motor": ...

    async def _message_handler(self, topic: str):
        """Internal method to handle incoming messages on a subscribed topic."""
        async with self.client.filtered_messages(topic) as messages:
            async for message in messages:
                if self.on_message_callback:
                    await self.on_message_callback(message)

    def set_on_disconnect_callback(self, callback: Callable):
        """Method to set the on_disconnect callback."""
        self.on_disconnect_callback = callback
        if self.client:
            self.client._client.on_disconnect = callback


async def run_mqtt():
    global mqtt_client
    mqtt_client = MQTTClient()
    
    try:
        await mqtt_client.connect()

        # Subscribe to a topic with a callback function
        await mqtt_client.subscribe("my/device/status", on_message)

        # Keep the main loop running to receive messages
        logging.info("Client is running. Press CMD+C to exit.")
        await asyncio.Event().wait()  # This will wait indefinitely
        
    except (MqttError, asyncio.CancelledError) as e:
        logging.error(f"An error occurred: {e}")
    finally:
        await mqtt_client.disconnect()
