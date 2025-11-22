# Oji_2 – 02_Response_Agent Guide

This workflow handles retrieval-augmented generation (RAG), crafts the reply, logs it, sends it back to the user, and triggers reflection. Import it after the Query Analysis Agent.

## Full Setup (applies to all three agents)
1. **Create a free MongoDB Atlas cluster and database `OjiDB`.**
2. **Import `config/OjiDB_blueprint.json` and `config/indexes.json`.** This seeds all required collections and indexes in one step.
3. **Add MongoDB & OpenAI credentials in n8n.** Match the names in `credentials/MongoDB_Atlas.json` and `credentials/OpenAI.json`.
4. **Import the three workflows in order: `01_Query_Analysis_Agent` → `02_Response_Agent` → `03_Reflection_Agent`.** Use n8n’s *Import from File* for each `workflow.json`.
5. **Activate only the `01_Query_Analysis_Agent` workflow.** This Response Agent is invoked via Execute Workflow from step 01.
6. **Test with the message “Hey Oji, who are you?”** Confirm RAG retrievals merge correctly and the response reaches the user.
7. **Extend later as needed.** Use the provided folders to add tools or memory sources without altering the core handoff sequence.

## What this agent does
- Loads the system, RAG, and retrieval example prompts from `prompts/response_system_prompt.txt`, `prompts/response_rag_prompt.txt`, and `prompts/rag_retrieval_examples.txt`.
- Runs parallel MongoDB RAG reads (memories, traits, history) and merges them with **Merge** nodes before calling OpenAI.
- Stores outputs in `ChatHistories`, `ActivityLog`, `ShortTermMemory`, and related collections.
- Triggers the `03_Reflection_Agent` via Execute Workflow with **Continue On Fail = true** so learning proceeds even if reflection has issues.

## Configuration tips
- Keep every collection name exactly as defined in the Atlas blueprint to avoid misaligned nodes.
- Follow the yellow Note nodes for credential naming and connection guidance.
- Preserve placeholder tokens (e.g., `{{user_input}}`, `{{session_id}}`, `{{memory_context}}`) if you edit prompts.
