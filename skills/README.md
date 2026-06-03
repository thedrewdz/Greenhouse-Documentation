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

## Usage Guidance

1. Start with documentation.md for scope, naming, and contract clarity.
2. Use role and cross-cutting engineering skills as needed for the task.
3. For implementation in consumer repositories, pair these docs skills with repository-local implementation skills.
4. Keep terms aligned with the selected CONTEXT file and ADRs.

## Domain Docs Convention

- Read CONTEXT.md first for canonical shared terms.
- Record hard-to-reverse architectural trade-offs in adr/.


