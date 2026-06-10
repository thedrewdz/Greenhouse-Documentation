# Software Architecture

This document is the central software architecture hub for the Greenhouse platform.

Use it to understand software boundaries, dependency direction, runtime collaboration, and implementation constraints. Load the focused detail documents under [architecture/](architecture/) only when the task touches that area.

For physical deployment, hardware makeup, host choices, Edge Unit makeup, and operational topology, read [system-topology.md](system-topology.md).

## Architecture Goals

- Keep automation local-first and deterministic.
- Keep domain policy independent from UI, storage, MQTT, hardware drivers, and future cloud or AI adapters.
- Keep the configured Main Unit able to run headless, without starting or serving the web UI.
- Preserve MQTT-centered integration while preventing transport details from leaking into domain behavior.
- Make contracts explicit and testable before implementation.
- Keep Main Unit setup, network recovery, Edge Unit onboarding, and Edge Unit reconfiguration as separate workflows.
- Support incremental implementation without speculative frameworks.

## Software System Boundary

The Main Unit is the local system authority for software orchestration:

- owns automation policy and scheduling
- receives telemetry and heartbeat messages
- issues commands to Edge Units over MQTT
- persists configuration, topology, telemetry, and audit-relevant state
- exposes local UI and API surfaces
- coordinates Edge Unit onboarding and reconfiguration workflows

The web UI is optional for normal operation after Main Unit setup is complete. A configured Main Unit must be able to start its runtime services, load persisted state, process MQTT traffic, evaluate automation rules, dispatch commands, and maintain state without a browser session, web dashboard, or presentation host being active.

The UI and API are presentation clients of the Main Unit application contracts. They may display state and initiate user-driven use cases, but they must not own automation state, lifecycle-critical subscriptions, scheduling loops, or persistence authority.

Edge Unit firmware is a cooperating distributed endpoint. It publishes telemetry and heartbeat data, accepts commands, reports state, and enforces local failsafe behavior. Firmware-specific contracts live in [device-model.md](device-model.md), [mqtt-topics.md](mqtt-topics.md), and relevant specs.

## Layer Model

Use inward dependency direction:

1. Domain: greenhouse concepts, automation rules, invariants, and state transitions.
2. Application: use cases, workflow orchestration, ports, and transaction boundaries.
3. Infrastructure: MQTT, persistence, BLE, hardware adapters, OS services, and external integrations.
4. Presentation: web UI, API endpoints, screens, view models, and user interaction flows.

Outer layers may depend on inner layers. Inner layers must not depend on outer-layer implementations.

Read [architecture/layers.md](architecture/layers.md) when changing project/module structure, dependency direction, or layer ownership.

## Boundary Rules

- Parse and validate external input at system boundaries.
- Translate MQTT payloads, HTTP/API requests, BLE messages, database records, and hardware-driver responses into domain/application models before policy code uses them.
- Keep domain/application code free of framework, transport, storage, and hardware-driver types.
- Model error semantics as part of contracts.
- Treat recurring integration streams, such as heartbeats, as runtime-wide concerns behind shared abstractions.

Read [architecture/boundaries.md](architecture/boundaries.md) when changing adapters, ports, DTOs, validation, or error handling.

## Runtime Collaboration

Runtime behavior is message-oriented but not message-shaped internally:

- MQTT is the transport boundary.
- Application handlers own use-case decisions.
- Domain services/entities own domain rules and invariants.
- Infrastructure adapters own subscription, publishing, serialization, retry, and transport-specific behavior.
- Presentation initiates user-driven use cases through application contracts.

Read [architecture/runtime.md](architecture/runtime.md) when changing message handling, background services, subscriptions, scheduling, or use-case orchestration.

## Persistence

Persistence is an infrastructure detail behind application-owned ports. Storage choices must not shape domain behavior.

Initial local persistence is SQLite unless a specific spec or ADR says otherwise. Future storage engines must preserve domain-facing contracts and migration paths.

Read [architecture/persistence.md](architecture/persistence.md) when changing repositories, database schema, migrations, telemetry storage, or configuration persistence.

## Testing Strategy

Use behavior-focused tests at the smallest useful boundary:

- Domain tests for rules, invariants, calculations, and state transitions.
- Application tests for use cases, orchestration, and port collaboration.
- Contract tests for MQTT payloads, API schemas, DTO mapping, and adapter interfaces.
- Integration tests for persistence, MQTT adapters, BLE adapters, and framework wiring.
- Scenario/QA validation for user-visible workflows and acceptance criteria.

Read [architecture/testing.md](architecture/testing.md) when planning test coverage, closing test gaps, or reviewing verification strategy.

## Detail Documents

- [architecture/layers.md](architecture/layers.md): layer ownership, dependency direction, and project/module expectations.
- [architecture/boundaries.md](architecture/boundaries.md): ports, adapters, DTO translation, validation, and error semantics.
- [architecture/runtime.md](architecture/runtime.md): message handling, background services, subscriptions, and workflow orchestration.
- [architecture/persistence.md](architecture/persistence.md): storage boundaries, repositories, migrations, telemetry, and configuration state.
- [architecture/testing.md](architecture/testing.md): test layers, contract tests, integration tests, and acceptance verification.

## Related Canonical Docs

- [system-topology.md](system-topology.md): physical/logical system makeup, deployment assumptions, hardware, and host configuration.
- [CONTEXT.md](CONTEXT.md): canonical terminology.
- [device-model.md](device-model.md): Edge Unit, slot, module, telemetry, heartbeat, and device identity model.
- [mqtt-topics.md](mqtt-topics.md): MQTT topics and canonical payload contracts.
- [control-unit-model.md](control-unit-model.md): Main Unit domain model and automation behavior.
- [workflows/feature-delivery-harness.md](workflows/feature-delivery-harness.md): delivery loop, status gates, and artifact flow.
