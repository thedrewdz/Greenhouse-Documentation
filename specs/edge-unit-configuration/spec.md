# Spec: Edge Unit Onboarding and Reconfiguration

## Purpose and Scope

Define the user-facing workflow for onboarding new Edge Units and for reconfiguring known Edge Units when topology or module mapping changes.

The low-level BLE provisioning contract remains in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).

This spec replaces the former Edge Unit onboarding and reconfiguration journey document.

## Preconditions and Assumptions

- Main Unit setup is complete and WiFi credentials are stored in the `WifiCredentials` table.
- The Main Unit backend can scan for advertising Edge Units and pair over BLE.
- Unprovisioned Edge Units can enter Provisioning Mode and advertise over BLE.
- The Main Unit receives runtime heartbeats on `gh/heartbeat` after onboarding.
- The Main Unit is the source of truth for runtime configuration and slot mapping.
- Edge Units do not persist long-term runtime configuration in Phase 1 beyond the accepted provisioning values required by the BLE onboarding contract.
- The UI is a thin client that starts, cancels, and observes onboarding/reconfiguration through backend API resources and a SignalR hub.
- Phase 1 supports multiple Edge Units registered to a single Main Unit with no total count limit. Only one onboarding workflow session may be active at a time; concurrent onboarding of multiple Edge Units is not supported.

## Definitions and Canonical Terms

- Main Unit: local system authority for orchestration, validation, and configuration publication.
- Edge Unit: ESP32-based node that publishes heartbeat and receives runtime mapping updates.
- Onboarding: first-time provisioning flow for an unprovisioned Edge Unit.
- Reconfiguration: update flow for known Edge Unit when detected slot topology or module identity differs from stored mapping.
- Runtime Mapping: Main Unit-managed assignment of slot role, capability, and optional label metadata used for operation.
- Drift Flag: Main Unit state indicating known topology mismatch until a replacement mapping is acknowledged as successful.

## Flow Separation

- Setup: Main Unit first-run network and general configuration.
- Onboarding: first-time provisioning of a new Edge Unit.
- Reconfiguration: updates for a known Edge Unit when topology changes.

## Behavior and Workflow

### First-Time Onboarding

- When the user starts Add Edge Unit, the UI calls `POST /api/onboarding/scan`. The backend begins BLE scanning and publishes discovered device candidates over the SignalR onboarding hub as they are found.
- Keep scanning until the 30-second timeout, explicit cancellation, or selected-device handoff.
- If the user navigates away, the UI may stop observing the hub, but navigation alone must not cancel the backend scan. Explicit cancel actions must call the backend cancellation API.
- If no Edge Unit is discovered before timeout, the backend marks onboarding as `no-device-found` and publishes a state-change event. The UI shows a clear no-device state with a Restart action.
- While scanning, the backend records each actively advertising Edge Unit as a discovered device candidate for the active onboarding workflow.
- The UI displays candidates with identity and signal quality as they arrive via the hub. The user must explicitly tap a candidate to select it even if only one is discovered.
- After the user selects a candidate, the UI calls `POST /api/onboarding/{device_id}/start`. The backend stops scanning and begins full auto-provisioning:
  - Reads WiFi credentials from the `WifiCredentials` table.
  - Derives `mqtt_broker_uri` from the Main Unit's local network address via `INetworkConnector.GetLocalAddressAsync()`.
  - Omits `heartbeat_interval_ms`; the firmware default (30 000 ms) applies.
  - Connects to the selected Edge Unit over BLE and sends the provisioning payload.
- The backend publishes state-change events over the hub throughout provisioning, heartbeat-waiting, and completion phases.
- If the Edge Unit rejects the payload, the backend records the error details and publishes an error state event. The UI displays retry guidance.
- If Wi-Fi or MQTT bootstrap fails after a valid payload, the backend keeps the selected device context and exposes retry or cancellation actions via state-change events.
- If first-heartbeat publish fails after MQTT connect, treat it as MQTT bootstrap failure and apply the same bounded retry-budget behavior defined in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- When the first valid heartbeat arrives from the selected device_id, the backend persists that heartbeat as the current Edge Unit state, marks onboarding complete, and publishes a `mapping-required` state event.
- If no valid heartbeat arrives before the 90-second onboarding timeout, the backend marks onboarding `failed` and publishes a failure state event.
- Main Unit does not auto-retry onboarding after timeout.
- If the user selects Retry from the failure state, the UI calls `POST /api/onboarding/scan` to begin a new session.

