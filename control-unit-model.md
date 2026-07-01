# Main Unit Agent Instructions

Use Main Unit and Edge Unit as canonical terms throughout this document.

Legacy terms are deprecated and should not be introduced in new code or docs.

## Purpose

This document gives coding instructions for an agent implementing the **Greenhouse Main Unit**.

Canonical references for adjacent concerns:

- Domain language: `CONTEXT.md`
- Durable agent policy: `AGENTS.md`
- Edge Unit onboarding payload contract: `specs/edge-unit-onboarding/spec.md`

The Main Unit is the local-first brain of the greenhouse automation platform. It runs on a Raspberry Pi, communicates with ESP32 Edge Unit nodes over MQTT, stores local state/history, hosts an optional local touchscreen UI process, and executes deterministic automation rules.

The current preferred implementation is:

- **Main Unit runtime host decoupled from the UI process**
- **Backend API exposed by the Main Unit backend**
- **Thin Flutter app for the optional local touchscreen UI**
- **Flutter UI rendered via `flutter-pi` on Raspberry Pi**
- **No authentication initially**
- **Explicit `Program.cs` with `public static void Main(string[] args)`**
- **SQLite initially**
- **Mosquitto as the MQTT broker**
- **No containerization in Phase 1**
- **Raspberry Pi Debian Bookworm target**
- **Touch-first appliance UI**

---

## Operating Assumptions

The agent should assume the project is being developed incrementally after successful experiments proving that:

- The Raspberry Pi can run .NET.
- The Raspberry Pi can run Mosquitto.
- ESP32 devices can connect over WiFi.
- ESP32 devices can send and receive custom MQTT messages.
- The next step is implementation of the production-shaped Main Unit.

Do not over-engineer the first version. Build a clean foundation that can evolve.

---

## Core Architectural Direction

The system is **local-first**, **message-oriented**, and **deterministic**.

- All critical greenhouse control must execute locally. 
- Internet access must not be required for normal automation.
- MQTT is the primary communication backbone between the Main Unit and ESP32 Edge Unit nodes.
- The automation engine is authoritative. 
- AI features may eventually suggest, analyze, or recommend, but AI must not directly operate hardware.

---

## Recommended Solution Structure

Create a solution that can start simple but cleanly separates responsibilities.

Recommended projects:

```text
Greenhouse.Runtime
Greenhouse.Runtime.Tests
Greenhouse.Api
Greenhouse.Api.Tests
Greenhouse.UI
Greenhouse.UI.Tests
Greenhouse.Core
Greenhouse.Core.Tests
Greenhouse.Mqtt
Greenhouse.Mqtt.Tests
Greenhouse.Bluetooth
Greenhouse.Bluetooth.Tests
Greenhouse.Storage
Greenhouse.Storage.Tests
```

Optional later projects:

```text
Greenhouse.Automation
Greenhouse.DeviceSimulator
Greenhouse.Contracts
Greenhouse.AI
Greenhouse.CloudSync
```

Each project should have its own set of tests in a project co-located with the project under test.

### Project Responsibilities

#### `Greenhouse.Runtime`

Main Unit runtime host and composition root.

Responsibilities:

- Start the configured Main Unit without requiring the UI process.
- Register application services and infrastructure implementations.
- Run hosted background services for MQTT, telemetry ingestion, heartbeat processing, automation scheduling, command dispatch, retries, and persistence.
- Load persisted configuration, topology, automation rules, and runtime state during startup.
- Maintain operational state independently from UI lifecycle.

#### `Greenhouse.UI`

Optional thin Flutter touchscreen application rendered via `flutter-pi`.

Responsibilities:

- Host the local touchscreen dashboard experience.
- Register UI presentation services and backend API clients.
- Provide the local appliance UI.
- Support direct on-device touch interaction.
- Display state returned by backend API calls.
- Initiate user-driven use cases through backend API calls.
- Poll backend status resources or connect to documented realtime read channels for workflow progress.

Must not:

- Own automation state, topology state, or persisted Main Unit state.
- Be required for MQTT subscriptions, telemetry ingestion, heartbeat processing, automation scheduling, command dispatch, retries, or persistence.
- Register lifecycle-critical background services only in the UI host.
- Host backend API endpoints.
- Call application services, repositories, BLE adapters, MQTT adapters, or database contexts directly.
- Own BLE onboarding or Edge Unit reconfiguration workflow state.

#### `Greenhouse.Api`

Backend API presentation host.

Responsibilities:

- Expose RESTful API endpoints over Main Unit application contracts.
- Validate API request DTOs and translate them into application commands or queries.
- Return resource representations, operation status, validation errors, and workflow state.
- Expose onboarding and reconfiguration workflow resources owned by backend services.
- Optionally expose a documented realtime read channel for progress updates.

Must not:

