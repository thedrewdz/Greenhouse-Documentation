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
- `2026-08-04` | `in-dev (updated)` | `BA/PO Agent` | `Retired the "independent review of 041c86f" outstanding gate. The Merge Approval reviewer condition was removed harness-wide (Greenhouse-Documentation#43, #39): on a single-maintainer project it was clearable only by account switching, which produced content-free approvals, and where it was not, Stage 6 could never run so nothing could reach Done. Merge approval is now required checks green only. Remaining gates on this spec are unchanged.`
- `2026-07-30` | `ready-for-dev -> in-dev` | `Retrospective Agent` | `Status was stale by an entire delivery cycle: it read ready-for-dev with execution status "not started" while Greenhouse-Services #25 had been implemented (5dfdb13), reviewed (5 defects filed as #46-#50), and patched (041c86f, suite 235 -> 251 passing). Root cause is that no .agent-output stage artifacts were ever created, so every stage entry gate passed by absence and nothing prompted a status update — filed as #33 and #34. Retrospective at Greenhouse-Services .agent-output/specs/edge-unit-configuration/retrospective.md; guardrail gaps filed as #33-#36.`