### UI / Backend Interaction

- UI-to-backend interactions must use RESTful API resources.
- API calls must be stateless; the request path, selected `device_id`, action, and request payload must carry the context needed for each request.
- Mutating workflow calls must be idempotent from the UI client's point of view. Repeating the same `start` or `cancel` request for the same active unit must return the current onboarding state rather than duplicate BLE work.
- The UI must not call BLE adapters, MQTT adapters, repositories, or application services directly.
- The primary real-time channel is the SignalR hub at `/hubs/onboarding`. The UI subscribes on startup and receives state changes and device discovery events throughout the workflow. Polling `GET /api/onboarding` is the documented fallback if SignalR is unavailable.

API resource paths:

```text
POST /api/onboarding/scan
GET  /api/onboarding
POST /api/onboarding/{device_id}/start
POST /api/onboarding/{device_id}/cancel
GET  /api/edge-units
GET  /api/edge-units/{device_id}
PUT  /api/edge-units/{device_id}/mapping
```

### Runtime Registration and Slot Mapping

- When the first heartbeat arrives from a newly onboarded Edge Unit and no runtime mapping exists, prompt the user to configure unit name, location, slot role per discovered slot, capability mapping, and optional display labels.
- When the mapping input is valid, store it locally and publish configuration to the Edge Unit.

### Reconfiguration

- When a heartbeat arrives from a known Edge Unit and slot topology or module identity differs from stored mapping, show a reconfiguration prompt that identifies the detected changes.
- When the user confirms reconfiguration, store the new mapping, publish updates to the Edge Unit, and resume normal operation.

## API Contracts

### Onboarding State Values

| `status` | Meaning |
|---|---|
| `idle` | No active session |
| `scanning` | BLE scan in progress |
| `candidates-ready` | Scan complete; device list available |
| `provisioning` | BLE payload being sent to selected device |
| `awaiting-heartbeat` | Payload accepted; waiting for first heartbeat |
| `mapping-required` | First heartbeat received; runtime mapping needed |
| `complete` | Mapping stored and published to Edge Unit |
| `failed` | Error — see `errorCode` and `errorMessage` |
| `no-device-found` | Scan timed out with no candidates |

### POST /api/onboarding/scan — 202 Accepted

```json
{ "status": "scanning" }
```

Returns 409 if an onboarding session is already active.

### GET /api/onboarding — 200 OK (polling fallback)

```json
{
  "status": "scanning",
  "candidates": [
    { "deviceId": "1ADD5912AF61", "advertisedName": "GH-Edge-1ADD5912AF61", "rssi": -60 }
  ],
  "selectedDeviceId": null,
  "errorCode": null,
  "errorMessage": null
}
```

`candidates` is empty when `status` is `idle`. `errorCode` and `errorMessage` are null unless
`status` is `failed`.

### POST /api/onboarding/{device_id}/start — 202 Accepted

No request body. The backend derives WiFi credentials, MQTT broker URI, and heartbeat interval
automatically.

```json
{ "status": "provisioning", "deviceId": "1ADD5912AF61" }
```

Returns 404 if `device_id` is not a current candidate. Returns 409 if a different device is
already selected.

### POST /api/onboarding/{device_id}/cancel — 200 OK

```json
{ "status": "idle" }
```

### GET /api/edge-units — 200 OK

```json
{
  "edgeUnits": [
    {
      "deviceId": "1ADD5912AF61",
      "advertisedName": "GH-Edge-1ADD5912AF61",
      "unitName": "East Sensor Unit",
      "location": "Zone A",
      "mappingStatus": "acknowledged",
      "lastHeartbeatAt": "2026-07-01T22:00:00Z"
    }
  ]
}
```

### GET /api/edge-units/{device_id} — 200 OK / 404

Returns the full registered Edge Unit including last-known slot topology from heartbeat.

