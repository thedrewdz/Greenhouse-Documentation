# Persistence Architecture

Use this document when changing repositories, database schema, migrations, telemetry storage, or configuration persistence.

## Persistence Principle

Storage is an infrastructure detail. Domain behavior must not depend on a specific database engine, query library, table shape, or document shape.

## Initial Storage Direction

Initial local persistence uses SQLite unless a spec or ADR supersedes this direction.

Future storage options may include PostgreSQL, TimescaleDB, or InfluxDB when scale or query requirements justify them. Such changes require explicit migration and compatibility planning.

## Persistent State Categories

Persisted state may include:

- greenhouse configuration
- Edge Unit registration
- slot and module topology
- automation rules
- command/audit history
- telemetry
- heartbeat-derived liveness snapshots
- onboarding/reconfiguration state

Persisted state is owned by the Main Unit runtime, not by the UI. The configured Main Unit must be able to reconstruct operational state from persistence and resume runtime behavior during headless startup.

## Repository And State Store Rules

- Application code depends on repository/state-store contracts, not concrete database implementations.
- Persistence adapters map database records to application/domain models.
- Migrations must preserve or explicitly transform existing user configuration.
- Telemetry retention must be bounded and documented.
- Offline buffering must be bounded and recoverable.
- UI view state must not be the source of truth for configuration, topology, automation rules, telemetry, liveness, command history, or onboarding/reconfiguration state.

## Review Checklist

- Does this change alter user-visible behavior or only storage mechanics?
- Are migrations or compatibility notes needed?
- Are retention, ordering, and idempotency rules explicit?
- Are database details isolated from domain/application code?
- Are tests covering mapping and persistence edge cases?
