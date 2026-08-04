---
name: code-review-gate
description: Use this skill when performing a strict review gate for non-trivial code changes, validating correctness, contract compliance, architecture boundaries, dependency direction, test adequacy, recurring message handling, and actionable blocking or non-blocking feedback.
---

# Code Review Gate Skill

Provide a strict review gate for non-trivial code changes before they are accepted.

## Review and Fix Separation

**This skill raises findings. It does not fix them.** Every finding — blocking or not, however small, mechanical, or obvious the fix looks — is filed and routed to a separate implementation pass. A one-line workflow or config correction is still a fix. See [Review and Fix Separation](../../../workflows/feature-delivery-harness.md#review-and-fix-separation) for why.

The reason is not merge-gate independence — the merge gate is required checks green and nothing else (see [Merge Approval](../../../workflows/feature-delivery-harness.md#merge-approval)). It is that a pass cannot reliably review its own reasoning: five findings fixed in the session that raised them produced three further defects in the fixes, one of them asserted as correct in three places and disproved by a ten-line probe.

**This pass also does not merge the pull request and does not set any board item to Done.** Stage 6 owns both — see [Pull Request Ownership](../../../workflows/feature-delivery-harness.md#pull-request-ownership). It has two terminal transitions: **Ready For Dev** on blocking findings, **In Review** when none remain. Pulling the latest task branch is a different operation and is still required.

This rule is stated here as well as in [code-review-agent](../code-review-agent/SKILL.md) because a review pass may load only this skill.

## Review Focus Order

1. Correctness and regressions.
2. Contract compliance with docs and specs.
3. Architecture and dependency boundaries.
4. Dependency management and hidden-coupling anti-patterns.
5. Test coverage and missing negative-path tests.

## Architectural Principles

Apply these principles on every non-trivial review:

- Dependencies point inward toward stable abstractions.
- Layer ownership is explicit and respected.
- Outer layers implement inner-layer contracts, not the reverse.
- Business orchestration stays in domain/application layers.
- Presentation and infrastructure layers coordinate through contracts, not implementation coupling.

If layer ownership is unclear, treat it as a blocking documentation gap and file a documentation feedback item.

## Architecture Boundary Checks

Confirm and record evidence for the following:

- Each changed file is in the correct architectural layer.
- Presentation-layer code depends on application abstractions, not infrastructure implementations.
- Infrastructure implementations remain in infrastructure modules only.
- No direct transport, persistence, or framework client calls are added to presentation-layer orchestration.
- Dependency direction still points inward.
- Recurring integration message streams are handled through a shared messaging abstraction instead of lifecycle-scoped application services.

## Never Events

Treat these examples as automatically blocking:

- Infrastructure implementation class placed in a presentation-layer project or folder.
- Presentation-layer class directly constructing or importing infrastructure implementation types.
- Domain or application logic depending on infrastructure implementation namespaces.
- Contract changes introduced in code without corresponding canonical documentation updates.
- Lifecycle-scoped services, such as setup-only services, owning recurring heartbeat ingestion.
- Feature-specific application services directly subscribing to transport channels or topics instead of using a shared messaging abstraction.

## Mandatory Checks

- Behavior matches relevant specs and workflow rules.
- Contracts match canonical schema and integration docs.
- No infrastructure leakage into domain abstractions.
- Dependencies are explicit and testable.
- Error, retry, and degraded-state paths are handled deterministically.
- Long-lived channel or topic subscriptions, such as heartbeat, are wired via shared abstraction and remain active for process lifetime.
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
