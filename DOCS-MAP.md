# Documentation Map

Use this map for incremental documentation loading. Read only the documents that match the task, then follow cross-references from those documents when needed.

## Start Here

Always read:

- [AGENTS.md](AGENTS.md): repository policy, terminology rules, quality gates, and instruction precedence.
- [CONTEXT.md](CONTEXT.md): canonical platform terminology.
- [DOCS-MAP.md](DOCS-MAP.md): this routing map.
- [adr/README.md](adr/README.md): ADR digest and ADR loading rules.

Read before any feature, bug-fix, or update work in any repository:

- [branching-strategy.md](branching-strategy.md): solution-wide version-control guardrail and feature branch naming convention.
- [work-item-tracking.md](work-item-tracking.md): solution-wide work capture and the Greenhouse Delivery project board (one issue per work item; manual-rank priority).

## Platform Orientation

Read these when the task touches broad architecture, platform boundaries, or cross-domain terminology:

- [vision.md](vision.md): product intent, platform outcomes, local-first direction.
- [system-topology.md](system-topology.md): physical/logical platform makeup, Main Unit and Edge Unit topology, host choices, MQTT broker, deployment assumptions, and future expansion areas.
- [device-model.md](device-model.md): Edge Unit, slot, module, telemetry, heartbeat, and device identity model.
- [mqtt-topics.md](mqtt-topics.md): MQTT topic names, payload examples, command topics, telemetry, heartbeat, and canonical message contracts.

Do not load all platform orientation docs by default. Load the smallest set that covers the affected concepts.

## Software Architecture

Read [architecture.md](architecture.md) when the task touches software structure, dependency direction, layers, ports/adapters, runtime collaboration, persistence boundaries, or test architecture.

Load architecture detail documents only when they match the task:

- [architecture/layers.md](architecture/layers.md): layer ownership, dependency direction, and project/module expectations.
- [architecture/boundaries.md](architecture/boundaries.md): ports, adapters, DTO translation, validation, and error semantics.
- [architecture/runtime.md](architecture/runtime.md): message handling, background services, subscriptions, and workflow orchestration.
- [architecture/persistence.md](architecture/persistence.md): storage boundaries, repositories, migrations, telemetry, and configuration state.
- [architecture/testing.md](architecture/testing.md): test layers, contract tests, integration tests, and acceptance verification.

## Domain And Journey Docs

Read these when the task touches the named domain or journey:

- [control-unit-model.md](control-unit-model.md): Main Unit control model, domain entities, automation rules, configuration, runtime behavior.
- [specs/main-unit-setup/spec.md](specs/main-unit-setup/spec.md): Main Unit first-run setup flow.
- [specs/network-recovery/spec.md](specs/network-recovery/spec.md): reconnecting a configured Main Unit.
- [specs/edge-unit-onboarding/spec.md](specs/edge-unit-onboarding/spec.md): first-time provisioning of an unprovisioned Edge Unit.
- [specs/edge-unit-configuration/spec.md](specs/edge-unit-configuration/spec.md): topology or mapping updates for a known Edge Unit.
- [specs/empty-dashboard/spec.md](specs/empty-dashboard/spec.md): empty dashboard behavior and user-facing starting state.

Journey separation rule:

- Use setup only for Main Unit first-run flow.
- Use onboarding only for first-time Edge Unit provisioning.
- Use reconfiguration only for topology or mapping updates for a known Edge Unit.
- Use network recovery only for reconnecting a configured Main Unit.

## Spec Dossiers

Read [specs/README.md](specs/README.md) when creating, moving, promoting, or auditing spec dossiers.

Read a full `specs/<spec-name>/spec.md` when implementing, testing, reviewing, QA-validating, or updating that feature. Read other files in the same dossier when they exist and match the current stage:

- `status.md`: canonical docs-repo milestone status.
- `implementation-plan.md`: implementation scope, branch, and verification plan.
- `test-gap-report.md`: test evidence and remaining coverage risk.
- `review-report.md`: review findings and merge-safety decision.
- `qa-report.md`: scenario validation and release recommendation.
- `doc-feedback.md`: documentation or skill gaps discovered by delivery agents.
- `retrospective.md`: repeated issues and guardrail analysis.
- `promotion-log.md`: retrospective promotion decisions.

## Delivery Workflow

