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
3. [architecture.md](architecture.md)
4. [device-model.md](device-model.md)
5. [mqtt-topics.md](mqtt-topics.md)
6. [vision.md](vision.md)

All other documentation files in this repo are listed below and reachable from this index.

## Canonical Policy And Context

- [AGENTS.md](AGENTS.md)
- [CONTEXT.md](CONTEXT.md)
- [.github/copilot-instructions.md](.github/copilot-instructions.md)

## Core Platform Docs

- [architecture.md](architecture.md)
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

## Agent Skill Packs

- [skills/README.md](skills/README.md)
- [skills/documentation-agent-skill.md](skills/documentation-agent-skill.md)
- [skills/implementation-agent-skill.md](skills/implementation-agent-skill.md)
- [skills/test-agent-skill.md](skills/test-agent-skill.md)
- [skills/code-review-agent-skill.md](skills/code-review-agent-skill.md)
- [skills/qa-agent-skill.md](skills/qa-agent-skill.md)
- [skills/retrospective-agent-skill.md](skills/retrospective-agent-skill.md)
- [skills/grill-with-docs.md](skills/grill-with-docs.md)
- [skills/clean-code-contract-first.md](skills/clean-code-contract-first.md)
- [skills/code-review-gate.md](skills/code-review-gate.md)
- [skills/qa-evaluation.md](skills/qa-evaluation.md)

## Role Contracts

- [roles/documentation-agent.md](roles/documentation-agent.md)
- [roles/implementation-agent.md](roles/implementation-agent.md)
- [roles/test-agent.md](roles/test-agent.md)
- [roles/code-review-agent.md](roles/code-review-agent.md)
- [roles/qa-agent.md](roles/qa-agent.md)
- [roles/retrospective-agent.md](roles/retrospective-agent.md)

## Archived Template Readmes

- [references/experiments-ex2/include/README](references/experiments-ex2/include/README)
- [references/experiments-ex2/lib/README](references/experiments-ex2/lib/README)
- [references/experiments-ex2/test/README](references/experiments-ex2/test/README)


