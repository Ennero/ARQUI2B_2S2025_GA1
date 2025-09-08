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
import serial
import time
import os
from dotenv import load_dotenv
from datetime import datetime, timezone

# Importar nuestros módulos
from config.mongodb import MongoDBConnection
from config.mqtt import G1MqttClient
from services.event_handler import EventHandler
from utils.parser import parse_serial_data

load_dotenv()

class ApplicationG1:
    
    def __init__(self):
        self._serial_port_name = os.getenv('RASPBERRY_PI_PORT')
        self._serial_port = None

        # Connections to third-party services
        self.db_connection = MongoDBConnection()
        self.mqtt_client = G1MqttClient()

        # Database collections
        db_name = os.getenv('DATABASE_NAME')
        self.alerts_collection = self.db_connection.get_collection(db_name, 'events')
        self.readings_collection = self.db_connection.get_collection(db_name, 'readings')

        # Business logic components
        self.event_handler = EventHandler(self.mqtt_client, self.alerts_collection)

    def _process_reading(self, state: dict):
        '''Processes and saves the complete system reading.'''
        reading_document = {
            "timestamp": datetime.now(timezone.utc),
            "deviceId": "ARDUINO_MEGA_ZONA1",
            "data": state
        }
        # Publish the complete reading to a general topic
        self.mqtt_client.publish("system/zone1/readings", str(state))

        # Save to the readings collection
        self.readings_collection.insert_one(reading_document)
        print("Reading stored and published.")

    def perform(self):
        '''
        Main method that starts the application, connects services,
        and enters the reading loop.
        '''
        try:
            # Connect to MQTT
            self.mqtt_client.connect()
            self.mqtt_client.run() # Start the MQTT loop in a separate thread

            # Connect to the serial port
            self._serial_port = serial.Serial(self._serial_port_name, 9600, timeout=1)
            self._serial_port.flush()
            print(f"Successfully connected to serial port {self._serial_port_name}")

            while True:
                if self._serial_port.in_waiting > 0:
                    line = self._serial_port.readline().decode('utf-8').rstrip()

                    # Parse the raw data into a dictionary
                    current_state = parse_serial_data(line)
                    
                    if not current_state:
                        continue # If the line is malformed, we ignore it

                    print(f"Received from Arduino: {current_state}")

                    # Delegate event handling
                    self.event_handler.process_state(current_state)

                    # Process and save the complete reading
                    self._process_reading(current_state)
                
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
            self.db_connection.close()