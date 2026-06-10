---
name: qa
description: Use this skill when performing QA agent work or scenario-level validation after review, including acceptance criteria checks, defect recording, release readiness, spec mismatch reporting, QA artifacts, and execution status transitions.
---

# QA Skill

Validate scenario-level behavior and release readiness.

Used by custom agent: [../../../.codex/agents/qa-agent.toml](../../../.codex/agents/qa-agent.toml)

For standalone QA evaluation guidance, read [references/qa-evaluation.md](references/qa-evaluation.md) when the work requires scenario checklist design or release-readiness framing beyond the role workflow.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If an output artifact is not required, still create it with `Not required` and a reason.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Check `.agent-output/specs/<spec-name>/` before commencing.
3. Read `.agent-output/specs/<spec-name>/implementation-plan.md` for branch and scope context.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Continue only when status is `ready-for-qa` or `qa-in-progress`.
6. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
7. On accepted entry, set status to `qa-in-progress` and append Status History in `spec-status.md`.
8. Build scenario checklist from `spec.md` acceptance criteria.
9. Execute scenario validation.
10. Record defects with severity and reproducibility.
11. Record mismatches between observed behavior and docs.
12. Create or update `.agent-output/specs/<spec-name>/qa-report.md` from `templates/qa-report.md`.
13. Provide release recommendation.
14. Set final status based on recommendation and root cause: `Go` to `complete`; `Conditional-Go` or `No-Go` to `ready-for-implementation` when issues are fixable by implementation work; `blocked` only when QA cannot safely continue because docs, acceptance criteria, prerequisites, or process state are unresolved.
15. Append documentation feedback items for spec mismatches, ambiguous acceptance criteria, or missing skill/workflow guidance.
16. Append Status History with rationale in `spec-status.md`.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible.
- Recommendation is evidence-based.
- `qa-report.md` is complete and uses the template structure.
- Fixable defects return status to `ready-for-implementation`.
- True documentation, prerequisite, or process blockers set status to `blocked` with a documentation feedback item.
- Final status transition is recorded in `spec-status.md`.
