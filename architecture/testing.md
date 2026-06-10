# Testing Architecture

Use this document when planning test coverage, closing test gaps, or reviewing verification strategy.

## Testing Principle

Test behavior at the smallest boundary that gives useful confidence. Avoid tests that only preserve implementation details.

## Test Layers

## Domain Tests

Use for:

- automation rules
- thresholds
- hysteresis
- safety constraints
- state transitions
- value object validation

## Application Tests

Use for:

- use-case orchestration
- command/query handlers
- collaboration through ports
- failure paths
- idempotency and retry decisions

## Contract Tests

Use for:

- MQTT payload shapes
- command topics
- telemetry and heartbeat examples
- API schemas
- REST statelessness and idempotency for UI-facing API calls
- DTO mapping
- adapter interfaces

## Integration Tests

Use for:

- database adapters
- MQTT adapter behavior
- BLE onboarding adapter behavior
- backend-owned onboarding workflow recovery across UI disconnects or repeated client requests
- framework wiring
- serialization and deserialization

## Scenario And QA Validation

Use for:

- setup flow
- network recovery flow
- Edge Unit onboarding flow
- Edge Unit reconfiguration flow
- dashboard and user-visible behavior
- degraded-state and recovery behavior

## Coverage Expectations

- Critical acceptance criteria need test evidence before review.
- Negative and degraded paths must be covered when they affect safety, recovery, or user trust.
- Remaining risks must be explicit in `test-gap-report.md`.
- Fixable test gaps return to implementation.
- True missing requirements or contradictory docs create documentation feedback.
