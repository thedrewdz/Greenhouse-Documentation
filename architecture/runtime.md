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

### IMessagingService Contract

```
PublishAsync(topic: string, payload: string, cancellationToken) → Task
Subscribe(topicPattern: string, handler: Func<MessageEnvelope, Task>) → void
Unsubscribe(topicPattern: string) → void
```

`MessageEnvelope` carries transport metadata only:

```
Topic: string       — exact received topic
Payload: string     — raw payload string, not parsed
ReceivedAt: DateTime — UTC receipt timestamp
```

Topic patterns follow MQTT wildcard conventions (`+` single-level, `#` multi-level).
Subscribers register at startup via the runtime host composition root.
Feature services must not call `Subscribe` from inside request handlers or use-case constructors.

### MqttMessagingService (Concrete Implementation)

- Lives in `Greenhouse.Mqtt`.
- Registered as both `IMessagingService` (singleton) and `IHostedService` in `Program.cs`.
- Starts the MQTT client connection on `StartAsync`; reconnects automatically on disconnect.
- Dispatches inbound messages to all matching subscribers on the thread pool.
- Does not parse payload content.

## BLE Transport

BLE is used exclusively for Edge Unit onboarding in Phase 1. It is not a persistent connection; the
BLE session is only active while an onboarding workflow is in progress.

### Two-Layer BLE Architecture

BLE is split into two layers to keep BLE mechanics out of application code:

**Layer 1 — `IBleTransport` (infrastructure-internal, `Greenhouse.Bluetooth`)**

A low-level transport building block used only within the `Greenhouse.Bluetooth` project. It is
not an application-layer port and must not be referenced by `Greenhouse.Core`, `Greenhouse.Runtime`,
or `Greenhouse.Api`.

```
ScanAsync(filter: BleScanFilter, cancellationToken) → Task<IReadOnlyList<BleDeviceInfo>>
ConnectAsync(deviceId: string, cancellationToken) → Task
WriteCharacteristicAsync(deviceId, serviceUuid, characteristicUuid, data, cancellationToken) → Task
ReadCharacteristicAsync(deviceId, serviceUuid, characteristicUuid, cancellationToken) → Task<byte[]>
DisconnectAsync(deviceId: string, cancellationToken) → Task
```

GATT UUIDs are private constants inside `Greenhouse.Bluetooth` only. Canonical values
(decoded from ESP32 firmware `services_ble_onboarding.c`):

| Role | UUID |
|---|---|
| Onboarding service | `00014452-414f-424e-4f2d-454744454847` |
| Provisioning payload characteristic | `00024452-414f-424e-4f2d-454744454847` |
| Provisioning status characteristic | `00034452-414f-424e-4f2d-454744454847` |

Provisioning payload characteristic: Write (with response).
Provisioning status characteristic: Read + Notify.
Advertising name prefix: `GH-Edge-` (e.g. `GH-Edge-1ADD5912AF61`).

The `BlueZBleTransport` implementation uses `bluetoothctl` subprocess (same pattern as the
proven `services-old/Greenhouse.Bluetooth/BlueZEdgeUnitDiscoveryService`). No BLE NuGet
library is required. GATT write/read operations use `bluetoothctl` interactive mode.

**Layer 2 — `IEdgeUnitProvisioningTransport` (application port, `Greenhouse.Core`)**

The application-layer contract that use cases depend on. Expresses operations in Greenhouse
domain terms with no BLE-specific types.

```
ScanForProvisionableUnitsAsync(timeout: TimeSpan, cancellationToken)
    → Task<IReadOnlyList<ProvisionableUnit>>

ProvisionUnitAsync(deviceId: string, payload: ProvisioningPayload, cancellationToken)
    → Task<ProvisioningResult>
```

`ProvisioningPayload` and `ProvisioningResult` are application models in `Greenhouse.Core`.
They map to the BLE provisioning JSON schema defined in `specs/edge-unit-onboarding/spec.md`.

**`BleEdgeUnitProvisioningAdapter` (`Greenhouse.Bluetooth`)**

Implements `IEdgeUnitProvisioningTransport`. Uses `IBleTransport` internally. Owns all GATT
UUID constants as private members. Serialises `ProvisioningPayload` to JSON before writing;
deserialises the BLE status response into `ProvisioningResult`.

### BLE Startup and Lifecycle

- `BlueZBleTransport` is registered as `IBleTransport` (singleton) in `Program.cs`.
- `BleEdgeUnitProvisioningAdapter` is registered as `IEdgeUnitProvisioningTransport` (singleton).
- Neither starts a BLE scan at process startup. BLE scanning begins only when an onboarding
  use case calls `ScanForProvisionableUnitsAsync`.
- The adapter must clean up any open GATT connections on cancellation or timeout.

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
