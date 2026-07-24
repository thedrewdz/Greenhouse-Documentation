# Canonical Spec Status: Empty Dashboard

Use this file in the documentation repository at `specs/<spec-name>/status.md`.

This is the durable milestone status for the spec in canonical docs.

## Current Status

- Status: `ready-for-dev`
- Updated At: `2026-07-24`
- Updated By: `Documentation Agent`
- Reason: Groomed during a board-triage pass. Single-stack (UI-only) feature; decomposed into
  one implementation task (Greenhouse-WebUI#3). Depends on the edge-units list endpoint
  (`GET /api/edge-units`) delivered by the Edge Unit onboarding epic (Greenhouse-Services#35).

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

- Implementation repository (UI): `thedrewdz/Greenhouse-WebUI`
- Execution status file: `.agent-output/specs/empty-dashboard/spec-status.md`
- Last observed execution status: `not started`

## Task Decomposition

Single-stack, UI-only. One implementation task:

| Task | Stack | Depends on | Notes |
|---|---|---|---|
| Greenhouse-WebUI#3 — Empty dashboard state | `ui` | Greenhouse-Services#35 (`GET /api/edge-units` list endpoint) | Renders the configured-but-no-Edge-Units dashboard state; "Onboard an Edge Unit" CTA routes to the Add Edge Unit flow (Greenhouse-WebUI#19). |

## History

- `2026-07-24` | `new → ready-for-dev` | `Documentation Agent` | Created missing canonical status
  file during board-triage grooming. Confirmed empty-dashboard was not delivered in the rebuild.
  Groomed the pre-rebuild umbrella tracker Greenhouse-WebUI#3 into a single-stack UI task with a
  declared dependency on Greenhouse-Services#35.
