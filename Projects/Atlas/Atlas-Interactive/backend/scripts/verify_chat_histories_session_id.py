import argparse
import os
import sys

from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.server_api import ServerApi


def main() -> int:
    load_dotenv()

    parser = argparse.ArgumentParser(
        description="Verify ChatHistories documents have a non-empty session_id and no duplicate session_id values."
    )
    parser.add_argument("--db", default=os.getenv("DB_NAME", "atlas_interactive"))
    parser.add_argument("--collection", default="ChatHistories")
    parser.add_argument("--uri", default=os.getenv("MONGODB_URI", ""))
    parser.add_argument("--limit", type=int, default=20)
    args = parser.parse_args()

    if not args.uri:
        print("❌ MONGODB_URI is not set (env or --uri).")
        return 2

    client = MongoClient(args.uri, server_api=ServerApi("1"))
    db = client[args.db]
    col = db[args.collection]

    bad_filter = {
        "$or": [
            {"session_id": None},
            {"session_id": {"$exists": False}},
            {"session_id": ""},
        ]
    }
    bad_count = col.count_documents(bad_filter)
    print(f"Bad session_id docs: {bad_count}")
    if bad_count:
        for doc in col.find(bad_filter, {"_id": 1, "session_id": 1, "sessionId": 1}).limit(
            args.limit
        ):
            print(doc)

    dup_pipeline = [
        {"$match": {"session_id": {"$exists": True, "$type": "string", "$ne": ""}}},
        {
            "$group": {
                "_id": "$session_id",
                "count": {"$sum": 1},
                "ids": {"$push": "$_id"},
            }
        },
        {"$match": {"count": {"$gt": 1}}},
        {"$sort": {"count": -1}},
        {"$limit": args.limit},
    ]
    dups = list(col.aggregate(dup_pipeline))
    print(f"Duplicate session_id values: {len(dups)}")
    if dups:
        for d in dups:
            print({"session_id": d["_id"], "count": d["count"], "ids": d["ids"]})

    return 1 if bad_count or dups else 0


if __name__ == "__main__":
    raise SystemExit(main())

