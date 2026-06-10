---
name: solid
description: Use this skill when implementing, refactoring, reviewing, or designing software because maintainability, testability, boundaries, and long-term change cost matter. Apply SOLID as required design guardrails alongside tests, contracts, domain language, and incremental design. Deviate only when a principle clearly does not fit the use case, and make that rare exception explicit.
---

# SOLID Skill: Governed Software Design

Use SOLID to make software easier to change safely. Treat the principles as decision aids that are expected to govern the design. Deviate only when a principle clearly does not make sense for the use case; that should be rare, deliberate, and explainable. Default to clear behavior, stable contracts, small cohesive modules, and simple designs that fit the existing system.

## When This Skill Applies

Use this skill when:

- Adding or changing services, modules, use cases, handlers, UI workflows, firmware components, or integration code.
- Refactoring code with unclear responsibilities, duplicated behavior, tight coupling, or brittle tests.
- Reviewing code for maintainability, substitutability, dependency direction, contract drift, or avoidable complexity.
- Planning architecture where future change, testing strategy, or system boundaries are significant.

Skip this skill only for tiny mechanical edits where the existing design is unaffected.

## Core Philosophy

Good software serves users by making correct behavior affordable to build, verify, operate, and change.

Optimize for these outcomes:

- Clear behavior and acceptance criteria.
- Stable contracts at system boundaries.
- High cohesion and low coupling.
- Local reasoning: a developer can understand one unit without loading the whole system.
- Fast feedback through appropriate tests.
- Incremental evolution without speculative frameworks.

## Working Process

### 1. Clarify Behavior Before Design

Before implementation, identify:

- The user-visible behavior or system outcome.
- Inputs, outputs, side effects, failure modes, and invariants.
- Existing contracts, schemas, APIs, topics, events, storage models, or hardware assumptions.
- The smallest useful change that satisfies the requirement.

When contracts are involved, update or verify the contract before implementation.

### 2. Choose the Right Test Feedback

Use behavior-first testing. Default to TDD for new domain logic, bug fixes, risky refactors, parsers, validators, and boundary contracts. Skip test-first work only when it would add brittle or meaningless tests; document or explain that exception when the risk is non-trivial.

Use the smallest test that gives useful confidence:

- Unit tests for domain logic, branching rules, pure functions, parsing, validation, and small services.
- Integration tests for adapters, database queries, MQTT/message flows, HTTP clients, framework configuration, and serialization.
- Contract tests for public APIs, message payloads, schemas, and adapter interfaces.
- End-to-end or acceptance tests for critical user journeys and cross-component behavior.

See: [references/testing.md](references/testing.md) and [references/tdd.md](references/tdd.md)

### 3. Apply SOLID Pragmatically

Use SOLID to reduce change cost. These are guardrails, not casual preferences:

| Principle | Practical Standard |
|-----------|--------------------|
| Single Responsibility | A module must have one primary reason to change and a responsibility that can be named in domain language. |
| Open/Closed | Stable, tested behavior must be extended through new policies, handlers, strategies, or configuration instead of repeated edits to central conditionals. |
| Liskov Substitution | Implementations of the same abstraction must honor the same contract, error semantics, invariants, and side effects. |
| Interface Segregation | Interfaces must be shaped around client use cases, not implementation convenience. Do not force consumers to know methods they never use. |
| Dependency Inversion | Domain and application policy must not depend on frameworks, transport clients, storage engines, or hardware drivers. Keep details behind ports/adapters. |

See: [references/solid-principles.md](references/solid-principles.md)

### 4. Keep Boundaries Explicit

Boundary code must parse, validate, translate, and isolate external details.

Apply these rules:

- Domain/application code uses domain concepts and contracts, not raw transport payloads.
- Infrastructure adapters own framework, database, MQTT, HTTP, file, cloud, and device-driver details.
- Serialization and parsing stay near the system boundary.
- Mapping between external DTOs and internal models is explicit and tested.
- Error handling is part of the contract, not an afterthought.

### 5. Name and Shape Code for Readers

Naming priority:

1. Consistency with domain and repository terminology.
2. Specificity over vague names such as `data`, `info`, `helper`, `manager`, or `processor`.
3. Readability at the call site.
4. Searchability for important concepts.
5. Brevity when it does not reduce clarity.

Structure code so intent is obvious:

- Keep functions and classes small enough to reason about locally. Treat size thresholds as warning signals, not automatic failure gates.
- Use early returns and guard clauses when they clarify flow.
- Avoid hidden temporal coupling and surprising side effects.
- Use primitive values for simple scalar data by default.
- Do not introduce single-field wrapper classes or structs solely to prevent argument-order mistakes.
- Introduce a dedicated domain type only when it carries meaningful behavior, validation, conversion, unit semantics, or invariants beyond storing one primitive.
- Default to composition over inheritance unless the substitutability contract is clear and tested.

See: [references/clean-code.md](references/clean-code.md) and [references/object-design.md](references/object-design.md)

### 6. Manage Complexity Deliberately

Distinguish essential complexity from accidental complexity.

Watch for:

