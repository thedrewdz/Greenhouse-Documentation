# Testing Strategy

## Purpose

Tests are part of the design contract. Every meaningful behavior change must have useful verification unless a test would be brittle, impossible in the current environment, or lower signal than another validation method. Exceptions must be explicit for non-trivial work.

## Test Portfolio

Use a balanced test portfolio:

- Unit tests for domain rules, pure logic, validators, parsers, and small services.
- Integration tests for adapters, storage, broker clients, HTTP clients, serialization, and framework wiring.
- Contract tests for public APIs, message payloads, schemas, and ports with multiple implementations.
- End-to-end or acceptance tests for critical user journeys and cross-component workflows.

Default to many fast tests near the behavior and fewer broad tests at the system edge. Do not rely only on end-to-end tests for business rules.

## Unit Tests

Unit tests must be fast, deterministic, and focused on observable behavior.

```csharp
[Fact]
public void CalculatesTotalForTwoLineItems()
{
    var order = new Order();
    order.AddItem(new OrderItem(price: 100m));
    order.AddItem(new OrderItem(price: 50m));

    order.CalculateTotal().Should().Be(150m);
}
```

## Integration Tests

Integration tests must cover important boundaries and real adapter behavior.

Use them for:

- Database persistence and queries.
- MQTT or message broker contracts.
- HTTP clients and APIs.
- Serialization and deserialization.
- Dependency injection and framework configuration.

## Contract Tests

Contract tests are required when multiple implementations claim to satisfy the same interface or message/API schema.

```csharp
public abstract class UserRepositoryContract
{
    protected abstract IUserRepository CreateRepository();

    [Fact]
    public async Task SavesAndRetrievesAUser()
    {
        var repo = CreateRepository();
        var user = User.Create("Test");

        await repo.SaveAsync(user);

        var found = await repo.FindByIdAsync(user.Id);
        found.Should().Be(user);
    }
}
```

## End-to-End and Acceptance Tests

Use end-to-end tests for critical workflows only. They must verify user-visible or system-visible outcomes, not implementation details.

Examples:

- First-run setup completes.
- Edge Unit onboarding completes.
- A command path reaches an actuator and reports acknowledgement.
- A critical safety workflow preserves failsafe behavior.

## Arrange, Act, Assert

Structure tests with clear setup, behavior, and assertion. Equivalent Given/When/Then structure is acceptable for scenario tests.

```csharp
[Fact]
public void RejectsTelemetryPayloadsWithoutDeviceId()
{
    var payload = new TelemetryPayload { Id = 10 };

    var result = ValidateTelemetryPayload(payload);

    result.Should().Be(ValidationResult.MissingField("device_id"));
}
```

## Test Naming

Test names must describe behavior in domain language and are exceptions to the "clean and concise" standard for general method naming. In contrast, test names are often very long and descriptive.

Avoid:

```csharp
public void Works() { }
public void SetsProperty() { }
```

Use:

```csharp
public void RejectsTelemetryPayloadsWithoutDeviceId() { }
public void ReturnsNullWhenTheUserDoesNotExist() { }
```

## Test Doubles

Use test doubles to isolate expensive, slow, nondeterministic, or external behavior. Use real domain objects for ordinary business rules.

- Dummy: passed but unused.
- Stub: returns known values.
- Spy: records calls for later assertions.
- Mock: verifies expected interactions.
- Fake: working simplified implementation.

Fakes standing in for production adapters must be covered by shared contract tests when behavior matters.

## Builders and Fixtures

Use builders or fixtures when setup noise hides the behavior under test. Keep builders domain-focused and avoid creating one giant fixture that couples unrelated tests.

## Common Mistakes

| Mistake | Problem | Required Response |
|---------|---------|-------------------|
| Testing implementation details | Tests break during harmless refactors | Assert behavior and contract outcomes. |
| Too many mocks | Tests verify wiring instead of behavior | Use real objects unless isolation is needed. |
| Shared mutable state | Flaky tests | Isolate each test. |
| No meaningful assertions | False confidence | Assert the outcome that matters. |
| Only broad tests | Slow feedback and poor diagnosis | Add focused lower-level tests. |
| Ignoring boundary behavior | Contracts drift | Add integration or contract tests. |
