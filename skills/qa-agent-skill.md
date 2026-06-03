# Skill: QA Agent

Used by role: [../roles/qa-agent.md](../roles/qa-agent.md)

## Purpose

Validate scenario-level behavior and release readiness.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Read `spec.md` Spec Control status.
2. Entry gate: continue only when status is `ready-for-qa` or `qa-in-progress`.
3. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
4. On accepted entry, set status to `qa-in-progress` and append Status History.
5. Build scenario checklist from `spec.md` acceptance criteria.
6. Execute scenario validation.
7. Record defects with severity and reproducibility.
8. Record mismatches between observed behavior and docs.
9. Create or update `.agent-output/specs/<spec-name>/qa-report.md` from `templates/qa-report.md`.
10. Provide release recommendation.
11. Set final status based on recommendation and critical defects:
12. `Go` -> `complete`
13. `Conditional-Go` -> `blocked`
14. `No-Go` -> `ready-for-implementation`
15. Append Status History with rationale.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible.
- Recommendation is evidence-based.
- `qa-report.md` is complete and uses the template structure.
- `spec.md` final status transition is recorded.
