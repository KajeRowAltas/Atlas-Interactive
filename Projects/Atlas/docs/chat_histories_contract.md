# ChatHistories Contract (Atlas Interactive)

## Canonical identifiers

- `session_id` (string, **required**, non-empty): stable per conversation.
- `trace_id` (string, optional): per workflow run / request.
- `turn_id` (int, optional): monotonic per `session_id` (client-generated is fine).

For transition safety, accept camelCase aliases (`sessionId`, `traceId`, `turnId`) but always **write** `session_id` to MongoDB.

## n8n workflow exports

- Current exported workflow: `Oji_N8N_Backend.json`
- Patched export (guardrails + safer defaults): `Oji_Patch.json`

`Oji_Patch.json` keeps the original agent prompts intact, ensures `session_id` is non-empty at the workflow edge, and moves LangChain chat memory writes to a separate collection (`LangchainChatMemory`) to avoid collisions with the `ChatHistories.session_id` unique index.

## n8n guardrail (first node after Webhook)

Add a **Set** node (or **Code** node) that guarantees a non-empty `session_id` and forwards it to every agent.

Code node example:

```js
// n8n Code node (JavaScript)
const crypto = require('crypto');
const incoming = $json;

const session_id =
  (typeof incoming.session_id === 'string' && incoming.session_id.trim()) ||
  (typeof incoming.sessionId === 'string' && incoming.sessionId.trim()) ||
  crypto.randomUUID();

return [{ ...incoming, session_id, sessionId: session_id }];
```

## ChatHistories write pattern (no insertOne)

Every agent stage should append to the same document using `updateOne(..., { upsert: true })` + `$push`.

MongoDB node example (operation: **Update**):

- Filter: `{ "session_id": "={{$json.session_id}}" }`
- Update:

```json
{
  "$setOnInsert": {
    "created_at": "={{$now}}",
    "session_id": "={{$json.session_id}}",
    "sessionId": "={{$json.session_id}}"
  },
  "$set": { "updated_at": "={{$now}}" },
  "$push": {
    "messages": {
      "ts": "={{$now}}",
      "agent": "agent-2-response",
      "role": "assistant",
      "content": "={{$json.output}}",
      "trace_id": "={{$json.trace_id}}",
      "turn_id": "={{$json.turn_id}}",
      "meta": {}
    }
  }
}
```

If you prefer to centralize writes, call the backend endpoint `POST /chat/history/append` (see `Atlas-Interactive/backend/app/routers/chat_history.py`).

## Optional: updated prompts (do not overwrite canonical prompts)

If you want the agents to standardize on `session_id`/`trace_id`/`turn_id` in their outputs, see `docs/n8n_agent_prompts_patch.md`.
