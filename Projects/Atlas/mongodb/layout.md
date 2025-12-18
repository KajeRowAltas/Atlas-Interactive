# MongoDB Cluster Architecture Analysis

This document outlines the architecture of the MongoDB cluster associated with the Oji-AI project. The analysis was performed by inspecting all databases, collections, sample documents, and indexes.

## Summary of Databases

The cluster contains two primary user-facing databases:

-   `OjiDB`: This appears to be the main, active database for the "digital duplicate" project. It is highly structured, with numerous collections corresponding to different types of memory, project management, and AI personality traits. It features a sophisticated indexing strategy, including unique constraints, TTL (time-to-live) indexes for automatic data pruning, and indexes tailored for efficient querying.
-   `Oji-AI`: This database seems to be older, a prototype, or used for a different purpose. Its collections are less structured (e.g., using numbers in names) and it completely lacks any custom indexing beyond the default `_id` index, suggesting it is not optimized for performance.

---

## OjiDB Database

This is the core database.

### Collection: `ActivityLog`

-   **Purpose**: Tracks operations and events within the database.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('69130adafc07e1a7300db0c0')",
      "action": "insert",
      "collection": "Projects",
      "success": true,
      "timestamp": "2025-11-11T08:00:00Z",
      "severity": "info",
      "details": {
        "doc_id": "atlas-education",
        "reason": "new project creation"
      }
    }
    ```
-   **Indexes**:
    ```json
    [
      { "key": { "_id": 1 } },
      { "key": { "timestamp": -1 } },
      { "key": { "severity": 1 } },
      { "key": { "timestamp": 1 }, "expireAfterSeconds": 7776000 }
    ]
    ```
-   **Analysis**: This collection has a 90-day TTL index, automatically deleting documents older than 90 days. This is excellent for managing log data size.

### Collection: `AgentProfile`

-   **Purpose**: Defines the core identity of the AI agent.
-   **Schema**:
    ```json
    {
      "_id": "oji",
      "name": "Oji",
      "version": "1.0",
      "backstory": "An AI created by Kaje David Row...",
      "voice_style": "warm, sarcastic, helpful, concise",
      "created_at": "ISODate('2025-11-07T09:14:37.867Z')",
      "updated_at": "ISODate('2025-11-08T13:38:21.444Z')"
    }
    ```
-   **Indexes**:
    ```json
    [ { "key": { "_id": 1 } } ]
    ```
-   **Analysis**: Likely a singleton collection holding the profile for the 'oji' agent.

### Collection: `ChatHistories`

-   **Purpose**: Stores conversation logs.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('6912066bb59e1cae473965f4')",
      "session_id": "64d51990cdb442b68bd56036bb806628",
      "messages": [
        { "type": "human", "data": { "content": "..." } },
        { "type": "ai", "data": { "content": "..." } }
      ]
    }
    ```
-   **Indexes**:
    ```json
    [
      { "key": { "_id": 1 } },
      { "key": { "session_id": 1 }, "unique": true }
    ]
    ```
-   **Analysis**: `session_id` must be present and non-null; older clients may send `sessionId` (camelCase) which should be normalized to `session_id` before writing, otherwise the unique index sees `session_id: null` and collisions occur.

### Collection: `CurrentEmotionalState`

-   **Purpose**: Tracks the AI's real-time emotional state.
-   **Schema**:
    ```json
    {
      "_id": "current",
      "mood": "neutral",
      "energy": 1,
      "triggers": [],
      "last_update": "ISODate('2025-11-07T09:14:37.883Z')"
    }
    ```
-   **Indexes**:
    ```json
    [ { "key": { "_id": 1 } } ]
    ```
-   **Analysis**: A singleton collection identified by `_id: 'current'`.

### Collection: `EmotionalHistory`

-   **Purpose**: Logs changes in emotional state over time.
-   **Schema**: This collection was empty.
-   **Indexes**:
    ```json
    [
      { "key": { "_id": 1 } },
      { "key": { "timestamp": -1 } },
      { "key": { "timestamp": 1 }, "expireAfterSeconds": 15552000 }
    ]
    ```
-   **Analysis**: Has a 180-day TTL index for automatic data pruning.

### Collection: `EpisodicMemories`

-   **Purpose**: Stores memories of specific events.
-   **Schema**: This collection was empty.
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "timestamp": -1 } },
        { "key": { "importance": -1 } }
    ]
    ```
-   **Analysis**: Indexed for retrieving recent or important memories.

### Collection: `GoalsValuesBeliefs`

-   **Purpose**: Stores the AI's core guiding principles.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('6913074afc07e1a7300db09d')",
      "type": "goal",
      "belief": "Create and sustain Atlas",
      "priority": 1,
      "strength": 1
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "type": 1 } },
        { "key": { "priority": -1 } }
    ]
    ```
-   **Analysis**: Well-indexed for filtering and sorting.

### Collection: `KnowledgeMemories`

-   **Purpose**: Stores factual information, likely for retrieval.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('69130b08fc07e1a7300db0c3')",
      "fact": "Always use the appropriate vector index before performing similarity searches.",
      "category": "DB Best Practices",
      "confidence": 0.9,
      "embedding": [ 0, 0, 0, 0 ]
    }
    ```
-   **Indexes**:
    ```json
    [ { "key": { "_id": 1 } } ]
    ```
-   **Analysis**: Contains an `embedding` field but surprisingly lacks a vector search index. This is a significant finding and a potential area for optimization.

### Collection: `OpenStorage`

-   **Purpose**: A generic key-value store.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('6911fe0480292a620fd27348')",
      "key": "oji_system_prompt_v1",
      "value": "...",
      "expires_at": null
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "expires_at": 1 }, "expireAfterSeconds": 0 },
        { "key": { "key": 1 }, "unique": true }
    ]
    ```
