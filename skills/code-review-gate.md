# Skill: Code Review Gate

## Purpose

Provide a strict review gate for non-trivial code changes before they are accepted.

## Use This Skill When

- Reviewing any non-trivial code change produced by another agent.
- Validating design boundaries, contract-first compliance, and dependency management practices.
- Producing actionable feedback for a documentation update loop.

## Review Focus Order

1. Correctness and regressions.
2. Contract compliance with docs and specs.
3. Architecture and dependency boundaries.
4. Dependency management and hidden-coupling anti-patterns.
5. Test coverage and missing negative-path tests.

## Architectural Principles (Mandatory)

Apply these principles on every non-trivial review:

- Dependencies point inward toward stable abstractions.
- Layer ownership is explicit and respected.
- Outer layers implement inner-layer contracts, not the reverse.
- Business orchestration stays in domain/application layers.
- Presentation and infrastructure layers coordinate through contracts, not implementation coupling.

If layer ownership is unclear, treat it as a blocking documentation gap and file a documentation feedback item.

## Architecture Boundary Checks (Required Evidence)

Confirm and record evidence for the following:

- Each changed file is in the correct architectural layer.
- Presentation-layer code depends on application abstractions, not infrastructure implementations.
- Infrastructure implementations remain in infrastructure modules only.
- No direct transport, persistence, or framework client calls are added to presentation-layer orchestration.
- Dependency direction still points inward.

## Never Events (Auto-Blocking Examples)

Use these as concrete blocking examples of principle violations:

- Infrastructure implementation class placed in a presentation-layer project or folder.
- Presentation-layer class directly constructing or importing infrastructure implementation types.
- Domain or application logic depending on infrastructure implementation namespaces.
- Contract changes introduced in code without corresponding canonical documentation updates.

## Mandatory Checks

- Behavior matches relevant specs and workflow rules.
- Contracts match canonical schema and integration docs.
- No infrastructure leakage into domain abstractions.
- Dependencies are explicit and testable.
- Error, retry, and degraded-state paths are handled deterministically.
- No never events are present.

## Review Output Format

- Findings ordered by severity.
- For each finding: impacted file, risk, recommended fix.
- Explicit statement when no findings are identified.
- Residual risks and testing gaps.
- For each blocking finding, include a prevention note describing which guardrail should be added or updated.

## Feedback Loop Requirement

When a review reveals contract ambiguity or missing requirements:

- File a documentation feedback item.
- Propose exact doc updates needed.
- Route updates to documentation agent before final implementation pass.

When a review finds a never event or repeated boundary violation:

- File a documentation feedback item marked `systemic`.
- Propose a concrete update to one or more of: skills, templates, workflow rules.
- Require retrospective stage to confirm the prevention update was completed.

