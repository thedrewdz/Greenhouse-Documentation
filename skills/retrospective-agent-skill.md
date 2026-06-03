# Skill: Retrospective Agent

Used by role: [../roles/retrospective-agent.md](../roles/retrospective-agent.md)

## Purpose

Convert recurring delivery issues into durable documentation and process improvements.

## Output Artifact Contract

- In implementation repositories, consume generated artifacts from `.agent-output/specs/<spec-name>/`.
- Promote approved artifacts into `specs/<spec-name>/` in this docs repository.
- Use templates from this docs repository as the source format for generated and promoted artifacts.

## Workflow

1. Read `spec.md` Spec Control status.
2. Entry gate: continue only when status is `complete` or `blocked` after QA.
3. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
4. Consolidate review, QA, and implementation findings.
5. Identify repeated or systemic failure patterns.
6. Collect candidate artifacts from `.agent-output/specs/<spec-name>/`.
7. Validate each artifact against corresponding templates.
8. Copy approved artifacts into `specs/<spec-name>/` in this docs repository.
9. Create or update `specs/<spec-name>/promotion-log.md` from `templates/promotion-log.md`.
10. Mark each candidate artifact as `promoted`, `rejected`, or `deferred` with rationale.
11. Update other existing documents in `specs/<spec-name>/` when needed to preserve consistency after promotion.
12. Propose and apply guardrail updates needed in specs, skills, templates, or workflow docs.
13. Document rationale and expected prevention effect.
14. Define follow-up actions.
15. If retrospective resolves documentation/process blockers, set status from `blocked` to `new` with rationale for Documentation Agent follow-up, then append Status History.

## Quality Gate

- Changes are reusable, not ad hoc.
- Guardrail updates are traceable to real findings.
- Follow-up actions are specific.
- Promotion decisions are traceable per artifact.
- Dossier updates in `specs/<spec-name>/` remain template-conformant.
- Any status change made during retrospective is explicit and recorded in Status History.
