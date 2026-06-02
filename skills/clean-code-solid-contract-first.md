# Skill: Clean Code with SOLID and Contract-First

## Purpose

Guide agents to produce maintainable Main Unit C# code using SOLID principles and contract-first design.

## Use This Skill When

- Adding new services, use cases, or message handlers.
- Refactoring large classes or coupled workflows.
- Reviewing code for design quality and long-term maintainability.

## Core Rules

- Keep one clear responsibility per class.
- Depend on abstractions, not implementations.
- Keep interfaces small and use-case focused.
- Prefer composition over inheritance-heavy designs.
- Keep modules extendable without rewriting stable code paths.

## Contract-First Rules

- Define contracts in Core before implementation details.
- Treat message contracts and repository contracts as source of truth.
- Keep transport-specific and storage-specific details behind adapters.
- Reject schema drift between docs and implementation.

## Boundary Rules

- UI components must not contain business orchestration logic.
- Infrastructure code must not dictate domain model behavior.
- Parse and validate external payloads at system boundaries.

## Quality Gate

- Every changed class has a clear responsibility statement.
- New behavior is introduced through a contract first, then implementation.
- No duplicate orchestration logic across UI, services, and transport.

