# Skill: Test Agent

Used by role: [../roles/test-agent.md](../roles/test-agent.md)

## Purpose

Close test coverage gaps against accepted feature behavior.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Read `spec.md` Spec Control status.
2. Entry gate: continue only when status is `ready-for-test` or `test-in-progress`.
3. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
4. On accepted entry, set status to `test-in-progress` and append Status History.
5. Map acceptance criteria to concrete tests.
6. Validate happy, negative, and degraded paths.
7. Add or update tests to cover gaps.
8. Create or update `.agent-output/specs/<spec-name>/test-gap-report.md` from `templates/test-gap-report.md`.
9. Record remaining untested risks and required follow-ups.
10. If critical acceptance criteria have test evidence, set status to `ready-for-review`; otherwise set status to `blocked` with reason and append Status History.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Negative-path behavior is covered where relevant.
- Remaining risks are explicit.
- `test-gap-report.md` exists and maps findings to acceptance criteria.
- `spec.md` status transition is recorded (`ready-for-review` or `blocked`).
