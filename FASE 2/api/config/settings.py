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

from pydantic_settings import BaseSettings
from pydantic import Field
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseSettings):
    # General application settings
    app_name: str = Field(default=os.getenv('INSTANCE_NAME'), alias="APP_NAME")
    app_env: str = Field(default=os.getenv('APP_ENV'), alias="APP_ENV")
    
    # MongoDB settings
    mongo_uri: str = Field(default=os.getenv('MONGO_URI'), alias="MONGO_URI")
    mongo_db: str = Field(default=os.getenv('MONGODB_NAME'), alias="MONGO_DB")
    
    # MQTT settings
    mqtt_broker: str = Field(default=os.getenv('MQTT_BROKER'), alias="MQTT_BROKER")
    mqtt_port: int = Field(default=int(os.getenv('MQTT_PORT', 1883)), alias="MQTT_PORT")
    mqtt_client_id: str = Field(default=os.getenv('MQTT_CLIENT_ID'), alias="MQTT_CLIENT_ID")
    mqtt_client_topic_prefix: str = Field(default=os.getenv('MQTT_CLIENT_TOPIC_PREFIX'), alias="MQTT_CLIENT_TOPIC_PREFIX")

    # Devices information
    # arduino_mega_01: str = Field(default=os.getenv('ARDUINO_MEGA_01'), alias="ARDUINO_MEGA_01")

settings = Settings()