# Skill: Retrospective Agent

Used by role: [../roles/retrospective-agent.md](../roles/retrospective-agent.md)

## Purpose

Convert recurring delivery issues into durable documentation and process improvements.

## Output Artifact Contract

- In implementation repositories, consume generated artifacts from `.agent-output/specs/<spec-name>/`.
- Promote approved artifacts into `specs/<spec-name>/` in this docs repository.
- Use templates from this docs repository as the source format for generated and promoted artifacts.

## Workflow

1. Consolidate review, QA, and implementation findings.
2. Identify repeated or systemic failure patterns.
3. Collect candidate artifacts from `.agent-output/specs/<spec-name>/`.
4. Validate each artifact against corresponding templates.
5. Copy approved artifacts into `specs/<spec-name>/` in this docs repository.
6. Create or update `specs/<spec-name>/promotion-log.md` from `templates/promotion-log.md`.
7. Mark each candidate artifact as `promoted`, `rejected`, or `deferred` with rationale.
8. Update other existing documents in `specs/<spec-name>/` when needed to preserve consistency after promotion.
9. Propose and apply guardrail updates needed in specs, skills, templates, or workflow docs.
10. Document rationale and expected prevention effect.
11. Define follow-up actions.

## Quality Gate

- Changes are reusable, not ad hoc.
- Guardrail updates are traceable to real findings.
- Follow-up actions are specific.
- Promotion decisions are traceable per artifact.
- Dossier updates in `specs/<spec-name>/` remain template-conformant.
