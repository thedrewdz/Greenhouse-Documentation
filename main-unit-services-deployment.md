# Main Unit Services Deployment Procedure

Canonical procedure for deploying the Greenhouse Services daemon (`Greenhouse.Runtime`) to a
Main Unit host and starting it for the first time and on subsequent updates.

## Purpose and Scope

This document covers first-run and repeat deployment of the **Main Unit services daemon** — the
headless ASP.NET Core process that owns domain logic, MQTT, storage, and onboarding
(per [adr/0001-main-unit-ui-services-separation.md](adr/0001-main-unit-ui-services-separation.md)).

In scope:

- Host prerequisites (.NET runtime/SDK, MQTT broker, database directory).
- First-run behavior, including automatic database migration.
- Required configuration before launch.
- Launching the runtime, and expected healthy-start signals.
- Subsequent deploys (pull, build, restart).
- Registering the daemon to autostart at boot via systemd.

Out of scope:

- The Main Unit **UI** process (Flutter via flutter-pi, `/ui`). UI deployment is documented
  separately.
- Containerized deployment — deferred to Phase 2 (see
  [system-topology.md](system-topology.md), Containerization).

## Preconditions and Assumptions

- Target host: Raspberry Pi 4 running Raspberry Pi OS / Debian Bookworm (ARM64). Other hosts
  are future work (see [system-topology.md](system-topology.md)).
- The host is on the trusted local network. The services API binds to loopback only and is not
  exposed externally.
- An MQTT broker (Mosquitto) is installed and reachable at the address configured under `Mqtt`
  (default `localhost:1883`). The broker is a separate concern from this daemon.
- The operator has a shell on the host and `sudo` for the systemd and directory-permission
  steps.

## Definitions

- **Services daemon** — the `Greenhouse.Runtime` process; the Main Unit "brain".
- **Runtime project** — `Greenhouse.Runtime`, an ASP.NET Core Web application; the composition
  root and process entry point.
- **Loopback API** — REST + OpenAPI surface bound to `127.0.0.1`; the only network surface the
  daemon exposes.

## 1. Prerequisites

### 1.1 .NET

The daemon targets **.NET 8.0** (`net8.0`).

