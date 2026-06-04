# Execution Spec Status: <Feature Name>

## Scope

- Spec name: `<spec-name>`
- Source spec: `specs/<spec-name>/spec.md`
- Repository: `<implementation-repo>`

This file tracks execution lifecycle status in implementation repositories only.

## Current Status

- Status: `new`
- Updated At: `<YYYY-MM-DD>`
- Updated By: `<Role>`
- Reason: `<Why this status is set>`

## Allowed Status Values

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

## Status Transition Rules

- Only the active stage owner role may change status.
- If prerequisites are missing or contradictory, set status to `blocked` with a concrete reason.
- Documentation Agent sets `ready-for-implementation` when docs quality gate passes.
- Implementation Agent must stop when status is not `ready-for-implementation` or `implementation-in-progress`.
- Test Agent must stop when status is not `ready-for-test` or `test-in-progress`.
- Code Review Agent must stop when status is not `ready-for-review` or `review-in-progress`.
- QA Agent must stop when status is not `ready-for-qa` or `qa-in-progress`.
- QA Agent sets status to `complete` only when recommendation is `Go` and critical acceptance criteria are satisfied.

## Status History

- `<YYYY-MM-DD>` | `<old-status -> new-status>` | `<Role>` | `<Reason>`
