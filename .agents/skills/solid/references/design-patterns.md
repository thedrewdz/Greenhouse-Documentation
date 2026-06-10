# Design Patterns

## Purpose

Design patterns are standard solutions to recurring design forces. Use them as implementation tools when they strengthen responsibility, extension, substitution, or boundary control.

Patterns must solve a real problem in the current design. Do not add a pattern for a hypothetical future need, but do use an appropriate pattern when the design force is already present.

## Pattern Selection Rule

Before introducing a pattern, confirm:

1. The problem is present now.
2. The pattern makes responsibilities clearer.
3. The pattern reduces coupling or protects a boundary.
4. The team and codebase can support the added structure.
5. A simpler direct implementation would be less maintainable.

If these are true, use the pattern. If not, keep the design direct and document the reason when the tradeoff is meaningful.

## Creational Patterns

### Factory

Use a factory when object creation is complex, varies by type, or must hide infrastructure details.

```csharp
public interface INotification
{
    void Send(string message);
}

public sealed class NotificationFactory
{
    public INotification Create(NotificationType type)
    {
        return type switch
        {
            NotificationType.Email => new EmailNotification(),
            NotificationType.Sms => new SmsNotification(),
            NotificationType.Push => new PushNotification(),
            _ => throw new ArgumentOutOfRangeException(nameof(type))
        };
    }
}
```

### Builder

Use a builder when construction has many valid combinations, must preserve invariants, or tests need readable setup.

```csharp
var order = new OrderBuilder()
    .WithCustomer(customer)
    .WithItem(item)
    .Paid()
    .Build();
```

### Singleton

Use a singleton only when a single process-wide instance is a true invariant. Prefer dependency injection for configuration, logging, clients, and services so tests and composition remain controlled.

## Structural Patterns

### Adapter

Use an adapter whenever external APIs, SDKs, transport clients, storage records, or hardware drivers differ from the internal contract.

```csharp
public interface IPaymentGateway
{
    ChargeResult Charge(decimal amount);
}

public sealed class LegacyPaymentAdapter : IPaymentGateway
{
    private readonly LegacyPaymentApi _legacyApi;

    public LegacyPaymentAdapter(LegacyPaymentApi legacyApi)
    {
        _legacyApi = legacyApi;
    }

    public ChargeResult Charge(decimal amount)
    {
        var success = _legacyApi.MakePayment(decimal.ToInt32(amount * 100));
        return success ? ChargeResult.Success() : ChargeResult.Failed();
    }
}
```

### Decorator

Use a decorator when cross-cutting behavior must wrap an existing contract without changing the underlying implementation.

Common uses:

- Logging.
- Metrics.
- Retries.
- Authorization.
- Caching.

### Composite

Use composite for tree structures where individual items and groups must share a contract.

### Proxy

Use proxy for access control, lazy loading, caching, or remote resource protection when callers should keep using the same contract.

## Behavioral Patterns

### Strategy

Use strategy when a policy or algorithm varies behind one stable contract.

```csharp
public interface IPricingPolicy
{
    decimal Calculate(Order order);
}

public sealed class CheckoutService
{
    private readonly IPricingPolicy _pricingPolicy;

    public CheckoutService(IPricingPolicy pricingPolicy)
    {
        _pricingPolicy = pricingPolicy;
    }

    public CheckoutResult Checkout(Order order)
    {
        var total = _pricingPolicy.Calculate(order);
        return CheckoutResult.WithTotal(total);
    }
}
```

### Observer

Use observer or pub/sub when producers must not know all consumers of an event. Keep event contracts explicit and avoid hiding critical synchronous behavior behind surprise side effects.

### Command

Use command when operations need queuing, retries, auditability, undo/compensation, or transport across a boundary.

### Template Method

Use template method only when inheritance is already justified and the algorithm skeleton is stable. Prefer strategy or composition when steps vary independently.

## Anti-Patterns

| Anti-Pattern | Problem | Required Response |
|--------------|---------|-------------------|
| God object | One unit owns unrelated responsibilities | Split by reason to change. |
| Golden hammer | One pattern used for every problem | Match the pattern to the actual design force. |
| Premature abstraction | Extension point without current variation | Remove it until the variation exists. |
| Framework leakage | Domain code imports framework or SDK types | Add a port/adapter boundary. |
| Copy-paste rules | Same business rule in multiple places | Extract the rule behind a named contract. |

## Deviation Rule

Do not avoid a pattern merely to keep code short when the pattern would protect a real contract or responsibility. Do not add a pattern merely to look sophisticated. Deviations from the expected pattern must be narrow and based on clarity, performance, framework constraints, or proven stability of the simple case.
