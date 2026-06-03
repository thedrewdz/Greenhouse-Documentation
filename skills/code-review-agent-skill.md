# Skill: Code Review Agent

Used by role: [../roles/code-review-agent.md](../roles/code-review-agent.md)

## Purpose

Run a structured review pass focused on correctness, contracts, architecture, and maintainability.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Compare code diff to accepted `spec.md`.
2. Check contract compatibility and boundary rules.
3. Validate test adequacy at a review level.
4. Classify findings as blocking or non-blocking.
5. Create or update `.agent-output/specs/<spec-name>/review-report.md` from `templates/review-report.md`.
6. Emit documentation feedback items for recurring issues in `.agent-output/specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md`.

## Quality Gate

- Findings are specific and actionable.
- Severity and risk are explicit.
- Documentation feedback is captured for systemic issues.
- `review-report.md` and required feedback artifacts exist in `.agent-output/specs/<spec-name>/`.
