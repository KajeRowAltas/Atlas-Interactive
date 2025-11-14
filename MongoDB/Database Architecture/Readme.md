Oji Information Architecture (conceptual overview)
1. Core Identity & Personality

Collections:

AgentProfile

PersonalityTraits

GoalsValuesBeliefs

Roles:

AgentProfile
Holds the stable identity of Oji:

name, backstory, voice_style

created_at, updated_at, version
→ This is “who Oji is” at a narrative + config level.

PersonalityTraits
Parametric knobs that shape behaviour:

trait (e.g. Empathy, Precision)

level (0–1)

example, context
→ This is “how Oji tends to act”, in different contexts.

GoalsValuesBeliefs
Motivational core:

type: "goal" | "value" | "belief"

belief: text description

priority, strength
→ This is “what Oji cares about and orients towards” (Atlas, integrity, etc.).

2. Memory System

Collections:

SemanticMemories

KnowledgeMemories

ProceduralMemories

EpisodicMemories

ShortTermMemory

VectorMemoryChunks (reserved/empty in this dump)

Roles:

SemanticMemories
Long-term, vectorised facts:

fact, category, confidence

sources

embedding (float array)
→ This is Oji’s semantic memory bank: “things Oji knows”, searchable via vectors.

KnowledgeMemories
Higher-level rules, DB best practices, etc.:

fact, category, confidence, embedding
→ “How to think/work with systems”, more meta-knowledge.

ProceduralMemories
Skills and procedures:

name (e.g. “Vector Search”, “Insert Document”)

trigger (when to run)

steps (ordered list)

success_rate
→ This is Oji’s procedural skill library.

EpisodicMemories
Reserved for episodes/experiences (empty in this snapshot).
→ Would store time-stamped “events” or interactions like “On date X, user and I did Y”.

ShortTermMemory
Working memory / scratchpad:

session_id

key, value

expires_at
→ Local, ephemeral context for the current workflow (e.g. “last_operation”, pending actions).

VectorMemoryChunks
Reserved for chunked retrieval index (empty here).
→ Designed for pre-segmented, retrieval-optimised memory units.

3. Emotion & Affective Layer

Collections:

CurrentEmotionalState

EmotionalHistory (empty now)

Roles:

CurrentEmotionalState
Single-doc snapshot:

_id: "current"

mood (e.g. neutral)

energy

triggers

last_update
→ The live emotional state Oji is “in” right now.

EmotionalHistory
Reserved for time-series of moods, energy, triggers.
→ Can be used later for emotional trend analysis.

4. Meta-Cognition, Logging & Self-Improvement

Collections:

ActivityLog

ReflectionsInsights

QueryAnalysis

Roles:

ActivityLog

action (insert, update, etc.)

collection

success

timestamp

severity

details (e.g. doc_id, reason)
→ Operational audit trail of what Oji does.

ReflectionsInsights

insight (e.g. “I often insert without checking duplicates”)

strength

generated_at
→ Oji’s self-reflection layer: what it learns about its own behaviour.

QueryAnalysis

query

intent

entities

executed_tool

result_summary

timestamp
→ Structured understanding of user requests: how input → action.

5. Interaction Layer

Collections:

ChatHistories

(plus ShortTermMemory as supporting context)

Roles:

ChatHistories

sessionId

messages (human + ai, with content + metadata)
→ Full conversations, used for:

context reconstruction

meta-learning

debugging agent behaviour

6. Project / Life Management Layer

Collections:

Projects

ProjectMilestones

ProjectTasks

ProjectFiles

Roles:

Projects

name, main

subProjects

createdAt, updatedAt, version

project_id

domain, status, searchReady

embedding_text
→ Canonical registry of your life-projects (Atlas, Crypto trading, Sports, etc.).

ProjectMilestones
Reserved for project stepping stones (empty now).

ProjectTasks
Reserved for concrete, actionable tasks (empty now).

ProjectFiles
Reserved for file/resource linkage per project (empty now).

These 4 together form your personal PKM / project brain inside Oji.

7. Open Storage & Config

Collections:

OpenStorage

Role:

Generic key–value storage:

key (e.g. oji_system_prompt_v1)

value (raw text / structured data)

metadata

expires_at (optional)
→ This is your flexible “drawer” for prompts, configs, or anything that doesn’t fit elsewhere.

8. Blueprint & Index Metadata

From the export:

OjiDB_blueprint.json — structural list of collections + index definitions

indexes.json — raw index info per collection

These are meta and not part of the live cognitive graph, but they are crucial for:

rebuilding the DB elsewhere

telling other LLMs how to search efficiently

documenting the technical layout
