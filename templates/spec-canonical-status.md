# Canonical Spec Status: <Feature Name>

Use this file in the documentation repository at `specs/<spec-name>/status.md`.

This is the durable milestone status for the spec in canonical docs.

## Current Status

- Status: `new`
- Updated At: `<YYYY-MM-DD>`
- Updated By: `<Role>`
- Reason: `<Why this status is set>`

## Allowed Status Values

- `new`
- `ready-for-dev`
- `in-dev`
- `complete`
- `blocked`

## Status Guidance

- `new`: drafting or unresolved planning state in docs.
- `ready-for-dev`: spec is implementation-ready and handed off.
- `in-dev`: implementation lifecycle is active in an implementation repository.
- `complete`: implementation has been validated and merged to the implementation repository `main` branch.
- `blocked`: unresolved issue prevents safe progress or completion.

## Execution Linkage

- Implementation repository: `<owner/repo or local path>`
- Execution status file: `.agent-output/specs/<spec-name>/spec-status.md`
- Last observed execution status: `<status>`

## History

- `<YYYY-MM-DD>` | `<old-status -> new-status>` | `<Role>` | `<Reason>`