- Change amplification: one small behavior change requires edits across many files.
- Cognitive load: the reader must understand unrelated systems to change one feature.
- Coupling by convention: behavior depends on undocumented order, naming, timing, or shared mutable state.
- Abstraction debt: indirection exists without multiple implementations, protected contracts, or a real change axis.
- Duplication debt: repeated logic is already diverging or likely to diverge.

Use simple, reversible designs. Extract abstractions when they protect a real boundary or after repeated duplication reveals a stable pattern.

See: [references/complexity.md](references/complexity.md)

### 7. Use Patterns as Vocabulary, Not Decoration

Patterns are useful when they simplify a known force:

- Strategy for interchangeable policies.
- Adapter for translating external systems into internal contracts.
- Factory or builder for complex creation with invariants.
- Repository only when persistence access needs a stable domain-facing contract.
- Observer/pub-sub for events where producers should not know consumers.
- Command for auditable operations, queues, retries, or undo/compensation.

Use patterns when they clarify a real design force. Use a direct function, module, or data structure only when a pattern would add ceremony without improving responsibility, substitution, or boundary control.

See: [references/design-patterns.md](references/design-patterns.md)

## Simple Design Standard

Use the XP simple design priorities:

1. The code works and the relevant tests pass.
2. The code clearly expresses intent.
3. Duplication is removed when the abstraction is more obvious than the repetition.
4. The design contains no unnecessary moving parts.

## Code Smells and Required Responses

| Smell | Required Response |
|-------|--------------------|
| Long method | Extract named steps around behavior, not arbitrary line counts. |
| Large class | Split by responsibility or reason to change. |
| Long parameter list | Introduce a request, command, or options type when the group has meaning. |
| Divergent change | Separate responsibilities that change for different reasons. |
| Shotgun surgery | Move related rules behind one cohesive contract. |
| Feature envy | Move behavior closer to the data or capability it uses. |
| Data clumps | Model the concept explicitly when the values travel together. |
| Primitive obsession | Keep primitives simple; introduce a domain type only when it adds behavior, validation, conversion, or invariant protection. |
| Type switches | Use polymorphism, strategy, lookup tables, or pattern matching based on language idiom and complexity. Do not let central type switches grow unchecked. |
| Speculative generality | Remove unused extension points until a real variation exists. |

See: [references/code-smells.md](references/code-smells.md)

## Behavioral Principles

- Tell, Don't Ask: put decisions near the data and rules they depend on.
- Design by Contract: define preconditions, postconditions, invariants, and error semantics.
- Inversion of Control: application policy should call abstractions; composition roots wire implementations.
- Law of Demeter: avoid long navigation chains that expose object internals.
- Fail Fast at Boundaries: reject invalid external input before it reaches core logic.

## Pre-Code Checklist

Before implementation, answer:

1. [ ] What behavior or contract is changing?
2. [ ] What existing convention, boundary, or domain term applies?
3. [ ] What is the smallest design that can satisfy this safely?
4. [ ] What test or verification gives useful confidence?
5. [ ] What should remain unchanged?

## During-Code Checklist

While coding, continuously ask:

1. [ ] Is this the simplest thing that could work?
2. [ ] Does this unit have a clear responsibility and reason to change?
3. [ ] Are dependencies pointing toward policy instead of details?
4. [ ] Can I name this more clearly?
5. [ ] Is duplication harmless for now, or has it revealed a stable abstraction?
6. [ ] Are invalid states prevented or handled at the right boundary?

## Post-Code Checklist

After the code works:

1. [ ] Do all tests pass?
2. [ ] Are contracts, schemas, examples, or docs updated if behavior changed?
3. [ ] Is there dead code, speculative abstraction, or unnecessary configuration to remove?
4. [ ] Are names still accurate after the final design?
5. [ ] Can the next maintainer understand and safely modify this?

## Red Flags

- Business logic depends directly on framework, transport, storage, or device-driver types.
- Public contracts changed without compatibility review, migration, or tests.
- A central conditional keeps growing for every new type, action, or capability.
- Subclasses or implementations throw "not supported" for required contract methods.
- A small change requires unrelated edits across layers.
- Tests assert implementation details instead of behavior.
- Abstractions are introduced before a real variation point exists.
- Error handling is inconsistent across implementations of the same abstraction.
- Domain language is replaced by generic technical names.

## Tradeoff Rules

- Default to explicit duplication over the wrong abstraction.
- Default to cohesive modules over artificially tiny objects.
- Default to stable contracts over shared concrete implementations.
- Default to composition over inheritance.
- Default to reversible design decisions until evidence justifies commitment.
- Follow repository and language idioms unless they conflict with core boundary, contract, or responsibility rules.

## Deviation Rule

Deviation from SOLID guidance is allowed only when following the principle would clearly make the use case worse through unnecessary ceremony, misleading abstraction, framework conflict, performance cost, or loss of clarity. This should be rare. When deviating on meaningful design work, state the reason and keep the decision narrow.

## Output Expectations

When using this skill, deliver one or more of:

- Implementation that follows existing architecture and naming.
- Focused refactoring that reduces a concrete change cost.
- Tests or verification appropriate to the risk.
- Notes on any contract, boundary, or dependency-direction issue discovered.
- A brief explanation of important tradeoffs when the design is not obvious.

The goal is not to make code look "SOLID." The goal is to make the system easier to reason about, safer to change, and faithful to its contracts.
