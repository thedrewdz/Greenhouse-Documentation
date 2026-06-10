# Skills Index

This folder contains Codex-discoverable reusable skills for both Greenhouse documentation domains.

## Shared Skills

- documentation/
  - Produces complete implementation-ready documentation and runs one-question-at-a-time plan interrogation when scope is ambiguous.
- grill-with-docs/
  - Challenges plans against glossary terms and ADR decisions, then updates docs inline.

## Role Skills

- documentation/
  - Governs documentation-role output quality and handoff readiness while serving as the canonical documentation skill.
- implementation/
  - Governs implementation-role execution from accepted specs.
- test/
  - Governs test-role coverage and risk reporting.
- code-review-agent/
  - Governs review-role findings quality and classification.
- qa/
  - Governs QA-role scenario validation and release recommendation.
- retrospective/
  - Governs retrospective-role guardrail update quality.

## Cross-Cutting Engineering Skills

- solid/
  - Applies pragmatic SOLID design, boundary discipline, testing strategy, and clean-code heuristics for implementation and review work.
- code-review-gate/
  - Enforces review-gate checks and prioritized improvement feedback.
- qa/references/qa-evaluation.md
  - Runs scenario-level QA validation and release-readiness checks.

## Usage Guidance

1. Start with the documentation skill for scope, naming, contract clarity, and Plan Interrogation Method behavior.
2. Use role and cross-cutting engineering skills as needed for the task.
3. For implementation in consumer repositories, pair these docs skills with repository-local implementation skills.
4. Keep terms aligned with the selected CONTEXT file and ADRs.
5. Enforce `spec-status.md` entry and exit gates in `.agent-output/specs/<spec-name>/` for every stage.

## Domain Docs Convention

- Read CONTEXT.md first for canonical shared terms.
- Record hard-to-reverse architectural trade-offs in adr/.


