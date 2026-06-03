# Skills Index

This folder contains reusable skills for both Greenhouse documentation domains.

## Shared Skills

- documentation.md
  - Produces consistent implementation-ready documentation and runs one-question-at-a-time plan interrogation when scope is ambiguous.
- grill-with-docs.md
  - Challenges plans against glossary terms and ADR decisions, then updates docs inline.

## Role Skills

- documentation-agent-skill.md
  - Governs documentation-role output quality and handoff readiness.
- implementation-agent-skill.md
  - Governs implementation-role execution from accepted specs.
- test-agent-skill.md
  - Governs test-role coverage and risk reporting.
- code-review-agent-skill.md
  - Governs review-role findings quality and classification.
- qa-agent-skill.md
  - Governs QA-role scenario validation and release recommendation.
- retrospective-agent-skill.md
  - Governs retrospective-role guardrail update quality.

## Cross-Cutting Engineering Skills

- clean-code-contract-first.md
  - Enforces SOLID and contract-first implementation for maintainable code.
- code-review-gate.md
  - Enforces review-gate checks and prioritized improvement feedback.
- qa-evaluation.md
  - Runs scenario-level QA validation and release-readiness checks.

## Main Unit Skills (.NET)
- dotnet-di-without-service-locator.md
  - Enforces explicit constructor injection and rejects service locator usage.
- dotnet-clean-architecture.md
  - Defines clean C# boundaries across UI, core, messaging, and storage.
- blazor-ui-backend-patterns.md
  - Guides touch-first Blazor workflows and component-to-service patterns.
- mqtt-contract-integration-dotnet.md
  - Preserves MQTT topic/payload contracts in .NET integration code.
- dotnet-storage-and-persistence.md
  - Guides persistence behavior and repository boundaries.
- dotnet-testing-strategy.md
  - Guides unit, integration, and contract test coverage for key flows.
## Edge Firmware Skills (ESP32)

- esp32-firmware-architecture.md
  - Enforces layered firmware architecture and startup/runtime patterns.
- esp32-i2c-bus-reliability.md
  - Covers shared-bus I2C design, recovery, and fault reporting.
- esp32-wifi-mqtt-resilience.md
  - Covers non-blocking reconnect, command handling, and offline behavior.
- esp-idf-firmware-practices.md
  - Enforces ESP-IDF component structure, FreeRTOS safety, and header/source separation.
- esp-idf-testing-strategy.md
  - Defines unit, host-mock, and hardware-in-loop testing strategy for ESP-IDF firmware.
- embedded-oo-coding-standards.md
  - Enforces object-oriented design and code quality standards.

## Usage Guidance

1. Start with documentation.md for scope, naming, and contract clarity.
2. Pick one primary domain track:
   - Main Unit track: use .NET skills above.
   - Edge Firmware track: use ESP32/ESP-IDF skills above.
3. Add cross-cutting engineering skills for clean design, review, and QA gates.
4. Select a role skill when running a multi-agent workflow.
5. Keep terms aligned with the selected CONTEXT file and ADRs.

## Domain Docs Convention

- Read CONTEXT.md first for canonical shared terms.
- Record hard-to-reverse architectural trade-offs in adr/.


