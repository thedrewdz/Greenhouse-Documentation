# BLE-First Onboarding for Edge Units

Status: accepted  
Date: 2026-06-02  
Source: originally recorded in `/edge/docs/adr/0001-ble-first-onboarding.md`; consolidated here
as this decision affects both Edge Unit firmware and Main Unit services.

Phase 1 onboarding for new Edge Units defaults to BLE, with wired onboarding retained only as
an optional fallback for recovery and manufacturing workflows.

This decision was made because onboarding must be accessible to non-technical users and should
not depend on manual cable handling or static-IP setup, while still preserving a service path
when BLE is unavailable.

## Considered Options

- BLE-first onboarding with wired fallback
- Wired-first onboarding (I2C/connector) with optional BLE
- Wired-only onboarding

## Decision

BLE-first with wired fallback. The Edge Unit firmware enters an explicit unprovisioned
Provisioning Mode over BLE before normal WiFi and MQTT startup. The Main Unit provides BLE
discovery, auto-provisioning payload delivery (WiFi credentials from storage, MQTT broker URI
derived from Main Unit local address), and success confirmation after the first heartbeat.

## Consequences

- Firmware must support an explicit Provisioning Mode over BLE before normal WiFi and MQTT startup.
- Main Unit must provide BLE discovery, payload delivery, and success confirmation after first heartbeat.
- Provisioning payload contracts are a stable interface between Main Unit and Edge Unit firmware.
- WiFi credentials must be stored on the Main Unit (see `specs/main-unit-setup/spec.md`
  §WifiCredentialsEntity) so they can be included in the provisioning payload without prompting
  the user again during Edge Unit onboarding.
- The `mqtt_broker_uri` is derived automatically from the Main Unit's local network address;
  the user is never required to enter it.
- Security hardening details remain deferred to implementation-phase specs and follow-on ADRs.
