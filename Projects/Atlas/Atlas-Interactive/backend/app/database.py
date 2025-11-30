import os
from functools import lru_cache
from typing import Any

from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from pymongo import MongoClient
from pymongo.server_api import ServerApi

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "")
MONGODB_DB = os.getenv("DB_NAME", "atlas_interactive")


@lru_cache
def get_sync_client() -> MongoClient:
    if not MONGODB_URI:
        raise RuntimeError("MONGODB_URI is not set")
    return MongoClient(MONGODB_URI, server_api=ServerApi("1"))


@lru_cache
def get_client() -> AsyncIOMotorClient:
    if not MONGODB_URI:
        raise RuntimeError("MONGODB_URI is not set")
    return AsyncIOMotorClient(MONGODB_URI, server_api=ServerApi("1"))


def get_database() -> AsyncIOMotorDatabase:
    client = get_client()
    return client[MONGODB_DB]


async def ping() -> dict[str, Any]:
    db = get_database()
    return await db.command("ping")
