# Role: Test Agent

## Purpose

Validates behavioral coverage against accepted specs and identifies residual risks.

## Primary Skill

- [../skills/test-agent-skill.md](../skills/test-agent-skill.md)

## Owns

- Test strategy execution for a feature change
- Gap analysis across happy path, negative path, and degraded path behavior

## May Change

- Test files in implementation repositories
- Test plan artifacts in spec dossiers
- `.agent-output/specs/<spec-name>/test-gap-report.md`

## Must Not Change

- Product behavior definitions in specs
- Architecture boundaries without documentation feedback
- Files in the documentation repository (this repository)

## Required Inputs

- Accepted `spec.md`
- Implementation diff
- Existing test suite and strategy docs

## Required Outputs

- Test gap report
- Added or updated tests
- Remaining untested risks
- `.agent-output/specs/<spec-name>/test-gap-report.md` (from `templates/test-gap-report.md`)
