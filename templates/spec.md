# Spec: <Feature Name>

## Spec Control

- Status: `new`
- Status Updated At: `<YYYY-MM-DD>`
- Status Updated By: `<Role>`
- Status Reason: `<Why this status is set>`

### Allowed Status Values

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

### Status Transition Rules

- Only the active stage owner role may change status.
- If prerequisites are missing or contradictory, set status to `blocked` with a concrete reason.
- Documentation Agent moves `new` to `ready-for-implementation` when the spec passes its quality gate.
- Implementation Agent must stop and report a handoff failure when status is not `ready-for-implementation` (or `implementation-in-progress` for resumed work).
- Test Agent must stop and report a handoff failure when status is not `ready-for-test` (or `test-in-progress` for resumed work).
- Code Review Agent must stop and report a handoff failure when status is not `ready-for-review` (or `review-in-progress` for resumed work).
- QA Agent must stop and report a handoff failure when status is not `ready-for-qa` (or `qa-in-progress` for resumed work).
- QA Agent sets status to `complete` only when recommendation is `Go` and all critical acceptance criteria are satisfied.

### Status History

- `<YYYY-MM-DD>` | `<Old Status -> New Status>` | `<Role>` | `<Reason>`

## Purpose and Scope

Describe what this feature is and what is explicitly out of scope.

## Preconditions and Assumptions

- Assumption 1
- Assumption 2

## Definitions and Canonical Terms

- Term: Definition

## Behavior and Workflow

### Routing Rules

- Rule 1

### Journey

1. Step 1
2. Step 2

## Data Contracts and Schemas

- Contract location and shape

## Validation Rules and Error Handling

- Validation 1
- Error behavior 1

## Non-Functional Constraints

- Performance
- Reliability
- Safety

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Deferred Work

- Deferred item 1

## Open Questions

- Question 1