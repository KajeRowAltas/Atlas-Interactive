# Oji_2 – 03_Reflection_Agent Guide

This workflow closes each turn by summarizing and writing insights back to multiple MongoDB collections, keeping Oji self-improving after every response.

## Full Setup (applies to all three agents)
1. **Create a free MongoDB Atlas cluster and database `OjiDB`.**
2. **Import `config/OjiDB_blueprint.json` and `config/indexes.json`.** This seeds all required collections and indexes in one step.
3. **Add MongoDB & OpenAI credentials in n8n.** Match the names in `credentials/MongoDB_Atlas.json` and `credentials/OpenAI.json`.
4. **Import the three workflows in order: `01_Query_Analysis_Agent` → `02_Response_Agent` → `03_Reflection_Agent`.** Use n8n’s *Import from File* for each `workflow.json`.
5. **Activate only the `01_Query_Analysis_Agent` workflow.** Reflection is triggered automatically from the Response Agent with Continue On Fail enabled.
6. **Test with the message “Hey Oji, who are you?”** Verify this agent records summaries and insights across the memory collections.
7. **Extend later as needed.** Add more post-processing or storage targets while keeping the existing collection names intact.

## What this agent does
- Ingests prior message, analysis, and response context to generate reflections using the prompt in `prompts/reflection_prompt.txt`.
- Writes to 8–12 collections (e.g., `ReflectionsInsights`, `ShortTermMemory`, `EpisodicMemories`, `KnowledgeMemories`, `SemanticMemories`, `EmotionalHistory`, `CurrentEmotionalState`, `ActivityLog`, `ProjectTasks`, `OpenStorage`).
- Uses shared helpers in `utils/common_functions.js` for consistent logging and formatting.
- Completes without sending user-facing messages, keeping the UI experience clean.

## Configuration tips
- Ensure MongoDB collection names exactly match the blueprint to keep all write nodes aligned.
- Review the yellow Note nodes inside the workflow for credential wiring and recommended defaults.
- Keep placeholder tokens intact if you edit the reflection prompt (e.g., `{{recent_interaction}}`, `{{learning_targets}}`).