- Store per-client request state required by later API calls.
- Put business rules in controllers or endpoint handlers.
- Depend on UI framework types.

#### `Greenhouse.Core`

Domain and application abstractions.

Responsibilities:

- Device models.
- Capability models.
- Slot models.
- Command models.
- Telemetry models.
- Rule abstractions.
- Service interfaces.
- Shared enums/value objects.
- Message queue contracts/abstractions (interfaces)
- `IMessagingService` contract
- message envelope model

This project should not depend on ASP.NET Core, MQTTnet, EF Core, SQLite, or UI framework types.

#### `Greenhouse.Mqtt`

MQTT integration layer.

Responsibilities:

- Connect to Mosquitto.
- Subscribe to topics.
- Publish to topics.
- Extract message topic, payload, and transport metadata into a generic message envelope.
- Implement `IMessagingService`.
- Provide registration and unsubscription for received message callbacks.
- Reconnect on broker/network failure.

This project must depend on MQTT client libraries.

Canonical MQTT client library: `MQTTnet` version `5.1.0.1559` (NuGet package `MQTTnet`).
Do not use the `MQTTnet.AspNetCore` variant; it is sunset.
Broker connection settings are read from configuration under the `Mqtt` key:

```json
"Mqtt": {
  "Host": "localhost",
  "Port": 1883,
  "ClientId": "greenhouse-runtime"
}
```

#### `Greenhouse.Storage`

Persistence layer.

Responsibilities:

- Store known Edge Unit information and configuration
- Store telemetry history (commands and responses, including heartbeats).
- Store events/faults.
- Store rule definitions. 

Initial database:

```text
SQLite
```

---

## Main Unit Responsibilities

The Main Unit handles:

- Message queue through MQTT abstraction.
- Device registration.
- Device configuration assignment.
- Device status tracking.
- Telemetry ingestion.
- Actuator command dispatch.
- Historical persistence.
- optional local touchscreen dashboard.
- Backend REST API.
- Automation rules.
- Alerts and notifications.
- OTA coordination later.
- AI orchestration later.
- Cloud synchronization later.

For Phase 1, prioritize:

1. MQTT connectivity.
2. Heartbeat ingestion.
3. Device registration from heartbeat.
4. Device state display in dashboard.
5. Read command publishing.
6. Write command publishing.
7. Read/ack response ingestion.
8. Basic persistence.

---

## Flutter UI Instructions

Use a thin Flutter UI rendered through `flutter-pi` for the on-device dashboard.

The Flutter app runs separately from the backend. It calls backend API endpoints and renders the returned state. It must not reference backend implementation projects or invoke application services directly.

Design UI components for touch use:

- Large buttons.
- Large status cards.
- Clear online/offline indicators.
- Minimal dense menus.
- No hover-only functionality.
- High contrast.
- Simple navigation.

Initial pages/components:

```text
/
/devices
/devices/{deviceId}
/devices/{deviceId}/onboarding
/telemetry
/actuators
/settings
```

Suggested first dashboard widgets:

- MQTT broker connection status.
- Known devices count.
- Online devices count.
- Last heartbeat timestamp.
- Recent telemetry messages.
- Recent command acknowledgements.
- Fault summary.

## Backend API Instructions

Expose UI-facing capabilities through backend REST API endpoints.

API rules:

- Requests must be stateless: each request must contain the identifiers and payload needed to process it without relying on per-client request memory.
- Mutating calls must be idempotent from the UI client's point of view. Repeating `start`, `cancel`, or `provision` for the same active unit must return the current backend state rather than duplicate work.
- Long-running operations must return or update backend-owned resource state rather than keeping progress in the UI.
- Response bodies should be resource representations or operation status DTOs.
- API handlers should call application commands/queries and should not own business policy.

Examples of resource-oriented API shapes:

```text
GET /api/runtime/status
GET /api/edge-units
GET /api/edge-units/{device_id}
GET /api/onboarding
POST /api/onboarding/scan
POST /api/onboarding/{device_id}/start
POST /api/onboarding/{device_id}/provision
POST /api/onboarding/{device_id}/cancel
```

Polling is acceptable for Phase 1 workflow progress:

```text
GET /api/onboarding
```

A socket-based read channel may be added when polling becomes awkward or wasteful. If added, it must be observational only: the backend still owns durable workflow state, and state-changing actions still go through REST resources.

---

## Program.cs Style

The user prefers explicit C# structure.

Do not use top-level statements.

Use this style:

```csharp
namespace Greenhouse.Api;


public sealed class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Register services here.

        var app = builder.Build();

        // Configure middleware here.

        app.Run();
    }
}
```

If asynchronous startup is needed, use:

```csharp
public static async Task Main(string[] args)
{
    var builder = WebApplication.CreateBuilder(args);

    var app = builder.Build();

    await app.RunAsync();
}
```

