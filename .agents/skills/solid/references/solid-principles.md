# SOLID Principles

## Overview

SOLID is a set of object-oriented design guardrails for reducing coupling, improving cohesion, and making change safer. The principles also apply at module, service, and architecture boundaries. They are expected defaults, but they are not a replacement for domain modeling, tests, observability, security, or operational judgment.

Use SOLID to answer practical questions before committing to a design:

- What is likely to change independently?
- What contract must stay stable?
- What detail should be hidden behind an adapter?
- What behavior can be tested without real infrastructure?
- What abstraction protects a real boundary instead of adding ceremony?

## S - Single Responsibility Principle

Core idea:

A unit must have one primary reason to change.

SRP is about change drivers, not tiny files. A class or module can contain multiple helper methods and still have one responsibility only when they all serve the same policy or capability.

### Problem It Solves

SRP reduces god objects, mixed concerns, and unrelated edits. Violations often appear when one class handles domain rules, persistence, serialization, validation, logging, and UI formatting at the same time.

### Apply It

- Name the responsibility in domain language.
- Separate policy from transport, storage, presentation, and device details.
- Split code when different stakeholders, failure modes, or release cadences pull it in different directions.
- Keep cohesive data and behavior together when they change together.

```csharp
// Weak: domain behavior, persistence, and presentation are mixed.
public sealed class OrderWithMixedResponsibilities
{
    public decimal CalculateTotal() { /* ... */ }
    public Task SaveToDatabaseAsync() { /* ... */ }
    public string RenderInvoiceHtml() { /* ... */ }
}

// Better: each type has a focused reason to change.
public sealed class Order
{
    public void AddItem(OrderItem item) { /* ... */ }
    public decimal CalculateTotal() { /* ... */ }
}

public interface IOrderRepository
{
    Task SaveAsync(Order order);
}

public sealed class InvoiceRenderer
{
    public InvoiceDocument Render(Order order) { /* ... */ }
}
```

### Detection Questions

- Can the responsibility be described without "and then"?
- Would separate requirements change different parts of this unit for unrelated reasons?
- Does testing this behavior require unrelated infrastructure?
- Is data being passed around because behavior lives in the wrong place?

## O - Open/Closed Principle

Core idea:

Stable behavior must be open for extension and closed for risky modification.

OCP does not mean every condition needs a class hierarchy. It means high-churn variation points must be designed so new cases can be added without repeatedly editing tested central logic.

### Problem It Solves

OCP reduces regressions caused by large conditionals, central registries that require scattered edits, and direct changes to stable policy code whenever a new type or capability appears.

### Apply It

- Identify variation points that are real or already emerging.
- Use strategy, handlers, data-driven rules, configuration, pattern matching, or lookup maps as appropriate to the language and scale.
- Keep extension mechanisms discoverable and tested.
- Avoid speculative plugin systems only when a direct conditional is clearly simpler and unlikely to grow.

```csharp
// Weak when new shipping methods are frequent.
public sealed class ShippingCalculator
{
    public decimal Calculate(string type, decimal orderValue)
    {
        if (type == "standard") return orderValue < 50 ? 5m : 0m;
        if (type == "express") return 15m;
        throw new InvalidOperationException("Unsupported shipping type");
    }
}

// Better when shipping methods are a real variation point.
public interface IShippingMethod
{
    decimal CalculateCost(decimal orderValue);
}

public sealed class StandardShipping : IShippingMethod
{
    public decimal CalculateCost(decimal orderValue) { /* ... */ }
}

public sealed class ExpressShipping : IShippingMethod
{
    public decimal CalculateCost(decimal orderValue) { /* ... */ }
}
```

### Detection Questions

- Does every new type require editing the same central function?
- Is stable, tested behavior being reopened for unrelated additions?
- Is the abstraction protecting a real change axis, or only guessing at one?

## L - Liskov Substitution Principle

Core idea:

An implementation must be usable anywhere its abstraction is expected without breaking the caller's assumptions.

LSP is contract discipline. It applies to subclasses, interface implementations, test doubles, repositories, message handlers, transport adapters, and device drivers.

### Problem It Solves

LSP prevents surprising implementations that force callers to add type checks, special cases, or defensive retries that are not part of the contract.

### Apply It

- Define required behavior, invariants, error semantics, side effects, and concurrency expectations.
- Do not weaken preconditions or strengthen postconditions unexpectedly.
- Do not return incompatible units, nullability, ordering, or error types.
- Keep test doubles honest enough to preserve production behavior that matters.

```csharp
public interface ITemperatureSensor
{
    Task<double> ReadCelsiusAsync();
}

// Weak: violates units promised by the interface.
public sealed class FahrenheitSensor : ITemperatureSensor
{
    public Task<double> ReadCelsiusAsync()
    {
        return Task.FromResult(72.0);
    }
}

// Better: adapter preserves the interface contract.
public sealed class FahrenheitSensorAdapter : ITemperatureSensor
{
    public async Task<double> ReadCelsiusAsync()
    {
        var fahrenheit = await ReadFahrenheitAsync();
        return (fahrenheit - 32) * 5 / 9;
    }

    private Task<double> ReadFahrenheitAsync() { /* ... */ }
}
```

### Detection Questions

