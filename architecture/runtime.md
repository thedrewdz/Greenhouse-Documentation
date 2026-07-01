# Runtime Architecture

Use this document when changing message handling, background services, subscriptions, scheduling, or use-case orchestration.

## Runtime Model

The Main Unit runs long-lived local services that coordinate automation and Edge Unit communication.

Runtime responsibilities include:

- MQTT subscription and publishing.
- Telemetry ingestion.
- Heartbeat processing.
- Topology/state tracking.
- Automation rule evaluation.
- Command dispatch.
- Backend API request handling when enabled.
- Onboarding and reconfiguration workflow coordination.

## Headless Operation

After Main Unit setup is complete, the configured Main Unit must support headless startup. Headless startup means the runtime starts without launching the local touchscreen UI.

In headless operation, the Main Unit must still:

- load persisted configuration, topology, automation rules, and runtime state needed for operation
- subscribe to MQTT topics and process telemetry and heartbeat messages
- evaluate automation rules and schedules
- publish commands to Edge Units
- persist telemetry, liveness snapshots, audit-relevant command history, and state changes
- recover bounded offline buffers according to documented retry and retention rules

UI availability is not a prerequisite for these runtime responsibilities. Backend API availability may be enabled for local clients, but API request handling must not be required for automation loops, MQTT handling, command dispatch, persistence, or workflow recovery.

## Backend API Runtime

The backend API is part of the Main Unit backend, not part of the Flutter UI process.

The backend API exposes RESTful resources for:

- current runtime state
- Edge Unit registration and topology
- telemetry and liveness summaries
- command requests and command history
- onboarding and reconfiguration workflow state resources
- setup and network recovery workflow resources where applicable

API handlers should be short-lived request handlers that validate input, call application use cases, and return resource representations or operation status. They must not own long-lived workflow state directly.

Long-lived workflow state belongs to backend application/runtime services and persistence. For example, Edge Unit onboarding owns BLE scanning, discovered Edge Unit candidates, selected-device handoff, pairing, provisioning, heartbeat waiting, timeout handling, cancellation, and final completion state in backend services. The UI starts or cancels onboarding through API calls and observes onboarding state through polling or an explicitly documented realtime read channel.

If a realtime channel is introduced, it must be treated as a read/progress channel. Durable state changes still go through backend application use cases and must remain recoverable from backend state.

## Message Handling

MQTT is a transport boundary. Message handlers must translate payloads into application commands, events, or state updates before policy code acts on them.

Recurring message streams, such as heartbeats and telemetry, are runtime-wide concerns. Do not bury long-lived subscriptions inside setup-only or feature-lifecycle-specific services.

## Code Biases For Long-Lived Runtime Concerns

Prefer explicit long-lived services for cross-cutting runtime responsibilities that must survive without the UI. These services should be owned by the Main Unit runtime host and governed by application/core contracts.

The first required long-lived service is `IMessagingService`.

`IMessagingService` owns generic message transport over MQTT:

- send messages
- receive messages
- expose message-received registration for other long-lived services and application services
- allow subscribers to unsubscribe
- maintain connection, subscription, reconnect, and transport health behavior

`IMessagingService` must be message type/content agnostic. It should treat each inbound or outbound item as a message envelope containing transport metadata and payload content. It must not know whether a message is a Heartbeat, Telemetry item, command acknowledgement, read response, onboarding event, or future message type.

Message senders are responsible for choosing the topic and payload shape. Message subscribers are responsible for deciding whether a received message is relevant and for parsing, validating, and processing its content through the correct application use case.

Do not add topic-specific methods such as `PublishHeartbeatAsync`, `HandleAckAsync`, or `SubscribeToTelemetryAsync` to `IMessagingService`. Topic-specific behavior belongs in subscriber services or application handlers that register with `IMessagingService`.

## Background Services

Background services may own:

- long-lived subscriptions
- scheduling loops
- retry loops
- offline buffer flushes
- health monitoring

Background services should delegate decisions to application/domain services instead of owning business policy directly.

Lifecycle-critical background services must be registered with the Main Unit runtime host, not with the UI host. The backend API may invoke application contracts, and the UI may observe or request changes through backend API calls, but stopping the UI must not stop automation, MQTT handling, command dispatch, onboarding workflows, or persistence.

## Workflow Separation

Keep these workflows distinct:

- Main Unit setup: first-run network and greenhouse configuration.
- Network recovery: reconnecting a configured Main Unit.
- Edge Unit onboarding: first-time provisioning of an unprovisioned Edge Unit.
- Edge Unit reconfiguration: topology or mapping updates for a known Edge Unit.

Shared runtime services may support multiple workflows, but workflow-specific orchestration must not redefine terms or contracts.

## AI And Cloud Runtime Rule

AI and cloud integrations are advisory or optional unless a future ADR changes that rule. Critical automation must continue locally without internet connectivity.
