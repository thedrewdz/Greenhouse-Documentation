# Architecture Boundaries

Use this document when changing adapters, ports, DTOs, validation, or error handling.

## Boundary Principle

External systems are details. Domain and application policy must work with Greenhouse concepts, not raw transport or storage shapes.

## Boundary Responsibilities

Boundary code must:

- Parse external data.
- Validate required fields and value ranges.
- Reject invalid input before policy code uses it.
- Translate external DTOs into internal models.
- Translate internal results back into external responses or payloads.
- Preserve clear error semantics.

## Ports And Adapters

Application-owned ports define what the software needs. Infrastructure adapters define how those needs are fulfilled.

Examples:

- MQTT adapter implements generic message transport ports such as `IMessagingService`.
- Persistence adapter implements repository or state-store ports.
- BLE adapter implements Edge Unit onboarding transport ports.
- Backend API adapter exposes RESTful resources over application contracts for the local UI and other local clients.
- Notification adapter implements user notification ports.

`IMessagingService` is a transport abstraction, not a domain router. It should move message envelopes across MQTT and notify subscribers that a message arrived. It must not parse message content into Heartbeat, Telemetry, command acknowledgement, read response, onboarding, or reconfiguration models.

## DTO Rules

- MQTT payload DTOs stay near MQTT adapter boundaries.
- Generic message envelopes may cross the messaging service boundary when they contain transport metadata and raw payload content only.
- API request/response DTOs stay near backend API presentation boundaries.
- UI view models stay in the UI and must be translated to backend API request/response DTOs.
- Database records stay near persistence boundaries.
- Domain/application code should receive named domain or application models.

## UI API Rules

The UI must communicate with the Main Unit backend through backend-exposed API calls. It must not call application services, infrastructure services, BLE adapters, MQTT adapters, repositories, or database contexts directly.

UI-facing API calls must be RESTful:

- Each request must contain all information needed to process that request, aside from persisted backend state.
- Request handling must not depend on in-memory state from a previous HTTP request by the same UI client.
- Mutating operations must be idempotent from the UI client's point of view. Prefer client-supplied resource identifiers, idempotency keys, or `PUT`/`DELETE` semantics for workflow actions.
- API responses should return resource representations, operation status resources, or links/identifiers for follow-up reads.
- Backend services may be stateful, but that state must be represented as backend-owned resources that can be queried or updated through stateless API requests.

Long-running workflows, such as Edge Unit onboarding, must expose backend-owned workflow state resources. The UI may poll these resources or subscribe to an explicitly documented realtime read channel. Realtime channels are for observation and progress updates; they must not make the UI the owner of workflow state.

## Error Semantics

Errors must be part of the contract:

- validation error
- unavailable dependency
- timeout
- retryable failure
- rejected command
- stale topology
- unsafe actuator command

Do not leak infrastructure exception types into domain policy unless the contract explicitly allows it.

## Documentation Requirements

Update or verify canonical docs when changing:

- MQTT topics or payload fields.
- API contracts.
- onboarding/reconfiguration message shapes.
- persistence semantics that affect behavior.
- error handling visible to users, operators, or Edge Units.
