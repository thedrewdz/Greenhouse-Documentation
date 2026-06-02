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

- [spec-edge-unit-onboarding-ble.md](spec-edge-unit-onboarding-ble.md)
- [spec-heartbeat-phase1-skeleton.md](spec-heartbeat-phase1-skeleton.md)

## ADR Docs

- [adr/README.md](adr/README.md)
- [adr/0001-ble-first-onboarding.md](adr/0001-ble-first-onboarding.md)

## Journey Docs

- [journeys/README.md](journeys/README.md)
- [journeys/01-Main Unit Setup.md](journeys/01-Main%20Unit%20Setup.md)
- [journeys/02-Network Recovery.md](journeys/02-Network%20Recovery.md)
- [journeys/03-Empty Dashboard.md](journeys/03-Empty%20Dashboard.md)
- [journeys/04-Edge Unit Onboarding and Reconfiguration.md](journeys/04-Edge%20Unit%20Onboarding%20and%20Reconfiguration.md)

## Shared Specs

- [specs/README.md](specs/README.md)
- [specs/spec-edge-unit-onboarding-ble.md](specs/spec-edge-unit-onboarding-ble.md)

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
- [spec-heartbeat-phase1-skeleton.md](spec-heartbeat-phase1-skeleton.md)

## Agent Skill Packs

- [skills/README.md](skills/README.md)
- [skills/documentation.md](skills/documentation.md)
- [skills/grill-with-docs-main-control-unit.md](skills/grill-with-docs-main-control-unit.md)
- [skills/clean-code-solid-contract-first.md](skills/clean-code-solid-contract-first.md)
- [skills/dotnet-di-without-service-locator.md](skills/dotnet-di-without-service-locator.md)
- [skills/dotnet-clean-architecture.md](skills/dotnet-clean-architecture.md)
- [skills/blazor-ui-backend-patterns.md](skills/blazor-ui-backend-patterns.md)
- [skills/mqtt-contract-integration-dotnet.md](skills/mqtt-contract-integration-dotnet.md)
- [skills/dotnet-storage-and-persistence.md](skills/dotnet-storage-and-persistence.md)
- [skills/dotnet-testing-strategy.md](skills/dotnet-testing-strategy.md)
- [skills/code-review-main-control-unit.md](skills/code-review-main-control-unit.md)
- [skills/qa-evaluation-main-control-unit.md](skills/qa-evaluation-main-control-unit.md)
- [skills/esp32-firmware-architecture.md](skills/esp32-firmware-architecture.md)
- [skills/esp32-i2c-bus-reliability.md](skills/esp32-i2c-bus-reliability.md)
- [skills/esp32-wifi-mqtt-resilience.md](skills/esp32-wifi-mqtt-resilience.md)
- [skills/esp-idf-firmware-practices.md](skills/esp-idf-firmware-practices.md)
- [skills/esp-idf-testing-strategy.md](skills/esp-idf-testing-strategy.md)
- [skills/embedded-oo-coding-standards.md](skills/embedded-oo-coding-standards.md)

## Archived Template Readmes

- [references/experiments-ex2/include/README](references/experiments-ex2/include/README)
- [references/experiments-ex2/lib/README](references/experiments-ex2/lib/README)
- [references/experiments-ex2/test/README](references/experiments-ex2/test/README)
- [references/greenhouse-edge/include/README](references/greenhouse-edge/include/README)
- [references/greenhouse-edge/lib/README](references/greenhouse-edge/lib/README)
- [references/greenhouse-edge/test/README](references/greenhouse-edge/test/README)


