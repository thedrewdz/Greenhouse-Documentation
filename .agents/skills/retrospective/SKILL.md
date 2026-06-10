---
name: retrospective
description: Use this skill when running retrospective agent work after QA or delivery, including promoting implementation artifacts into docs, validating templates, updating canonical spec status, identifying systemic failures, and applying durable guardrail updates.
---

# Retrospective Skill

Convert recurring delivery issues into durable documentation and process improvements.

Used by custom agent: [../../../.codex/agents/retrospective-agent.toml](../../../.codex/agents/retrospective-agent.toml)

## Output Artifact Contract

- In implementation repositories, consume generated artifacts from `.agent-output/specs/<spec-name>/`.
- Copy approved artifacts into `specs/<spec-name>/` in this docs repository.
- Use templates from this docs repository as the source format for generated and promoted artifacts.
- Update canonical docs status in `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
- Read status from `.agent-output/specs/<spec-name>/spec-status.md`.
- If an expected artifact is missing or not required, create a placeholder artifact with `Not required` and a reason before promotion decisions.

## Workflow

1. Pull latest remote changes for both docs and implementation repos with `git pull --ff-only` and stop on conflicts.
2. Identify the repository where the work was completed.
3. Check `.agent-output/specs/<spec-name>/` in that repository before commencing.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Read canonical status from `specs/<spec-name>/status.md`.
6. Continue only when execution status is `complete` or `blocked` after QA.
7. If execution status is not eligible, stop and emit a handoff failure with required upstream role and reason.
8. If execution status is `complete`, confirm the implemented changes were delivered through a pull request and that the pull request was merged to the implementation repository `main` branch.
9. If PR traceability or merge-to-main confirmation is missing for a `complete` spec, set execution status to `blocked` with rationale and required follow-up.
10. Consolidate review, QA, and implementation findings.
11. Consolidate test findings and all append-only documentation feedback items across repeated implementation loops.
12. Identify repeated or systemic failure patterns.
13. Import candidate artifacts from `.agent-output/specs/<spec-name>/` in the implementation repository into the retrospective workspace for evaluation.
14. Validate each artifact against corresponding templates.
15. Copy approved artifacts into `specs/<spec-name>/` in this docs repository.
16. Create or update `specs/<spec-name>/promotion-log.md` from `templates/promotion-log.md`.
17. Mark each candidate artifact as `promoted`, `rejected`, or `deferred` with rationale.
18. Update canonical docs status in `specs/<spec-name>/status.md`: set `complete` when execution status is complete and PR merge-to-main is confirmed; set `blocked` when unresolved retrospective blockers remain.
19. Append canonical status history entries with rationale.
20. Update other existing documents in `specs/<spec-name>/` when needed to preserve consistency after promotion.
21. Propose and apply guardrail updates needed in specs, skills, templates, or workflow docs.
22. Document rationale and expected prevention effect.
23. Define follow-up actions.
24. If retrospective resolves documentation/process blockers, set execution status from `blocked` to `new` with rationale for Documentation Agent follow-up, then append Status History in `spec-status.md`.

## Quality Gate

- Changes are reusable, not ad hoc.
- Guardrail updates are traceable to real findings.
- Follow-up actions are specific.
- Promotion decisions are traceable per artifact.
- All implementation, test, review, QA, and documentation feedback artifacts across repeated loops are considered.
- Dossier updates in `specs/<spec-name>/` remain template-conformant.
- Canonical status in `specs/<spec-name>/status.md` is updated with traceable history.
- Any status change made during retrospective is explicit and recorded in `spec-status.md` Status History.
- For `complete` specs, PR linkage and merge-to-main confirmation are recorded.
