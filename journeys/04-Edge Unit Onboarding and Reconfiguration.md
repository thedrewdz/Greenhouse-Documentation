# Edge Unit Onboarding and Reconfiguration User Journey

## Goal

Ensure the Main Unit can onboard new Edge Units using BLE-first provisioning, then maintain configuration correctness over time using heartbeat-driven runtime checks.

This journey is only for Edge Unit onboarding and reconfiguration.
It does not perform Main Unit first-run setup, network setup, or general greenhouse configuration.

## Preconditions and Assumptions

- Main Unit setup is complete.
- Main Unit can run BLE scan and pairing for onboarding.
- Unprovisioned Edge Units can enter Provisioning Mode and advertise over BLE.
- Main Unit receives runtime heartbeats on gh/heartbeat after onboarding.
- Main Unit is the source of truth for runtime configuration and slot mapping.
- Edge Units do not persist long-term runtime configuration in Phase 1.

## Flow Separation

- Setup: Main Unit first-run network and general information flow.
- Onboarding: first-time provisioning of a new Edge Unit.
- Reconfiguration: updates for a known Edge Unit when topology changes.

## BLE Pairing Roles

- Edge Unit advertises over BLE when unprovisioned and in Provisioning Mode.
- Main Unit scans for advertising Edge Units and initiates pairing.
- Main Unit owns onboarding orchestration, validation, and user guidance.

## Routing Rules

Given an Edge Unit is discovered over BLE and has no stored provisioning state.
When onboarding is initiated.
Then route to Edge Unit Onboarding flow.

Given a heartbeat is received from a known Edge Unit.
When discovered slot topology differs from stored configuration.
Then route to Edge Unit Reconfiguration flow.

Given a heartbeat is received from a known Edge Unit.
When discovered slot topology matches stored configuration.
Then continue normal operation and update runtime state only.

Given the Main Unit is scanning for advertising Edge Units.
When the user navigates away from Edge Unit pairing.
Then stop BLE scanning immediately on the Main Unit.

Given the Main Unit is scanning for advertising Edge Units.
When scan timeout is reached with no Edge Unit discovered.
Then route to No Edge Unit Discovered timeout state.

## Journey

### A. First-Time Edge Unit Onboarding (BLE Provisioning)

Given the user clicks Add Edge Unit.
When the action is initiated.
Then the Main Unit starts scanning for advertising Edge Units and shows guidance to power on an Edge Unit and place it in Provisioning Mode.

Given the Main Unit is scanning for advertising Edge Units.
When no Edge Unit is discovered yet.
Then keep showing onboarding guidance and continue scanning until timeout, cancellation, or discovery.

Given the Main Unit is scanning for advertising Edge Units.
When the user navigates away from Edge Unit pairing.
Then stop BLE scanning immediately on the Main Unit.

Given the Main Unit reaches scan timeout with no Edge Unit discovered.
When No Edge Unit Discovered timeout state is shown.
Then provide clear feedback that no advertising Edge Units were found and show a Restart action.

Given the user clicks Restart in No Edge Unit Discovered timeout state.
When Restart is confirmed.
Then restart the entire Add Edge Unit process on the Main Unit, including onboarding guidance and BLE scan from the beginning.

Given an unprovisioned Edge Unit is advertising over BLE.
When the Main Unit scan detects candidates.
Then show a selectable list with device identity and signal quality.

Given the user selects an Edge Unit.
When BLE pairing and session establishment succeeds.
Then collect and validate onboarding input:

- WiFi SSID (required)
- WiFi password (optional for open networks)
- MQTT broker URI (required)
- Optional heartbeat interval override in milliseconds

Given onboarding input is valid.
When the user confirms onboarding.
Then the Main Unit sends provisioning payload to the selected Edge Unit with:

- schema_version
- device_id
- wifi_ssid
- wifi_password
- mqtt_broker_uri
- heartbeat_interval_ms (optional)

Given the Edge Unit validates and stores provisioning payload.
When WiFi and MQTT bootstrap succeeds.
Then the Edge Unit publishes first heartbeat and the Main Unit marks onboarding complete.

Given provisioning payload is invalid.
When the Edge Unit rejects the payload.
Then display explicit error details, keep the unit in Provisioning Mode, and allow retry.

Given payload is valid but WiFi or MQTT connection fails.
When bootstrap retries are underway.
Then show connecting status and allow user cancellation or retry without losing selected Edge Unit context.

### B. Runtime Registration and Slot Mapping

Given first heartbeat has been received from a newly onboarded Edge Unit.
When no stored runtime mapping exists.
Then prompt the user to configure:

- unit name and location
- slot role per discovered slot (sensor or actuator)
- capability mapping per slot
- optional display labels

Given runtime mapping input is valid.
When user confirms.
Then store mapping locally and publish configuration to the Edge Unit.

### C. Edge Unit Reconfiguration

Given a known Edge Unit heartbeat is received.
When slot topology or module identity differs from stored mapping.
Then show a reconfiguration prompt that clearly identifies detected changes.

Given user confirms reconfiguration.
When updated mapping is saved.
Then store new configuration, publish updates to the Edge Unit, and resume normal operation.

## Success Criteria

- A new Edge Unit can be onboarded without wired provisioning.
- Main Unit can deliver WiFi and bootstrap MQTT endpoint over BLE.
- Edge Unit publishes first heartbeat after successful provisioning.
- Invalid provisioning payloads are rejected with explicit error details.
- New runtime mappings can be created from discovered slot topology.
- Topology drift for known Edge Units is detected and routed to reconfiguration.

## Deferred Items

- Full production PKI and certificate lifecycle.
- Bulk onboarding for multiple Edge Units at once.
- Historical diff view for prior Edge Unit configurations.
- Advanced capability inference from I2C ranges beyond initial defaults.