Do not mix styles within the same project.

---

## Authentication Strategy

Do not implement authentication in Phase 1.

Create the project with:

```text
Authentication: None
```

However, design the code so authentication can be added later without rewriting the application.

Avoid direct UI-to-hardware logic.

Bad pattern:

```csharp
await mqttClient.PublishAsync("ghcmd/wr-F11234AABC1A", payload);
```

Preferred pattern:

```csharp
await actuatorCommandService.SetActuatorStateAsync(deviceId, slotId, ActuatorState.On);
```

Add an abstraction that can later be backed by real identity:

```csharp
public interface ICurrentOperator
{
    string Name { get; }
    bool IsAuthenticated { get; }
    bool IsAdmin { get; }
}
```

Initial implementation:

```csharp
public sealed class LocalKioskOperator : ICurrentOperator
{
    public string Name => "Local Kiosk";
    public bool IsAuthenticated => true;
    public bool IsAdmin => true;
}
```

Future roles may include:

- Viewer
- Admin

---

## Device Model Instructions

The platform uses modular ESP32-based Edge Unit nodes.

A Edge Unit manages bus communications and relays canonicalized slot data. The Main Unit owns configuration and overall operational intelligence.

Phase 1 Edge Unit architecture assumptions:

- Each Edge Unit has a fixed slot count.
- Slots connect over 4-wire cables.
- Connected slot modules share an I2C bus on the Edge Unit.
- Sensor and actuator modules canonicalize values and state before reporting through the Edge Unit.
- Sensor module I2C addresses are unique and may encode sensor family ranges such as 0x20-0x2F for moisture sensors.

Initial node categories:

- Sensor Edge Unit
- Actuator Edge Unit

Future node categories:

- Hybrid Edge Unit
- Vision Edge Unit

### Device Identity

Use the ESP32 WiFi MAC address as the device identity.

Preferred canonical device ID format in code:


```text
{mac-address}
```

Topic Example:

`ghcmd/{commandType}-{deviceId}`

Examples:

- `ghcmd/rd-1ADD5912AF61`
- `ghcmd/rd-3555FA1BD1EE`

The topic format stays the same while payload content can differ per command.

Each device must expose or report:

- Device ID.
- Firmware version.
- Hardware revision.
- Uptime.
- WiFi RSSI.
- Capability list.
- General fault state.
- Per-capability or per-slot fault states later.

### Device Metadata Example

```json
{
  "device_id": "1ADD5912AF61",
  "hardware_revision": "A",
  "firmware_version": "1.0.3",
  "uptime_seconds": 92384,
  "wifi_rssi": -61,
  "capabilities": [
    "temperature",
    "humidity",
    "light"
  ]
}
```

Use one JSON naming convention consistently. Prefer snake_case for MQTT payloads because current topic documentation already uses fields like `device_id`, `slot_id`, and `error_code`.

In C#, use PascalCase properties and configure JSON serialization attributes where needed.

Example:

```csharp
public sealed record DeviceInfo
{
    [JsonPropertyName("id")]
    public long Id { get; init; }

    [JsonPropertyName("device_id")]
    public required string DeviceId { get; init; }

    [JsonPropertyName("hardware_revision")]
    public string? HardwareRevision { get; init; }

    [JsonPropertyName("firmware_version")]
    public string? FirmwareVersion { get; init; }

    [JsonPropertyName("uptime_seconds")]
    public long UptimeSeconds { get; init; }

    [JsonPropertyName("wifi_rssi")]
    public int? WifiRssi { get; init; }

    [JsonPropertyName("capabilities")]
    public IReadOnlyList<string> Capabilities { get; init; } = [];
}
```

---

## Device Registration Flow

Edge Unit devices do not own long-term configuration.

From the device perspective, startup and registration are unified after provisioning is complete.

Expected startup flow:

1. Device boots.
2. If provisioning data is missing, device enters BLE provisioning mode.
3. Main Unit provisions WiFi credentials and bootstrap MQTT endpoint over BLE.
4. Device validates and stores provisioning payload.
5. Device connects to WiFi.
6. Device connects to MQTT.
7. Device publishes heartbeat containing metadata.
8. Main Unit records or updates known device.
9. Main Unit sends runtime configuration to the device.
10. Device enters operational state.

In Phase 1, it is acceptable for step 9 to be stubbed or logged if the device firmware does not yet support configuration payloads. Devices should not persist long-term runtime configuration locally in Phase 1. The Main Unit is the source of truth and devices should receive runtime configuration from the Main Unit at startup and when updates occur.

The Main Unit must treat heartbeat as both:

- A liveness signal.
- A discovery/registration signal.

---

## Capability and Slot Model

The system should reason about capabilities rather than hard-coded hardware wherever possible.

