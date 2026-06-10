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

- Thin web UI client.
- Backend API endpoints.
- View models and request/response presentation shapes.
- User interaction flow.
- Calling application use cases through stable contracts.

Presentation must not construct or depend on infrastructure implementations directly.

Presentation is optional for a configured Main Unit at runtime. The web UI may be unavailable, stopped, or not installed without preventing automation, MQTT handling, command dispatch, persistence, or background services from continuing.

Presentation must not own durable Main Unit state. It reads state through application queries and requests changes through application commands.

The web UI and backend API are separate presentation hosts:

- The web UI is a thin Blazor application that renders views and calls backend APIs.
- The web UI must not host backend API endpoints.
- The web UI must not reference backend implementation projects, infrastructure adapters, BLE libraries, MQTT libraries, or persistence adapters.
- The backend API host exposes RESTful resources over application contracts.
- The backend API host may run in the same process as the Main Unit runtime host or as a separate backend process, but it remains part of the backend, not the web UI.

UI-to-backend communication must use backend-exposed API calls. Long-running workflow progress may use polling or an explicitly documented durable read channel, such as a WebSocket or SignalR connection, but the backend remains the source of truth.

## Runtime Host And Composition

A Main Unit runtime host or composition root wires application contracts to infrastructure implementations and starts long-lived services. This host may be a service process, appliance process, or another deployment-specific executable.

The runtime host owns process startup for:

- MQTT subscriptions and publishing adapters.
- Telemetry and heartbeat processing services.
- Automation scheduling and rule evaluation loops.
- Command dispatch and retry services.
- Persistence adapters and migrations.

The web UI has its own presentation host. It must not be the place where lifecycle-critical runtime services, backend API endpoints, BLE sessions, MQTT connections, or persistence adapters are registered or started.

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
