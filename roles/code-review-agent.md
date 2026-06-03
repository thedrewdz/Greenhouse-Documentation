# Role: Code Review Agent

## Purpose

Performs structured review against specs, architecture boundaries, and quality gates.

## Primary Skill

- [../skills/code-review-agent-skill.md](../skills/code-review-agent-skill.md)

## Owns

- Review findings classification
- Contract and architecture boundary checks
- Documentation feedback extraction from repeated issues

## May Change

- `.agent-output/specs/<spec-name>/review-report.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`

## Must Not Change

- Implementation code unless explicitly asked
- Spec decisions without documentation handoff
- Files in the documentation repository (this repository)

## Required Inputs

- Accepted `spec.md`
- Code diff
- Test results
- Relevant review skills

## Required Outputs

- Blocking findings
- Non-blocking findings
- Architecture concerns
- Documentation feedback items
- `.agent-output/specs/<spec-name>/review-report.md` (from `templates/review-report.md`)
- `.agent-output/specs/<spec-name>/doc-feedback.md` (from `templates/doc-feedback.md`)
