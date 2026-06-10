# Managing Complexity

## Two Types of Complexity

Essential complexity belongs to the problem domain. It includes real business rules, safety requirements, distributed systems behavior, physical hardware limits, regulatory constraints, and user workflows.

Accidental complexity is introduced by the solution. It includes unnecessary indirection, unclear names, duplicated rules, framework leakage, hidden state, premature generalization, and weak boundaries.

The goal is to express essential complexity clearly and remove accidental complexity aggressively but safely. Treat unnecessary complexity as a defect unless there is a clear, documented reason to keep it.

## How Complexity Shows Up

| Signal | Meaning |
|--------|---------|
| Change amplification | A small requirement touches many unrelated files. |
| Cognitive load | Understanding one behavior requires loading many unrelated concepts. |
| Unknown unknowns | Changes cause surprising side effects. |
| Hidden coupling | Behavior depends on call order, global state, naming conventions, or timing. |
| Abstraction debt | Interfaces and layers exist without protecting real variation points. |
| Duplication drift | Copied logic begins to diverge or contradict itself. |

## Simplicity Principles

### KISS

Start with the most direct design that satisfies the known requirement and preserves important boundaries. Add indirection only when it protects a real boundary, responsibility, or variation point.

```csharp
// Weak: ceremony before a real variation point exists.
public sealed class UserServiceFactoryProvider
{
    public UserServiceFactory CreateFactory() { /* ... */ }
}

// Better: direct and understandable.
public sealed class UserService
{
    public Task<User?> GetUserAsync(UserId id) { /* ... */ }
}
```

### YAGNI

Do not build features, extension points, configuration, or abstractions for hypothetical needs. Record future work separately when it matters.

Warning phrases:

- "We might need this later."
- "It would be nice to have."
- "This makes it enterprise-ready."
- "This is more flexible" without a named variation point.

### DRY

DRY means one source of truth for one piece of knowledge. It does not mean all similar-looking code must be merged.

Allow duplication only when:

- The duplicated code may evolve differently.
- The abstraction would need vague names.
- The abstraction hides important domain differences.
- There are only one or two examples and the pattern is not stable.

Extract when:

- The same rule appears in multiple places.
- Changes must remain synchronized.
- The common concept has a clear domain name.
- Tests can cover the shared behavior.

## Boundaries Reduce Complexity

Good boundaries make local reasoning possible:

- Domain policy does not know infrastructure details.
- Adapters translate external contracts to internal models.
- UI code coordinates presentation, not business rules.
- Message, API, and storage schemas are validated at the edge.
- Cross-cutting concerns such as logging, retries, authentication, and metrics are centralized without hiding behavior.

## Technical Debt

Technical debt is acceptable only when it is deliberate, visible, bounded, and justified by the current delivery need.

Pay it down when:

- It blocks current work.
- It causes defects or operational risk.
- It makes tests unreliable.
- You are already touching the affected area.

Avoid refactoring only when:

- The code is stable and unlikely to change.
- It is about to be replaced.
- You cannot protect behavior with tests or other verification.
- The refactor is unrelated to the current objective.

## Simple Design Checklist

1. Does the code work and have useful verification?
2. Does it express intent in domain language?
3. Are responsibilities and boundaries clear?
4. Is duplication intentional or safely removed?
5. Are there unnecessary abstractions, configuration options, or framework dependencies?
