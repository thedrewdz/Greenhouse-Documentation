# Software Architecture

## Goal

Architecture must make important change safer and cheaper. It must help teams add, change, remove, test, deploy, observe, and operate behavior without turning every feature into a cross-system excavation.

Good architecture is:

- Aligned with domain boundaries.
- Explicit about contracts and ownership.
- Boring where boring is enough.
- Flexible at real variation points.
- Simple enough to explain and verify.

## Vertical and Horizontal Boundaries

Organize around cohesive capabilities or features when it improves change locality. Preserve layers where they enforce important dependency direction.

```text
feature/
  domain/
  application/
  infrastructure/
  presentation/
```

Layer-first and feature-first structures can both work. The deciding question is: where do changes naturally cluster?

## Dependency Rule

Dependencies must point toward policy and stable contracts, not toward volatile details.

```text
Infrastructure -> Application -> Domain
```

- Domain policy must not import framework, database, broker, SDK, or driver types.
- Application code coordinates use cases through domain concepts and ports.
- Infrastructure implements ports and translates external details.
- Presentation must call application behavior, not persistence or transport details directly.

```csharp
// Inner layer defines the capability.
public interface IUserRepository
{
    Task SaveAsync(User user);
    Task<User?> FindByIdAsync(Guid userId);
}

// Outer layer implements it.
public sealed class PostgresUserRepository : IUserRepository
{
    public Task SaveAsync(User user)
    {
        /* Implementation here, probably Entity Framework code. */
        return Task.CompletedTask;
    }

    public Task<User?> FindByIdAsync(Guid userId)
    {
        /* Implementation here, probably Entity Framework code. */
        return Task.FromResult<User?>(null);
    }
}
```

## Contracts

Contracts are the stable surfaces between parts of the system:

- Public APIs.
- Message payloads.
- Database schema migrations.
- Ports and adapter interfaces.
- File formats.
- Device or firmware communication protocols.

Contracts must document shape, meaning, errors, compatibility expectations, and versioning or migration strategy when needed.

## Ports and Adapters

Use ports and adapters whenever policy must not depend on infrastructure.

- Port: inner contract named after a capability.
- Adapter: outer implementation for a concrete technology.
- Mapper: translation between external DTOs and internal models.
- Composition root: the place where concrete implementations are wired.

This pattern is especially useful for databases, MQTT or other brokers, HTTP clients, file systems, cloud SDKs, hardware drivers, and time/randomness providers.

## Cross-Cutting Concerns

Centralize cross-cutting concerns without hiding behavior:

- Logging and metrics.
- Authentication and authorization.
- Validation.
- Retries, timeouts, and circuit breakers.
- Tracing and correlation IDs.
- Error translation.

Use middleware, decorators, pipeline behaviors, or adapter-level policies instead of scattering these concerns across domain logic.

## Common Architectural Styles

### Layered Architecture

Best when the system is small or the framework naturally supports layers. Keep layer dependencies disciplined to avoid a big ball of mud.

```text
Presentation -> Application -> Domain
Infrastructure -> Application/Domain contracts
```

### Hexagonal Architecture

Best when the domain should be insulated from multiple external technologies.

```text
HTTP Adapter       MQTT Adapter       Database Adapter
       \              |              /
        +------ Application ------+
                   |
                 Domain
```

### Clean Architecture

Best when explicit dependency direction and use-case boundaries matter:

1. Domain entities and domain models.
2. Application use cases.
3. Interface adapters.
4. Frameworks and drivers.

Do not add all layers automatically. Add boundaries whenever they protect meaningful policy or change.

## Walking Skeleton

For new systems or major slices, start with a thin deployable path that proves:

- The main architecture compiles and runs.
- Contracts can be exercised.
- Deployment and configuration work.
- Observability exists for the path.
- Tests can run at the chosen boundaries.

Then deepen behavior incrementally.

## Testing Architecture

Use a balanced test portfolio:

- Many fast tests for domain rules and pure logic.
- Focused integration tests for adapters and important boundaries.
- Contract tests for multiple implementations of the same port or message/API schema.
- Few end-to-end tests for critical journeys.

## Architecture Decision Records

Record hard-to-reverse decisions when they involve real tradeoffs. Keep ADRs short:

```markdown
# Use SQLite for Phase 1 persistence

Status: accepted

We will use SQLite for Phase 1 because local-first deployment, low operational overhead, and simple backup matter more than horizontal database scale. Revisit PostgreSQL if measured concurrency or telemetry volume exceeds SQLite limits.
```

## Red Flags

- Circular dependencies between modules.
- Domain code imports infrastructure or framework types.
- Public contracts drift from implementation.
- Message parsing is spread across business logic.
- Shared mutable state crosses module boundaries.
- Generic `common` or `utils` packages grow without ownership.
- Database schema or transport payloads dictate the domain model.
- A simple feature requires edits in many unrelated areas.
