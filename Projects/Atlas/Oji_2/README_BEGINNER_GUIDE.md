# Oji_2 Beginner Guide

This folder contains everything you need to run the self-learning digital twin **Oji** inside n8n with MongoDB Atlas.

## Quick Start (under 2 hours)
1. **Create free MongoDB Atlas cluster → database “OjiDB”.**
2. **Import `config/OjiDB_blueprint.json` + `config/indexes.json`.** Use Atlas Data Import or Compass to create the collections and indexes in one shot.
3. **Add MongoDB & OpenAI credentials in n8n.** Create credentials that match `credentials/MongoDB_Atlas.json` and `credentials/OpenAI.json` (same names recommended).
4. **Import the three workflows in order 01 → 02 → 03.** Use n8n’s *Import from File* for each `workflow.json`.
5. **Activate ONLY the `01_Query_Analysis_Agent` workflow.** The others are triggered via `Execute Workflow` nodes.
6. **Test with the message “Hey Oji, who are you?”** Run the first workflow manually, confirm it cascades into the second and third.
7. **How to add future tools later.** Empty folders (`prompts`, `utils`, `config`, `tests`) are ready for new tools and prompts; add new nodes to the workflows as needed.

## Overview
- **01_Query_Analysis_Agent**: Parses user input, logs analysis to MongoDB, and triggers the response pipeline.
- **02_Response_Agent**: Performs RAG retrieval across memories, crafts the reply, stores chat history, and triggers reflection.
- **03_Reflection_Agent**: Writes insights back to 8–12 collections so Oji keeps learning.

## Folder Map
```
Oji_2/
├── 01_Query_Analysis_Agent/
├── 02_Response_Agent/
├── 03_Reflection_Agent/
├── credentials/
├── prompts/
├── utils/
├── config/
└── tests/
```

## Tips
- Keep MongoDB collection names exactly as provided so nodes bind correctly.
- Each workflow includes yellow sticky notes describing what to configure.
- Use the provided prompts as starting points; edit them without changing placeholders.
