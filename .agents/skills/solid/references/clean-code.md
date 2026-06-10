# Clean Code Practices

## What Clean Code Means

Clean code is code that communicates intent, protects important invariants, and can be changed with confidence. Follow the standards in this guide by default. Deviate only when a rule would clearly reduce clarity, correctness, or fit with the repository's established idioms.

Clean code is:

- Clear at the call site.
- Consistent with the domain language.
- Easy to test at the right boundary.
- Explicit about side effects and failure modes.
- Small enough to understand without needless fragmentation.
- Simple enough that future maintainers can safely change it.

## Naming Standards

Use names in this order of priority:

1. Consistent: the same concept has the same name everywhere.
2. Domain-centered: names come from requirements and contracts.
3. Specific: avoid vague names such as `data`, `info`, `helper`, `manager`, `processor`, and `utils`.
4. Readable at the call site.
5. Searchable for important concepts.
6. Brief when clarity is preserved.

```csharp
public interface ITelemetryService
{
    // Weak: vague and inconsistent.
    void ProcessData(object info);

    // Weak: name is more explicit, but still redundant because it restates the enclosing interface
    void ValidateTelemetryPayload(TelemetryPayload payload);

    // Better: the interface and parameter type already provide the context.
    void Validate(TelemetryPayload payload);
}
```

7. Avoid naming redundancy, like repeating the name of the domain or class in every method.

```csharp
/// poor example
public interface ISpaceDrive
{
    void SetSpaceDriveThrust(float spaceDriveThrust);
}

/// good example
public interface ISpaceDrive
{
    void SetThrust(float thrust);
}
```

## Function and Class Shape

Size is a warning signal, not an automatic failure gate. Keep functions and classes small enough to understand locally. Larger units must justify themselves by owning one cohesive concept more clearly than a split design would.

Use:

- Guard clauses for validation and exceptional cases.
- Functions that do one level of meaningful work.
- Extracted helpers with names that explain intent.
- Cohesive classes with one primary reason to change.
- Plain data structures for simple transport or view models.
- Rich domain objects when behavior and invariants belong with the data.

Avoid:

- Hidden side effects.
- Temporal coupling that requires undocumented call order.
- Long chains through object internals.
- Classes that mix domain rules, IO, serialization, and presentation.
- Splitting code so aggressively that behavior becomes harder to trace.

## Comments

Comments must explain why, not restate what the code says.

Good comments capture:

- Non-obvious business rules.
- Tradeoffs or compatibility constraints.
- Safety warnings.
- Links to decisions, specs, or external contracts.

Use clearer names and smaller functions instead of explanatory comments for ordinary control flow.

## Error Handling

Clean code must make failure predictable:

- Validate untrusted input at boundaries.
- Use consistent error types or result objects for a contract.
- Preserve useful diagnostic context without leaking secrets.
- Keep retry, timeout, and idempotency behavior explicit around external systems.
- Do not let infrastructure-specific exceptions leak into domain policy unless the contract says so.
- Avoid a try/catch block that simply rethrows the error. A try/catch block should only exist if something explicitly useful is being done with the exception.
- Prefer validation over error handling to find data that would result in an error state.
- Catch exceptions at system and workflow boundaries by default. Catch lower in the call stack only to recover, translate the exception, add useful context, clean up resources, or enforce retry/transaction policy.

## Formatting

Follow the repository's formatter and language idioms. Formatting should reduce visual noise:

- Keep related code together.
- Put public behavior before implementation details when it improves scanning.
- Use blank lines to separate concepts, not every statement.
- Let automated tools settle indentation, spacing, and line wrapping when available.
- In C#, use `#region` and `#endregion` as a consistent class map for larger classes. Standard regions may include `Fields`, `Constructors`, `Properties`, `Public Methods / Contract Realization`, and `Private / Protected Methods`.
- Domain-specific regions are acceptable when they identify one cohesive behavior area, such as `Hyperdrive setup logic`.
- Do not use regions to hide unrelated responsibilities, oversized classes, or code that should be extracted.

## General Practices

- Prefer fast fail logic.

```csharp
/// weak example
void PlantSeeds(int seedCount)
{
    if (seedCount > 0)
    {
        //  plant each seed here
    }
}

/// better example - easier to read without deeply nested IF statements. Failure and success path is obvious
void PlantSeeds(int seedCount)
{
    if (seedCount == 0) return;
    //  plant each seed here
}
```

- Avoid getters or setters with additional logic unless unavoidable because a framework depends on it.

```csharp
/// Avoid getter with logic. Avoid setter with logic - prefer a set method instead. Avoid private backing field unless needed.
private int seedCount;

public int SeedCount
{
    get
    {
        if (seedCount < 0)
        {
            seedCount = 0;
        }
        return seedCount;
    }
    set
    {
        if (value < 0)
        {
            seedCount = 0;
        }
        else
        {
            seedCount = value;
        }
    }
}

/// Prefer no backing field when no additional state behavior is needed.
public int SeedCount { get; private set; }

public void SetSeedCount(int seedCount)
{
    //  validate
    if (seedCount < 0) throw new ArgumentOutOfRangeException(nameof(seedCount));
    //  update the value
    SeedCount = seedCount;
}
```

3. Avoid exact-name shadowing that forces use of the `this` keyword. In C#, `SeedCount` and `seedCount` are different identifiers; that normal property/parameter casing does not count as shadowing.

```csharp
/// Avoid exact-name shadowing.
private int seedCount = 0;

void SetSeedCount(int seedCount)
{
    //  validate
    if (seedCount < 0) throw new ArgumentOutOfRangeException(nameof(seedCount));
    //  update the value
    this.seedCount = seedCount; // `this` is required because the parameter shadows the field.
}

/// Normal C# casing does not shadow.
void SetSeedCount(int seedCount)
{
    if (seedCount < 0) throw new ArgumentOutOfRangeException(nameof(seedCount));
    SeedCount = seedCount; // C# is case sensitive.
}
```

4. Setter-style methods should use PascalCase like all other C# methods.
5. Use Verb or Verb-Noun naming for method names, eg: `Execute` or `StartEngine`.
6. Avoid magic numbers. Prefer scoped constants depending on where they are needed. When a constant is used throughout the solution, consider placing it in a central constants code file in a project that is safe to reference where it is needed without violating other rules.
7. Avoid magic strings. This applies to general use string literals and exception messages.

```csharp
/// prefer scoped constants over magic strings and numbers
public class MyClass : IMyContract
{
    private const int MIN_SEED_THRESHOLD = 2;
    private const string MY_MAGIC_STRING = "Hello";

    /// Weak: do not use magic strings to reference variables, fields and methods
    void SetSeedCount(int seedCount)
    {
        if (seedCount < 0) throw new ArgumentOutOfRangeException("seedCount");
        SeedCount = seedCount; // C# and C++ are case sensitive
    }

    /// Prefer using nameof to reference variables, fields and methods rather than magic strings
    void SetSeedCount(int seedCount)
    {
        if (seedCount < 0) throw new ArgumentOutOfRangeException(nameof(seedCount));
        SeedCount = seedCount; // C# and C++ are case sensitive
    }
}
```


## Review Checklist

1. Can a maintainer name the responsibility of this unit quickly?
2. Are domain terms consistent with contracts and documentation?
3. Are side effects and failure modes visible?
4. Are invalid states prevented or rejected near the boundary?
5. Is the code simpler after the change than before, or is the added complexity justified?
