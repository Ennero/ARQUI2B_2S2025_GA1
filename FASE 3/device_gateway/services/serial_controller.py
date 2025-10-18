import os
import serial
import time
import json
from threading import Thread
from dotenv import load_dotenv
from services.mqtt_publisher import MQTTPublisher
from utils.parser import parse_serial_data

load_dotenv()

class SerialController:
    def __init__(self):
        self.port_name = os.getenv("RASPBERRY_PI_PORT")
        self.connection = None
        self.read_thread = None
        self._is_running = False
        self.mqtt_publisher = None

    def connect(self):
        if not self.port_name:
            print("WARNING: RASPBERRY_PI_PORT not set. Serial communication disabled.")
            return
        try:
            self.connection = serial.Serial(self.port_name, 9600, timeout=1)
            time.sleep(2)
            print(f"Successfully connected to Arduino on port {self.port_name}")
        except serial.SerialException as e:
            print(f"ERROR: Could not open serial port '{self.port_name}'. {e}")
            self.connection = None

    def start_reading(self, mqtt_publisher: MQTTPublisher):
        if not self.connection:
            return
        self.mqtt_publisher = mqtt_publisher
        self._is_running = True
        self.read_thread = Thread(target=self._read_and_publish_loop, daemon=True)
        self.read_thread.start()
        print("Arduino reading loop started.")

    def _read_and_publish_loop(self):
        """This function runs in a background thread, constantly reading from the Arduino."""
        while self._is_running:
            if self.connection and self.connection.in_waiting > 0:
                try:
                    raw_line = self.connection.readline()
                    line = raw_line.decode('utf-8', errors='ignore').rstrip()

                    if not line: continue
                    
                    state = parse_serial_data(line)
                    if not state: continue

                    reading_payload = json.dumps({"source": "arduino-mega-01", "frame": state})
                    self.mqtt_publisher.publish(self.mqtt_publisher.readings_topic, reading_payload)
                    
                    self._handle_events(state)

                except Exception as e:
                    print(f"Error in reading loop: {e}")
            time.sleep(0.1)

    def _handle_events(self, state: dict):
        """
        Analyzes the current state from the Arduino and publishes specific events
        if they are detected. This logic is a direct copy from the original ApplicationG1.
        """
        events_to_publish = []

        for i in range(1, 6):
            if str(state.get(f"PANICO{i}", "0")) == "1":
                events_to_publish.append({
                    "source": "arduino-mega-01",
                    "type": "panic",
                    "severity": "critical",
                    "data": {"button": f"PANICO{i}"},
                })
                break

        if str(state.get("SISMO", "0")) == "1":
            events_to_publish.append({
                "source": "arduino-mega-01",
                "type": "earthquake",
                "severity": "critical",
                "data": {"sensor": "SISMO"},
            })

        if str(state.get("INC1", "0")) == "1":
            events_to_publish.append({
                "source": "arduino-mega-01",
                "type": "fire",
                "severity": "critical",
                "data": {"sensor": "INC1"},
            })

        if str(state.get("INC2", "0")) == "1":
            events_to_publish.append({
                "source": "arduino-mega-01",
                "type": "fire",
                "severity": "critical",
                "data": {"sensor": "INC2"},
            })
            
        for code in ["INFRAA", "INFRAB", "INFRAC", "INFRAD"]:
            if str(state.get(code, "0")) == "1":
                events_to_publish.append({
                    "source": "arduino-mega-01",
                    "type": "infraction",
                    "severity": "medium",
                    "data": {"code": code},
                })

        for event in events_to_publish:
            self.mqtt_publisher.publish(self.mqtt_publisher.events_topic, json.dumps(event))
            print(f"Published event: {event.get('type')}")

    def send_alert(self, detection_type: str, buzzer_number: int):
        if not self.connection:
            return

        command_map = {"vehicle": "placas", "person": "antiRobo", "weapon": "armaBlanca"}
        command = command_map.get(detection_type)
        if not command: return

        message = f"{command}:{buzzer_number};"
        try:
            self.connection.write(message.encode('utf-8'))
            print(f"Sent serial command to Arduino: '{message}'")
        except Exception as e:
            print(f"Error writing to serial port: {e}")

    def disconnect(self):
        self._is_running = False
        if self.read_thread:
            self.read_thread.join()
        if self.connection and self.connection.is_open:
            self.connection.close()
            print("Serial port connection closed.")