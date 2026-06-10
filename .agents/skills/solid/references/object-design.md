# Object-Oriented Design

## Responsibility-Driven Design

Objects and modules are defined by responsibilities, not just data. A good responsibility must have a clear owner, a useful name, and a reason to change.

Start from:

- Domain concepts in requirements and contracts.
- Behaviors users or systems need.
- Invariants that must be protected.
- Boundaries where external details enter the system.

Do not mechanically turn every noun into a class or every verb into a method. Let the codebase, language idioms, and domain shape guide the design.

## Finding Responsibilities

For each unit, ask:

- What does it know?
- What does it do?
- What does it decide?
- What contract does it protect?
- What external detail does it hide, if any?

If the answer includes unrelated concerns, split the unit or move behavior closer to the owner of the rule.

## Useful Object Roles

Use these roles as vocabulary. A class does not need to fit a taxonomy perfectly, but its responsibility must still be clear:

| Role | Purpose | Example |
|------|---------|---------|
| Entity | Owns identity and lifecycle | `Order`, `EdgeUnit` |
| Domain model | Represents meaningful domain state or behavior | `Order`, `TelemetryPayload`, `IrrigationSchedule` |
| Policy | Encapsulates a rule or decision | `IrrigationPolicy` |
| Service | Performs stateful domain/application work, often for a cross-cutting concern | `MessagingService` |
| Coordinator | Performs stateless workflow orchestration | `OnboardEdgeUnitUseCase` |
| Port | Defines a needed capability | `MessagePublisher` |
| Adapter | Translates an external technology | `MqttMessagePublisher` |
| Mapper | Converts a model across a boundary | `HeartbeatPayloadMapper` |

## Tell, Don't Ask

Ask an object to perform behavior instead of pulling out its internals and deciding elsewhere.

```csharp
// Weak: caller owns Account's rule.
if (account.Balance >= amount)
{
    account.Balance -= amount;
}

// Better: Account protects its own invariant.
var result = account.Withdraw(amount);
```

Query data for display, reporting, serialization, or simple branching only when no domain decision is being moved away from the data and invariants it governs.

## Design by Contract

A contract must define:

- Preconditions: what must be true before calling.
- Postconditions: what is true after success.
- Invariants: what remains true throughout the object's life.
- Error semantics: how failure is represented.
- Side effects: what external changes may occur.

```csharp
public sealed class BankAccount
{
    private decimal _balance;

    // Invariant: balance is never negative.
    public WithdrawResult Withdraw(decimal amount)
    {
        if (amount <= 0)
        {
            return WithdrawResult.InvalidAmount();
        }

        if (_balance < amount)
        {
            return WithdrawResult.InsufficientFunds();
        }

        _balance -= amount;
        return WithdrawResult.Success(_balance);
    }
}
```

## Composition Over Inheritance

Use composition for behavior that varies independently. Use inheritance only when the subtype relationship is true, the base contract is stable, and substitutability is tested or obvious.

```csharp
public interface IDiscountPolicy
{
    decimal CalculateDiscount(Order order);
}

public sealed class Customer
{
    private readonly IDiscountPolicy _discountPolicy;

    public Customer(IDiscountPolicy discountPolicy)
    {
        _discountPolicy = discountPolicy;
    }

    public decimal DiscountFor(Order order)
    {
        return _discountPolicy.CalculateDiscount(order);
    }
}
```

Composition keeps policy changes local and avoids fragile base-class coupling.

## Law of Demeter

Avoid long navigation chains that expose internal object structure.

```csharp
// Weak: caller knows the object graph.
var city = order.Customer.Address.City;

// Better when shipping city is domain behavior.
var city = order.ShippingCity();
```

Do not hide simple data access behind awkward methods. Use this exception narrowly; object graph knowledge must not create coupling or duplicated traversal logic.

## Encapsulation

Encapsulation hides details that callers should not rely on:

- Mutable state.
- Invariant enforcement.
- Persistence or transport shape.
- External SDKs and framework types.
- Algorithms likely to change.

```csharp
public sealed class Order
{
    private readonly List<OrderItem> _items = [];

    public void AddItem(OrderItem item)
    {
        _items.Add(item);
        EnsureWithinOrderLimit();
    }

    public decimal Total()
    {
        return _items.Sum(item => item.Total);
    }
}
```

## Polymorphism and Alternatives

Polymorphism is useful for stable contracts with multiple implementations. It is not the only answer to conditionals.

Use:

- A simple conditional only when the cases are few, local, and stable.
- A lookup table when values map directly to actions or constants.
- Pattern matching when the language supports it clearly.
- Strategy or handler types when new cases are frequent or behavior is complex.
- Adapter types when external implementations must share one internal contract.

## Simple Values vs Domain Types

Use primitives and framework scalar types for simple values. Do not create a class or struct whose only meaningful behavior is wrapping one primitive field. That adds noise, mapping burden, serialization friction, and cognitive overhead without improving design.

Use a dedicated domain type only when it earns its place by owning behavior or invariants that would otherwise be duplicated.

Good reasons to introduce a domain type:

- It validates a non-trivial format or range in one place.
- It owns conversion logic, such as protocol encoding or unit conversion.
- It groups multiple related values that travel together.
- It protects a real invariant with behavior, not just a constructor guard.
- It is an entity with identity and lifecycle.

Poor reasons to introduce a domain type:

- Two parameters share the same primitive type.
- A primitive has a domain-sounding name.
- A style guide says primitives are suspicious.
- The type would contain only `Value` plus boilerplate equality.

### Entities

Entities have identity that survives attribute changes. They usually protect lifecycle rules through behavior.

Examples:

- `User`
- `Order`
- `EdgeUnit`
- `Greenhouse`

## Aggregates

An aggregate is a consistency boundary. The aggregate root is the entry point that protects invariants for related objects.

Use aggregates when:

- Multiple objects must change together safely.
- External code should not mutate child objects directly.
- There is a clear transactional consistency boundary.

Do not create aggregates for every object graph. Use them wherever consistency rules justify the structure.

## Review Checklist

1. Does this unit own a clear responsibility?
2. Are decisions close to the data and invariants they use?
3. Is inheritance avoided unless substitutability is clear?
4. Are external details hidden behind ports or adapters?
5. Is the design simpler than the problem it models?
