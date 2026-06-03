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

- Review report artifacts in spec dossiers

## Must Not Change

- Implementation code unless explicitly asked
- Spec decisions without documentation handoff

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
