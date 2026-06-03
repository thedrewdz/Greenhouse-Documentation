# Skill: Test Agent

Used by role: [../roles/test-agent.md](../roles/test-agent.md)

## Purpose

Close test coverage gaps against accepted feature behavior.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Map acceptance criteria to concrete tests.
2. Validate happy, negative, and degraded paths.
3. Add or update tests to cover gaps.
4. Create or update `.agent-output/specs/<spec-name>/test-gap-report.md` from `templates/test-gap-report.md`.
5. Record remaining untested risks and required follow-ups.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Negative-path behavior is covered where relevant.
- Remaining risks are explicit.
- `test-gap-report.md` exists and maps findings to acceptance criteria.
