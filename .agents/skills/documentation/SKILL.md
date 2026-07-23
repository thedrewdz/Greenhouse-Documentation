---
name: documentation-standards
description: Documentation standards reference for the Greenhouse project. Defines spec structure, style rules, and consistency rules used by other skills. For the full discovery and grooming workflow, use the ba-po skill instead.
---

# Documentation Standards Reference

> **Standards reference only.** This file defines the writing standards, spec structure, and consistency rules that all documentation work must follow. It is cited by other skills — primarily `ba-po` — not invoked as a standalone workflow skill.
>
> For discovery, epic creation, and grooming workflows, use [ba-po/SKILL.md](../ba-po/SKILL.md).

Used by custom agent: [../../../.codex/agents/documentation-agent.toml](../../../.codex/agents/documentation-agent.toml)

## Documentation Standards

- Write for two audiences at once: humans first, code-generation agents second.
- Prefer short sections with explicit headings and scannable lists.
- Keep terminology stable across all files.
- Remove ambiguity: define inputs, outputs, constraints, and edge cases.
- Make requirements testable: include acceptance criteria where relevant.
- Separate current behavior from future intent.
- Mark deferred items explicitly so they are not misread as in-scope.
- For recurring integration message traffic, such as heartbeat, document cross-cutting runtime handling explicitly and require a shared messaging abstraction contract, such as `register(channel, callback)`, instead of feature-lifecycle-specific application service splits.

## Required Structure for Spec-Style Docs

1. Purpose and scope.
2. Preconditions and assumptions.
3. Definitions and canonical terms.
4. Behavior and workflows, including cross-cutting runtime workflow ownership where applicable, such as long-lived channel or topic subscriptions.
5. Data contracts and schemas.
6. Validation rules and error handling.
7. Non-functional constraints: performance, safety, security.
8. Acceptance criteria.
9. Out-of-scope or deferred work.
10. Open questions.

## Style Rules

- Use plain language and concrete verbs.
- Avoid marketing language.
- Avoid hidden requirements in narrative paragraphs.
- Avoid contradictory guidance across files.
- Use examples that are syntactically valid and copy-safe.
- Keep paragraphs short and remove redundant statements.

## Consistency Rules

- One canonical term per concept.
- One canonical naming convention per data boundary.
- One source of truth for each major decision.
- If two documents conflict, resolve and update both in the same pass.