```json
{
  "deviceId": "1ADD5912AF61",
  "advertisedName": "GH-Edge-1ADD5912AF61",
  "unitName": "East Sensor Unit",
  "location": "Zone A",
  "mappingVersion": 1,
  "mappingStatus": "acknowledged",
  "lastHeartbeatAt": "2026-07-01T22:00:00Z",
  "slots": [
    { "slotId": 0, "role": "sensor", "capability": "moisture", "label": "Bed A Moisture", "i2cAddress": "0x25" }
  ]
}
```

`mappingStatus` values: `pending-mapping` | `publish-pending` | `published` | `acknowledged` | `failed`.

### PUT /api/edge-units/{device_id}/mapping — 200 OK / 404 / 422

Used by three flows: initial onboarding mapping, user-initiated reconfiguration, and topology
drift reconfiguration. The endpoint is identical for all three callers.

Request body:

```json
{
  "unitName": "East Sensor Unit",
  "location": "Zone A",
  "slots": [
    { "slotId": 0, "role": "sensor", "capability": "moisture", "label": "Bed A Moisture" }
  ]
}
```

| Field | Required | Constraints |
|---|---|---|
| `unitName` | Yes | Non-empty after trim |
| `location` | Yes | Non-empty after trim |
| `slots` | Yes | Non-empty; one entry per discovered slot |
| `slots[].slotId` | Yes | Integer; no duplicates |
| `slots[].role` | Yes | `sensor` or `actuator` |
| `slots[].capability` | Yes | Canonical capability name |
| `slots[].label` | No | Optional display label |

Response (200 OK):

```json
{
  "deviceId": "1ADD5912AF61",
  "unitName": "East Sensor Unit",
  "location": "Zone A",
  "mappingVersion": 1,
  "mappingStatus": "publish-pending"
}
```

The backend publishes the runtime configuration to `ghcfg/wr-{device_id}` asynchronously after
returning 200. The UI observes publish and ack progress via the SignalR hub.

## SignalR Hub Contract

Hub path: `/hubs/onboarding`

### DeviceDiscovered

Published during scanning when a new candidate is found.

```json
{ "deviceId": "1ADD5912AF61", "advertisedName": "GH-Edge-1ADD5912AF61", "rssi": -60 }
```

### OnboardingStateChanged

Published on every state transition throughout the workflow.

```json
{
  "status": "provisioning",
  "selectedDeviceId": "1ADD5912AF61",
  "errorCode": null,
  "errorMessage": null
}
```

`status` values match the onboarding state table above. `errorCode` and `errorMessage` are
non-null only when `status` is `failed`.

Polling fallback: If SignalR is unavailable, the UI polls `GET /api/onboarding` at a 1-second
interval. The backend state is always authoritative; SignalR is an observation channel only.

## Data Contracts and Schemas

### BLE Provisioning Boundary

- The BLE provisioning payload shape and field-level validation rules live in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- The BLE provisioning response shape and canonical onboarding error code set live in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- This spec uses that contract as the provisioning boundary and focuses on the user-facing orchestration around it.
- Main Unit backend should map returned BLE `error_code` values to canonical onboarding status details. The UI should display those details without redefining code semantics locally.

### Runtime Configuration Publish Contract (Main Unit to Edge Unit)

- When runtime mapping is created or changed, Main Unit must publish configuration to `ghcfg/wr-{device_id}`.
- Edge Unit must respond on `ghcfg/ack-{device_id}` with one result per received configuration message.
- `device_id` in topic and payload must match; mismatch is rejected.

Configuration payload shape (MQTT JSON payload):

```json
{
	"schema_version": 1,
	"message_id": 1201,
	"device_id": "1ADD5912AF61",
	"mapping_version": 3,
	"mapping_reason": "initial_registration",
	"unit_name": "Greenhouse East Sensor Unit",
	"location": "Zone A",
	"slots": [
		{
			"slot_id": 0,
			"role": "sensor",
			"i2c_address": "0x25",
			"capability": "moisture",
			"label": "Bed A Moisture"
		},
		{
			"slot_id": 4,
			"role": "actuator",
			"i2c_address": "0x51",
			"capability": "pump",
			"label": "Reservoir Pump"
		}
	]
}
```

Field requirements:

