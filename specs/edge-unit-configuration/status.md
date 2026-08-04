# Canonical Spec Status: Edge Unit Configuration

Use this file in the documentation repository at `specs/<spec-name>/status.md`.

This is the durable milestone status for the spec in canonical docs.

## Current Status

- Status: `in-dev`
- Updated At: `2026-07-30`
- Updated By: `Retrospective Agent`
- Reason: `Corrects a status that was stale by a full delivery cycle. Services implementation of all seven sub-issues is complete on a feature branch, code review raised five defects (#46-#50), and fixes are applied — but the spec is not complete: PR #45 is unmerged and unapproved, two defect sub-issues remain open, and Stage 5 QA has never run.`

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
- Last observed execution status: `ready-for-review` (observed `2026-07-30`)
- Outstanding gates: Stage 5 QA on the test Pi; Greenhouse-Services #47 (unverifiable without
  hardware) and #48 part 2 (reconnect seam undecided). The former "independent review of `041c86f`"
  gate is retired — the merge gate is required checks green only, with no reviewer condition
  (Greenhouse-Documentation#43).

## History

- `2026-06-04` | `new -> new` | `Documentation Agent` | `Initialized canonical status file to satisfy repository process requirements and track readiness work.`
- `2026-06-04` | `new -> ready-for-dev` | `Documentation Agent` | `Closed implementation-readiness gaps for contracts, validation/error handling, non-functional constraints, and acceptance criteria.`
- `2026-07-01` | `ready-for-dev (updated)` | `Documentation Agent` | `Spec pass: API response shapes for all 7 endpoints, SignalR hub contract (/hubs/onboarding), WiFi credentials auto-supplied from WifiCredentials table, mqtt_broker_uri derived from INetworkConnector.GetLocalAddressAsync, provision endpoint removed, multiple Edge Units confirmed (sequential sessions only), INetworkConnector.GetLocalAddressAsync added to main-unit-setup spec. GitHub epics created: Greenhouse-Services #25 and Greenhouse-WebUI #17.`
- `2026-08-04` | `in-dev (updated)` | `BA/PO Agent` | `Error-attribution and drift-notification decisions landed (Greenhouse-Documentation#47, #45, #32), unblocking Services#83. (1) New Main Unit error range 4xxx — 4001 credentials unavailable, 4002 broker address unavailable, 4003 BLE transport failure, 4004 empty status response, 4005 malformed, 4006 heartbeat timeout, 4099 internal. errorCode is now defined as the onboarding failure code whatever its origin, is never null on failed, and the range names which unit to inspect. Replaces the interim conventions of borrowing 2003/2004 and reporting null. (2) Silence on a status read is a Main Unit failure (4004), never Edge Unit 2099. (3) Edge Unit data is untrusted input: no control-signal matching across device-supplied values, bound anything reaching an operator or log, and never log write-path transcripts because they carry the WiFi password. (4) Topology drift gets EdgeUnitTopologyChanged plus topologyDriftDetectedAt and observedSlots on the Edge Unit resources; mappingStatus stays acknowledged. New acceptance criteria 23-27. NOTE: 1xxx was proposed for the Main Unit range and rejected — it was already the Edge Unit device-response set in mqtt-topics.md. New canonical error-code-ranges.md registry added so the next allocation cannot collide.`
- `2026-08-04` | `in-dev (updated)` | `BA/PO Agent` | `Three contract decisions landed, unblocking five Services defects. (1) Candidate rssi and the descending-RSSI ordering guarantee are REMOVED — bluetoothctl 5.66 emits no RSSI lines, so the field was null on every real device (Greenhouse-Documentation#52, Services#73). D-Bus scanning deferred. (2) Cancellation now has two routes: collection-scoped POST /api/onboarding/cancel for a scan with no candidates, and the device-scoped route which must honour its id (409/404 on mismatch) instead of cancelling any session for any value (#53, Services#76). (3) New Restart and Reconnect Recovery section plus a failureReason field, and an IsConnected/ConnectionStateChanged seam on IMessagingService in architecture/runtime.md (#54, Services#48/#74/#77). Six new acceptance criteria (17-22).`
- `2026-08-04` | `in-dev (updated)` | `BA/PO Agent` | `Retired the "independent review of 041c86f" outstanding gate. The Merge Approval reviewer condition was removed harness-wide (Greenhouse-Documentation#43, #39): on a single-maintainer project it was clearable only by account switching, which produced content-free approvals, and where it was not, Stage 6 could never run so nothing could reach Done. Merge approval is now required checks green only. Remaining gates on this spec are unchanged.`
- `2026-07-30` | `ready-for-dev -> in-dev` | `Retrospective Agent` | `Status was stale by an entire delivery cycle: it read ready-for-dev with execution status "not started" while Greenhouse-Services #25 had been implemented (5dfdb13), reviewed (5 defects filed as #46-#50), and patched (041c86f, suite 235 -> 251 passing). Root cause is that no .agent-output stage artifacts were ever created, so every stage entry gate passed by absence and nothing prompted a status update — filed as #33 and #34. Retrospective at Greenhouse-Services .agent-output/specs/edge-unit-configuration/retrospective.md; guardrail gaps filed as #33-#36.`
