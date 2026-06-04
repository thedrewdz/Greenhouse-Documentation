# Skill: QA Agent

Used by role: [../roles/qa-agent.md](../roles/qa-agent.md)

## Purpose

Validate scenario-level behavior and release readiness.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If an output artifact is not required, still create it with `Not required` and a reason.

## Workflow

1. Pull latest remote changes (`git pull --ff-only`) and stop on conflicts.
2. Check `.agent-output/specs/<spec-name>/` before commencing.
3. Read `.agent-output/specs/<spec-name>/implementation-plan.md` for branch and scope context.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Entry gate: continue only when status is `ready-for-qa` or `qa-in-progress`.
6. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
7. On accepted entry, set status to `qa-in-progress` and append Status History in `spec-status.md`.
8. Build scenario checklist from `spec.md` acceptance criteria.
9. Execute scenario validation.
10. Record defects with severity and reproducibility.
11. Record mismatches between observed behavior and docs.
12. Create or update `.agent-output/specs/<spec-name>/qa-report.md` from `templates/qa-report.md`.
13. Provide release recommendation.
14. Set final status based on recommendation and critical defects:
15. `Go` -> `complete`
16. `Conditional-Go` -> `blocked`
17. `No-Go` -> `ready-for-implementation`
18. Append Status History with rationale in `spec-status.md`.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible.
- Recommendation is evidence-based.
- `qa-report.md` is complete and uses the template structure.
- Final status transition is recorded in `spec-status.md`.
