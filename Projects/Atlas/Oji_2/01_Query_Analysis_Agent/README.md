# Oji_2 – 01_Query_Analysis_Agent Guide

This workflow is the first stage of Oji. It accepts user input, analyzes intent, logs it to MongoDB Atlas, and forwards the conversation to the Response Agent via an **Execute Workflow** node.

## Full Setup (applies to all three agents)
1. **Create a free MongoDB Atlas cluster and database `OjiDB`.**
2. **Import `config/OjiDB_blueprint.json` and `config/indexes.json`.** This seeds all required collections and indexes in one step.
3. **Add MongoDB & OpenAI credentials in n8n.** Match the names in `credentials/MongoDB_Atlas.json` and `credentials/OpenAI.json`.
4. **Import the three workflows in order: `01_Query_Analysis_Agent` → `02_Response_Agent` → `03_Reflection_Agent`.** Use n8n’s *Import from File* for each `workflow.json`.
5. **Activate only this `01_Query_Analysis_Agent` workflow.** It automatically triggers the others via Execute Workflow.
6. **Test with the message “Hey Oji, who are you?”** Run this workflow manually and confirm the cascade.
7. **Extend later as needed.** Use the `prompts`, `utils`, `config`, and `tests` folders for new tools without changing the core flow.

## What this agent does
- Loads the query analysis prompt from `prompts/query_analysis_prompt.txt`.
- Uses shared helpers in `utils/common_functions.js` and `utils/session_handler.js`.
- Logs query insights into MongoDB collections such as `QueryAnalysis`, `ChatHistories`, and `ActivityLog`.
- Hands off to the Response Agent through an Execute Workflow node (configured with continue-on-fail disabled here).

## Configuration tips
- Keep collection names exactly as provided in the blueprint to avoid node binding issues.
- Review the yellow sticky-note (Note) nodes inside n8n for step-by-step instructions on credentials and MongoDB connection setup.
- If you customize prompts, leave placeholder tokens intact (e.g., `{{user_input}}`, `{{session_id}}`).