Example capabilities:

- temperature
- humidity
- soil-moisture
- pump
- valve
- fan
- heater
- light
- co2
- ph
- ec-tds
- camera

Edge Unit nodes have slots.

A slot may represent:

- Sensor input.
- Relay output.
- MOSFET output.
- PWM output later.
- Virtual/calculated capability later.

Initial model should support:

```text
Device
  └── Slots
        ├── SlotId
        ├── Capability
        ├── Direction: Sensor | Actuator
        ├── CurrentValue
        ├── CurrentState
        ├── LastSeenUtc
        └── FaultState
```

Do not hard-code specific greenhouse layouts into the device model.

---

## MQTT Topic Contract

MQTT topics are intentionally simple and low in number.

The current topic design uses:

```text
ghcmd/rd-{deviceId}
ghcmd/wr-{deviceId}
gh/heartbeat
gh/ack
gh/rd
```

### Topic Direction

Edge Unit subscribes to:

```text
ghcmd/rd-{deviceId}
ghcmd/wr-{deviceId}
```

Edge Unit publishes to:

```text
gh/heartbeat
gh/ack
gh/rd
```

Main Unit subscribes to:

```text
gh/heartbeat
gh/ack
gh/rd
```

Main Unit publishes to:

```text
ghcmd/rd-{deviceId}
ghcmd/wr-{deviceId}
```

### Payload Format

Use JSON initially.

Reasons:

- Easy debugging.
- Human-readable MQTT inspection.
- Faster iteration.
- Compatible with current experiments.

Binary payloads may be considered later only if needed.

---

## MQTT Payload Contracts

Use one command schema for both read and write topics.

Topic:

```text
ghcmd/rd-{deviceId}
ghcmd/wr-{deviceId}
```

Payload:

```json
{
  "id": 502,
  "slot_id": 4,
  "state": "on",
  "value": 1
}
```

Field requirements and types:

- id: required integer, monotonic Main Unit message index.
- slot_id: required integer, target slot index.
- state: required string, use none for read commands.
- value: required number, use 0 default when not needed.

C# model:

```csharp
public sealed record CommandMessage
{
    [JsonPropertyName("id")]
    public long Id { get; init; }

    [JsonPropertyName("slot_id")]
    public int SlotId { get; init; }

    [JsonPropertyName("state")]
    public required string State { get; init; }

    [JsonPropertyName("value")]
    public double Value { get; init; }
}
```

### Response Messages

Use one canonical response schema for both ack and read responses.

### Acknowledge Message

Topic:

```text
gh/ack
```

Payload:

```json
{
  "id": 123,
  "device_id": "F11234AABC1A",
  "slot_id": 4,
  "value": 0,
  "state": "on",
  "error_code": 0
}
```

### Read Response Message

Topic:

```text
gh/rd
```

Payload:

```json
{
  "id": 235,
  "device_id": "1ADD5912AF61",
  "slot_id": 5,
  "value": 19.2,
  "state": "none",
  "error_code": 0
}
```

### Error Response

Topic:

```text
gh/ack
```

or:

```text
gh/rd
```

Payload:

```json
{
  "id": 123,
  "device_id": "F11234AABC1A",
  "slot_id": 4,
  "value": 0,
  "state": "error",
  "error_code": 1002
}
```

Response field requirements and types:

- id: required integer, Edge Unit message index.
- device_id: required string, Edge Unit WiFi MAC address.
- slot_id: required integer.
- value: required number, canonical value or 0 default.
- state: required string, canonical state or none.
- error_code: required integer, 0 for success.

### Heartbeat

Topic:

```text
gh/heartbeat
```

Payload:

```json
{
  "id": 8339,
  "device_id": "1ADD5912AF61",
  "hardware_revision": "A",
  "firmware_version": "1.0.3",
  "uptime_seconds": 92384,
  "wifi_rssi": -61,
  "slot_count": 8,
  "slots": [
    {
      "slot_id": 0,
      "direction": "sensor",
      "i2c_address": "0x25",
      "capability": "moisture",
      "state": "none",
      "value": 41.7,
      "error_code": 0
    },
    {
      "slot_id": 4,
      "direction": "actuator",
      "i2c_address": "0x51",
      "capability": "pump",
      "state": "off",
      "value": 0,
      "error_code": 0
    }
  ],
  "capabilities": [
    "moisture",
    "pump"
  ]
}
```

Heartbeat requirements:

- Include discovered slot topology and current slot state.
- Include sensor and actuator module identity using i2c_address.
- Use heartbeat as both liveness and topology update signal.

Main Unit heartbeat processing:

- No stored config for device: trigger new Edge Unit onboarding flow.
- Stored config exists but slot topology changed: trigger reconfiguration flow.
- Stored config exists and topology matches: update runtime state only.

Heartbeat interval:

