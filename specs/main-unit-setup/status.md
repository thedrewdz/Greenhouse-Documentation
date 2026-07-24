# Canonical Spec Status: Main Unit Setup

## Current Status

- Status: `complete`
- Updated At: `2026-07-24`
- Updated By: `Documentation Agent`
- Reason: Setup delivered by the rebuilt two-process architecture (ADR 0001). Services epic
  Greenhouse-Services#7 and UI epic Greenhouse-WebUI#7 are Done on the board, with all setup
  tasks completed. Pre-rebuild umbrella tracker Greenhouse-WebUI#2 closed as superseded.

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
- Last observed execution status: `complete` (Greenhouse-Services#7 and Greenhouse-WebUI#7 epics Done)

## History

- `2026-07-01` | `new → ready-for-dev` | `Documentation Agent` | Full API and data contracts
  added; services and UI work split into separate GitHub epics in `Greenhouse-Services` and
  `Greenhouse-WebUI`.
- `2026-07-02` | `ready-for-dev` (no change) | `Documentation Agent` | Grooming pass for
  Greenhouse-Services#37: corrected concrete adapter name from `NetworkManagerAdapter` to
  `NmcliNetworkAdapter` in `Greenhouse.Network`; noted `AddGreenhouseNetwork()` extension and
  deferred `GetLocalAddressAsync` implementation. Greenhouse-Services#37 advanced to Ready For Dev.
- `2026-07-24` | `ready-for-dev → complete` | `Documentation Agent` | Board-triage grooming pass:
  reconciled spec with delivered rebuild. Removed `GetLocalAddressAsync` from the Phase-1
  `INetworkConnector` port listing and added it to Deferred Work (owned by the Edge Unit
  onboarding epic) — resolves Greenhouse-Documentation#28. Marked spec complete; setup shipped
  via Greenhouse-Services#7 and Greenhouse-WebUI#7. Closed pre-rebuild tracker Greenhouse-WebUI#2.
