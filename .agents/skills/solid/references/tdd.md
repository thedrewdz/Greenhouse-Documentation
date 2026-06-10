# Test-Driven Development

## Purpose

TDD is a design and feedback technique. Use it by default when writing new domain logic, fixing bugs, changing contracts, or refactoring risky behavior. Professional testing strategy is broader than red-green-refactor, but skipping test-first work should be a deliberate exception, not the default.

## Core Loop

```text
Red -> Green -> Refactor
```

### Red

Write a failing test that describes one behavior in domain language.

Good tests are:

- Concrete examples.
- Focused on observable behavior.
- Clear about inputs, action, and expected outcome.
- Independent from unrelated system state.

### Green

Write the simplest implementation that satisfies the behavior. "Simplest" can be a fake, a direct implementation, or a small adaptation of existing code depending on context.

### Refactor

Improve design while keeping behavior unchanged:

- Rename unclear concepts.
- Remove duplication when the abstraction is clearer than the repetition.
- Move behavior to the owner of the rule.
- Split responsibilities that now have different reasons to change.
- Replace brittle test setup with builders or helpers.

## When TDD Helps Most

- Domain rules with edge cases.
- Parsers, validators, and serialization boundaries.
- Bug fixes where the test captures the regression.
- Refactoring legacy code under characterization tests.
- APIs, ports, and contracts with multiple implementations.

## When Another Feedback Loop May Be Better

- Exploratory spikes where the design is intentionally disposable.
- UI polish where visual inspection or component tests give better signal.
- Generated code or mechanical migrations.
- Trivial edits covered by existing tests.
- Infrastructure work that needs integration tests before unit tests are useful.

## Test Naming

Use behavior-centered names:

```csharp
// Weak: abstract and implementation-focused.
public void SetsValue() { }

// Better: concrete outcome.
public void RejectsTelemetryPayloadsWithoutDeviceId() { }
```

## Arrange, Act, Assert

```csharp
[Fact]
public void CalculatesTotalAfterApplyingADiscount()
{
    var order = OrderBuilder.WithItem(new OrderItem(price: 100m)).Build();
    var discount = PercentDiscount.Of(10);

    var total = order.CalculateTotal(discount);

    total.Should().Be(90m);
}
```

## Test Doubles

Use test doubles to isolate expensive, slow, nondeterministic, or external behavior. Use real domain objects for ordinary business rules.

- Dummy: passed but unused.
- Stub: returns known values.
- Spy: records calls for later assertions.
- Mock: verifies expected interactions.
- Fake: working simplified implementation, such as an in-memory repository.

Keep fakes honest with shared contract tests when they stand in for production adapters.

## Common Mistakes

| Mistake | Better Practice |
|---------|-----------------|
| Testing implementation details | Assert observable behavior and contract outcomes. |
| Mocking every collaborator | Use real objects when they are fast and deterministic. |
| Skipping refactor | Treat refactor as the design step. |
| Over-generalizing from one test | Add examples until the behavior is clear, then stop. |
| Making tests hard to read | Use builders, fixtures, and domain language. |