```text
30-60 seconds
```

Use heartbeat as the initial `is_online` signal.

A device should be considered offline if no heartbeat has been received within a configurable timeout, for example:

```text
3 x heartbeat interval
```

---

## Message Index and Time Model

Do not attempt to maintain accurate wall-clock time on every ESP32 device in Phase 1.

The Main Unit owns wall-clock time.

Edge Units should maintain an integer message index that increments with every payload they publish.

The Main Unit should store incoming messages with:

- Device-provided message ID/index.
- Main Unit received timestamp in UTC.
- Topic.
- Raw payload

On device startup, the Main Unit may eventually return the last known message index for that device so the device can continue incrementing from the existing value.

This avoids unnecessary NTP/time complexity on Edge Unit nodes.

---

## Messaging Service Design

Implement messaging integration as a hosted background service in the Main Unit runtime host.

Implement messaging abstractions from `Greenhouse.Core`.

The core model must not depend on MQTTnet types. Use generic messaging names in `Greenhouse.Core`, such as `MessagingOptions`, `MessagingTopics`, `MessageEnvelope`, `MessageSubscription`, and `IMessagingService`.

The MQTTnet-specific implementation belongs in the infrastructure-oriented `Greenhouse.Mqtt` project behind service abstractions. UI components and application services should not reference MQTTnet types directly.

```csharp
public sealed record MessageEnvelope
{
    public required string Topic { get; init; }
    public required string Payload { get; init; }
    public DateTimeOffset ReceivedAtUtc { get; init; }
}

public interface IMessageSubscription : IAsyncDisposable
{
}

public interface IMessagingService
{
    bool IsConnected { get; }
    Task StartAsync(CancellationToken cancellationToken = default);
    Task StopAsync(CancellationToken cancellationToken = default);
    Task SendAsync(MessageEnvelope message, CancellationToken cancellationToken = default);
    IMessageSubscription RegisterMessageReceived(Func<MessageEnvelope, CancellationToken, Task> handler);
}
```

The runtime-hosted service should:

- Connect at runtime startup.
- Subscribe to configured inbound MQTT topics.
- Publish outbound MQTT messages requested through `SendAsync`.
- Notify registered handlers when a message is received.
- Allow each registered handler to unsubscribe through the returned `IMessageSubscription`.
- Handle reconnects.
- Log connection status.
- Never crash the runtime process because of a bad message payload.

`IMessagingService` must be message type/content agnostic. It should not know whether a payload is a heartbeat, telemetry reading, command acknowledgement, read response, onboarding event, reconfiguration event, or future message type. A message is only a topic plus payload and transport metadata at this boundary.

Message senders are responsible for choosing the correct topic and payload. Message subscribers are responsible for deciding whether a received message is relevant, parsing it, validating it, and invoking the correct application use case.

Do not add topic-specific methods such as `PublishHeartbeatAsync`, `HandleAckAsync`, `SubscribeToTelemetryAsync`, or `RouteHeartbeatAsync` to `IMessagingService`.

Bad messages should be logged and ignored or recorded as malformed events by the subscriber that attempted to parse them.

---

## Application Services

Create application services behind the backend API rather than placing logic in UI components or API endpoint handlers.

Suggested services:

```csharp
public interface IDeviceService
{
    Task RegisterAsync(DeviceInfo deviceInfo, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<DeviceInfo>> GetDevicesAsync(CancellationToken cancellationToken = default);
    Task<DeviceInfo?> GetDeviceAsync(string deviceId, CancellationToken cancellationToken = default);
    Task SetActuatorStateAsync(string deviceId, int slotId, string state, CancellationToken cancellationToken = default);
}

public interface ITelemetryService
{
    Task ReceiveAsync(DeviceResponse message, CancellationToken cancellationToken = default);
}
```

- Backend API handlers should call these services through application commands or queries.
- UI components should call backend APIs and must not call these services directly.
- UI and API code should not directly publish MQTT messages or manipulate storage.
- Concrete implementation of these services should be injected using inversion of control - IoC
- Do not use a service locator pattern, eg: `get<TService>();`

---

## Setup and General Configuration

The setup and flow dossiers are documented separately in:

- `specs/main-unit-setup/spec.md`
- `specs/edge-unit-configuration/spec.md`

Use the following flow names consistently to avoid ambiguity:

- Main Unit Setup Flow: first-run setup of the Main Unit (network + greenhouse general configuration).
- Edge Unit Onboarding/Reconfiguration Flow: BLE-first provisioning for new Edge Units and heartbeat-driven runtime mapping/reconfiguration for known Edge Units.

Flow separation rules:

- Do not call Edge Unit onboarding "setup" in code comments, UI labels, or docs.
- Do not use Main Unit setup screens for Edge Unit onboarding or slot mapping.
- Do not use Edge Unit onboarding screens for Main Unit network/general configuration.
- Main Unit setup state is based on presence of main general configuration.
- Edge Unit onboarding state is based on heartbeat discovery and stored Edge Unit topology comparison.

Routing separation:

- Missing main general configuration: route to Main Unit Setup Flow.
- Main general configuration exists but network is unavailable: route to Network Recovery Flow.
- Main general configuration exists and BLE discovery reports unprovisioned Edge Unit: route to Edge Unit Onboarding Flow.
- Main general configuration exists and heartbeat reports unknown Edge Unit from a pre-provisioned device: route to runtime mapping flow.
- Main general configuration exists and heartbeat reports topology drift for known Edge Unit: route to Edge Unit Reconfiguration Flow.
- Main general configuration exists and no onboarding/reconfiguration condition is active: route to normal dashboard experience.

Keep setup, onboarding, and reconfiguration implementation aligned with Clean Architecture:

- UI components should collect user input and display backend API state only.
- Main setup and Edge Unit onboarding components should call backend APIs, not application services or use cases directly.
- Backend API handlers should call application services or use cases.
- Application services should coordinate validation, persistence, BLE operations, MQTT operations, and operating-system integration.
- Network setup should be initiated through backend APIs backed by an `INetworkService` abstraction, not directly from UI components.
- `INetworkService` is the application boundary for network status, connection attempts, and future network events or network changes.
- Domain/configuration models should live outside the UI project.
- Storage implementation details should stay behind repository or persistence abstractions.
- Do not put setup or onboarding persistence logic directly in UI components.
- Do not put BLE scan, pairing, provisioning, heartbeat waiting, timeout, retry, or cancellation logic directly in UI components.
- Do not hard-code setup state, onboarding state, or general configuration in MQTT handlers.

General configuration may be represented by a model such as `MainConfig`.

Edge Unit configuration should be represented by dedicated Edge Unit models (for example Edge Unit + slot mapping models) and should not be mixed into `MainConfig`.

The application should be able to:

- Determine whether general configuration exists during startup.
- Route to setup when general configuration is missing.
- Skip setup when general configuration exists.
- Store greenhouse name, greenhouse location, and optional description in local persistence.
- Retrieve general configuration for application state after setup completes.
- When general configuration exists but network connection is unavailable, route to the Network Recovery journey rather than first-run setup.

A use case such as `WriteGeneralConfiguration` may store configuration details through the appropriate application, repository, and persistence layers.

Wi-Fi credentials must not be stored in the application database. If credentials must be retained for automatic reconnect after reboot, persistence should be delegated to the operating system network manager.

For Phase 1:

- Network name is entered manually.
- Network password may be blank to support open networks.
- Wi-Fi network scanning is deferred.
- Changing Wi-Fi networks from a configured unit is covered by the Network Recovery journey when the unit is offline.
- Editing general configuration after setup should be covered by a separate user journey.
- Greenhouse name maximum length is 50 characters.
- Greenhouse location maximum length is 50 characters.
- Description maximum length is 100 characters.

---

## Storage Model

Use SQLite for Phase 1.

Initial tables/entities may include:

```text
Devices
DeviceCapabilities
Telemetry
CommandHistory
ApplicationEvents
```

### Devices

Store:

- Id (DeviceId)
- Friendly name
- Location / description.
- First seen timestamp.
- Last seen timestamp.
- Last heartbeat ID.
- Firmware version.
- Hardware revision.
- WiFi RSSI.
- Online/offline computed state.

### DeviceCapabilities

Store:

- Id
- Device ID.
- Slot ID.
- Name assigned by user
- Description assigned by user (optional)
- Capability.
- Direction.

### Telemetry

- Readings

Store:

- Id.
- Device ID.
- Slot ID.
- Capability if known.
- Numeric value.
- State text.
- Device message ID.
- Received UTC timestamp.
- Error code.

### CommandHistory

Store:

- ID.
- Device ID.
- Slot ID.
- Command type.
- Requested state/value.
- Created UTC timestamp.
- Published UTC timestamp.
- Ack received UTC timestamp.
- Result state.
- Error code.

---

## Retained MQTT Messages

Recommended retained topics later:

- Device status.
- Actuator state.
- Configuration.

Avoid retaining:

- High-frequency telemetry.
- Heartbeats.

For Phase 1, do not rely on retained messages for correctness. Use persistent local storage in the Main Unit.

---

## Automation Engine Boundary

Do not build a complex automation engine first.

Create a boundary that can support it later.

Suggested interface:

```csharp
public interface IAutomationEngine
{
    Task EvaluateTelemetryAsync(DeviceResponse response, CancellationToken cancellationToken = default);
    Task EvaluateHeartbeatAsync(DeviceHeartbeat heartbeat, CancellationToken cancellationToken = default);
}
```

