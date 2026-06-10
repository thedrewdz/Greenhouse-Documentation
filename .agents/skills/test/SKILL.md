---
name: test
description: Use this skill when running test agent work after implementation, closing coverage gaps against accepted feature behavior, mapping acceptance criteria to tests, validating happy and negative paths, producing test-gap reports, and updating execution status.
---

# Test Skill

Close test coverage gaps against accepted feature behavior.

Used by custom agent: [../../../.codex/agents/test-agent.toml](../../../.codex/agents/test-agent.toml)

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If an output artifact is not required for the current pass, still create it with `Not required` and a reason.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Check `.agent-output/specs/<spec-name>/` before commencing.
3. Read `.agent-output/specs/<spec-name>/implementation-plan.md` to identify the source branch and expected scope.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Continue only when status is `ready-for-test` or `test-in-progress`.
6. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
7. On accepted entry, set status to `test-in-progress` and append Status History in `spec-status.md`.
8. Map acceptance criteria to concrete tests.
9. Validate happy, negative, and degraded paths.
10. Add or update tests to cover gaps.
11. Create or update `.agent-output/specs/<spec-name>/test-gap-report.md` from `templates/test-gap-report.md`.
12. Record remaining untested risks and required follow-ups.
13. If failures or coverage gaps are fixable by implementation work, record concrete implementation feedback and set status to `ready-for-implementation`.
14. If critical acceptance criteria have test evidence, set status to `ready-for-review`.
15. If tests cannot be completed because docs, acceptance criteria, prerequisites, or process state are missing or contradictory, append a documentation feedback item and set status to `blocked`.
16. Append Status History in `spec-status.md`.
17. Commit and push resulting changes so downstream roles can access updated artifacts.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Negative-path behavior is covered where relevant.
- Remaining risks are explicit.
- `test-gap-report.md` exists and maps findings to acceptance criteria.
- Fixable test failures or coverage gaps return status to `ready-for-implementation`.
- True documentation, prerequisite, or process blockers set status to `blocked` with a documentation feedback item.
- Status transition is recorded in `spec-status.md`: `ready-for-review`, `ready-for-implementation`, or `blocked`.
- Output artifacts are available upstream via commit and push.
