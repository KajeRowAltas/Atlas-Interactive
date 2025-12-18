# n8n Workflow Notes (Atlas / Oji)

## Files

- `Oji_N8N_Backend.json`: exported current workflow.
- `Oji_Patch.json`: exported patched workflow with safer defaults (does **not** modify the embedded agent prompts).

## What `Oji_Patch.json` changes

- Ensures `body.session_id` is never empty (falls back from `sessionId`, else generates a UUID).
- Adds `trace_id` and `turn_id` fields (with camelCase mirrors for compatibility).
- Fixes MongoDB chat memory session keying and points LangChain chat memory at `OjiDB.LangchainChatMemory` instead of `OjiDB.ChatHistories` to avoid `session_id: null` unique-index collisions.

## Still required in n8n (by design)

To meet the canonical storage strategy:

- `ChatHistories` writes should be `updateOne(..., { upsert: true })` + `$push` keyed by `session_id`.
- Use either:
  - a MongoDB node configured for Update+Upsert+$push (see `docs/chat_histories_contract.md`), or
  - the backend endpoint `POST /chat/history/append` (`Atlas-Interactive/backend/app/routers/chat_history.py`).

## Prompt updates

Keep `docs/n8n_agent_prompts.md` as the canonical prompt set.

If you want a stricter `session_id`/`trace_id`/`turn_id` schema for agent outputs, see `docs/n8n_agent_prompts_patch.md` and copy/paste into n8n manually (don’t overwrite the canonical prompts unless you intend to).

