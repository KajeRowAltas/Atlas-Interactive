# Oji Project Status Handoff

## Purpose

This note is a handoff snapshot for a coding agent that needs to continue Oji work without relying on prior chat context.

## Current Live State

- Atlas-Interactive root site is being treated as the informational/dashboard surface.
- `oji.atlas-interactive.com` is the live Oji chat cockpit surface.
- The Oji notebook repo is active and being used as the durable project ledger.
- All canonical n8n workflows are currently inactive.

## Confirmed Working Capabilities

- Core Oji conversation workflow exists with Query Analysis, Response, and Reflection stages.
- Memory ingestion is live and persists interaction, analysis, response, reflection, lineage, and canonical memory artifacts.
- Readonly server adapter exists and is working for approved inspection scope.
- Notebook write control exists and is proven live for constrained proposal/apply behavior.
- Telegram approval is now the first working live approval surface for notebook proposals.
- Approval queue records proposal state and Telegram decisions.
- Adapter Factory exists and can generate inactive readonly adapters through an approval-gated path.
- A generated notebook freshness adapter exists as an inactive generated adapter.
- UI change control path exists separately from readonly inspection.

## Confirmed Approval / Control Model

- Proposal/apply separation exists.
- Notebook proposals can be delivered to Telegram.
- Telegram approve/reject callbacks are now functioning.
- Notebook apply still requires explicit approval plus constrained execution.
- All workflows were shut down after the latest controlled tests.

## Most Recent Completed Milestones

- Structural notebook proposal classification was repaired at the notebook adapter boundary so explicit notebook-structure recommendations no longer have to persist as ordinary `log_entry` proposals.
- Structural proposal `notebook_proposal_mndazpnl_8559c72f` was approved and applied to `projects/de-frisdrank-fabriek.md`.
- That proposal was then pushed to `origin/main`.
- The De Frisdrank Fabriek project ledger now includes an `Active Workstreams` structural section.

## Important Current Caveat

- The upstream main-workflow notebook planner can still emit generic `architecture_update` log-style payloads for notebook-structure prompts.
- The durable fix currently lives in the notebook write adapter, which now reclassifies explicit structure-oriented notebook proposals into structural proposal classes before persistence.
- A workflow-level adjustment-node repair was also attempted and partially corrected, but the reliable live control point is currently the adapter boundary, not the planner alone.

## Current Canonical Workflow Set

- Main conversation workflow: `CxMVkZXFS2MEPfuN`
- Readonly adapter workflow: `Q9Pj4sTf8Lm2VxRa`
- Notebook write control workflow: `N7mK4pLs2Qx8VbJn`
- UI change control workflow: `V8fK2mNa7Qe4LtPs`
- Adapter Factory workflow: `Rf2nK8sLm4Qp7VbX`

## Current Notebook / Approval State

- Notebook structural changes are now possible through proposal-only flow plus Telegram approval.
- Telegram approval queue is operational for notebook proposals.
- Google Chat approval path was prepared but is not the live operator surface right now.

## Recommended Next Steps

- Stabilize upstream notebook planner classification so structural recommendations are recognized before they reach the notebook adapter.
- Build the planned read-only operational state service so Oji can see workflow state, build state, approval state, deploy state, and failure state in one place.
- Extend Telegram approval beyond notebook proposals only after the operational state plane is clearer.
- Keep deployment and broader server actions approval-gated and separate from notebook/UI proposal generation.

## Workflow State At Handoff

- `CxMVkZXFS2MEPfuN`: inactive
- `Q9Pj4sTf8Lm2VxRa`: inactive
- `N7mK4pLs2Qx8VbJn`: inactive
- no active workflow ids reported by `n8n list:workflow --active=true --onlyId`
