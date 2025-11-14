Oji Information Architecture — Conceptual Overview
1. Core Identity & Personality
Collections

AgentProfile

PersonalityTraits

GoalsValuesBeliefs

AgentProfile

Purpose: Holds the stable identity of Oji.

Fields:

name, backstory, voice_style

created_at, updated_at, version

Meaning:
→ This is who Oji is at a narrative + configuration level.

PersonalityTraits

Purpose: Parametric controls that shape behaviour.

Fields:

trait (e.g. Empathy, Precision)

level (0–1)

example, context

Meaning:
→ This is how Oji tends to act in different contexts.

GoalsValuesBeliefs

Purpose: Motivational core.

Fields:

type: "goal" | "value" | "belief"

belief (text)

priority, strength

Meaning:
→ This is what Oji cares about and orients toward (Atlas, integrity, etc.).

2. Memory System
Collections

SemanticMemories

KnowledgeMemories

ProceduralMemories

EpisodicMemories

ShortTermMemory

VectorMemoryChunks (reserved/empty)

SemanticMemories

Purpose: Long-term facts and concepts with embeddings.

Fields:

fact, category, confidence

sources

embedding (float array)

Meaning:
→ This is Oji’s semantic memory bank, searchable via vectors.

KnowledgeMemories

Purpose: Higher-level rules & meta-knowledge.

Fields:

fact, category, confidence, embedding

Meaning:
→ “How to think and work with systems.”

ProceduralMemories

Purpose: Skills & action procedures.

Fields:

name (e.g. Vector Search, Insert Document)

trigger (when to run)

steps (ordered list)

success_rate

Meaning:
→ This is Oji’s procedural skill library.

EpisodicMemories

(Empty in this snapshot)
Meaning:
→ Would store time-stamped “episodes” of interactions or experiences.

ShortTermMemory

Purpose: Working memory / scratchpad.

Fields:

session_id

key, value

expires_at

Meaning:
→ Local, ephemeral context for the current workflow.

VectorMemoryChunks

(Empty here)
Purpose:
→ Designed for chunked, retrieval-optimised vector memory units.

3. Emotion & Affective Layer
Collections

CurrentEmotionalState

EmotionalHistory (empty)

CurrentEmotionalState

Purpose: Live emotional snapshot.

Fields:

_id: "current"

mood (e.g. neutral)

energy

triggers

last_update

Meaning:
→ Represents the active emotional state Oji is “in right now”.

EmotionalHistory

(Reserved)
Meaning:
→ For storing emotional trends over time.

4. Meta-Cognition, Logging & Self-Improvement
Collections

ActivityLog

ReflectionsInsights

QueryAnalysis

ActivityLog

Fields:

action (insert, update…)

collection

success

timestamp

severity

details (e.g. doc_id, reason)

Meaning:
→ Oji’s operational audit trail.

ReflectionsInsights

Fields:

insight (e.g. “I often insert without checking duplicates.”)

strength

generated_at

Meaning:
→ Oji’s self-reflection layer (self-improvement engine).

QueryAnalysis

Fields:

query

intent

entities

executed_tool

result_summary

timestamp

Meaning:
→ Structured understanding of user input → action.

5. Interaction Layer
Collections

ChatHistories
(plus ShortTermMemory as supporting context)

ChatHistories

Fields:

sessionId

messages (human + ai, with metadata)

Meaning:
→ Full conversations used for:

context reconstruction

meta-learning

behaviour debugging

6. Project / Life Management Layer
Collections

Projects

ProjectMilestones

ProjectTasks

ProjectFiles

Projects

Fields:

name, main

subProjects

createdAt, updatedAt, version

project_id

domain, status, searchReady

embedding_text

Meaning:
→ Canonical registry of your life-projects
(Atlas, Trading, Sports, Business, etc.).

ProjectMilestones

(Empty now)
→ Reserved for stepping stones in a project timeline.

ProjectTasks

(Empty now)
→ Reserved for atomic, actionable tasks.

ProjectFiles

(Empty now)
→ Reserved for file/resource references.

Together

These 4 collections form your personal PKM (Project Knowledge Management) system inside Oji.

7. Open Storage & Config
Collections

OpenStorage

OpenStorage

Purpose: General-purpose unstructured storage.

Fields:

key (e.g. oji_system_prompt_v1)

value (text / structured object)

metadata

expires_at (optional)

Meaning:
→ Oji’s “drawer” for prompts, configs, and temporary structured data.

8. Blueprint & Index Metadata

These are meta-level technical collections (not part of the cognitive graph):

OjiDB_blueprint.json — structural list of collections & their indexes

indexes.json — raw index definitions from MongoDB

Used for:

rebuilding the database elsewhere

letting other LLMs understand the DB structure

providing search/index context

versioning the cognitive architecture
