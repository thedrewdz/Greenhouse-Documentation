---
name: implementation
description: Use this skill when implementing accepted specs in a consumer repository, preserving documented behavior, contracts, architecture boundaries, test coverage, messaging abstractions, spec-stage artifacts, status transitions, push requirements, and pull request creation.
---

# Implementation Skill

Implement accepted specs while preserving contracts and architecture boundaries.

Used by custom agent: [../../../.codex/agents/implementation-agent.toml](../../../.codex/agents/implementation-agent.toml)

## Output Artifact Contract

- In implementation repositories, write spec-stage artifacts to `.agent-output/specs/<spec-name>/`.
- Use templates from this docs repository as the source format for generated artifacts.
- Do not write directly to this docs repository.
- Create or update `.agent-output/specs/<spec-name>/spec-status.md` from `templates/spec-status.md`.
- If a listed artifact is not required for the task, still create the file and record `Not required` plus a concrete reason.

## Preflight

Before coding, complete all checks below and record outcomes in `.agent-output/specs/<spec-name>/implementation-plan.md`:

1. Pull latest `main` into your current working branch.
2. Resolve merge conflicts before commencing spec work.
3. Stop only if merge conflicts cannot be resolved safely.
4. Check `.agent-output/specs/<spec-name>/` for prior artifacts and open follow-up notes.
5. Record the current working branch in `.agent-output/specs/<spec-name>/implementation-plan.md`.

## Workflow

1. Read `spec.md`, repo `AGENTS.md`, and relevant technical skills.
2. Read `.agent-output/specs/<spec-name>/spec-status.md`.
3. Continue only when status is `ready-for-implementation` or `implementation-in-progress`.
4. If status is `new`, `blocked`, or any later-stage status, stop and emit a handoff failure with required upstream role and reason.
5. On accepted entry, set status to `implementation-in-progress` and append Status History in `spec-status.md`.
6. Create or update `.agent-output/specs/<spec-name>/implementation-plan.md` from `templates/implementation-plan.md`, including selected branch and preflight evidence.
7. Read prior `test-gap-report.md`, `review-report.md`, `qa-report.md`, and `doc-feedback.md` when present, then resolve actionable implementation feedback before adding unrelated work.
8. Map each planned change to an architectural layer before coding.
9. For recurring integration message streams, such as heartbeat, acknowledgements, and state updates, define handling through a cross-cutting messaging abstraction instead of feature-lifecycle-specific application services.
10. Implement only documented behavior.
11. Add or update tests with implementation changes.
12. Run local verification.
13. Append deviations and documentation feedback in `.agent-output/specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md`.
14. When implementation quality gate passes, set status to `ready-for-test` and append Status History in `spec-status.md`.
15. Push changes upstream.
16. If this pass is not test-feedback or review-feedback remediation, create a new pull request.

## Cross-Cutting Messaging Rules

- Treat recurring integration message traffic as a runtime-wide concern, not a setup-only or feature-only concern.
- Do not create lifecycle-scoped orchestration services such as `SetupApplicationService` or `EdgeUnitConfigurationApplicationService` to own continuous message ingestion.
- Define a messaging abstraction in an inner stable layer, such as `IMessagingService`, and depend on that abstraction from application/use-case code.
- Implement transport-specific behavior in infrastructure, such as `BrokerMessagingService`, `MqttMessagingService`, or `AmqpMessagingService`, and wire it at composition boundaries.
- Feature workflows register handlers through the abstraction, such as `register(channel, callback)`, rather than directly subscribing through a transport client.
- Heartbeat handling must remain active for the lifetime of the Main Unit process and must not be modeled as a one-off setup transaction.
- If one channel or topic can trigger multiple workflows, keep subscription ownership centralized and route through callbacks or handlers.

## Final Self-Check

- [ ] Code is complete.
- [ ] Relevant tests are run and/or limitations are documented.
- [ ] `.agent-output/specs/<spec-name>/implementation-plan.md` exists.
- [ ] `.agent-output/specs/<spec-name>/doc-feedback.md` exists.
- [ ] `.agent-output/specs/<spec-name>/spec-status.md` is updated.

## Architecture Execution Checklist

Before finalizing implementation, verify:

- Each new or changed file is in the correct layer or module.
- Cross-layer collaboration happens through abstractions owned by stable inner layers.
- Infrastructure implementations are placed in infrastructure modules and wired through composition points.
- Presentation-layer code does not depend directly on infrastructure implementation types.
- Business orchestration is not moved into presentation or infrastructure layers.
- Recurring integration message ingestion is routed through a shared messaging abstraction and not through setup-only or feature-lifecycle-specific application service classes.

If any check fails, fix placement or abstraction boundaries before continuing.

## Quality Gate

- Behavior matches `spec.md`.
- Prior test, review, and QA feedback has been resolved or explicitly carried forward with rationale.
- No silent contract changes exist.
- Verification evidence is captured.
- Architecture execution checklist is fully satisfied.
- Cross-cutting messaging rules are fully satisfied.
- Required artifacts exist in `.agent-output/specs/<spec-name>/` and follow templates.
- Status transition to `ready-for-test` is recorded in `spec-status.md`.
- Changes are pushed upstream.
- A new pull request exists when work is not test-feedback or review-feedback remediation.
