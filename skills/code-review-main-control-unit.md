# Skill: Main Unit Code Review Gate

## Purpose

Provide a strict review gate for generated C#/.NET code changes before they are accepted.

## Use This Skill When

- Reviewing any non-trivial code change produced by another agent.
- Validating SOLID boundaries, contract-first compliance, and DI practices.
- Producing actionable feedback for a documentation update loop.

## Review Focus Order

1. Correctness and regressions.
2. Contract compliance with docs and specs.
3. Architecture and dependency boundaries.
4. DI usage and service locator anti-patterns.
5. Test coverage and missing negative-path tests.

## Mandatory Checks

- Behavior matches relevant specs and journey rules.
- Contracts match mqtt-topics.md and related schema docs.
- No infrastructure leakage into Core abstractions.
- No service locator usage in application/domain logic.
- Constructors declare required dependencies explicitly.
- Error and offline paths are handled deterministically.

## Review Output Format

- Findings ordered by severity.
- For each finding: impacted file, risk, recommended fix.
- Explicit statement when no findings are identified.
- Residual risks and testing gaps.

## Feedback Loop Requirement

When a review reveals contract ambiguity or missing requirements:

- File a documentation feedback item.
- Propose exact doc updates needed.
- Route updates to documentation agent before final implementation pass.

