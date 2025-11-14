OjiDB — Information Architecture Overview

OjiDB is the cognitive database that powers Oji, a personalized AI agent.
It contains the full architecture for identity, personality, memory, emotion, self-reflection, project management, and knowledge retrieval.

This document describes the complete conceptual layout of OjiDB V1.

📌 Table of Contents

Core Identity & Personality

Memory System

Emotion & Affective Layer

Meta-Cognition, Logging & Self-Improvement

Interaction Layer

Project / Life Management Layer

Open Storage & Config

Blueprint & Index Metadata

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

This defines who Oji is at a narrative and configuration level.

PersonalityTraits

Purpose: Parametric personality controls.

Fields:

trait (e.g. Empathy, Precision)

level (0–1)

example, context

Meaning:

This defines how Oji behaves across different contexts.

GoalsValuesBeliefs

Purpose: Motivational and value-orientation core.

Fields:

type: "goal" | "value" | "belief"

belief

priority, strength

Meaning:

This defines what Oji cares about and orients toward.

2. Memory System
Collections

SemanticMemories

KnowledgeMemories

ProceduralMemories

EpisodicMemories

ShortTermMemory

VectorMemoryChunks (reserved/empty)

SemanticMemories

Purpose: Long-term factual and conceptual memory.

Fields:

fact, category, confidence

sources

embedding (float array)

Meaning:

Oji’s semantic knowledge base, fully vector-searchable.

KnowledgeMemories

Purpose: Higher-level rules & meta-knowledge.

Fields:

fact, category, confidence, embedding

Meaning:

Encodes “how to think” and best practices.

ProceduralMemories

Purpose: Actionable skills and processes.

Fields:

name (e.g. Vector Search, Insert Document)

trigger

steps

success_rate

Meaning:

Oji’s skill library (procedural knowledge).

EpisodicMemories

(Empty in V1)

Meaning:

Intended for storing time-stamped personal experiences.

ShortTermMemory

Purpose: Working memory / scratchpad.

Fields:

session_id

key, value

expires_at

Meaning:

Short-lived contextual information for the current interaction.

VectorMemoryChunks

(Empty in V1)

Meaning:

Reserved for chunked embedding storage optimised for retrieval.

3. Emotion & Affective Layer
Collections

CurrentEmotionalState

EmotionalHistory (empty)

CurrentEmotionalState

Purpose: Dynamic emotional snapshot.

Fields:

_id: "current"

mood, energy, triggers

last_update

Meaning:

Tracks the emotional “state” Oji is in right now.

EmotionalHistory

(Reserved)

Meaning:

Intended for storing long-term emotional trends.

4. Meta-Cognition, Logging & Self-Improvement
Collections

ActivityLog

ReflectionsInsights

QueryAnalysis

ActivityLog

Purpose: Operational audit trail.

Fields:

action, collection, success

timestamp, severity

details (e.g. doc_id, reason)

Meaning:

Tracks all operations Oji performs.

ReflectionsInsights

Purpose: Long-term self-reflection engine.

Fields:

insight

strength

generated_at

Meaning:

This is how Oji learns about itself and improves over time.

QueryAnalysis

Purpose: Parsed structure of user queries.

Fields:

query

intent

entities

executed_tool

result_summary

timestamp

Meaning:

Shows how user input → internal reasoning → action.

5. Interaction Layer
Collections

ChatHistories

ChatHistories

Purpose: Conversation logs.

Fields:

sessionId

messages (human + ai with metadata)

Meaning:

Supports:

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

Purpose: High-level personal project registry.

Fields:

name, main

subProjects

createdAt, updatedAt, version

project_id

domain, status, searchReady

embedding_text

Meaning:

Oji’s project intelligence system (Atlas, Trading, Training, etc.).

ProjectMilestones

(Reserved)

Milestones for long-term project tracking.

ProjectTasks

(Reserved)

Atomic, actionable tasks inside each project.

ProjectFiles

(Reserved)

Project-related resources & file references.

7. Open Storage & Config
Collections

OpenStorage

OpenStorage

Purpose: Flexible unstructured storage.

Fields:

key

value (text / structured data)

metadata

expires_at (optional)

Meaning:

Oji’s “drawer” for prompts, configs, documents, and temporary data.

8. Blueprint & Index Metadata

From the export:

OjiDB_blueprint.json

indexes.json

These files are meta-level and not part of the cognitive graph.

Used for:

database rebuilding

search/index mapping

revealing structure to other LLMs

maintaining version control over the architecture

🧠 About OjiDB

OjiDB is designed as a cognitive architecture, not just a data store.
Its structure mirrors functional components of memory, identity, skill acquisition, emotional state, and self-improvement.

Future versions (V2+) will extend:

episodic memory

emotion tracking

project intelligence

vector memory chunking

compound index optimization

higher-order behavioural models
