# Edge Unit Onboarding Spec: BLE First (Phase 1)

## Purpose and Scope

Define the first-time onboarding flow for new Edge Units using BLE as the default provisioning channel.

Decision record: [ADR 0004 — BLE-first onboarding](../../adr/0004-ble-first-onboarding.md) in the documentation repository.

This spec covers:

- BLE-based first-time provisioning
- exchange of WiFi credentials and bootstrap MQTT endpoint
- transition from unprovisioned to operational heartbeat state

This spec does not cover production cryptographic key infrastructure, OTA enrollment, or cloud-based onboarding.

## Preconditions and Assumptions

- Main Unit hardware baseline is Raspberry Pi 4B with BLE support.
- Edge Unit hardware baseline is ESP32 with BLE support.
- Main Unit and Edge Unit are within BLE range during onboarding.
- Main Unit runs an onboarding service capable of BLE scan, pairing, and provisioning payload delivery.

## Canonical Terms

- Edge Unit: ESP32 node that publishes heartbeat and telemetry after onboarding.
- Onboarding: first-time setup workflow for an unprovisioned Edge Unit.
- Provisioning Mode: temporary BLE-advertising mode for onboarding.
- Bootstrap MQTT Endpoint: broker URI value required before first MQTT connection.

## Behavior and Workflow

1. Edge Unit boots and checks for provisioning data.
2. If provisioning data is missing, Edge Unit enters Provisioning Mode.
3. Main Unit scans for unprovisioned Edge Units over BLE.
4. Main Unit establishes BLE session with selected Edge Unit.
5. Main Unit sends provisioning payload.
6. Edge Unit validates payload and stores values in persistent local configuration (NVS-backed storage on ESP32).
7. Edge Unit exits Provisioning Mode and starts normal network bootstrap.
8. Edge Unit connects to WiFi and MQTT.
9. Edge Unit publishes first heartbeat to gh/heartbeat.
10. Main Unit marks onboarding as complete.

Failure behavior:

- If validation fails, Edge Unit remains in Provisioning Mode and reports reason over BLE response.
- If WiFi or MQTT connect fails after valid provisioning, Edge Unit retries with bounded backoff and jitter using a finite retry budget.
- Phase 1 retry budget is 5 total attempts per bootstrap stage (WiFi and MQTT), counted as consecutive failures within that stage.
- If either retry budget is exhausted, Edge Unit re-enters Provisioning Mode (BLE) and waits for a new onboarding attempt.
- If first heartbeat publish fails after MQTT connect, treat this as bootstrap failure in the MQTT stage and continue using the same MQTT retry budget.
- If first-heartbeat publish keeps failing until MQTT retry budget is exhausted, Edge Unit re-enters Provisioning Mode (BLE) and waits for a new onboarding attempt.

Phase 1 bootstrap timing defaults:

- WiFi connection attempt timeout: 10 seconds per attempt.
- MQTT connection attempt timeout: 5 seconds per attempt.
- Retry delay backoff schedule between attempts for a 5-attempt budget: 1s, 2s, 4s, 8s.
- Retry delay jitter: plus or minus 20 percent applied to each scheduled delay.
- Retry counters reset when the corresponding stage succeeds (WiFi connected, MQTT connected).
- Retry counters also reset when a new valid provisioning payload is accepted.
- When the fifth attempt in a stage fails, Edge Unit must re-enter Provisioning Mode immediately without scheduling another delay.

## Data Contract and Schema

Provisioning payload shape (BLE application payload):

```json
{
  "schema_version": 1,
  "device_id": "1ADD5912AF61",
  "wifi_ssid": "ExampleWiFi",
  "wifi_password": "ExamplePassword",
  "mqtt_broker_uri": "mqtt://192.168.1.50",
  "heartbeat_interval_ms": 30000
}
```

Field requirements:

- schema_version: required integer, must be 1 in Phase 1.
- device_id: required string, must match Edge Unit hardware identity.
- wifi_ssid: required string.
- wifi_password: required string, may be empty only for open networks.
- mqtt_broker_uri: required string in URI format.
- heartbeat_interval_ms: optional integer, defaults to 30000 if omitted.

Persistence requirements:

