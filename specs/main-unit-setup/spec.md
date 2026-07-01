# Spec: Main Unit Setup

## Purpose and Scope

Define the Main Unit first-run flow for network setup and greenhouse config.

**Services scope:** REST API endpoints, application use cases, EF Core persistence, and OS network
connector port. Covered by the `[Epic] Main Unit Setup — Services` GitHub issue in
`Greenhouse-Services`.

**UI scope:** Flutter screens and backend API wiring. Covered by the `[Epic] Main Unit Setup — UI`
GitHub issue in `Greenhouse-WebUI`. UI work is dependent on services being complete first.

This spec does not cover Edge Unit onboarding, reconfiguration, or network recovery.

## Preconditions and Assumptions

- The Main Unit has a connected touch screen.
- A keyboard may be connected, but the flow must remain usable from touch only.
- The setup UI communicates with the backend over loopback REST; loopback is always available
  before the Main Unit joins a network.
- The system determines whether MainConfig exists via `GET /api/setup/main-config`.
- The system determines whether the Main Unit is online via `GET /api/setup/wifi-config`.
- The user manually enters the network name and password in Phase 1.
- Network scanning and network changes from the unit are deferred.
- No authentication is required in Phase 1.

## Definitions and Canonical Terms

| Term | Definition |
|---|---|
| `MainConfig` | Persisted greenhouse identity: name, location, and optional description. At most one record per Main Unit. |
| `WifiConfig` | Transient model holding WiFi credentials for a single connection attempt. Never persisted. |
| `MainConfigEntity` | EF Core infrastructure entity. Maps to the `MainConfigs` database table. Must not be referenced outside `Greenhouse.Storage`. |
| `IMainConfigRepository` | Application-layer contract for MainConfig persistence operations. |
| `MainConfigRepository` | Concrete EF Core implementation of `IMainConfigRepository`. Lives in `Greenhouse.Storage`. |
| `INetworkConnector` | Application-layer port for OS-level WiFi connectivity. Credentials never leave this boundary. |
| `WriteMainConfig` | Use case that validates and persists a new MainConfig. |
| `ReadMainConfig` | Use case that retrieves the current MainConfig when it exists. |
| `ConnectToNetwork` | Use case that submits WiFi credentials to `INetworkConnector` and returns a result. |
| `ReadSetupStatus` | Use case that assembles the routing decision from config existence and connectivity state. |
| Setup status | Read model: `setupComplete`, `isOnline`, `requiredStep`. |

> **Grill note — WiFi repository:** A `WifiConfigRepository` backed by the database is not
> appropriate here. The spec constraint "do not store WiFi credentials in the application
> database" means there is no persistable WiFi resource. The application-layer boundary for WiFi
> is `INetworkConnector` (a port), not a repository. The `WifiConfigController` uses the
> `ConnectToNetwork` use case which calls `INetworkConnector`.

## Behavior and Workflow

### Routing Rules

The `ReadSetupStatus` use case produces a deterministic `requiredStep` based on two inputs:
config existence (from `IMainConfigRepository`) and online state (from `INetworkConnector`).

| MainConfig exists | Online | `requiredStep` |
|---|---|---|
| No | No | `"network-connection"` |
| No | Yes | `"main-config"` |
| Yes | No | `"network-recovery"` — hand off to Network Recovery spec |
| Yes | Yes | `null` — setup complete, proceed to normal application experience |

### Network Connection Step

- Require the user to enter the network name.
- Allow the user to enter the network password.
- Trim leading and trailing whitespace from the network name before use.
- Allow an empty or null password for open networks.
- Validate input before attempting to connect.
- **Do not store WiFi credentials in the application database or in any log.**
- Submit the credentials to `INetworkConnector.ConnectAsync` immediately.
- On `Failed`: return the error message to the UI for display; do not retain credentials.
- On `TimedOut`: return a timeout result; do not retain credentials.
- On `Connected`: UI proceeds to the Main Config step.

### Main Config Step

- Require greenhouse name (max 50 characters).
- Require location (max 50 characters).
- Allow optional description (max 100 characters).
- Invoke the `WriteMainConfig` use case to validate and persist.
- After persistence succeeds, the setup flow is complete.
- Redirect the user to the normal application experience.

## Data Contracts and Schemas

### WifiConfig — Transient, Never Persisted

Request body for `POST /api/setup/wifi-config`:

```json
{
  "networkName": "MyNetwork",
  "password": "secret"
}
```

| Field | Type | Required | Constraints |
|---|---|---|---|
| `networkName` | string | Yes | Non-empty after trim; max 100 chars |
| `password` | string | No | Null or empty string accepted (open networks) |

### WiFi Status Response

