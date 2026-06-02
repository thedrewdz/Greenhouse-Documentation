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

**Sensor Edge Unit**:
An Edge Unit role that reports measurements from attached sensors.
Avoid: Reader node

**Actuator Edge Unit**:
An Edge Unit role that executes hardware actions through attached actuators.
Avoid: Output node

### Hardware Model

**Slot**:
A numbered attachment point on an Edge Unit for one module.
Avoid: Port, channel

**Module**:
A sensor or actuator module attached to a slot.
Avoid: Addon, plugin

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



