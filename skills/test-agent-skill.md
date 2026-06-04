# Skill: Test Agent

Used by role: [../roles/test-agent.md](../roles/test-agent.md)

## Purpose

Close test coverage gaps against accepted feature behavior.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If an output artifact is not required for the current pass, still create it with `Not required` and a reason.

## Workflow

1. Pull latest remote changes (`git pull --ff-only`) and stop on conflicts.
2. Check `.agent-output/specs/<spec-name>/` before commencing.
3. Read `.agent-output/specs/<spec-name>/implementation-plan.md` to identify the source branch and expected scope.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Entry gate: continue only when status is `ready-for-test` or `test-in-progress`.
6. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
7. On accepted entry, set status to `test-in-progress` and append Status History in `spec-status.md`.
8. Map acceptance criteria to concrete tests.
9. Validate happy, negative, and degraded paths.
10. Add or update tests to cover gaps.
11. Create or update `.agent-output/specs/<spec-name>/test-gap-report.md` from `templates/test-gap-report.md`.
12. Record remaining untested risks and required follow-ups.
13. If critical acceptance criteria have test evidence, set status to `ready-for-review`; otherwise set status to `blocked` with reason and append Status History in `spec-status.md`.
14. Commit and push resulting changes so downstream roles can access updated artifacts.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Negative-path behavior is covered where relevant.
- Remaining risks are explicit.
- `test-gap-report.md` exists and maps findings to acceptance criteria.
- Status transition is recorded in `spec-status.md` (`ready-for-review` or `blocked`).
- Output artifacts are available upstream via commit and push.
