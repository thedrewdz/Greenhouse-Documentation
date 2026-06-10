# Architecture Layers

Use this document when changing project/module structure, dependency direction, or ownership boundaries.

## Layer Ownership

## Domain Layer

Owns:

- Greenhouse domain concepts and language.
- Automation rules and deterministic policy.
- State transitions and invariants.
- Value objects and domain services when they carry real behavior.

Must not depend on:

- UI frameworks.
- MQTT clients.
- Databases.
- BLE libraries.
- Hardware drivers.
- Cloud or AI SDKs.

## Application Layer

Owns:

- Use cases and workflow orchestration.
- Ports/interfaces used by domain and application policy.
- Command/query handlers.
- Transaction and consistency boundaries.
- Coordination between domain behavior and infrastructure ports.

Must not depend on infrastructure implementations.

## Infrastructure Layer

Owns:

- MQTT clients, subscriptions, publishing, serialization, and retry behavior.
- Database implementations and migrations.
- BLE provisioning adapters.
- Hardware/OS integrations.
- Future cloud, weather, AI, or notification adapters.

Infrastructure implements application-owned contracts.

## Presentation Layer

Owns:

- Web UI and API endpoints.
- View models and request/response presentation shapes.
- User interaction flow.
- Calling application use cases through stable contracts.

Presentation must not construct or depend on infrastructure implementations directly.

Presentation is optional for a configured Main Unit at runtime. The web UI may be unavailable, stopped, or not installed without preventing automation, MQTT handling, command dispatch, persistence, or background services from continuing.

Presentation must not own durable Main Unit state. It reads state through application queries and requests changes through application commands.

## Runtime Host And Composition

A Main Unit runtime host or composition root wires application contracts to infrastructure implementations and starts long-lived services. This host may be a service process, appliance process, or another deployment-specific executable.

The runtime host owns process startup for:

- MQTT subscriptions and publishing adapters.
- Telemetry and heartbeat processing services.
- Automation scheduling and rule evaluation loops.
- Command dispatch and retry services.
- Persistence adapters and migrations.

The web UI may have its own presentation host, but it must not be the only place where lifecycle-critical runtime services are registered or started.

## Dependency Direction

Dependencies point inward:

```text
Presentation -> Application -> Domain
Infrastructure -> Application -> Domain
Runtime Host -> Application + Infrastructure
```

Composition roots wire concrete infrastructure implementations to application contracts.

## Review Checklist

- Can each changed file be assigned to one layer?
- Does any inner layer reference an outer-layer implementation?
- Are infrastructure details isolated behind ports/adapters?
- Does presentation call application contracts instead of infrastructure classes?
- Are domain terms preserved at the domain/application boundary?