Read [workflows/feature-delivery-harness.md](workflows/feature-delivery-harness.md) when a task participates in the closed delivery loop:

1. Documentation
2. Implementation
3. Test
4. Code review
5. QA
6. Retrospective
7. Durable documentation update

This workflow defines stage gates, loopbacks, artifact ownership, and the current manual stage-advancement expectation until orchestration exists.

## Templates

Read templates only when creating or validating the matching artifact:

- [templates/spec.md](templates/spec.md): feature spec.
- [templates/spec-canonical-status.md](templates/spec-canonical-status.md): docs-repo `specs/<spec-name>/status.md`.
- [templates/spec-status.md](templates/spec-status.md): implementation-repo `.agent-output/specs/<spec-name>/spec-status.md`.
- [templates/implementation-plan.md](templates/implementation-plan.md): implementation plan.
- [templates/test-gap-report.md](templates/test-gap-report.md): test gap report.
- [templates/review-report.md](templates/review-report.md): code review report.
- [templates/qa-report.md](templates/qa-report.md): QA report.
- [templates/retrospective.md](templates/retrospective.md): retrospective report.
- [templates/doc-feedback.md](templates/doc-feedback.md): append-only documentation feedback.
- [templates/promotion-log.md](templates/promotion-log.md): retrospective promotion log.
- [templates/spec-dossier-scaffold.md](templates/spec-dossier-scaffold.md): new spec dossier scaffold.

## Codex Skills

Codex-discoverable skills live under [.agents/skills](.agents/skills).

Read [.agents/skills/README.md](.agents/skills/README.md) when choosing skills for a task. Then load only the matching skill:

- [.agents/skills/documentation/SKILL.md](.agents/skills/documentation/SKILL.md): documentation, specs, terminology, acceptance criteria, and plan interrogation.
- [.agents/skills/grill-with-docs/SKILL.md](.agents/skills/grill-with-docs/SKILL.md): stress-test fuzzy plans against glossary, ADRs, and docs.
- [.agents/skills/implementation/SKILL.md](.agents/skills/implementation/SKILL.md): implementation-stage execution and artifact/status rules.
- [.agents/skills/test/SKILL.md](.agents/skills/test/SKILL.md): test-stage coverage and loopback rules.
- [.agents/skills/code-review-agent/SKILL.md](.agents/skills/code-review-agent/SKILL.md): review-stage artifacts and status rules.
- [.agents/skills/code-review-gate/SKILL.md](.agents/skills/code-review-gate/SKILL.md): strict review checks and blocking finding rules.
- [.agents/skills/qa/SKILL.md](.agents/skills/qa/SKILL.md): QA-stage validation and release recommendation rules.
- [.agents/skills/retrospective/SKILL.md](.agents/skills/retrospective/SKILL.md): artifact promotion, guardrail updates, and documentation feedback consolidation.
- [.agents/skills/solid/SKILL.md](.agents/skills/solid/SKILL.md): software design, maintainability, SOLID, clean code, testing, and boundary discipline.

Skill reference files are loaded only when the corresponding `SKILL.md` instructs the agent to read them.

## Codex Custom Agents

Codex custom subagent profiles live under [.codex/agents](.codex/agents).

Read these only when spawning, auditing, or editing project-scoped Codex custom agents:

- [.codex/agents/documentation-agent.toml](.codex/agents/documentation-agent.toml)
- [.codex/agents/implementation-agent.toml](.codex/agents/implementation-agent.toml)
- [.codex/agents/test-agent.toml](.codex/agents/test-agent.toml)
- [.codex/agents/code-review-agent.toml](.codex/agents/code-review-agent.toml)
- [.codex/agents/qa-agent.toml](.codex/agents/qa-agent.toml)
- [.codex/agents/retrospective-agent.toml](.codex/agents/retrospective-agent.toml)

## Tool-Specific Bridges

Read these only when configuring or auditing that tool's behavior:

- [CLAUDE.md](CLAUDE.md): Claude Code bridge to `AGENTS.md`.
- [.github/copilot-instructions.md](.github/copilot-instructions.md): GitHub Copilot bridge to `AGENTS.md` and `.agents/skills/README.md`.

## Session Scratchpad

- [agent-handoff.md](agent-handoff.md): maintainer scratchpad only. Do not use it as durable domain guidance.
