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
- The UI displays candidates with identity as they arrive via the hub, in the order they were discovered. No signal-strength or proximity indication is available in Phase 1 — see Candidate Ordering and Signal Strength. The user must explicitly tap a candidate to select it even if only one is discovered.
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
- Mutating workflow calls must be idempotent from the UI client's point of view. Repeating the same `start` or `cancel` request for the same active unit must return the current onboarding state rather than duplicate BLE work. Idempotence does not mean permissiveness: a device-scoped call naming a device that is not the active one is an error, not a no-op — see Cancelling an Onboarding Session.
- A cancel action that is not scoped to a specific device — stopping a scan that has found nothing — must call the session-scoped `POST /api/onboarding/cancel`. A client must never fabricate a `device_id` to reach a device-scoped route.
- The UI must not call BLE adapters, MQTT adapters, repositories, or application services directly.
- The primary real-time channel is the SignalR hub at `/hubs/onboarding`. The UI subscribes on startup and receives state changes and device discovery events throughout the workflow. Polling `GET /api/onboarding` is the documented fallback if SignalR is unavailable.

API resource paths:

```text
POST /api/onboarding/scan
GET  /api/onboarding
POST /api/onboarding/cancel
POST /api/onboarding/{device_id}/start
POST /api/onboarding/{device_id}/cancel
GET  /api/edge-units
GET  /api/edge-units/{device_id}
PUT  /api/edge-units/{device_id}/mapping
```

