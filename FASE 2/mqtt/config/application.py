'''
MIT License

Copyright (c) 2025 Marcos Bonifasi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''
import os
import time
import json
import serial
from threading import Thread
from dotenv import load_dotenv
from config.mqtt import G1MqttClient
from utils.parser import parse_serial_data

load_dotenv()

class ApplicationG1:
    
    def __init__(self):
        self._serial_port_name = os.getenv('RASPBERRY_PI_PORT')
        self._serial_port = None

        # Connections to third-party services
        self.mqtt_client = G1MqttClient()
        self.events_topic = f"{os.getenv('MQTT_TOPIC_PREFIX')}/gt/zone1/events"
        self.readings_topic = f"{os.getenv('MQTT_TOPIC_PREFIX')}/gt/zone1/readings"

    def perform(self):
        try:
            # Connect to MQTT
            self.mqtt_client.connect()
            # self.mqtt_client.run() # Start the MQTT loop in a separate thread

            self.mqtt_thread = Thread(target=self.mqtt_client.run, daemon=True)
            self.mqtt_thread.start()

            # Connect to the serial port
            self._serial_port = serial.Serial(self._serial_port_name, 9600, timeout=1)
            self._serial_port.flush()
            print(f"Successfully connected to serial port {self._serial_port_name}")

            while True:
                if self._serial_port.in_waiting > 0:
                    line = self._serial_port.readline().decode('utf-8').rstrip()

                    # Parse the raw data into a dictionary
                    current_state = parse_serial_data(line)

                    print(f"Received from Arduino: {current_state}")
                    print(current_state)
                    
                    if not current_state:
                        continue # If the line is malformed, we ignore it

                    reading_payload = {
                        "source": "arduino-mega-01",
                        "frame": current_state
                    }
                    self.mqtt_client.publish(self.readings_topic, json.dumps(reading_payload))

                    events = []

                    # Panic buttons
                    for i in range(1, 6):
                        if str(current_state.get(f"PANICO{i}", "0")) == "1":
                            events.append({
                                "source": "arduino-mega-01",
                                "type": "panic",
                                "severity": "critical",
                                "data": {"button": f"PANICO{i}"},
                            })
                            break
                    # Earthquake
                    if str(current_state.get("SISMO", "0")) == "1":
                        events.append({
                            "source": "arduino-mega-01",
                            "type": "earthquake",
                            "severity": "critical",
                            "data": {"sensor": "SISMO"},
                        })
                    # Infractions
                    for code in ["INFRAA", "INFRAB", "INFRAC", "INFRAD"]:
                        if str(current_state.get(code, "0")) == "1":
                            events.append({
                                "source": "arduino-mega-01",
                                "type": "infraction",
                                "severity": "medium",
                                "data": {"code": code},
                            })

                    # Publish events if any
                    for event in events:
                        self.mqtt_client.publish(self.events_topic, json.dumps(event))
                        print(f"Published event: {event}")
                
                time.sleep(0.1)

        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
        except KeyboardInterrupt:
            print("Application stopped by user.")
        finally:
            if self._serial_port and self._serial_port.is_open:
                self._serial_port.close()
                print("Serial port closed.")
            self.mqtt_client.disconnect()