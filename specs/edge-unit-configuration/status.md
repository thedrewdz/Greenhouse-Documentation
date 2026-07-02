# Canonical Spec Status: Edge Unit Configuration

Use this file in the documentation repository at `specs/<spec-name>/status.md`.

This is the durable milestone status for the spec in canonical docs.

## Current Status

- Status: `ready-for-dev`
- Updated At: `2026-07-02`
- Updated By: `Documentation Agent`
- Reason: `Full API contracts, SignalR hub contract, WiFi credential auto-supply, mqtt_broker_uri derivation via INetworkConnector.GetLocalAddressAsync, provision endpoint removed, multiple Edge Units confirmed in Phase 1, INetworkConnector.GetLocalAddressAsync added. All acceptance criteria updated.`

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
- Execution status file: `.agent-output/specs/edge-unit-configuration/spec-status.md`
- Last observed execution status: `not started`

## History

- `2026-06-04` | `new -> new` | `Documentation Agent` | `Initialized canonical status file to satisfy repository process requirements and track readiness work.`
- `2026-06-04` | `new -> ready-for-dev` | `Documentation Agent` | `Closed implementation-readiness gaps for contracts, validation/error handling, non-functional constraints, and acceptance criteria.`
- `2026-07-01` | `ready-for-dev (updated)` | `Documentation Agent` | `Spec pass: API response shapes for all 7 endpoints, SignalR hub contract (/hubs/onboarding), WiFi credentials auto-supplied from WifiCredentials table, mqtt_broker_uri derived from INetworkConnector.GetLocalAddressAsync, provision endpoint removed, multiple Edge Units confirmed (sequential sessions only), INetworkConnector.GetLocalAddressAsync added to main-unit-setup spec. GitHub epics created: Greenhouse-Services #25 and Greenhouse-WebUI #17.`