- `schema_version`: required integer, must be `1` in Phase 1.
- `message_id`: required integer, Main Unit generated identifier for correlation.
- `device_id`: required string, must equal Edge Unit hardware identity.
- `mapping_version`: required integer, must increase by `1` for each accepted update per device.
- `mapping_reason`: required string, allowed values are `initial_registration` and `topology_change`.
- `unit_name`: required string.
- `location`: required string.
- `slots`: required array, one entry per discovered slot.
- `slots[].slot_id`: required integer.
- `slots[].role`: required string, allowed values are `sensor` and `actuator`.
- `slots[].i2c_address`: required string, hex address format such as `0x25`.
- `slots[].capability`: required string, canonical capability name.
- `slots[].label`: optional string, UI display label.

Ack payload shape (MQTT JSON payload):

```json
{
	"schema_version": 1,
	"message_id": 1201,
	"device_id": "1ADD5912AF61",
	"mapping_version": 3,
	"result": "success",
	"error_code": 0,
	"error_message": ""
}
```

Ack response rules:

- If `result` is `success`, `error_code` must be `0` and `error_message` should be empty.
- If `result` is `error`, `error_code` must be non-zero and `error_message` must be a short diagnostic string.
- Edge Unit must emit exactly one ack message for each received configuration message.

Phase 1 minimum runtime-configuration error code set:

- `0`: success
- `3001`: unsupported_schema_version
- `3002`: device_id_mismatch
- `3003`: invalid_mapping_payload
- `3004`: mapping_version_conflict
- `3099`: internal_apply_error

## Validation Rules and Error Handling

### Main Unit Input Validation

Main Unit must reject configuration submission before publish when any of the following are true:

- `unit_name` is empty after trim.
- `location` is empty after trim.
- `slots` is empty.
- Any discovered slot is missing from `slots`.
- Any `slot_id` in `slots` is duplicated.
- Any `role` value is not `sensor` or `actuator`.
- Any `i2c_address` is not a valid hex format (`0x00` through `0x7F`).
- Any `capability` is empty or not in the canonical capability vocabulary used by the Main Unit.

If local validation fails:

- Main Unit must not publish `ghcfg/wr-{device_id}`.
- Main Unit must show field-level validation messages and keep user-entered values for correction.

### Runtime Configuration Ack Handling

- Main Unit waits for ack on `ghcfg/ack-{device_id}` after publishing `ghcfg/wr-{device_id}`.
- Ack timeout is 8 seconds per publish attempt.
- Main Unit retry budget is 3 total publish attempts per configuration update.
- Retry delay schedule is fixed at 1 second, then 2 seconds between retries.
- If timeout occurs and retries remain, Main Unit retries with the same `message_id` and `mapping_version`.
- If timeout occurs on the third attempt, Main Unit marks publish as failed and shows retry or cancel actions.

### Error-Code-Driven Main Unit Behavior

- `3001` unsupported_schema_version: stop retries and show non-retryable incompatibility error.
- `3002` device_id_mismatch: stop retries, invalidate current device selection, require fresh device selection.
- `3003` invalid_mapping_payload: keep current form data and show correctable validation guidance.
- `3004` mapping_version_conflict: fetch latest stored mapping, increment version, and require user confirmation before resend.
- `3099` internal_apply_error: allow retry up to retry budget; if exhausted, route to failure state.

### Reconfiguration Session Error Handling

- Reconfiguration must be bound to the latest heartbeat `device_id` and observed slot topology snapshot.
- If a new heartbeat arrives with different topology while reconfiguration dialog is open, mark the draft stale and require user to reload draft from latest topology.
- If user cancels reconfiguration, Main Unit keeps prior active mapping and continues normal operation with drift flag active.
- Drift flag remains active until a configuration update is acknowledged with `result=success`.
- Main Unit must never partially persist mapping changes; local persistence is atomic per accepted configuration update.

## Non-Functional Constraints

### Performance

- BLE scan startup after the UI triggers onboarding scan must begin within 2 seconds.
- No-device discovery timeout must be 30 seconds per scan session.
- Onboarding session timeout waiting for first valid heartbeat must be 90 seconds from provisioning payload acceptance.
- Runtime configuration publish-to-ack latency target is 3 seconds or less under normal LAN conditions.
- Reconfiguration drift prompt must be shown within 5 seconds of detecting topology mismatch from heartbeat.

