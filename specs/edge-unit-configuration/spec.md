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
- When the first heartbeat arrives, mark onboarding complete.

### Runtime Registration and Slot Mapping

- When the first heartbeat arrives from a newly onboarded Edge Unit and no runtime mapping exists, prompt the user to configure unit name, location, slot role per discovered slot, capability mapping, and optional display labels.
- When the mapping input is valid, store it locally and publish configuration to the Edge Unit.

### Reconfiguration

- When a heartbeat arrives from a known Edge Unit and slot topology or module identity differs from stored mapping, show a reconfiguration prompt that identifies the detected changes.
- When the user confirms reconfiguration, store the new mapping, publish updates to the Edge Unit, and resume normal operation.

## Data Contracts and Schemas

- The BLE provisioning payload shape and field-level validation rules live in [../edge-unit-onboarding/spec.md](../edge-unit-onboarding/spec.md).
- This spec uses that contract as the provisioning boundary and focuses on the user-facing orchestration around it.

## Acceptance Criteria

- A new Edge Unit can be onboarded without wired provisioning.
- Main Unit can deliver Wi-Fi and bootstrap MQTT endpoint data over BLE to a fresh Edge Unit.
- Edge Unit publishes first heartbeat after successful provisioning.
- Invalid provisioning payloads are rejected with explicit error details.
- New runtime mappings can be created from discovered slot topology.
- Topology drift for known Edge Units is detected and routed to reconfiguration.
## Deferred Work

- Full production PKI and certificate lifecycle.
- Bulk onboarding for multiple Edge Units at once.
- Historical diff view for prior Edge Unit configurations.
- Advanced capability inference from I2C ranges beyond initial defaults.