- Edge Unit must persist accepted provisioning values to local non-volatile storage (NVS) so they survive reboot and power loss.
- At minimum, Edge Unit must persist wifi_ssid, wifi_password, and mqtt_broker_uri.
- If heartbeat_interval_ms is provided, Edge Unit must persist and apply it.
- Edge Unit may update these persisted values at any time when a new valid provisioning payload is accepted, including onboarding or later reconfiguration flows.
- Persistence must be applied as one logical configuration update; on write failure, Edge Unit must retain the last known valid configuration.

## GATT Service and Characteristic UUIDs

These UUIDs are canonical. Firmware (NimBLE) stores them in little-endian byte order internally;
the values below are the standard big-endian UUID string representations.

| Role | UUID | Properties |
|---|---|---|
| Onboarding service | `00014452-414f-424e-4f2d-454744454847` | Primary service |
| Provisioning payload characteristic | `00024452-414f-424e-4f2d-454744454847` | Write (with response) |
| Provisioning status characteristic | `00034452-414f-424e-4f2d-454744454847` | Read + Notify |

BLE advertising:
- Edge Unit advertises the onboarding service UUID in its advertisement payload.
- Edge Unit advertisement name follows the pattern `GH-Edge-{device_id}` (e.g. `GH-Edge-1ADD5912AF61`).
- Main Unit BLE scanner filters on the `GH-Edge-` name prefix to discover provisionable Edge Units.

Provisioning write/read flow:
1. Main Unit writes the provisioning payload JSON to the provisioning payload characteristic.
2. Edge Unit validates and processes the payload.
3. Main Unit reads (or receives a notification on) the status characteristic to obtain the result.

## Validation Rules and Error Handling

Edge Unit must reject onboarding payload when:

- schema_version is unsupported
- device_id does not match local hardware identity
- wifi_ssid is empty
- mqtt_broker_uri is missing or malformed

Edge Unit response contract (BLE status response):

- result: success or error
- error_code: stable integer when result is error
- error_message: short diagnostic string for local UI

Phase 1 minimum error code set (canonical):

- 0: success
- 2001: unsupported_schema_version
- 2002: device_id_mismatch
- 2003: wifi_ssid_empty
- 2004: mqtt_broker_uri_invalid
- 2099: internal_persistence_error

Response rules:

- If result is success, error_code must be 0 and error_message should be empty.
- If result is error, error_code must be one of the non-zero codes above and error_message must be a short human-readable diagnostic.
- Edge Unit must return exactly one error code per rejected payload.

## Non-Functional Constraints

- Provisioning Mode must be bounded and low-power friendly.
- Retries for WiFi and MQTT remain non-blocking and bounded with jitter.
- Onboarding should complete within 60 seconds under normal LAN conditions.
- Edge Unit must never require static IP assumptions for broker reachability.

Bootstrap completion note:

- For Phase 1 onboarding completion, the first heartbeat may be a minimal liveness payload and does not need connected peripheral or slot detail.
- Detailed slot and peripheral reporting is deferred to subsequent heartbeat revisions.
- Edge Unit onboarding is complete after the first heartbeat is published successfully to the configured MQTT broker.
- Edge Unit does not require an explicit onboarding ACK message from the Main Unit in Phase 1.
- Successful publish confirms broker-session delivery semantics only and does not prove Main Unit processing; Main Unit session-timeout and device_id matching rules are the source of truth for Main Unit completion state.
- Phase 1 does not require maintaining an active BLE control channel after provisioning payload acceptance; recovery path is re-entering Provisioning Mode and advertising for a new session.

## Acceptance Criteria

- New Edge Unit can be onboarded with no wired connection.
- Main Unit can provision WiFi and MQTT endpoint over BLE to a fresh Edge Unit.
- Edge Unit publishes first heartbeat after successful onboarding.
- Invalid onboarding payloads are rejected with explicit error codes.
- Rebooted, already-provisioned Edge Unit skips Provisioning Mode and proceeds to normal startup.
- Edge Unit loads persisted WiFi and MQTT configuration from NVS on boot and can overwrite persisted values when a newer valid payload is received.

## Out-of-Scope / Deferred Work

- Full production PKI and certificate lifecycle.
- Cloud relay onboarding.
- BLE Mesh onboarding.
- Multi-Main Unit arbitration.

## Open Questions

- What is the exact factory-reset gesture and timeout policy for re-entering Provisioning Mode?
- Should heartbeat_interval_ms be editable by user onboarding flow in Phase 1 UI?
