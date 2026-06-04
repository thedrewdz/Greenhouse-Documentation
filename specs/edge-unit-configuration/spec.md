# Spec: Edge Unit Onboarding and Reconfiguration

## Purpose and Scope

Define the user-facing workflow for onboarding new Edge Units and for reconfiguring known Edge Units when topology or module mapping changes.

The low-level BLE provisioning contract remains in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).

This spec replaces the former Edge Unit onboarding and reconfiguration journey document.

## Preconditions and Assumptions

- Main Unit setup is complete.
- The Main Unit can scan for advertising Edge Units and pair over BLE.
- Unprovisioned Edge Units can enter Provisioning Mode and advertise over BLE.
- The Main Unit receives runtime heartbeats on `gh/heartbeat` after onboarding.
- The Main Unit is the source of truth for runtime configuration and slot mapping.
- Edge Units do not persist long-term runtime configuration in Phase 1 beyond the accepted provisioning values required by the BLE onboarding contract.

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

- When the user starts Add Edge Unit, begin BLE scanning and show guidance to power on an Edge Unit and place it in Provisioning Mode.
- Keep scanning until timeout, cancellation, or discovery.
- If the user navigates away, stop BLE scanning immediately.
- If no Edge Unit is discovered before timeout, show a clear no-device state with a Restart action.
- When a device is discovered, show a selectable list with device identity and signal quality.
- After pairing succeeds, collect onboarding input for Wi-Fi SSID, Wi-Fi password, MQTT broker URI, and optional heartbeat interval override.
- When input is valid, send the provisioning payload required by the BLE onboarding contract.
- If the Edge Unit rejects the payload, show explicit error details and allow retry.
- If Wi-Fi or MQTT bootstrap fails after a valid payload, keep the selected device context and allow retry or cancellation.
- If first-heartbeat publish fails after MQTT connect, treat it as MQTT bootstrap failure and apply the same bounded retry-budget behavior defined in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md), including fallback to BLE provisioning when the MQTT-stage retry budget is exhausted.
- When the first valid heartbeat arrives from the selected device_id for the active onboarding session, persist that heartbeat as the current Edge Unit state and mark onboarding complete.
- A first heartbeat may also trigger subsequent runtime registration work, but for Phase 1 happy-path onboarding the flow completes at this point.
- If no valid heartbeat arrives before the onboarding session timeout, mark onboarding failed and show a clear user-facing failure state.
- Main Unit does not auto-retry onboarding after timeout.
- If the user selects Retry from the failure state, navigate to the Edge Unit onboarding view and restart BLE scanning as a new onboarding session.

### Runtime Registration and Slot Mapping

- When the first heartbeat arrives from a newly onboarded Edge Unit and no runtime mapping exists, prompt the user to configure unit name, location, slot role per discovered slot, capability mapping, and optional display labels.
- When the mapping input is valid, store it locally and publish configuration to the Edge Unit.

### Reconfiguration

- When a heartbeat arrives from a known Edge Unit and slot topology or module identity differs from stored mapping, show a reconfiguration prompt that identifies the detected changes.
- When the user confirms reconfiguration, store the new mapping, publish updates to the Edge Unit, and resume normal operation.

## Data Contracts and Schemas

### BLE Provisioning Boundary

- The BLE provisioning payload shape and field-level validation rules live in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- The BLE provisioning response shape and canonical onboarding error code set live in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- This spec uses that contract as the provisioning boundary and focuses on the user-facing orchestration around it.
- Main Unit onboarding UI should map returned error_code values directly to user-facing retry guidance without redefining code semantics locally.

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

- BLE scan startup after user selects Add Edge Unit must begin within 2 seconds.
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

1. Given a new unprovisioned Edge Unit in Provisioning Mode, when user starts Add Edge Unit, then BLE scanning starts within 2 seconds and discovered devices are listed with identity and signal quality.
2. Given no advertising Edge Unit, when scan session reaches 30 seconds, then Main Unit shows a no-device state with Restart and does not keep scanning in background.
3. Given valid onboarding input and accepted provisioning payload, when first valid heartbeat from selected `device_id` arrives within 90 seconds, then onboarding is marked complete and heartbeat state is persisted.
4. Given onboarding input rejected by BLE provisioning validation, when Edge Unit returns non-zero onboarding `error_code`, then Main Unit shows explicit error details and allows retry without losing selected device context.
5. Given first heartbeat from a device with no stored runtime mapping, when user submits valid mapping input, then Main Unit publishes configuration on `ghcfg/wr-{device_id}` with required schema fields.
6. Given runtime configuration publish, when Edge Unit returns ack on `ghcfg/ack-{device_id}`, then ack has matching `message_id`, `device_id`, and `mapping_version` and result is processed exactly once.
7. Given runtime configuration ack timeout, when fewer than 3 attempts have been sent, then Main Unit retries with same `message_id` and `mapping_version`; on third timeout it enters failure state with retry/cancel actions.
8. Given invalid runtime mapping form input, when user attempts submit, then Main Unit blocks publish, shows field-level validation errors, and preserves form values.
9. Given runtime-configuration error codes `3001`, `3002`, `3003`, `3004`, or `3099`, when ack is received with `result=error`, then Main Unit behavior follows the deterministic handling defined in this spec.
10. Given topology drift for known device, when mismatch is detected from heartbeat, then reconfiguration prompt appears within 5 seconds and prior acknowledged mapping remains active until new mapping is acknowledged as success.
11. Given reconfiguration dialog open and a new heartbeat with changed topology, when drift snapshot changes, then draft is marked stale and user must reload from latest topology before submit.
12. Given accepted runtime mapping update, when persistence occurs, then mapping write is atomic and no partial mapping state is observable.
## Deferred Work

- Full production PKI and certificate lifecycle.
- Bulk onboarding for multiple Edge Units at once.
- Historical diff view for prior Edge Unit configurations.
- Advanced capability inference from I2C ranges beyond initial defaults.

## Open Questions

- None for Phase 1 implementation scope; unresolved ideas remain explicitly deferred in this document.