Initial implementation may be a no-op.

Future rules should support:

- Threshold triggers.
- Schedules.
- Hysteresis.
- Debounce logic.
- Time windows.
- Logical conditions.
- Sensor aggregation.

Example future rule:

```text
If soil moisture < 30% for 5 minutes, run pump for 20 seconds.
```

Automation must remain deterministic, auditable, and user-visible.

---

## Safety Rules

Actuator commands must be treated as safety-sensitive.

Initial safeguards:

- Pumps default OFF.
- Heaters default OFF.
- Valves default CLOSED.
- Unknown devices cannot be commanded unless explicitly allowed.
- Unknown slots cannot be commanded unless explicitly configured.
- Command attempts should be logged.
- MQTT publish failure should not be silently ignored.

Future safeguards:

- Maximum pump runtime.
- Minimum rest period.
- Flow confirmation.
- Tank/reservoir level checks.
- Thermal shutdown.
- Watchdog enforcement.

---

## Configuration Model

Edge Unit devices do not permanently own their configuration.

The Main Unit should eventually store and provide:

- Device friendly name.
- Device location.
- Slot capability assignments.
- Slot calibration values.
- Actuator safety limits.
- Telemetry reporting intervals.
- Heartbeat interval.

In Phase 1, configuration may be manual and stored locally in SQLite or `appsettings.Development.json` while the model is still evolving.

Do not hard-code configuration in MQTT handlers.

---

## Logging and Diagnostics

Use standard .NET logging.

Log at minimum:

- Application startup.
- MQTT connection/disconnection.
- MQTT subscriptions.
- Heartbeat received.
- Device registered.
- Device updated.
- Read response received.
- Ack received.
- Command published.
- Malformed payload.
- Unknown topic.
- Storage errors.

Do not log excessively inside high-frequency loops.

Prefer structured logging:

```csharp
logger.LogInformation("Heartbeat received from {DeviceId} with message id {MessageId}", message.DeviceId, message.Id);
```

---

## Error Handling Rules

The Main Unit must be resilient.

Do not let these failures crash the app:

- MQTT broker unavailable.
- WiFi interruption.
- Malformed JSON.
- Unknown device ID.
- Unknown slot ID.
- Duplicate message ID.
- Missing fields.
- Database temporarily locked.

Bad inbound messages should become diagnostic events, not fatal exceptions.

---

## Dependency Injection Rules

Use dependency injection consistently.

Register services by interface where practical.

Example:

```csharp
builder.Services.AddSingleton<ICurrentOperator, LocalKioskOperator>();
builder.Services.AddSingleton<IMessagingService, MessagingService>();
builder.Services.AddHostedService<MessagingHostedService>();
builder.Services.AddScoped<IDeviceService, DeviceService>();
```

Be careful with singleton services depending on scoped EF Core contexts.

If using EF Core with hosted services, use:

```csharp
IDbContextFactory<TContext>
```

or create scopes explicitly.

---

## Recommended Initial Milestones

### Milestone 1: Empty App Foundation

- Create Main Unit runtime host.
- Create optional Flutter UI dashboard.
- Disable top-level statements.
- Add initial project structure.
- Add basic dashboard page.
- Show empty dashboard states for missing Edge Units and rules.
- Add app settings for messaging host/port.

### Milestone 2: Runtime Messaging Connection

- Add MQTT client package.
- Connect the runtime host to Mosquitto.
- Subscribe to inbound topics from the runtime host.
- Persist or expose connection status through application state/query contracts.
- Display connection status on dashboard when the dashboard is enabled.

### Milestone 3: Heartbeat Ingestion

- Parse `gh/heartbeat`.
- Register/update device in memory.
- Show devices on dashboard.

### Milestone 4: SQLite Persistence

- Add SQLite.
- Persist known devices.
- Persist heartbeats.
- Reload known devices on startup.

### Milestone 5: Read/Write Commands

- Publish read command.
- Publish write command.
- Receive `gh/rd` and `gh/ack`.
- Display last read/ack per device slot.

### Milestone 6: Basic Safety and Faults

- Track offline devices.
- Track error codes.
- Prevent commands to unknown slots.
- Add command history.

### Milestone 7: Early Automation Boundary

- Add no-op automation engine.
- Route telemetry through it.
- Add one simple manually configured rule only after the model is stable.

---

## Coding Style Preferences

Prefer:

- Clear C# object models.
- Contract-first design.
- Explicit interfaces for meaningful service boundaries.
- Async/await for I/O.
- Cancellation tokens on background and I/O services.
- Small focused classes.
- Strongly typed options via `IOptions<T>`.
- Explicit `Program.Main` style.
- Practical code over premature abstraction.

Avoid:

