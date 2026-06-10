# Code Smells and Anti-Patterns

## What Code Smells Are

Code smells are evidence that a design may be harder to understand, test, or change than necessary. Treat them as required review prompts. Leave a smell in place only when refactoring would clearly make the use case worse or drift outside the task.

## Common Smells

| Smell | Typical Signal | Required Response |
|-------|----------------|--------------------|
| Long method | One function mixes validation, policy, IO, and formatting | Extract meaningful steps or separate responsibilities. |
| Large class | One class changes for unrelated reasons | Split by responsibility or boundary. |
| Long parameter list | Repeated groups of values travel together | Introduce a command, request, or options type. |
| Data clump | Same values appear together across calls | Model the concept explicitly. |
| Primitive obsession | Raw strings/numbers carry rules that are repeatedly revalidated | Keep primitives by default; introduce a domain type only when it adds behavior, validation, conversion, or invariant protection. |
| Divergent change | One unit changes for many unrelated requirements | Separate concerns by change driver. |
| Shotgun surgery | One requirement requires scattered edits | Move related behavior behind one contract. |
| Feature envy | A method uses another object more than itself | Move behavior closer to the owner of the rule. |
| Inappropriate intimacy | Callers know internal structure | Encapsulate behavior or introduce a boundary method. |
| Message chain | Code walks through object graphs | Ask the immediate collaborator for the needed behavior. |
| Speculative generality | Extension points exist without real variation | Remove or inline until a variation point is proven. |
| Fat interface | Implementers throw unsupported methods | Split interfaces by client role. |
| Growing type switch | New cases repeatedly edit central logic | Consider strategy, handler registration, lookup tables, or language-native pattern matching. |

## Example: Mixed Responsibilities

```csharp
// Weak: one function owns validation, calculation, persistence, and notification.
async Task ProcessOrderWithMixedResponsibilitiesAsync(Order order)
{
    if (order.Items.Count == 0) throw new InvalidOperationException("Empty order");

    var total = CalculateTotal(order);
    order.SetTotal(total);
    await database.Orders.InsertAsync(order);
    await emailClient.SendAsync(order.CustomerEmail, "Order confirmed");
}

// Better: orchestration names the steps and details live behind contracts.
async Task ProcessOrderAsync(Order order)
{
    orderValidator.Validate(order);
    var pricedOrder = pricingPolicy.Price(order);
    await orderRepository.SaveAsync(pricedOrder);
    await notifications.SendOrderConfirmedAsync(pricedOrder);
}
```

## Example: Speculative Generality

```csharp
// Weak: unused methods force fake implementations.
public interface IFatPaymentProcessor
{
    Task<PaymentResult> ProcessAsync(Payment payment);
    Task RollbackAsync(PaymentId paymentId);
    Task<AuditReport> AuditAsync(PaymentId paymentId);
}

// Better: expose the capability clients need today.
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessAsync(Payment payment);
}
```

## Refactoring Rules

1. Confirm whether the smell causes maintenance, testing, or correctness risk.
2. Add or identify tests that protect current behavior.
3. Refactor in small, reversible steps when the smell is in scope.
4. Preserve public contracts unless the change explicitly includes migration.
5. Stop when the design satisfies the rule; do not polish unrelated code.

## Prevention

- Keep responsibilities named and reviewable.
- Test behavior at useful boundaries.
- Use clear contracts over shared concrete details.
- Let abstractions emerge from evidence.
- Use static analysis and formatters for mechanical consistency.
