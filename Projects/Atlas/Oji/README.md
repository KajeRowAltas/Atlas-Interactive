# Oji Conversational AI (Atlas Interactive)

This folder (in the repo path `Projects/Atlas/Oji`) contains the complete n8n implementation for **Oji**, a three-agent conversational system backed by MongoDB Atlas. The assets here can be imported directly so you get a working, self-learning assistant from day one.

## Visual layout of the workflows

### Main Conversation Flow (01_Main_Conversation_Flow.json)
```
Webhook → Set/Load Session & ShortTermMemory → Query Analysis → [Parallel] Knowledge RAG + Tooling RAG → Response Agent → Save to ChatHistories → Webhook Response → Execute Reflection Async
```

### Reflection Async Flow (02_Reflection_Async_Flow.json)
```
Incoming Trigger → 10s Wait → Load Latest Chat History → Generate Reflection → Update IntentSummaries + ToolFeedback + ReflectionQueue → Store LongTermMemory
```

### Agent Workflows
- **01_Query_Analysis_Agent/workflow.json**: parses intent, domain, and tool hints using the query analysis prompt.
- **02_Response_Agent/workflow.json**: crafts the final reply using retrieved snippets and the response prompts.
- **03_Reflection_Agent/workflow.json**: distills the exchange into self-learning artifacts for OjiDB.

## File map
- `01_Main_Conversation_Flow.json` and `02_Reflection_Async_Flow.json`: import directly into n8n.
- `01_Query_Analysis_Agent/`, `02_Response_Agent/`, `03_Reflection_Agent/`: standalone agent flows used by the main pipeline.
- `config/`: MongoDB Atlas blueprint and collection/index definitions.
- `prompts/`: all prompt texts referenced by the workflows.
- `credentials/`: placeholder JSON files for MongoDB Atlas and OpenAI keys.
- `utils/common_functions.js`: helper utilities (JSON serialization, safe defaults).
- `README_BEGINNER_GUIDE.md`: step-by-step setup for new users.

## Three-agent diagram (prompt excerpt)
```
User Message → Query Analysis Agent (detect intent, entities, routing flags)
          ↘ Knowledge RAG (semantic search)      ↘ Tooling RAG (available tools)
                ↘ Response Agent (compose reply with citations and action plan)
                            ↘ Reflection Agent (after 10s, summarize & teach self)
```
