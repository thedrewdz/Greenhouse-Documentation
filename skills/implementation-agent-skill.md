# Skill: Implementation Agent

Used by role: [../roles/implementation-agent.md](../roles/implementation-agent.md)

## Purpose

Implement accepted specs while preserving contracts and architecture boundaries.

## Workflow

1. Read `spec.md`, repo `AGENTS.md`, and relevant technical skills.
2. Map each planned change to an architectural layer before coding.
3. Implement only documented behavior.
4. Add or update tests with implementation changes.
5. Run local verification.
6. Record deviations and documentation feedback items.

## Architecture Execution Checklist

Before finalizing implementation, verify:

- Each new or changed file is in the correct layer/module.
- Cross-layer collaboration happens through abstractions owned by stable inner layers.
- Infrastructure implementations are placed in infrastructure modules and wired through composition points.
- Presentation-layer code does not depend directly on infrastructure implementation types.
- Business orchestration is not moved into presentation or infrastructure layers.

If any check fails, fix placement or abstraction boundaries before continuing.

## Quality Gate

- Behavior matches `spec.md`.
- No silent contract changes.
- Verification evidence is captured.
- Architecture execution checklist is fully satisfied.