### Reliability

- Main Unit must use bounded retries only: 3 publish attempts for runtime configuration updates.
- Main Unit must preserve selected `device_id`, entered mapping form values, and current `mapping_version` across retry attempts in the same session.
- Main Unit must persist accepted runtime mapping atomically, with no partial writes visible to runtime consumers.
- Main Unit must log each runtime configuration publish attempt and ack result with `device_id`, `message_id`, `mapping_version`, and `error_code`.

### Safety

- If reconfiguration is pending for topology drift, Main Unit must keep the last acknowledged mapping active until a newer mapping is acknowledged with `result=success`.
- Main Unit must not publish slot write commands for slot IDs that are absent from the currently active acknowledged mapping.
- On unrecoverable configuration publish failure, Main Unit must present clear operator actions (`retry`, `cancel`) and must not auto-apply unacknowledged mapping changes.

## Acceptance Criteria

1. Given a new unprovisioned Edge Unit in Provisioning Mode, when the UI triggers backend onboarding scan, then backend BLE scanning starts within 2 seconds and `GET /api/onboarding` exposes discovered devices with identity and signal quality.
2. Given no advertising Edge Unit, when scan reaches 30 seconds, then backend onboarding state becomes no-device-found, the UI shows Restart, and the backend does not keep scanning.
3. Given multiple advertising Edge Units are discovered during active onboarding scan, when the UI requests `GET /api/onboarding`, then the backend returns all currently active candidates with identity and signal quality.
4. Given the UI submits `POST /api/onboarding/{device_id}/start`, when that `device_id` is still an active candidate, then the backend pairs with that Edge Unit and records selected-device status.
5. Given the backend receives a valid provisioning payload accepted by the Edge Unit, when the first valid heartbeat from selected `device_id` arrives within 90 seconds, then the backend marks onboarding `mapping-required`, persists the heartbeat state, and publishes an `OnboardingStateChanged` event.
6. Given onboarding input rejected by BLE provisioning validation, when Edge Unit returns non-zero onboarding `error_code`, then backend onboarding status exposes explicit error details and allows retry without losing selected device context.
7. Given first heartbeat from a device with no stored runtime mapping, when user submits valid mapping input, then Main Unit publishes configuration on `ghcfg/wr-{device_id}` with required schema fields.
8. Given runtime configuration publish, when Edge Unit returns ack on `ghcfg/ack-{device_id}`, then ack has matching `message_id`, `device_id`, and `mapping_version` and result is processed exactly once.
9. Given runtime configuration ack timeout, when fewer than 3 attempts have been sent, then Main Unit retries with same `message_id` and `mapping_version`; on third timeout it enters failure state with retry/cancel actions.
10. Given invalid runtime mapping form input, when user attempts submit, then Main Unit blocks publish, shows field-level validation errors, and preserves form values.
11. Given runtime-configuration error codes `3001`, `3002`, `3003`, `3004`, or `3099`, when ack is received with `result=error`, then Main Unit behavior follows the deterministic handling defined in this spec.
12. Given topology drift for known device, when mismatch is detected from heartbeat, then reconfiguration prompt appears within 5 seconds and prior acknowledged mapping remains active until new mapping is acknowledged as success.
13. Given reconfiguration dialog open and a new heartbeat with changed topology, when drift snapshot changes, then draft is marked stale and user must reload from latest topology before submit.
14. Given accepted runtime mapping update, when persistence occurs, then mapping write is atomic and no partial mapping state is observable.
15. Given the UI refreshes, disconnects, or navigates away during onboarding, when `GET /api/onboarding` is requested again, then the current backend-owned onboarding state is returned without relying on UI memory.
16. Given the UI repeats a mutating onboarding request for the same `device_id` and action, when the backend has already accepted that action, then the backend returns the current onboarding state without duplicating BLE scan, pairing, provisioning, or cancellation work.

## Deferred Work

- Full production PKI and certificate lifecycle.
- Bulk onboarding for multiple Edge Units at once.
- Historical diff view for prior Edge Unit configurations.
- Advanced capability inference from I2C ranges beyond initial defaults.

## Open Questions

- None for Phase 1 implementation scope; unresolved ideas remain explicitly deferred in this document.
