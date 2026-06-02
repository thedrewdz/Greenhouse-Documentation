# Skill: .NET Clean Architecture

## Purpose

Guide agents to implement Main Unit features with clear boundaries between UI, application, domain, and infrastructure.

## Use This Skill When

- Adding new use cases or services in C#.
- Refactoring code that mixes transport, persistence, and business logic.
- Defining dependency injection and project boundaries.

## Do Not Use This Skill When

- The task is edge firmware implementation.
- The task is pure documentation formatting.

## Architecture Rules

- Keep `Greenhouse.Core` technology-neutral.
- Keep UI concerns in `Greenhouse.UI` only.
- Keep MQTT transport details in `Greenhouse.Mqtt`.
- Keep storage details in `Greenhouse.Storage`.
- Depend inward: UI and infrastructure depend on Core contracts, not the reverse.

## Service Design Rules

- Blazor components call application services, not repositories or transport clients directly.
- Use interfaces for orchestration boundaries (`IDeviceService`, `ITelemetryService`, etc.).
- Keep message parsing and validation out of UI components.

## Quality Gate

- No infrastructure types leak into Core abstractions.
- No UI component directly publishes MQTT commands.
- Use cases are testable without web host startup.

