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

from datetime import datetime, timezone
from system.enums import EventType

class EventHandler:
    '''
    Process the state of the sensors to detect and handle alert events.
    Keeps the previous state to detect significant changes (e.g. from 0 to 1).
    '''
    def __init__(self, mqtt_client, alerts_collection):
        self.mqtt_client = mqtt_client
        self.alerts_collection = alerts_collection
        self._previous_state = {}
        
        # Maps sensor prefixes to event types
        self._event_map = {
            'PANICO': EventType.PANIC,
            'SISMO': EventType.SEISMIC,
            'INC': EventType.FIRE
        }

    def _check_for_event(self, key, value):
        '''
        Verifies whether a state change constitutes a new event.
        An event occurs when the state changes from '0' to '1'.
        '''
        return self._previous_state.get(key) == '0' and value == '1'

    def process_state(self, current_state: dict):
        '''
        Analyses the current state of the sensors, generates events if necessary,
        and updates the previous state.
        '''
        for key, value in current_state.items():
            # Identifies if the key corresponds to an event type
            prefix = ''.join(filter(str.isalpha, key))
            
            if prefix in self._event_map and self._check_for_event(key, value):
                event_type = self._event_map[prefix]
                
                # Creates the event document for the database
                event_document = {
                    'timestamp': datetime.now(timezone.utc),
                    'eventType': event_type.value,
                    'sourceId': key,
                    'status': 'active'
                }
                
                # Publish to MQTT
                topic = f'system/zone1/events/{event_type.value.lower()}'
                payload = f'Event detected: {event_type.name} from {key}'
                self.mqtt_client.publish(topic, payload)
                print(f'Event published to MQTT topic "{topic}": {payload}')

                # Insert data to MongoDB
                self.alerts_collection.insert_one(event_document)
                print(f'Event stored in MongoDB: {event_document}')

        # Update the previous state for the next comparison
        self._previous_state = current_state