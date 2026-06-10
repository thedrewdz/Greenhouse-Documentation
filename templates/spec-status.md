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
- If prerequisites are missing or contradictory, set status to `blocked` with a concrete reason and a documentation feedback item when docs or skills contributed to the blocker.
- Documentation Agent sets `ready-for-implementation` when docs quality gate passes.
- Implementation Agent must stop when status is not `ready-for-implementation` or `implementation-in-progress`.
- Implementation Agent sets status to `ready-for-test` when implementation and local verification pass.
- Test Agent must stop when status is not `ready-for-test` or `test-in-progress`.
- Test Agent sets status to `ready-for-review` when critical acceptance criteria have test evidence.
- Test Agent sets status to `ready-for-implementation` when failures or coverage gaps are fixable by implementation work.
- Code Review Agent must stop when status is not `ready-for-review` or `review-in-progress`.
- Code Review Agent sets status to `ready-for-qa` when no blocking findings remain.
- Code Review Agent sets status to `ready-for-implementation` when findings are fixable by implementation work.
- QA Agent must stop when status is not `ready-for-qa` or `qa-in-progress`.
- QA Agent sets status to `complete` only when recommendation is `Go` and critical acceptance criteria are satisfied.
- QA Agent sets status to `ready-for-implementation` when `Conditional-Go` or `No-Go` findings are fixable by implementation work.
- Any stage sets status to `blocked` only for unresolved docs, missing decisions, unsafe process state, unavailable prerequisites, or other blockers that cannot be resolved by implementation alone.

## Loopback Rules

- `ready-for-implementation` -> `implementation-in-progress` -> `ready-for-test`
- `ready-for-test` -> `test-in-progress` -> `ready-for-review` on pass
- `test-in-progress` -> `ready-for-implementation` on fixable test or coverage failure
- `ready-for-review` -> `review-in-progress` -> `ready-for-qa` on pass
- `review-in-progress` -> `ready-for-implementation` on fixable review findings
- `ready-for-qa` -> `qa-in-progress` -> `complete` on `Go`
- `qa-in-progress` -> `ready-for-implementation` on fixable `Conditional-Go` or `No-Go`
- Any status -> `blocked` only for true documentation, prerequisite, merge-safety, or process blockers

## Artifact Rules

- Stage artifacts are retained across repeated implementation loops.
- Stage owners append new findings and status history rather than deleting prior loop evidence.
- `doc-feedback.md` is append-only across stages; each item must identify source role, impact, recommended change, and disposition.

## Status History

- `<YYYY-MM-DD>` | `<old-status -> new-status>` | `<Role>` | `<Reason>`