-   **Analysis**: A flexible collection with a unique key constraint and a TTL index that can be set on a per-document basis.

### Collection: `PersonalityTraits`

-   **Purpose**: Defines the AI's personality characteristics.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('6913076efc07e1a7300db0a4')",
      "trait": "Empathy",
      "level": 0.8,
      "example": "Reflects user tone when conversing.",
      "context": "Chat interactions"
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "trait": 1 }, "unique": true }
    ]
    ```
-   **Analysis**: Ensures that each personality trait is unique.

### Collection: `ProceduralMemories`

-   **Purpose**: Stores step-by-step instructions for tasks.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('691307e8fc07e1a7300db0ad')",
      "name": "Vector Search",
      "trigger": "Agent receives retrieval request",
      "steps": [ "...", "..." ],
      "success_rate": 1
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "success_rate": -1 } }
    ]
    ```
-   **Analysis**: Can be queried to find the most successful procedures.

### Collection: `Projects`

-   **Purpose**: Core collection for project management.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('690b723befaa78fcbfdd35a5')",
      "name": "Crypto trading",
      "project_id": "Crypto_trading_1762512993_4",
      "status": "active",
      "importance": 0.98,
      "embedding": [ -0.0395, ... ]
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "project_id": 1 }, "unique": true },
        { "key": { "status": 1 } },
        { "key": { "importance": -1 } }
    ]
    ```
-   **Analysis**: A central and heavily indexed collection. It also contains an `embedding` field but lacks a vector index.

### Collections: `ProjectFiles`, `ProjectMilestones`, `ProjectTasks`

-   **Purpose**: Manage files, milestones, and tasks related to the `Projects` collection.
-   **Schema**: These collections were empty.
-   **Indexes**: All are indexed on `project_id` to link back to the parent project. `ProjectTasks` has additional indexes for status and due date, and a unique compound key on `(project_id, task_id)`.

### Collection: `QueryAnalysis`

-   **Purpose**: Logs incoming queries and how they were handled.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('69130ac9fc07e1a7300db0bd')",
      "query": "Add a new Atlas sustainability milestone",
      "intent": "Insert_ProjectMilestone",
      "entities": [ "Atlas", "sustainability", "milestone" ],
      "timestamp": "2025-11-11T08:05:00Z"
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "intent": 1 } }
    ]
    ```
-   **Analysis**: Allows for efficient searching by classified intent.

### Collection: `ReflectionsInsights`

-   **Purpose**: Stores metacognitive insights generated by the AI about its own performance.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('69130a87fc07e1a7300db0b7')",
      "insight": "I often insert without checking for duplicate project_id. Add validation step.",
      "strength": 0.85,
      "generated_at": "2025-11-11T08:10:00Z"
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "strength": -1 } },
        { "key": { "generated_at": -1 } }
    ]
    ```
-   **Analysis**: Indexed to retrieve the strongest or most recent insights.

### Collection: `SemanticMemories`

-   **Purpose**: Core memory collection for storing semantic facts.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('690dd6dcb59e1cae472adc25')",
      "fact": "Rapture: A feeling of intense pleasure or joy...",
      "category": "emotion",
      "confidence": 1,
      "embedding": [ 0.0081, ... ]
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "category": 1 } }
    ]
    ```
-   **Analysis**: Like `KnowledgeMemories` and `Projects`, this collection is designed for vector search but is missing a vector index. This is a recurring theme and a major point of potential improvement.

### Collection: `ShortTermMemory`

-   **Purpose**: Holds temporary data for a specific session.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('69130a65fc07e1a7300db0b4')",
      "session_id": "db-agent-20251111-1",
      "key": "last_operation",
      "value": { ... },
      "expires_at": "2025-11-11T09:10:00Z"
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "expires_at": 1 }, "expireAfterSeconds": 0 },
        { "key": { "session_id": 1 }, "unique": true }
    ]
    ```
-   **Analysis**: A well-designed collection for managing session state with automatic expiration.

### Collection: `VectorMemoryChunks`

-   **Purpose**: Stores chunks of text from larger documents for vector retrieval.
-   **Schema**:
    ```json
    {
      "_id": "ObjectId('6921c5613254d43ee84ffc7e')",
      "text": "I wake up every day before 6:30...",
      "source": "morning_routine",
      "category": "habits",
      "metadata": { "importance": "high", "person": "Kaje" }
    }
    ```
-   **Indexes**:
    ```json
    [
        { "key": { "_id": 1 } },
        { "key": { "metadata.project": 1 } },
        { "key": { "metadata.type": 1 } }
    ]
    ```
-   **Analysis**: Indexes on metadata suggest a "filter-then-search" pattern for vector queries. It is also missing an explicit vector index.

---

## Oji-AI Database

This database appears to be a prototype or legacy system. All collections **only** have the default `_id` index and lack any optimization.

-   `0. N8N Chat Histories`
-   `0A. [Open storage]`
-   `1A. Emotional States`
-   `1B. Main Activities`
-   `1C. Activity Log`
-   `2A. Personality Records`
-   `2B. Insights`
-   `3. Query Collection & Analysis`
-   `4. Logs/Reflection/Memories`
-   `ChatHistories`

The schema of these collections appears to be an early version of what is now in `OjiDB`.
