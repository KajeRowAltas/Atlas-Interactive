# ChatHistories `session_id` index migration

## Problem

If any writer inserts documents without `session_id` (or uses `sessionId` only), MongoDB treats the indexed `session_id` value as `null`. With a **unique** index on `session_id`, the second bad insert fails with:

`E11000 duplicate key error ... dup key: { session_id: null }`

## Target index (resilient)

Replace the current unique index with a **partial unique** index that ignores missing/null/empty values:

```js
db.ChatHistories.createIndex(
  { session_id: 1 },
  {
    name: "session_id_unique_nonnull",
    unique: true,
    partialFilterExpression: { session_id: { $exists: true, $type: "string", $ne: "" } }
  }
);
```

This prevents `null` collisions while still enforcing uniqueness for valid `session_id` strings.

## n8n note (common source of `session_id: null`)

The n8n LangChain MongoDB chat memory node (`@n8n/n8n-nodes-langchain.memoryMongoDbChat`) typically writes documents keyed by `sessionId` (camelCase) and may not populate `session_id`. If it writes into `ChatHistories`, the unique index on `session_id` can see `null` and collide.

Mitigations:
- Prefer pointing LangChain chat memory at a separate collection (e.g. `LangchainChatMemory`) and reserve `ChatHistories` for the canonical `session_id` contract.
- Or apply the partial unique index below so `null`/missing values do not collide.

## Safe migration (recommended)

Use the backend script `Atlas-Interactive/backend/scripts/migrate_chat_histories_session_id.py`:

1. Dry-run:
   - `python scripts/migrate_chat_histories_session_id.py`
2. Apply:
   - `python scripts/migrate_chat_histories_session_id.py --apply`

Then verify:
- `python scripts/verify_chat_histories_session_id.py`
