# Atlas Interactive Monorepo

This repository organizes the original Atlas deliverables, MongoDB exports, and related initiatives into a consistent, scalable layout. Each initiative lives under `Projects/` with shared database resources under `Shared_Resources/`.

## Project directories
- [Projects/Atlas](Projects/Atlas/README.md) — Atlas VR experience assets, including the Oji chat UI, prompt collections, and research notes.
- [Projects/De_Frisdrank_Fabriek](Projects/De_Frisdrank_Fabriek/README.md) — Beverage factory automation and operational modeling.
- [Projects/Crypto](Projects/Crypto/README.md) — Trading strategy workspace and supporting documentation.
- [Projects/Sports](Projects/Sports/README.md) — Sports analytics and activity tracking backlog.
- [Projects/Nutrition](Projects/Nutrition/README.md) — Nutrition tracking and health-focused workflows.
- [Projects/Gaming](Projects/Gaming/README.md) — Video game design, prototyping, and experimentation.
- [Projects/_review_needed](Projects/_review_needed/README.md) — Items awaiting proper placement (e.g., legacy CI/CD workflows) preserved for review.

## Shared resources
- [Shared_Resources/Mongodb](Shared_Resources/Mongodb/Readme.md) — OjiDB architecture and project definitions exported from MongoDB, including collection JSON dumps and index metadata.

## Conventions
- Keep project-specific assets inside their project directory; introduce feature folders (`ui/`, `docs/`, `data/`, etc.) as needed.
- Reuse common assets by linking to `Shared_Resources/` rather than duplicating files across projects.
- When adding new initiatives, create a project directory with a `README.md` and `LICENSE` to describe scope, structure, and usage.
