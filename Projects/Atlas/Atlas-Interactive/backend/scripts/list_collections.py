import os
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

# Load environment variables from .env file
load_dotenv()

# Get the MongoDB connection string and database name from environment variables
uri = os.getenv("MONGODB_URL")
db_name = os.getenv("DB_NAME", "OjiDB") # Default to OjiDB if not set

if not uri:
    print("Error: MONGODB_URL environment variable not set.")
    exit(1)

print(f"Connecting to MongoDB...")

try:
    # Create a new client and connect to the server
    client = MongoClient(uri)
    
    # Send a ping to confirm a successful connection
    client.admin.command('ping')
    print("Successfully connected to MongoDB.")
    
    # Get the database
    db = client[db_name]
    
    # List the collections
    print(f"Collections in database '{db_name}':")
    collections = db.list_collection_names()
    
    if not collections:
        print("No collections found in this database.")
    else:
        for collection in sorted(collections):
            print(f"- {collection}")

except ConnectionFailure as e:
    print(f"Connection failed: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    # Ensure that the client is closed when you're done with it
    if 'client' in locals() and client:
        client.close()
