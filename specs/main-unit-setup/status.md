# Canonical Spec Status: Main Unit Setup

## Current Status

- Status: `ready-for-dev`
- Updated At: `2026-07-01`
- Updated By: `Documentation Agent`
- Reason: Full API contracts, data contracts, application-layer contracts, validation rules, and
  acceptance criteria added. Services and UI work split into separate GitHub epics. Open questions
  are non-blocking for services implementation.

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

- Implementation repository (services): `thedrewdz/Greenhouse-Services`
- Implementation repository (UI): `thedrewdz/Greenhouse-WebUI`
- Execution status file: `.agent-output/specs/main-unit-setup/spec-status.md`
- Last observed execution status: `not started`

## History

- `2026-07-01` | `new → ready-for-dev` | `Documentation Agent` | Full API and data contracts
  added; services and UI work split into separate GitHub epics in `Greenhouse-Services` and
  `Greenhouse-WebUI`.
