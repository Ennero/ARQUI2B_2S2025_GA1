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
from pymongo import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv

load_dotenv()

class MongoDBConnection:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MongoDBConnection, cls).__new__(cls)
            cls._instance._initialize_connection()
        return cls._instance
    
    def _initialize_connection(self):
        
        uri = os.getenv("MONGODB_URI")
        self.client = MongoClient(
            uri,
            server_api=ServerApi('1'),
            connectTimeoutMS=30000,
            socketTimeoutMS=30000,
            maxPoolSize=50
        )
        try:
            # Test the connection
            self.client.admin.command('ping')
            print("Successfully connected to MongoDB Atlas!")
        except Exception as e:
            print(f"Failed to connect to MongoDB: {e}")
            raise
    
    def get_database(self, db_name: str):
        return self.client[db_name]
    
    def get_last_document(self, db_name: str, collection_name: str):
        db = self.get_database(db_name)
        collection = db[collection_name]
        last_document = collection.find_one(sort=[('_id', -1)])
        return last_document
    
    def close_connection(self):
        if self.client:
            self.client.close()
            self._instance = None

mongodb_connection = MongoDBConnection()