- Top-level statements.
- Direct MQTT calls from UI components.
- Business logic in UI components.
- Tight coupling in dependencies or naming conventions.
- Technology-specific names in core contracts.
- Redundant names within a project or namespace.
- Hard-coded device IDs outside tests/demo config.
- Hard-coded greenhouse layouts.
- Cloud dependencies in core control paths.
- AI-driven direct actuator commands.
- Overbuilding authentication before the core system works.
- Docker/containerization in Phase 1 unless specifically requested.

### Contract-First Rules

- Design contracts before implementations.
- Put cross-boundary contracts in the owning abstraction layer before writing infrastructure code.
- Depend on abstractions from application/core code; infrastructure projects should realize those abstractions.
- Do not let UI components, application services, or domain models depend directly on infrastructure libraries.
- Avoid tight coupling in naming as well as dependencies.
- Use technology-neutral names in core contracts. For example, prefer `IMessagingService` over `IMqttService`.
- Keep implementation-specific names and details inside the project that owns that implementation. For example, MQTTnet types and MQTT-specific details belong in `Greenhouse.Mqtt`; storage-provider details belong in `Greenhouse.Storage`; UI-framework details belong in `Greenhouse.UI`.
- Avoid redundant names within any project or namespace. For example, in `Greenhouse.Mqtt`, prefer names like `MessagingService` or `MessageTransport` rather than `MqttMessagingService` unless multiple messaging transports exist in the same namespace.
- Add a technology prefix only when it removes real ambiguity or distinguishes multiple implementations in the same namespace.

---

## Suggested Options Classes

```csharp
public sealed class MessagingOptions
{
    public string Host { get; set; } = "localhost";
    public int Port { get; set; } = 1883;
    public string ClientId { get; set; } = "greenhouse-control-unit";
}

public sealed class DeviceOptions
{
    public int HeartbeatTimeoutSeconds { get; set; } = 180;
}
```

Example `appsettings.json`:

```json
{
  "Messaging": {
    "Host": "localhost",
    "Port": 1883,
    "ClientId": "greenhouse-control-unit"
  },
  "Device": {
    "HeartbeatTimeoutSeconds": 180
  }
}
```

---

## Raspberry Pi Deployment Direction

Phase 1 deployment should be simple:

- Build/publish from development machine or directly on Pi.
- Run as a .NET app on Raspberry Pi Debian Bookworm.
- Mosquitto runs as a system service.
- Main Unit backend eventually runs as a systemd service.
- Thin Flutter UI runs as a separate local touchscreen app via `flutter-pi`.

Do not require Docker for the first working version.

Future deployment may use:

- systemd hardening.
- Docker Compose.
- app auto-update.
- backup/restore tooling.
- cloud sync.

---

## Kiosk UI Direction

The appliance-like interface runs as a Flutter touchscreen app on the Pi display using `flutter-pi`.

The UI process should start locally after boot and connect to backend API endpoints over loopback, for example:

```text
http://127.0.0.1:5000
```

The control logic must not depend on the touchscreen UI process being active.

The backend must continue running if:

- The UI process crashes.
- The touchscreen is disconnected.
- A remote client is used instead.

---

## Future OTA Topic Placeholders

Do not implement OTA in Phase 1 unless explicitly requested.

Reserve these topic concepts for later:

```text
ghota/{deviceId}/update
ghota/{deviceId}/status
```

OTA design must eventually include:

- Integrity validation.
- Rollback support.
- Staged deployment.
- Version tracking.

---

## Future AI Boundary

AI may eventually:

- Analyze telemetry.
- Identify anomalies.
- Recommend rules.
- Generate notifications.
- Provide conversational assistance.

AI must remain advisory.

Never implement direct AI-to-actuator control.

Correct flow:

```text
AI recommends rule
User reviews rule
User accepts rule
Deterministic rules engine executes rule
Command history records actions
```

---

## Known Documentation Corrections / Normalization

When coding against the current project docs, normalize the following minor inconsistencies:

1. Use `device_id` consistently in MQTT JSON payloads.
2. Use `slot_id` consistently in MQTT JSON payloads.
3. Put `slot_id` in the payload for Phase 1 instead of appending slot IDs to command topics.
4. Use `hardware_revision`, `firmware_version`, `uptime_seconds`, and `wifi_rssi` in MQTT JSON payloads.
5. Treat the WiFi MAC address as the unique device ID.
6. Treat heartbeat as discovery, registration, and online-state evidence.

---

## First Coding Target

The first useful deliverable should be:

```text
A Main Unit runtime running on the Raspberry Pi that ingests MQTT heartbeat messages from ESP32 devices, records/upserts those devices into the Main Unit device registry, and exposes that state to an optional local dashboard UI.
```

Do not begin with full automation rules, OTA, AI, authentication, cloud sync, or mobile apps.

Build the local control foundation first.



