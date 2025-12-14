import argparse
import os
import sys
import uuid
from datetime import datetime, timezone
from typing import Any
from typing import Optional

from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.server_api import ServerApi


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def normalize_str(value: Any) -> Optional[str]:
    if not isinstance(value, str):
        return None
    trimmed = value.strip()
    return trimmed or None


def summarize_indexes(col: Collection) -> None:
    print("Indexes:")
    for name, info in col.index_information().items():
        print(f"- {name}: {info}")


def find_duplicates(col: Collection, limit: int) -> list[dict[str, Any]]:
    pipeline = [
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
        {"$limit": limit},
    ]
    return list(col.aggregate(pipeline))


def merge_duplicates(col: Collection, session_id: str, ids: list[Any], dry_run: bool) -> None:
    docs = list(col.find({"_id": {"$in": ids}}))
    if len(docs) <= 1:
        return

    def created_at_key(doc: dict[str, Any]) -> tuple[int, Any]:
        created_at = doc.get("created_at")
        if isinstance(created_at, datetime):
            return (0, created_at)
        return (1, doc.get("_id"))

    docs.sort(key=created_at_key)
    canonical = docs[0]
    canonical_id = canonical["_id"]

    merged_messages: list[Any] = []
    merged_from: list[Any] = []
    for d in docs:
        merged_from.append(d["_id"])
        messages = d.get("messages")
        if isinstance(messages, list):
            merged_messages.extend(messages)

    if dry_run:
        print(
            f"[dry-run] Merge {len(docs)} docs for session_id={session_id} into _id={canonical_id}"
        )
        return

    col.update_one(
        {"_id": canonical_id},
        {
            "$set": {
                "updated_at": utc_now(),
                "messages": merged_messages,
                "merged_from": merged_from,
            }
        },
    )

    for d in docs[1:]:
        suffix = str(d["_id"])
        col.update_one(
            {"_id": d["_id"]},
            {
                "$set": {
                    "archived_at": utc_now(),
                    "merged_into": canonical_id,
                    "session_id": f"{session_id}__merged__{suffix}",
                    "sessionId": f"{session_id}__merged__{suffix}",
                }
            },
        )


def drop_unique_session_id_indexes(col: Collection, dry_run: bool) -> None:
    to_drop: list[str] = []
    for name, info in col.index_information().items():
        keys = info.get("key")
        if keys == [("session_id", 1)] and info.get("unique") is True:
            to_drop.append(name)

    if not to_drop:
        print("No unique session_id indexes found to drop.")
        return

    for name in to_drop:
        if dry_run:
            print(f"[dry-run] drop_index({name})")
        else:
            print(f"Dropping index {name}...")
            col.drop_index(name)


def create_partial_unique_index(col: Collection, index_name: str, dry_run: bool) -> None:
    spec = [("session_id", 1)]
    opts = {
        "name": index_name,
        "unique": True,
        "partialFilterExpression": {
            "session_id": {"$exists": True, "$type": "string"}
        },
    }

    if dry_run:
        print(f"[dry-run] create_index({spec}, {opts})")
        return

    print(f"Creating partial unique index {index_name}...")
    col.create_index(spec, **opts)


def main() -> int:
    load_dotenv()

    parser = argparse.ArgumentParser(
        description="Migrate ChatHistories to enforce non-null session_id and install a partial unique index."
    )
    parser.add_argument("--uri", default=os.getenv("MONGODB_URI", ""))
    parser.add_argument("--db", default=os.getenv("DB_NAME", "atlas_interactive"))
    parser.add_argument("--collection", default="ChatHistories")
    parser.add_argument("--index-name", default="session_id_unique_nonnull")
    parser.add_argument("--apply", action="store_true", help="Execute writes (default: dry-run).")
    parser.add_argument(
        "--merge-duplicates",
        action="store_true",
        help="Merge duplicate session_id docs (otherwise abort before index change).",
    )
    parser.add_argument("--limit", type=int, default=50)
    args = parser.parse_args()

    if not args.uri:
        print("❌ MONGODB_URI is not set (env or --uri).")
        return 2

    dry_run = not args.apply
    client = MongoClient(args.uri, server_api=ServerApi("1"))
    col = client[args.db][args.collection]

    print(f"Target: {args.db}.{args.collection}")
    summarize_indexes(col)

    # 1) Normalize legacy sessionId -> session_id where possible.
    legacy_filter = {
        "$and": [
            {"session_id": {"$in": [None, ""]}},
            {"sessionId": {"$exists": True, "$type": "string", "$ne": ""}},
        ]
    }
    legacy_count = col.count_documents(legacy_filter)
    print(f"Legacy docs (sessionId -> session_id): {legacy_count}")
    if legacy_count and not dry_run:
        col.update_many(
            legacy_filter,
            [{"$set": {"session_id": {"$trim": {"input": "$sessionId"}}}}],
        )

    # 2) Generate session_id for anything still missing/null/empty.
    missing_filter = {
        "$or": [
            {"session_id": None},
            {"session_id": {"$exists": False}},
            {"session_id": ""},
        ]
    }
    missing_count = col.count_documents(missing_filter)
    print(f"Docs missing/invalid session_id: {missing_count}")
    if missing_count:
        if dry_run:
            print("[dry-run] Would assign generated session_id values to these docs.")
        else:
            for doc in col.find(missing_filter, {"_id": 1, "sessionId": 1}).limit(args.limit):
                new_id = f"migrated-{uuid.uuid4()}"
                print(f"Assigning session_id={new_id} to _id={doc['_id']}")
                col.update_one(
                    {"_id": doc["_id"]},
                    {"$set": {"session_id": new_id, "sessionId": new_id, "updated_at": utc_now()}},
                )
            remaining = col.count_documents(missing_filter)
            if remaining:
                print(
                    f"⚠️ Remaining docs with invalid session_id after first pass: {remaining} (re-run with higher --limit)."
                )
                return 3

    # 3) Duplicates check/merge before touching unique indexes.
    dups = find_duplicates(col, limit=args.limit)
    if dups:
        print(f"Found duplicate session_id values: {len(dups)} (showing up to {args.limit})")
        for d in dups:
            print({"session_id": d["_id"], "count": d["count"], "ids": d["ids"]})

        if not args.merge_duplicates:
            print("❌ Aborting: resolve duplicates (or pass --merge-duplicates).")
            return 4

        for d in dups:
            merge_duplicates(col, d["_id"], d["ids"], dry_run=dry_run)

        # Re-check after merge.
        dups_after = find_duplicates(col, limit=args.limit)
        if dups_after:
            print("❌ Duplicates still present after merge attempt.")
            return 5

    # 4) Replace unique index with partial unique index that ignores null/missing/empty values.
    drop_unique_session_id_indexes(col, dry_run=dry_run)
    create_partial_unique_index(col, args.index_name, dry_run=dry_run)

    print("Done." if not dry_run else "Dry-run complete (re-run with --apply to execute).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
