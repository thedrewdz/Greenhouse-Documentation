# Skill: Code Review Agent

Used by role: [../roles/code-review-agent.md](../roles/code-review-agent.md)

## Purpose

Run a structured review pass focused on correctness, contracts, architecture, and maintainability.

## Workflow

1. Compare code diff to accepted `spec.md`.
2. Check contract compatibility and boundary rules.
3. Validate test adequacy at a review level.
4. Classify findings as blocking or non-blocking.
5. Emit documentation feedback items for recurring issues.

## Quality Gate

- Findings are specific and actionable.
- Severity and risk are explicit.
- Documentation feedback is captured for systemic issues.
