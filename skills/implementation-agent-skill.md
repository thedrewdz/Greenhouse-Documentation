# Skill: Implementation Agent

Used by role: [../roles/implementation-agent.md](../roles/implementation-agent.md)

## Purpose

Implement accepted specs while preserving contracts and architecture boundaries.

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.

## Workflow

1. Read `spec.md`, repo `AGENTS.md`, and relevant technical skills.
2. Create or update `.agent-output/specs/<spec-name>/implementation-plan.md` from `templates/implementation-plan.md`.
3. Map each planned change to an architectural layer before coding.
4. Implement only documented behavior.
5. Add or update tests with implementation changes.
6. Run local verification.
7. Record deviations and documentation feedback in `.agent-output/specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md`.

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
- Required artifacts exist in `.agent-output/specs/<spec-name>/` and follow templates.
