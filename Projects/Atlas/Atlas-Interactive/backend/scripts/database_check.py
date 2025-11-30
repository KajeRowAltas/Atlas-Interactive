import os
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.server_api import ServerApi

# 1. Laad de kluis
load_dotenv()

# 2. Haal de sleutel op
uri = os.getenv("MONGODB_URI")
db_name = os.getenv("DB_NAME")

if not uri:
    print("❌ FOUT: Geen MONGODB_URI gevonden in .env bestand!")
    exit()

# 3. Probeer verbinding te maken
print("📡 Verbinding maken met Atlas Memory Core...")

try:
    client = MongoClient(uri, server_api=ServerApi('1'))
    
    # Stuur een 'ping' om te checken of we er zijn
    client.admin.command('ping')
    
    print("✅ SUCCES! Verbinding met MongoDB Atlas is tot stand gebracht.")
    print(f"📂 Gekoppeld aan database: {db_name}")
    
    # Even kijken hoeveel herinneringen er al zijn (waarschijnlijk 0)
    db = client[db_name]
    count = db.memories.count_documents({})
    print(f"🧠 Aantal herinneringen in geheugen: {count}")

except Exception as e:
    print(f"❌ MISLUKT: {e}")