- Do callers check the concrete type before using an abstraction?
- Do some implementations throw "not supported" for required methods?
- Do different implementations use different units, ordering, retry behavior, or errors?
- Are tests passing only because the fake is easier than the real implementation?

## I - Interface Segregation Principle

Core idea:

Clients must depend only on the behavior they use.

ISP requires use-case-shaped interfaces over broad capability bags. It keeps dependencies understandable and prevents partial implementations.

### Problem It Solves

ISP avoids fat interfaces that cause empty methods, unsupported operations, needless mocking, and consumers that become coupled to unrelated capabilities.

### Apply It

- Split read/write, command/query, lifecycle/runtime, and admin/user concerns when clients use them separately.
- Keep interface names role-based and client-facing.
- Compose small interfaces where a broader capability is genuinely needed.
- Avoid exposing framework or infrastructure types through inner-layer interfaces.

```csharp
// Weak: one interface forces unrelated capabilities onto every device.
public interface IGreenhouseDevice
{
    Task<Telemetry> ReadTelemetryAsync();
    Task SetRelayAsync(int slotId, RelayState state);
    Task StartOtaUpdateAsync(Uri imageUri);
}

// Better: clients depend on the role they need.
public interface ITelemetrySource
{
    Task<Telemetry> ReadTelemetryAsync();
}

public interface IActuatorCommander
{
    Task SetRelayAsync(int slotId, RelayState state);
}

public interface IOtaUpdateTarget
{
    Task StartOtaUpdateAsync(Uri imageUri);
}
```

### Detection Questions

- Are consumers mocking methods they never call?
- Are implementers forced to throw unsupported errors?
- Does a UI or workflow depend on methods that belong to another workflow?
- Would splitting the interface clarify ownership and testing?

## D - Dependency Inversion Principle

Core idea:

High-level policy must not depend on low-level details. Both must depend on stable abstractions.

DIP protects domain and application behavior from framework, transport, storage, and hardware decisions. It does not require creating an interface for every class, but it does require abstractions around unstable details, test boundaries, cross-process contracts, or multiple implementations.

### Problem It Solves

DIP reduces tight coupling to databases, HTTP clients, MQTT clients, UI frameworks, file systems, cloud SDKs, and hardware drivers. It also improves testability by allowing policy code to run without real infrastructure.

### Apply It

- Define ports in the inner layer using domain language.
- Put adapters for concrete technologies in outer layers.
- Use dependency injection or composition roots to wire implementations.
- Keep DTOs, SDK objects, database records, and transport payloads out of core policy code.

```csharp
// Weak: policy is tied to a concrete email vendor.
public sealed class VendorLockedOrderConfirmationService
{
    private readonly SendGridClient _email = new();

    public async Task ConfirmAsync(Order order)
    {
        await _email.SendAsync(order.CustomerEmail, "Order confirmed");
    }
}

// Better: policy depends on the capability it needs.
public interface INotificationPort
{
    Task SendOrderConfirmedAsync(string email, Guid orderId);
}

public sealed class OrderConfirmationService
{
    private readonly INotificationPort _notifications;

    public OrderConfirmationService(INotificationPort notifications)
    {
        _notifications = notifications;
    }

    public async Task ConfirmAsync(Order order)
    {
        await _notifications.SendOrderConfirmedAsync(order.CustomerEmail, order.Id);
    }
}
```

### Detection Questions

- Does domain/application code import framework, database, broker, or SDK types?
- Is a real external service required to test policy behavior?
- Would replacing a transport or storage engine require changing business rules?
- Are abstractions named after implementation details instead of capabilities?

## Architecture-Level Application

SOLID scales when applied to boundaries:

| Principle | Architecture Application |
|-----------|--------------------------|
| SRP | A bounded context, module, or service owns one cohesive business capability. |
| OCP | New policies, message handlers, device capabilities, or workflows can be added without destabilizing unrelated flows. |
| LSP | Adapters and implementations honor the same contract, including payload shape, errors, units, timing assumptions, and idempotency. |
| ISP | Public APIs, ports, and message contracts are shaped around consumer workflows. |
| DIP | Domain/application policy depends on ports and contracts; infrastructure implements them. |

## Common Tradeoffs and Rare Exceptions

- A small conditional is acceptable instead of a strategy hierarchy only when the case list is stable, local, and not duplicated elsewhere.
- A little duplication is acceptable only when the abstraction would hide behavior or guess at an unproven change axis.
- Primitive scalar values are the default for simple data. Dedicated domain types are justified only when they own behavior, validation, conversion, or invariant protection beyond wrapping one primitive.
- Interfaces are required at boundaries, around volatility, or where tests need replacement behavior.
- Inheritance is rare and must be contract-driven; composition is the default.

Document meaningful deviations from these defaults. The exception must stay narrow and tied to the specific use case.

## Quick Reference

| Principle | One-Liner | Red Flag |
|-----------|-----------|----------|
| SRP | One primary reason to change | One class owns rules, IO, formatting, and persistence |
| OCP | Extend stable behavior safely | New cases repeatedly edit central policy code |
| LSP | Same abstraction, same contract | Callers branch by concrete implementation |
| ISP | Small client-shaped interfaces | Implementations throw unsupported methods |
| DIP | Policy depends on capabilities, not details | Core code imports framework, broker, database, SDK, or driver types |
