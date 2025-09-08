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
from pymongo import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv

load_dotenv()

class MongoDBConnection:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            print('Creating new MongoDB connection instance.')
            cls._instance = super(MongoDBConnection, cls).__new__(cls)
            try:
                cls._instance._initialize_connection()
            except Exception as e:
                # If connection fails, don't keep a failed instance
                cls._instance = None
                print(f'Failed to initialize MongoDB connection: {e}')
                raise  # Re-raise the exception to stop the app
        return cls._instance
    
    def _initialize_connection(self):
        uri = os.getenv('MONGO_URI')
        if not uri:
            raise ValueError('MONGO_URI environment variable not set.')
            
        self.client = MongoClient(
            uri,
            server_api=ServerApi('1')
            # The default timeouts and pool size are usually sufficient
            # to start. We can add whether we need specific tuning.
        )
        # The ismaster command is cheap and does not require auth.
        self.client.admin.command('ping')
        print('Successfully connected to MongoDB Atlas!')
    
    def get_database(self, db_name: str):
        return self.client[db_name]

    def get_collection(self, db_name: str, collection_name: str):
        db = self.get_database(db_name)
        return db[collection_name]
    
    def close(self):
        '''
        Closes the connection to MongoDB.
        This method should only be called when the application is shutting down.
        '''
        if self.client:
            self.client.close()
            MongoDBConnection._instance = None # Allows restarting the singleton if necessary
            print('MongoDB connection closed.')