There are **two** cancel routes and they are not interchangeable — see Cancelling an Onboarding
Session.

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
    { "deviceId": "1ADD5912AF61", "advertisedName": "GH-Edge-1ADD5912AF61" }
  ],
  "selectedDeviceId": null,
  "errorCode": null,
  "errorMessage": null
}
```

`candidates` is empty when `status` is `idle`, and is ordered by discovery time — earliest first.
`errorCode` and `errorMessage` are null unless `status` is `failed`.

#### Candidate Ordering and Signal Strength

**Candidates carry no signal-strength field and are ordered by discovery time, not proximity.**

An earlier revision of this contract specified an `rssi` field and ordering by descending RSSI so the
nearest unit sorted first. Both are removed: `bluetoothctl` 5.66 emits no RSSI lines during a scan, so
the field was null on every real device and the ordering guarantee had nothing to sort by. Verified on
the test Pi against a live ESP32 — a 25-second scan produced zero lines matching `RSSI` or `TxPower`
(Greenhouse-Services#73).

A contract must not publish a field that is never populated, so the honest contract is the one above.
Consequences to accept:

- The operator has no proximity signal when several units are in range. Distinguishing this
  greenhouse's unit from a neighbour's relies on the `device_id` in the advertised name, which the
  operator can read off the unit.
- No client may sort, filter, or badge candidates by signal strength, because the data does not exist.

Restoring a proximity signal requires reading `org.bluez.Device1.RSSI` over D-Bus rather than parsing
`bluetoothctl` output. That is a scan-transport change, deferred — see Out-of-Scope / Deferred Work. If
it is taken, `rssi` and an ordering guarantee return to this contract together, and the parser must
handle the real on-device format (`RSSI: 0xffffffc4 (-60)` — hex plus a parenthesised decimal), not the
plain integer the removed branch assumed.

### POST /api/onboarding/{device_id}/start — 202 Accepted

No request body. The backend derives WiFi credentials, MQTT broker URI, and heartbeat interval
automatically.

```json
{ "status": "provisioning", "deviceId": "1ADD5912AF61" }
```

Returns 404 if `device_id` is not a current candidate. Returns 409 if a different device is
already selected.

### Cancelling an Onboarding Session

Cancellation has two routes because it answers two different questions. The session-scoped one is
required: a scan that has discovered nothing has no `device_id` for the caller to name.

#### POST /api/onboarding/cancel — 200 OK

Cancels **whatever onboarding session is currently active**, whether or not a device has been selected.
This is the route a "Stop scanning" control calls.

```json
{ "status": "idle" }
```

- Returns 200 with `{ "status": "idle" }` when a session was cancelled.
- Returns 200 with `{ "status": "idle" }` when no session was active — cancelling nothing is a
  success, which keeps the call idempotent for a client that has lost track of state.
- Takes no request body and no device id.

#### POST /api/onboarding/{device_id}/cancel — 200 OK

Cancels the active session **only if it is the session for `device_id`**. Use this when the client
believes a specific device is being onboarded and must not cancel anything else.

```json
{ "status": "idle" }
```

- Returns 200 when `device_id` matches the currently selected device.
- Returns **409 Conflict** when a session is active for a different device, or when a session is active
  with no device selected yet (still scanning). The active session is left running.
- Returns **404 Not Found** when `device_id` is neither the selected device nor a current candidate.

**The device id must be honoured, not ignored.** Before this was specified, the endpoint accepted any
value and cancelled the active session regardless: `POST /api/onboarding/000000000000/cancel` returned
`200 {"status":"idle"}` for an id that was never discovered and does not exist
(Greenhouse-Services#76). Two consequences made that worse than cosmetic — a UI wanting to stop an
empty scan had to invent an id, and inventing one *worked*, so the workaround would have become the de
facto contract; and a stale client cancelling a device it believed was onboarding would silently cancel
whichever session was actually running.

A path parameter that scopes nothing is a contract defect. If a caller names a device, a mismatch is an
error — it is never a licence to act on a different session.

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

**Transient versus terminal.** `publish-pending` and `published` are **transient** — each asserts that a
publisher is actively working on this mapping right now. `pending-mapping`, `acknowledged`, and `failed`
are **terminal**: they rest indefinitely and are the only statuses an operator may be shown as a
settled state. The distinction is load-bearing; see Restart and Reconnect Recovery.

When `mappingStatus` is `failed`, the detail response also carries `failureReason`:

```json
{ "mappingStatus": "failed", "failureReason": "broker-unreachable" }
```

`failureReason` values, and whether the Main Unit may recover from each without operator action:

| `failureReason` | Meaning | Auto-recoverable |
|---|---|---|
| `broker-unreachable` | Every publish attempt failed because the transport was down | Yes |
| `interrupted` | A restart or shutdown ended the publish with no outcome | Yes |
| `ack-timeout` | Published successfully; the Edge Unit never acknowledged within the retry budget | No |
| `rejected` | The Edge Unit acknowledged with a non-zero `result` code | No |

`failureReason` is null for every status other than `failed`. A non-recoverable reason means the Edge
Unit itself did not cooperate, so retrying without operator involvement would loop.

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

Published during scanning when a new candidate is found. One event per candidate, in discovery order.

```json
{ "deviceId": "1ADD5912AF61", "advertisedName": "GH-Edge-1ADD5912AF61" }
```

No signal-strength field — see Candidate Ordering and Signal Strength.

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
- If timeout occurs on the third attempt, Main Unit marks publish as `failed` with `failureReason` `ack-timeout` and shows retry or cancel actions.
- If every attempt fails because the transport was down rather than unacknowledged, Main Unit marks publish as `failed` with `failureReason` `broker-unreachable`, which is auto-recoverable — see Restart and Reconnect Recovery.

### Restart and Reconnect Recovery

**The governing invariant: no operation may leave a durable status implying it completed, or implying
that something is still working on it, when nothing is.**

Two triggers break that invariant, and both are observed defects rather than hypotheticals.

#### On daemon start

Any mapping found in a **transient** status (`publish-pending`, `published`) has no publisher — the
process that owned it is gone. Reconcile at startup:

- Set it to `failed` with `failureReason` `interrupted`. Retain the mapping, its `mapping_version`, and
  its `message_id`.
- Because `interrupted` is auto-recoverable, the mapping is then re-published by the recovery pass below
  rather than waiting for the operator.
- Never leave it transient. `published` means "sent, waiting for the Edge Unit to confirm"; after a
  restart it means "abandoned", and the two must not look the same to an operator. Observed on-device:
  a mapping sat at `published` indefinitely across repeated restarts with no republish, no retry budget,
  and no ack timeout (Greenhouse-Services#74).

Any **onboarding session** found in a non-terminal status (`scanning`, `provisioning`,
`awaiting-heartbeat`) is reset to `idle` at startup:

- `no-device-found` may only be written by a scan window that actually elapsed. The teardown path must
  never stamp a terminal scan outcome. Observed on-device: stopping the service five seconds into a
  30-second window persisted `no-device-found`, which then survived every later restart — a definitive
  "no Edge Unit found" verdict produced by a scan that never finished, sending the operator to check
  hardware that was fine (Greenhouse-Services#77).
- `idle` is the truthful state for "no scan has completed since startup".

#### On transport reconnect

The Main Unit observes reconnection through `IMessagingService.ConnectionStateChanged` — see the
[IMessagingService contract](../../architecture/runtime.md#imessagingservice-contract). On a transition
to connected:

- Re-publish every mapping at `publish-pending`, and every mapping at `failed` whose `failureReason` is
  auto-recoverable (`broker-unreachable`, `interrupted`).
- Do **not** re-publish `ack-timeout` or `rejected`. The transport was never the problem; the Edge Unit
  was, and retrying without operator involvement loops.
- Re-publish with the **same** `message_id` and `mapping_version` so the Edge Unit can deduplicate a
  configuration it may already have applied.
- Restore the full retry budget for a re-published mapping. It is a fresh delivery attempt, not a
  continuation.

De-duplication, which a flapping broker makes mandatory rather than nice to have:

- Skip any unit that already has a publish request in flight. Each re-enqueue otherwise costs a full
  retry budget per unit, and a broker that flaps fires the signal repeatedly.
- Apply a minimum interval of 5 seconds between recovery passes. A reconnect arriving inside that
  window is coalesced into the pending pass, never queued as a second one.
- Recovery is a query over stored mapping state, not a queue held in memory. It must produce the same
  result whether the transport dropped for one second or the daemon was restarted in between.

Without this, a mapping accepted while the broker was down reached a truthful `failed` and was then
never delivered — the only exit was the operator re-submitting an identical mapping, and nothing
prompted them to (Greenhouse-Services#48). On a Pi where Mosquitto and the daemon start independently,
that window is the first boot after a power cut.

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

1. Given a new unprovisioned Edge Unit in Provisioning Mode, when the UI triggers backend onboarding scan, then backend BLE scanning starts within 2 seconds and `GET /api/onboarding` exposes discovered devices by identity, with no signal-strength field.
2. Given no advertising Edge Unit, when scan reaches 30 seconds, then backend onboarding state becomes no-device-found, the UI shows Restart, and the backend does not keep scanning.
3. Given multiple advertising Edge Units are discovered during active onboarding scan, when the UI requests `GET /api/onboarding`, then the backend returns all currently active candidates by identity, ordered by discovery time, with no signal-strength field and no proximity ordering claim.
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
17. Given a scan in progress that has discovered no candidates, when the UI calls `POST /api/onboarding/cancel`, then the scan is cancelled and the state becomes `idle` without the client supplying any `device_id`.
18. Given a session active for one device, when `POST /api/onboarding/{device_id}/cancel` names a different device or an unknown id, then the backend returns 409 or 404 respectively and the active session continues running.
19. Given a mapping in a transient status (`publish-pending` or `published`), when the daemon restarts, then that mapping is `failed` with `failureReason` `interrupted` and no mapping remains transient with no publisher.
20. Given an onboarding session in a non-terminal status, when the daemon is stopped inside the scan window and restarted, then the session is `idle` and `no-device-found` was not written.
21. Given mappings at `publish-pending` or at `failed` with an auto-recoverable `failureReason`, when `IMessagingService` transitions to connected, then each is re-published once with its original `message_id` and `mapping_version`, and mappings at `ack-timeout` or `rejected` are not re-published.
22. Given a broker that connects and disconnects repeatedly, when reconnect events arrive within 5 seconds of each other, then recovery passes are coalesced and no unit has more than one publish request in flight.

## Deferred Work

- Full production PKI and certificate lifecycle.
- Bulk onboarding for multiple Edge Units at once.
- Historical diff view for prior Edge Unit configurations.
- Advanced capability inference from I2C ranges beyond initial defaults.
- **D-Bus BLE scanning, and with it a restored proximity signal.** Reading `org.bluez.Device1.RSSI`
  over D-Bus would make candidate signal strength available, which parsing `bluetoothctl` output cannot
  — see Candidate Ordering and Signal Strength. This is a scan-transport change, not a parser fix. If
  taken, `rssi` and a proximity-ordering guarantee return to the candidate contract together.
- **Resuming an interrupted publish rather than restarting it.** Restart and Reconnect Recovery re-sends
  a mapping from the beginning with a fresh retry budget. Resuming mid-budget would need the in-flight
  attempt count persisted, and buys little over a clean re-send that the Edge Unit deduplicates.

## Open Questions

- None for Phase 1 implementation scope; unresolved ideas remain explicitly deferred in this document.
