# Greenhouse Documentation

Central documentation repository for the Greenhouse platform.

This repo consolidates docs from:

- D:/Code/Greenhouse/dev
- D:/Code/Greenhouse/esp32-main

The repository is docs-only and intentionally does not use a top-level docs folder.

## Vision

AI-enabled greenhouse automation with a local-first architecture centered on a Main Unit and Edge Units.

## Single Entry Point

Use this file as the only required entry point for consuming agents.

Recommended read order:

1. [AGENTS.md](AGENTS.md)
2. [CONTEXT.md](CONTEXT.md)
3. [DOCS-MAP.md](DOCS-MAP.md)
4. [adr/README.md](adr/README.md)

Use DOCS-MAP.md to choose the smallest relevant set of documentation files for the task.

## Canonical Policy And Context

- [AGENTS.md](AGENTS.md)
- [CLAUDE.md](CLAUDE.md)
- [CONTEXT.md](CONTEXT.md)
- [DOCS-MAP.md](DOCS-MAP.md)
- [.github/copilot-instructions.md](.github/copilot-instructions.md)

## Core Platform Docs

- [architecture.md](architecture.md)
- [system-topology.md](system-topology.md)
- [device-model.md](device-model.md)
- [mqtt-topics.md](mqtt-topics.md)
- [vision.md](vision.md)

## Main Unit Docs

- [control-unit-model.md](control-unit-model.md)

## Edge Firmware Docs

- [specs/edge-unit-onboarding/spec.md](specs/edge-unit-onboarding/spec.md)

## ADR Docs

- [adr/README.md](adr/README.md)

## Spec Dossiers

- [specs/README.md](specs/README.md)
- [specs/main-unit-setup/spec.md](specs/main-unit-setup/spec.md)
- [specs/network-recovery/spec.md](specs/network-recovery/spec.md)
- [specs/empty-dashboard/spec.md](specs/empty-dashboard/spec.md)
- [specs/edge-unit-configuration/spec.md](specs/edge-unit-configuration/spec.md)

## Contract Specs

- [specs/edge-unit-onboarding/spec.md](specs/edge-unit-onboarding/spec.md)

## Dossier Templates

- [templates/spec-dossier-scaffold.md](templates/spec-dossier-scaffold.md)
- [templates/spec.md](templates/spec.md)
- [templates/implementation-plan.md](templates/implementation-plan.md)
- [templates/test-gap-report.md](templates/test-gap-report.md)
- [templates/review-report.md](templates/review-report.md)
- [templates/qa-report.md](templates/qa-report.md)
- [templates/retrospective.md](templates/retrospective.md)
- [templates/doc-feedback.md](templates/doc-feedback.md)
- [templates/promotion-log.md](templates/promotion-log.md)

## Local MQTT Operations

Main Unit deployments commonly use Mosquitto as the local MQTT broker on Raspberry Pi.

Typical service commands:

```sh
sudo systemctl status mosquitto
sudo systemctl start mosquitto
sudo systemctl enable mosquitto
sudo journalctl -u mosquitto -n 100 --no-pager
```

Traffic inspection examples:

```sh
mosquitto_sub -h localhost -t "gh/heartbeat" -v
mosquitto_sub -h localhost -t "gh/#" -v
```

See also:

- [mqtt-topics.md](mqtt-topics.md)
- Edge firmware heartbeat contract documentation moved to `esp32-main`.

## Codex Skills

- [.agents/skills/README.md](.agents/skills/README.md)
- [.agents/skills/documentation/SKILL.md](.agents/skills/documentation/SKILL.md)
- [.agents/skills/implementation/SKILL.md](.agents/skills/implementation/SKILL.md)
- [.agents/skills/test/SKILL.md](.agents/skills/test/SKILL.md)
- [.agents/skills/code-review-agent/SKILL.md](.agents/skills/code-review-agent/SKILL.md)
- [.agents/skills/code-review-gate/SKILL.md](.agents/skills/code-review-gate/SKILL.md)
- [.agents/skills/qa/SKILL.md](.agents/skills/qa/SKILL.md)
- [.agents/skills/retrospective/SKILL.md](.agents/skills/retrospective/SKILL.md)
- [.agents/skills/grill-with-docs/SKILL.md](.agents/skills/grill-with-docs/SKILL.md)
- [.agents/skills/solid/SKILL.md](.agents/skills/solid/SKILL.md)

## Codex Custom Agents

- [.codex/agents/documentation-agent.toml](.codex/agents/documentation-agent.toml)
- [.codex/agents/implementation-agent.toml](.codex/agents/implementation-agent.toml)
- [.codex/agents/test-agent.toml](.codex/agents/test-agent.toml)
- [.codex/agents/code-review-agent.toml](.codex/agents/code-review-agent.toml)
- [.codex/agents/qa-agent.toml](.codex/agents/qa-agent.toml)
- [.codex/agents/retrospective-agent.toml](.codex/agents/retrospective-agent.toml)

