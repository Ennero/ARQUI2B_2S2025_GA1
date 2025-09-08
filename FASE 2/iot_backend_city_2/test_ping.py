# test_ping.py
import certifi
from pymongo import MongoClient
from pymongo.server_api import ServerApi

uri = "mongodb+srv://Campero011235xYz:dnvD37rUJ8ag5yPE@arqui2g1campero.bxp9uus.mongodb.net/ARQUI2B_2S2025_GA1?retryWrites=true&w=majority&appName=Arqui2G1Campero"
client = MongoClient(uri, tls=True, tlsCAFile=certifi.where(), server_api=ServerApi('1'))
print(client.admin.command('ping'))