Install the .NET SDK for the deploying user without modifying the global `PATH`, using the
Microsoft install script:

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0
```

This installs to `~/.dotnet`. Confirm the runtime is usable without a global `PATH` change by
invoking it by full path:

```bash
~/.dotnet/dotnet --info
```

> A published, self-contained deployment can avoid a host-wide SDK entirely; the SDK is required
> to build on the host (the Phase 1 approach) or to run `dotnet ef` tooling if ever needed.
> When running under systemd, make `dotnet` available to the service user — either reference the
> full `~/.dotnet/dotnet` path in the unit file or export `DOTNET_ROOT` and extend `PATH` for that
> user only. Do not modify the global `PATH`.

### 1.2 Source

Clone the services repository from `main` to a stable working directory on the host:

```bash
git clone https://github.com/thedrewdz/Greenhouse-Services.git
cd Greenhouse-Services
```

### 1.3 Database directory

The default connection string writes the SQLite database to `/var/greenhouse/greenhouse.db`.
SQLite creates the database **file** on first run, but not its parent **directory**. Create the
directory and grant ownership to the service user before first launch:

```bash
sudo mkdir -p /var/greenhouse
sudo chown "$USER" /var/greenhouse
```

> If this directory is missing or not writable, first-run migration fails when the daemon starts.
> See [Troubleshooting](#troubleshooting).

## 2. Configuration

Configuration is read from `Greenhouse.Runtime/appsettings.json`, overridable by environment
variables (ASP.NET Core `Section__Key` convention) or an environment-specific
`appsettings.{Environment}.json`.

Settings that must be correct before launch:

| Setting | Key | Default | Notes |
|---|---|---|---|
| Database location | `ConnectionStrings:Default` | `Data Source=/var/greenhouse/greenhouse.db` | Parent directory must exist and be writable (see 1.3). |
| MQTT broker host | `Mqtt:Host` | `localhost` | Address of the Mosquitto broker. |
| MQTT broker port | `Mqtt:Port` | `1883` | |
| MQTT client id | `Mqtt:ClientId` | `greenhouse-runtime` | |

The API bind address (`http://127.0.0.1:5150`) is set in code and is **not** a configuration
value; see [Launching](#3-launching-the-runtime).

Example environment-variable override (no file edit):

```bash
export ConnectionStrings__Default="Data Source=/var/greenhouse/greenhouse.db"
export Mqtt__Host="localhost"
```

## 3. Launching the Runtime

The daemon binds to **`http://127.0.0.1:5150`** (loopback only, plain HTTP) — this is set in
`Program.cs` and applies in every environment. Loopback traffic is intentionally not HTTPS
(per adr/0001 and the services host rules).

### First run and every run: automatic migration

Database schema is applied automatically at startup: `Program.cs` runs
`GreenhouseDbContext.Database.MigrateAsync()` before the daemon serves traffic. **No manual
`dotnet ef database update` step is required** — on a clean host the schema (including
`__EFMigrationsHistory`) is created on first start, and pending migrations are applied on
every subsequent start.

### Production launch (published binary — recommended)

Publish once, then run the framework-dependent binary. A published app ignores
`launchSettings.json`, so set the environment explicitly:

```bash
~/.dotnet/dotnet publish Greenhouse.Runtime/Greenhouse.Runtime.csproj -c Release -o /opt/greenhouse-services
ASPNETCORE_ENVIRONMENT=Production ~/.dotnet/dotnet /opt/greenhouse-services/Greenhouse.Runtime.dll
```

### Development / bring-up launch (run from source)

```bash
ASPNETCORE_ENVIRONMENT=Production ~/.dotnet/dotnet run --project Greenhouse.Runtime --no-launch-profile
```

> `dotnet run` without `--no-launch-profile` applies the `http` profile in
> `Properties/launchSettings.json`, which forces `ASPNETCORE_ENVIRONMENT=Development`.
> `launchSettings.json` is a local development convenience only — never rely on it for a
> deployed service.

### Expected healthy startup

- No unhandled exception; the process stays running.
- Log shows the host listening on `http://127.0.0.1:5150`.
- The MQTT hosted service connects to the broker (or begins its reconnect loop if the broker is
  not yet up — the daemon still starts).
- OpenAPI/Swagger is reachable locally: `curl -s http://127.0.0.1:5150/swagger/index.html`.

## 4. Subsequent Deploys

On each update to `main`:

```bash
cd Greenhouse-Services
git pull
~/.dotnet/dotnet publish Greenhouse.Runtime/Greenhouse.Runtime.csproj -c Release -o /opt/greenhouse-services
sudo systemctl restart greenhouse-services
```

Pending EF Core migrations are applied automatically on restart (Section 3). No separate
migration command is needed.

## 5. Systemd Autostart

Per [adr/0001-main-unit-ui-services-separation.md](adr/0001-main-unit-ui-services-separation.md),
services autostarts on boot and runs headless with **zero dependency on the UI**. Register it as
its own process unit, enabled independently of the (optional) UI unit.

Reference unit (`/etc/systemd/system/greenhouse-services.service`) — adjust `User`, paths, and
`DOTNET_ROOT` to the host:

```ini
[Unit]
Description=Greenhouse Main Unit Services
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=greenhouse
WorkingDirectory=/opt/greenhouse-services
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_ROOT=/home/greenhouse/.dotnet
ExecStart=/home/greenhouse/.dotnet/dotnet /opt/greenhouse-services/Greenhouse.Runtime.dll
Restart=on-failure
RestartSec=5
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now greenhouse-services
sudo systemctl status greenhouse-services
journalctl -u greenhouse-services -f
```

The daemon honors `SIGTERM` for graceful shutdown, so `systemctl restart`/`stop` and reboots
stop it cleanly.

## Troubleshooting

| Symptom | Likely cause | Resolution |
|---|---|---|
| Startup crash referencing the database or a read-only/unwritable path | `/var/greenhouse` missing or not writable by the service user | Create the directory and set ownership (Section 1.3). |
| API not reachable from the UI on `127.0.0.1:5150` | UI pointed at a different port/host, or daemon not running | Confirm the daemon is listening on `127.0.0.1:5150`; check `journalctl -u greenhouse-services`. |
| MQTT features inactive but daemon is up | Broker not running/reachable | Start/verify Mosquitto at the configured `Mqtt:Host:Port`. |
| `dotnet: command not found` under systemd | Service user cannot see the SDK/runtime | Use the full `dotnet` path in `ExecStart` and set `DOTNET_ROOT` (Section 1.1). |

## Acceptance Criteria

- A clean Main Unit host can be taken from bare OS to a running services daemon using only this
  document.
- First run creates the database and schema with no manual migration command.
- The daemon starts and serves the loopback API with no UI process present.
- The daemon is registered to start on boot and restart on failure.

## Deferred and Out-of-Scope Work

- **Containerized deployment** (Docker/Compose) — Phase 2
  (Greenhouse-Services issue: "Containerization & deployment reproducibility").
- **UI process deployment** — documented separately when the UI deployment flow is specified.
- **Provisioning of a checked-in systemd unit file / install script** in the services repo — the
  unit above is a reference; a committed asset is tracked as a services implementation task.

## Open Questions

- Standard service **user** and **install path** conventions (`greenhouse` user, `/opt/...`) are
  proposed here; confirm and canonicalize when the systemd unit asset is committed to the
  services repo.
