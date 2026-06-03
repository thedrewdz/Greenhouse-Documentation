# Skill: Clean Code and Contract-First

## Purpose

Guide agents to produce maintainable code using SOLID principles and contract-first design.

## Use This Skill When

- Adding new services, use cases, handlers, or modules.
- Refactoring large classes or coupled workflows.
- Reviewing code for design quality and long-term maintainability.

## Core Rules

- Keep one clear responsibility per unit of code.
- Depend on abstractions, not implementations.
- Keep interfaces small and use-case focused.
- Prefer composition over inheritance-heavy designs.
- Keep modules extendable without rewriting stable code paths.

## Contract-First Rules

- Define contracts before implementation details.
- Treat message contracts and data access contracts as source of truth.
- Keep transport-specific and storage-specific details behind adapters.
- Reject schema drift between docs and implementation.

## Boundary Rules

- UI components must not contain business orchestration logic.
- Infrastructure code must not dictate domain behavior.
- Parse and validate external payloads at system boundaries.
- Presentation-layer modules must not reference infrastructure implementation types directly.
- Keep infrastructure implementations in infrastructure modules only.

## Boundary Violation Severity Rules

- Any layer-placement violation is blocking.
- Any direct presentation-to-infrastructure implementation dependency is blocking.
- Repeated boundary violations must trigger a guardrail update in retrospective artifacts.

## Quality Gate

- Every changed unit has a clear responsibility statement.
- New behavior is introduced through a contract first, then implementation.
- No duplicate orchestration logic across UI, services, and integration boundaries.

