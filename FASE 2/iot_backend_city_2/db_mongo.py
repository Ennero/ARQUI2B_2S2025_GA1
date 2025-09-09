# db_mongo.py
from pymongo import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv
import certifi   

load_dotenv()

class MongoDBConnection:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            print('Creating new MongoDB connection instance.')
            cls._instance = super(MongoDBConnection, cls).__new__(cls)
            cls._instance._initialize_connection()
        return cls._instance

    def _initialize_connection(self):
        uri = os.getenv('MONGODB_URI')
        if not uri:
            raise ValueError('MONGODB_URI not set')
        """ self.client = MongoClient(uri, server_api=ServerApi('1'))
        self.client.admin.command('ping') """
        # Forzar TLS y usar el CA bundle de certifi
        self.client = MongoClient(
            uri,
            tls=True,
            tlsCAFile=certifi.where(),   # <--- clave para arreglar el verify failed
            server_api=ServerApi('1'),
        )
        # Prueba de conexión
        self.client.admin.command('ping')
        print('Successfully connected to MongoDB Atlas with TLS verification!')

    def get_collection(self, db_name: str, coll_name: str):
        return self.client[db_name][coll_name]


    def get_database(self, db_name: str):
        return self.client[db_name]


    def close(self):
        if self.client:
            self.client.close()
            MongoDBConnection._instance = None
            print('MongoDB connection closed.')