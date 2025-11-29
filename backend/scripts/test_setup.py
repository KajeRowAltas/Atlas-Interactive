import sys
import ccxt
import pymongo
import fastapi

print("✅ Atlas System Check:")
print(f"• Python Versie: {sys.version.split()[0]}")
print(f"• CCXT (Trading) Geïnstalleerd: {ccxt.__version__}")
print(f"• PyMongo (Memory) Geïnstalleerd: {pymongo.__version__}")
print(f"• FastAPI (Interface) Geïnstalleerd: {fastapi.__version__}")
print("🚀 Ready to build.")