Returned by `GET /api/setup/wifi-config`. Credentials are never included.

```json
{
  "isOnline": true,
  "networkName": "MyNetwork"
}
```

`networkName` is read from the OS at request time via `INetworkConnector.GetCurrentNetworkNameAsync`.
It is never retrieved from the database.

### WiFi Connection Response

Returned by `POST /api/setup/wifi-config`:

```json
{ "connected": true }
```

On failure:

```json
{ "connected": false, "errorMessage": "Authentication failed" }
```

### Setup Status Response

Returned by `GET /api/setup/status`:

```json
{
  "setupComplete": false,
  "isOnline": false,
  "requiredStep": "network-connection"
}
```

| `requiredStep` value | Meaning |
|---|---|
| `"network-connection"` | No config; Main Unit offline |
| `"main-config"` | No config; Main Unit online |
| `"network-recovery"` | Config exists; Main Unit offline |
| `null` | Setup complete |

### MainConfig Request

Request body for `POST /api/setup/main-config` and `PUT /api/setup/main-config`:

```json
{
  "greenhouseName": "North Greenhouse",
  "location": "Block A",
  "description": "Main production greenhouse"
}
```

| Field | Type | Required | Constraints |
|---|---|---|---|
| `greenhouseName` | string | Yes | Max 50 chars |
| `location` | string | Yes | Max 50 chars |
| `description` | string | No | Max 100 chars |

### MainConfig Response

Returned by `GET /api/setup/main-config` and on successful write:

```json
{
  "greenhouseName": "North Greenhouse",
  "location": "Block A",
  "description": "Main production greenhouse",
  "createdAt": "2026-07-01T12:00:00Z",
  "updatedAt": "2026-07-01T12:00:00Z"
}
```

### MainConfigEntity — EF Core, Infrastructure Only

Belongs in `Greenhouse.Storage`. Must not be referenced by application or domain code directly.

| Column | CLR Type | Constraints |
|---|---|---|
| `Id` | `int` | Primary key, auto-increment |
| `GreenhouseName` | `string` | Not null; max 50; EF `HasMaxLength(50)` |
| `Location` | `string` | Not null; max 50; EF `HasMaxLength(50)` |
| `Description` | `string?` | Nullable; max 100; EF `HasMaxLength(100)` |
| `CreatedAt` | `DateTime` | Not null; UTC |
| `UpdatedAt` | `DateTime` | Not null; UTC |

Table name: `MainConfigs`. The repository treats this as a single-row store: `GetAsync` returns
the first row or `null`. A second `POST` must return 409 before reaching the repository.

## Application Layer Contracts

### Use Cases

**`WriteMainConfig`**
```
Input:  greenhouseName (string), location (string), description (string?)
Output: Result — one of:
          Success
          ValidationError(field: string, message: string)
          AlreadyExists
```

**`ReadMainConfig`**
```
Input:  (none)
Output: MainConfig | null
```

**`ConnectToNetwork`**
```
Input:  networkName (string), password (string?)
Output: ConnectResult — one of:
          Connected
          Failed(errorMessage: string)
          TimedOut
```

**`ReadSetupStatus`**
```
Input:  (none)
Output: SetupStatus { setupComplete: bool, isOnline: bool, requiredStep: string? }
```

### Repository Contract

**`IMainConfigRepository`**
```
GetAsync()               → Task<MainConfig?>
CreateAsync(MainConfig)  → Task
UpdateAsync(MainConfig)  → Task
DeleteAsync()            → Task
```

### Infrastructure Port

**`INetworkConnector`**
```
IsOnlineAsync()                    → Task<bool>
GetCurrentNetworkNameAsync()       → Task<string?>
ConnectAsync(networkName, password?) → Task<ConnectResult>
```

The concrete adapter (`NetworkManagerAdapter` in `Greenhouse.Storage` or a dedicated infra
project) implements this via the OS network manager. See Open Questions for the mechanism choice.

## API Contracts

### SetupController

| Method | Route | Success | Error |
|---|---|---|---|
| GET | `/api/setup/status` | 200 SetupStatus | — |

### WifiConfigController

| Method | Route | Request Body | Success | Error |
|---|---|---|---|---|
| GET | `/api/setup/wifi-config` | — | 200 WiFiStatus | — |
| POST | `/api/setup/wifi-config` | WifiConfig | 200 `{connected:true}` | 422 `{connected:false, errorMessage}` · 504 timeout · 503 connector unavailable |

No PUT or DELETE: credentials are never stored; there is nothing to update or remove.

### MainConfigController

