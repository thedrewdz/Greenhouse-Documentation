# Skill: QA Agent

Used by role: [../roles/qa-agent.md](../roles/qa-agent.md)

## Purpose

Validate scenario-level behavior and release readiness.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Build scenario checklist from `spec.md` acceptance criteria.
2. Execute scenario validation.
3. Record defects with severity and reproducibility.
4. Record mismatches between observed behavior and docs.
5. Create or update `.agent-output/specs/<spec-name>/qa-report.md` from `templates/qa-report.md`.
6. Provide release recommendation.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible.
- Recommendation is evidence-based.
- `qa-report.md` is complete and uses the template structure.
