# AGENTS

## Purpose

This repository is the central documentation hub for the Greenhouse platform.

It documents architecture, workflows, contracts, and intended outcomes for all platform domains.

This file is the canonical, neutral agent policy for this repository.

## Scope Boundaries

- This repo is documentation-only.
- Prioritize clarity, consistency, and implementation-readiness in all docs.
- Keep durable guidance in canonical docs, not session notes.
- Do not couple repository policy to a single consumer implementation.
- Keep terminology stable across Main Unit and Edge Unit documentation.
- Preserve local-first and MQTT-centered platform assumptions.
- Avoid cloud-first assumptions in Phase 1 docs unless explicitly marked as future work.

## Instruction Precedence

Use this precedence order when instructions overlap:

1. AGENTS.md (this file)
2. CONTEXT.md
3. DOCS-MAP.md
4. .agents/skills/README.md and .agents/skills/*/SKILL.md
5. workflows/*.md
6. .codex/agents/*.toml
7. adr/*.md
8. Canonical docs for touched areas
9. agent-handoff.md (session scratchpad only)

If guidance conflicts, follow the highest-precedence source.

## Incremental Documentation Loading

Always read:

- CONTEXT.md
- DOCS-MAP.md
- adr/README.md

Then use DOCS-MAP.md to choose the smallest relevant set of architecture, workflow, spec, template, skill, and agent files for the task.

Read ADR files relevant to touched areas:

- adr/*.md

Read area-specific docs only when applicable.

## Repository Rules

- Keep docs root-based. Do not introduce a top-level docs folder.
- Preserve stable contracts and terminology across domains.
- Keep onboarding and setup flows clearly separated:
	- setup is Main Unit first-run flow
	- onboarding/reconfiguration are Edge Unit flows
- Keep MQTT payload examples valid JSON.
- Update cross-references when moving or renaming docs.

## Domain Docs Workflow

Use this workflow for documentation changes:

1. Read CONTEXT.md and relevant ADRs first.
2. Use DOCS-MAP.md to identify touched contracts, journeys, and specs.
3. Read the touched contracts/journeys/specs end-to-end.
4. If direction is ambiguous, use .agents/skills/documentation/SKILL.md Plan Interrogation Method and ask one question at a time with a recommended answer.
5. Resolve terminology conflicts before adding new content.
6. Update related docs in the same pass to prevent drift.
7. Keep examples syntactically valid and copy-safe.

## Naming Rules

- Use Main Unit for the local system authority.
- Use Edge Unit for ESP32-connected nodes.
- Do not use legacy aliases for Main Unit or Edge Unit.
- Use setup only for Main Unit first-run flow.
- Use onboarding or reconfiguration only for Edge Unit flows.

## Required Journey Separation

- Main Unit Setup Flow: first-run network and general configuration.
- Network Recovery Flow: reconnect a configured Main Unit.
- Edge Unit Onboarding Flow: first-time provisioning of an unprovisioned Edge Unit.
- Edge Unit Reconfiguration Flow: topology or mapping updates for a known Edge Unit.

## Quality Gates

Before finalizing doc changes, verify:

1. No contradictory terms or flow definitions across docs.
2. Contracts, examples, and field names match canonical docs.
3. MQTT payload examples remain valid JSON.
4. Setup vs onboarding/reconfiguration separation remains explicit.
5. ADR digest and ADR files are consistent.
6. Deferred items are clearly marked and not mixed with current scope.

## Handoff Files

agent-handoff.md is a repo-maintainer session scratchpad only.

Do not use it as domain guidance and do not duplicate durable policy there.