| Method | Route | Request Body | Success | Error |
|---|---|---|---|---|
| GET | `/api/setup/main-config` | — | 200 MainConfig | 404 not configured |
| POST | `/api/setup/main-config` | MainConfig request | 201 MainConfig | 409 already exists · 422 validation |
| PUT | `/api/setup/main-config` | MainConfig request | 200 MainConfig | 404 · 422 validation |
| DELETE | `/api/setup/main-config` | — | 204 | 404 not found |

PUT and DELETE are specified here for completeness. Editing config post-setup and factory-reset
deletion are deferred; controllers should return `501 Not Implemented` for those verbs until
the corresponding use cases are built.

## Validation Rules and Error Handling

### Request Validation

Validation occurs at the controller boundary before any use case is invoked.

| Field | Rule |
|---|---|
| `networkName` | Required; strip leading/trailing whitespace; reject if empty after trim; max 100 chars |
| `password` | Optional; null and empty string both accepted |
| `greenhouseName` | Required; max 50 chars |
| `location` | Required; max 50 chars |
| `description` | Optional; max 100 chars |

### Error Response Envelope

All error responses use a consistent shape:

```json
{
  "type": "validation-error",
  "errors": {
    "greenhouseName": ["Greenhouse name is required."],
    "location": ["Location must not exceed 50 characters."]
  }
}
```

### HTTP Status Map

| Scenario | Status |
|---|---|
| Validation failure | 422 Unprocessable Entity |
| Resource not found | 404 Not Found |
| POST when MainConfig already exists | 409 Conflict |
| WiFi authentication failure | 422 Unprocessable Entity |
| WiFi connection timeout | 504 Gateway Timeout |
| OS connector unavailable | 503 Service Unavailable |

### Security Constraints

- WiFi `password` must not appear in any log output.
- WiFi `password` must not appear in any API response.
- WiFi `password` must not be written to the database.

## Non-Functional Constraints

- `GET /api/setup/status` must respond within 200 ms under normal operation.
- All non-WiFi-connection endpoints must respond within 500 ms.
- `POST /api/setup/wifi-config` must not block indefinitely: `INetworkConnector` must enforce
  a timeout and return `TimedOut` to the use case.
- MainConfig write must be atomic (single EF `SaveChangesAsync` call).

## Acceptance Criteria

- [ ] `GET /api/setup/status` returns `requiredStep: "network-connection"` when no config exists and Main Unit is offline.
- [ ] `GET /api/setup/status` returns `requiredStep: "main-config"` when no config exists and Main Unit is online.
- [ ] `GET /api/setup/status` returns `requiredStep: "network-recovery"` when config exists but Main Unit is offline.
- [ ] `GET /api/setup/status` returns `setupComplete: true` and `requiredStep: null` when config exists and Main Unit is online.
- [ ] `POST /api/setup/wifi-config` returns 200 `{connected: true}` on successful network connection.
- [ ] `POST /api/setup/wifi-config` returns 422 `{connected: false}` on authentication failure.
- [ ] `POST /api/setup/wifi-config` returns 504 on connection timeout.
- [ ] `GET /api/setup/wifi-config` returns connectivity status and never includes credentials.
- [ ] `POST /api/setup/main-config` returns 201 and the created MainConfig on first creation.
- [ ] `POST /api/setup/main-config` returns 409 when MainConfig already exists.
- [ ] `POST /api/setup/main-config` returns 422 when required fields are missing or exceed maximum length.
- [ ] `GET /api/setup/main-config` returns 200 when MainConfig exists.
- [ ] `GET /api/setup/main-config` returns 404 when no MainConfig has been created.
- [ ] WiFi credentials do not appear in the `MainConfigs` database table.
- [ ] WiFi credentials do not appear in any API response.
- [ ] WiFi credentials do not appear in application logs.
- [ ] The user can complete setup from the connected touch screen without a keyboard.
- [ ] After setup completes, the normal application experience starts.
- [ ] On later startup, setup is skipped when MainConfig already exists and Main Unit is online.

## Deferred Work

- Scanning and selecting available Wi-Fi networks.
- Editing MainConfig after setup (`PUT /api/setup/main-config`).
- Factory-reset deletion of MainConfig (`DELETE /api/setup/main-config`).
- Edge Unit onboarding and reconfiguration (separate specs).
- Authentication and authorization.

## Open Questions

- **OS network connection mechanism:** Which Linux networking interface does `INetworkConnector`
  use on Raspberry Pi Debian Bookworm — NetworkManager D-Bus, `nmcli` subprocess, or
  `wpa_supplicant`? Recommended: `nmcli` subprocess for Phase 1 simplicity, with a documented
  upgrade path to D-Bus in a later phase.
- **WiFi connection timeout value:** How many seconds should `INetworkConnector` wait before
  returning `TimedOut`? Recommended: 15 seconds.