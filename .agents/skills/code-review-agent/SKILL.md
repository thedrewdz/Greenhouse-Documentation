---
name: code-review-agent
description: Use this skill for structured code review agent work after implementation, especially when reviewing pull requests or implementation artifacts against an accepted spec, architecture boundaries, contracts, tests, and release-stage status transitions.
---

# Code Review Agent Skill

Run a structured review pass focused on correctness, contracts, architecture, and maintainability.

Used by custom agent: [../../../.codex/agents/code-review-agent.toml](../../../.codex/agents/code-review-agent.toml)

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If an output artifact is not required, still create it with `Not required` and a reason.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Check `.agent-output/specs/<spec-name>/` before commencing.
3. Read `.agent-output/specs/<spec-name>/implementation-plan.md` for branch and scope context.
4. Read `.agent-output/specs/<spec-name>/spec-status.md`.
5. Continue only when status is `ready-for-review` or `review-in-progress`.
6. If status is not eligible, stop and emit a handoff failure with required upstream role and reason.
7. On accepted entry, set status to `review-in-progress` and append Status History in `spec-status.md`.
8. Compare code diff to accepted `spec.md`.
9. Check contract compatibility and boundary rules.
10. Validate test adequacy at a review level.
11. Classify findings as blocking or non-blocking.
12. Create or update `.agent-output/specs/<spec-name>/review-report.md` from `templates/review-report.md`.
13. Append documentation feedback items for recurring, systemic, ambiguous, or missing guidance in `.agent-output/specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md`.
14. If findings are fixable in code or tests, set status to `ready-for-implementation`.
15. If no blocking findings remain, set status to `ready-for-qa`.
16. If review cannot safely continue because docs, prerequisites, merge state, or process state are unresolved, set status to `blocked`.
17. Append Status History in `spec-status.md`.
18. Once review is complete, decide merge safety for the active pull request.
19. If not safe to merge to `main`, record concrete implementation feedback for resolution and do not merge.
20. If safe to merge to `main`, merge the pull request to `main`.

## Quality Gate

- Findings are specific and actionable.
- Severity and risk are explicit.
- Documentation feedback is captured for systemic issues.
- `review-report.md` and required feedback artifacts exist in `.agent-output/specs/<spec-name>/`.
- Status transition is recorded in `spec-status.md`: `ready-for-implementation` on fixable findings, `ready-for-qa` on pass, or `blocked` on true documentation/process blockers.
- Pull request decision is explicit: feedback issued when unsafe, merged to `main` when safe.
