# Feature Delivery Harness

Use this workflow for all non-trivial feature work.

## Core Rules

- Use spec dossiers in `specs/<spec-name>/` as the durable source of truth for feature-level work.
- Each dossier must contain `spec.md` at minimum.
- In implementation repositories, all non-documentation artifact generation must go to `.agent-output/specs/<spec-name>/`.
- Only Documentation Agent and Retrospective Agent may write directly to this docs repository.
- If a stage discovers ambiguity, create a documentation feedback item and route it back to documentation before continuing.
- Do not silently change contracts in implementation repos.
- Every `spec.md` must include Spec Control status fields and status history.
- Every stage owner must enforce status entry gates before proceeding.

## Canonical Spec Status Lifecycle

Statuses:

- `new`
- `ready-for-implementation`
- `implementation-in-progress`
- `ready-for-test`
- `test-in-progress`
- `ready-for-review`
- `review-in-progress`
- `ready-for-qa`
- `qa-in-progress`
- `complete`
- `blocked`

Primary flow:

- `new` -> `ready-for-implementation` -> `implementation-in-progress` -> `ready-for-test` -> `test-in-progress` -> `ready-for-review` -> `review-in-progress` -> `ready-for-qa` -> `qa-in-progress` -> `complete`

Loopbacks:

- Review blocking findings: `review-in-progress` -> `ready-for-implementation`
- QA no-go: `qa-in-progress` -> `ready-for-implementation`
- Any unresolved prerequisite: `*` -> `blocked`
- Retrospective unblock for doc follow-up: `blocked` -> `new`

## Stage 1: Documentation and Planning

Role: Documentation Agent

Inputs:

- User request
- `CONTEXT.md`
- Relevant architecture, spec dossiers, and ADR files

Outputs:

- New or updated `spec.md`
- Acceptance criteria
- Open questions
- Implementation handoff summary
- Durable dossier updates in `specs/<spec-name>/` using templates

Exit criteria:

- The next implementation step is clear enough for a coding agent to act without inventing missing behavior.
- `spec.md` status is `ready-for-implementation` for accepted work, otherwise `new` or `blocked` with reason.

## Stage 2: Implementation

Role: Implementation Agent

Inputs:

- Accepted `spec.md`
- `AGENTS.md` from the target implementation repo
- Relevant skills

Outputs:

- Code changes
- Tests added or updated with the implementation
- Local verification results
- Deviations from spec and documentation feedback items
- `.agent-output/specs/<spec-name>/implementation-plan.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`

Rules:

- Implement only documented behavior.
- Do not redefine glossary terms, contracts, or ADR decisions in code.
- If docs are incomplete or contradictory, log a documentation feedback item.
- Entry gate status: `ready-for-implementation` or `implementation-in-progress`.
- Exit status on pass: `ready-for-test`.

## Stage 3: Test Pass

Role: Test Agent

Inputs:

- `spec.md`
- Code diff
- Existing tests

Outputs:

- Test gap report
- Added or updated tests
- Remaining untested risks
- `.agent-output/specs/<spec-name>/test-gap-report.md`

Rules:

- Prefer behavior-focused tests over implementation-detail tests.
- Include negative-path and degraded-state tests where relevant.
- Entry gate status: `ready-for-test` or `test-in-progress`.
- Exit status on pass: `ready-for-review`; on unresolved critical coverage: `blocked`.

## Stage 4: Code Review Gate

Role: Code Review Agent

Inputs:

- `spec.md`
- Code diff
- Test results
- Relevant skills

Outputs:

- Blocking findings
- Non-blocking findings
- Architecture boundary concerns
- Documentation feedback items
- `.agent-output/specs/<spec-name>/review-report.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`

Rules:

- Do not fix code during review unless explicitly instructed.
- Every repeated or systemic issue must become a documentation or skill feedback item.
- Treat architecture boundary never events as blocking.
- Require a guardrail update action for every blocking boundary finding.
- Entry gate status: `ready-for-review` or `review-in-progress`.
- Exit status: `ready-for-qa` when no blocking findings, else `ready-for-implementation`.

## Stage 5: QA Evaluation

Role: QA Agent

Inputs:

- `spec.md` and its acceptance criteria
- Running behavior or a testable implementation

Outputs:

- Scenario checklist
- Defects
- Spec mismatches
- Release recommendation
- `.agent-output/specs/<spec-name>/qa-report.md`

Rules:

- Validate user-visible behavior against acceptance criteria.
- Record doc mismatches as documentation feedback items.
- Entry gate status: `ready-for-qa` or `qa-in-progress`.
- Exit status: `complete` on `Go`, `blocked` on `Conditional-Go`, `ready-for-implementation` on `No-Go`.

## Stage 6: Retrospective and Artifact Promotion

Role: Retrospective Agent

Inputs:

- Review findings
- QA findings
- Implementation deviations

Outputs:

- `.agent-output/specs/<spec-name>/retrospective.md`
- Guardrail update proposals
- Promoted artifacts copied into `specs/<spec-name>/` in this docs repository
- `specs/<spec-name>/promotion-log.md`

Rules:

- Do not add vague rules.
- Add only reusable guidance that would have prevented or reduced the issue.
- For every systemic or repeated boundary failure, include at least one concrete guardrail proposal.
- Record `promoted`, `rejected`, or `deferred` for each artifact candidate from `.agent-output/specs/<spec-name>/`.
- Promote only artifacts that conform to templates.
- Retrospective Agent may update other existing documents in `specs/<spec-name>/` to keep the dossier consistent after promotion.
- Entry gate status: `complete` or `blocked`.
- Optional status update: `blocked` -> `new` when blockers are converted into actionable documentation work.

## Stage 7: Durable Documentation Update

Role: Documentation Agent

Inputs:

- Promoted artifacts in `specs/<spec-name>/`
- `promotion-log.md`

Outputs:

- Durable updates to specs, skills, templates, workflow docs, or ADR-linked guidance

Rules:

- Resolve promoted feedback into canonical docs in this repository.
- Keep terminology and contracts consistent with `CONTEXT.md` and ADRs.

## Recommended Dossier Artifacts

At minimum, each spec folder should include:

- `spec.md`

Recommended supporting artifacts as work progresses:

- `implementation-plan.md`
- `test-gap-report.md`
- `review-report.md`
- `qa-report.md`
- `retrospective.md`
- `doc-feedback.md`
- `promotion-log.md`

Template scaffolding is provided in `templates/`.