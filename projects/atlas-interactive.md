# Atlas-Interactive

## Status

Active coordination and interface layer within the Atlas ecosystem, now operating as both a live Oji environment and a structured project notebook.

## Current Role

- Core coordination environment for Atlas.
- Browser-facing interface through which Oji operates and supports project work.
- Central notebook and development ledger for structured project-state tracking.

## Live Interface

- Oji chat is deployed at `oji.atlas-interactive.com`.
- Atlas-Interactive is used as the primary operational interface for browser-based Oji interactions.

## Core Architecture

- Conversational workflow uses a 3-agent structure:
  - Query Analysis
  - Response
  - Reflection
- Agent calls are routed through OpenRouter with a split model strategy:
  - Query Analysis -> Grok
  - Response -> ChatGPT
  - Reflection -> Gemini
- Memory backend persists:
  - interaction turns
  - query analysis events
  - response events
  - reflection events
  - reflection edges
  - canonical memory nodes
  - memory versions
  - memory vectors

## Current Utility

- Provides project-state visibility across the Atlas ecosystem.
- Supports structured documentation of confirmed developments.
- Connects operational memory and project-ledger workflows in one environment.

## Open Operational Details

- Notebook update rules and review boundaries should remain explicit as Oji writes more project updates.
- Additional detail may still be needed on repo access patterns, maintenance ownership, and long-term notebook conventions.

## Last Updated

2026-03-21 UTC
