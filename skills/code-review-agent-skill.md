# Skill: Code Review Agent

Used by role: [../roles/code-review-agent.md](../roles/code-review-agent.md)

## Purpose

Run a structured review pass focused on correctness, contracts, architecture, and maintainability.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Read `spec.md` Spec Control status.
2. Entry gate: continue only when status is `ready-for-review` or `review-in-progress`.
3. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
4. On accepted entry, set status to `review-in-progress` and append Status History.
5. Compare code diff to accepted `spec.md`.
6. Check contract compatibility and boundary rules.
7. Validate test adequacy at a review level.
8. Classify findings as blocking or non-blocking.
9. Create or update `.agent-output/specs/<spec-name>/review-report.md` from `templates/review-report.md`.
10. Emit documentation feedback items for recurring issues in `.agent-output/specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md`.
11. If blocking findings exist, set status to `ready-for-implementation`; otherwise set status to `ready-for-qa`. Append Status History.

## Quality Gate

- Findings are specific and actionable.
- Severity and risk are explicit.
- Documentation feedback is captured for systemic issues.
- `review-report.md` and required feedback artifacts exist in `.agent-output/specs/<spec-name>/`.
- `spec.md` status transition is recorded (`ready-for-implementation` on blocking findings, otherwise `ready-for-qa`).
