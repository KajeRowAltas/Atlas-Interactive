# Oji Beginner Guide

This guide walks you through creating MongoDB Atlas resources, importing the n8n workflows, and testing the first conversation with Oji.

## 1. Create the MongoDB Atlas cluster and database `OjiDB`
1. Sign in to [MongoDB Atlas](https://cloud.mongodb.com/).
2. Create a **Serverless** or **M0+** cluster in your preferred region.
3. In **Database Deployments → Browse Collections**, create a database named **`OjiDB`**.
4. Add initial collections listed in `config/collections.json` (Atlas will create them automatically on first write if you prefer).
5. Create a database user with **readWrite** access to `OjiDB` and allow access from your n8n host IP (or 0.0.0.0/0 while testing).

## 2. Apply the blueprint and indexes
1. Download `config/OjiDB_blueprint.json` and `config/indexes.json` locally.
2. Use MongoDB Atlas UI or `mongosh` to run the commands:
   - `mongosh "mongodb+srv://<user>:<password>@<cluster-url>/OjiDB" --file OjiDB_blueprint.json`
   - `mongosh "mongodb+srv://<user>:<password>@<cluster-url>/OjiDB" --file indexes.json`
3. Confirm the collections `ChatHistories`, `ShortTermMemory`, `LongTermMemory`, `IntentSummaries`, `ToolFeedback`, `ReflectionQueue`, and `RAGSnippets` exist with the specified indexes.

## 3. Add credentials in n8n
1. In n8n, open **Credentials** → **MongoDB** and create a new credential named **`MongoDB Atlas - Oji`** using your SRV connection string and `OjiDB` as the database.
2. Create an **OpenAI** credential named **`OpenAI - Oji`** with your API key.
3. If you self-host n8n, store environment variables securely (e.g., `N8N_ENCRYPTION_KEY`).

## 4. Import the workflows
1. Import `01_Main_Conversation_Flow.json` and `02_Reflection_Async_Flow.json` first.
2. Import the agent workflows inside the subfolders:
   - `01_Query_Analysis_Agent/workflow.json`
   - `02_Response_Agent/workflow.json`
   - `03_Reflection_Agent/workflow.json`
3. Ensure the **Execute Workflow** nodes point to the imported agent workflows.
4. Map credentials: select **MongoDB Atlas - Oji** for all MongoDB nodes and **OpenAI - Oji** for OpenAI nodes.

## 5. Test with the first message "Hey Oji"
1. Copy the **Webhook** URL from `01_Main_Conversation_Flow`.
2. Send a POST request (cURL or Postman) with JSON body:
   ```json
   { "message": "Hey Oji", "sessionId": "demo-session-001" }
   ```
3. The response should greet you and outline how it understood the intent. Check `ChatHistories` and `ShortTermMemory` collections to confirm the write operations.
4. After ~10 seconds, verify that `IntentSummaries`, `ToolFeedback`, and `ReflectionQueue` received new documents from the reflection flow.

## 6. Add new tools/functions later
- Leave the empty subfolders under `utils/` or create new ones (e.g., `utils/tools/`) to store connectors.
- Add new `MongoDB` collections and indexes to `config/collections.json` and `config/indexes.json` as you grow.
- Extend the **Tooling RAG** MongoDB node query inside `01_Main_Conversation_Flow` to surface the new tools to the Response Agent.

You now have everything needed to spin up a self-learning Oji instance end-to-end.
