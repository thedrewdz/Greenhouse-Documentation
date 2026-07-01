# Greenhouse Platform Context

This context defines shared domain language for the Greenhouse documentation hub.
Use these terms consistently across all docs, design discussions, and implementation planning.

## Language

### Platform Topology

**Main Unit**:
The local system authority that runs automation, coordinates Edge Units, and issues commands over MQTT.
Avoid: legacy aliases for this role

Deprecated aliases to avoid:

- server
- cloud backend

**Edge Unit**:
An ESP32-based unit connected to the Main Unit over MQTT.
Avoid: legacy aliases for this role

**UI**:
The Main Unit touchscreen operator interface — a Flutter app rendered via flutter-pi.
The GitHub repository is named `Greenhouse-WebUI` for technical reasons; this does not make
"WebUI" a canonical term. Always refer to it as "UI" or "Main Unit UI" in specs, docs, and
issue titles.
Avoid: WebUI, web app, web UI, dashboard app

**Sensor Edge Unit**:
An Edge Unit role that reports measurements from attached sensors.
Avoid: Reader node

**Actuator Edge Unit**:
An Edge Unit role that executes hardware actions through attached actuators.
Avoid: Output node

### Hardware Model

**Slot**:
A numbered attachment point on an Edge Unit for one Peripheral Unit.
Avoid: Port, channel

**Module**:
A sensor or actuator module attached to a slot.
Avoid: Addon, plugin

**Peripheral Unit**:
A microcontroller-based unit hosted by an Edge Unit and hard-coded for a specific sensor or actuator.
A Peripheral Unit communicates with its hosting Edge Unit exclusively over I2C: it receives a generic instruction from the Edge Unit, executes the sensor read or actuator action, and returns a canonicalized response to the Edge Unit.
Peripheral Units own all sensor- or actuator-specific hardware interactions, keeping Edge Unit firmware hardware-agnostic.
A Peripheral Unit may be sensor-oriented (reads a measurement and returns a canonicalized telemetry value) or actuator-oriented (executes an actuator action and returns a canonicalized status response).
The hosting Edge Unit mediates between MQTT commands from the Main Unit and I2C instructions to Peripheral Units; Peripheral Units have no direct MQTT presence.
Avoid: sensor MPU, actuator MPU (use "sensor Peripheral Unit" or "actuator Peripheral Unit" when the role must be specified)

**Slot Fault Isolation**:
A fault containment rule where one failing slot does not cascade failure to other slots.
Avoid: Global I2C reset strategy

### Messaging

**Telemetry**:
Published measurement or state data emitted by an Edge Unit.
Avoid: Metrics, logs

**Heartbeat**:
A periodic liveness and topology/state message from an Edge Unit.
Avoid: Ping packet

**Command Topic**:
The MQTT topic namespace used by the Main Unit to request Edge Unit actions.
Avoid: RPC endpoint

**Canonical Payload**:
The project-standard message shape and field semantics for MQTT payloads.
Avoid: Ad hoc payload

### Provisioning and Onboarding

**Setup**:
Main Unit first-run flow for network and general greenhouse configuration.
Avoid: Using setup for Edge Unit flows

**Onboarding**:
First-time setup flow where a new Edge Unit receives bootstrap connectivity data from the Main Unit.
Avoid: Manual preconfiguration

**Reconfiguration**:
Flow for a known Edge Unit when discovered slot topology or module mapping differs from stored configuration.
Avoid: Treating topology drift as first-run setup

**Provisioning Mode**:
Temporary state where an unprovisioned Edge Unit advertises over BLE and accepts onboarding data.
Avoid: Permanent pairing mode

**BLE Provisioning**:
Phase 1 onboarding transport used to exchange WiFi credentials and bootstrap MQTT endpoint data.
Avoid: Static-IP-only bootstrap

**Bootstrap MQTT Endpoint**:
The broker URI needed by an Edge Unit before first MQTT connection.
Avoid: Hard-coded static IP assumptions

### Reliability and Safety

**Offline Buffering**:
Bounded local retention of outbound messages while connectivity is unavailable.
Avoid: Infinite queueing

**Failsafe State**:
The safe actuator condition maintained during uncertain or degraded conditions.
Avoid: Last-known-good if unsafe



