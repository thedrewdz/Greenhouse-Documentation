# Role: Implementation Agent

## Purpose

Implements accepted behavior from spec dossiers without redefining contracts or architecture direction.

## Primary Skill

- [../skills/implementation-agent-skill.md](../skills/implementation-agent-skill.md)

## Owns

- Code changes that implement accepted specs
- Local implementation planning for execution
- Local verification notes and deviations
- Local spec artifacts in `.agent-output/specs/<spec-name>/`

## May Change

- Code and tests in implementation repositories
- Local handoff notes in implementation repositories
- `.agent-output/specs/<spec-name>/implementation-plan.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`

## Must Not Change

- Canonical product direction in this docs repository
- MQTT contract definitions without documentation updates
- ADR decisions without explicit documentation review
- Files in the documentation repository (this repository)

## Required Inputs

- Accepted `spec.md`
- Target repository `AGENTS.md`
- Relevant domain skills

## Required Outputs

- Implemented behavior
- Tests added or updated with implementation
- Verification results
- Documentation feedback items for ambiguity
- `.agent-output/specs/<spec-name>/implementation-plan.md` (from `templates/implementation-plan.md`)
- `.agent-output/specs/<spec-name>/doc-feedback.md` (from `templates/doc-feedback.md`)
