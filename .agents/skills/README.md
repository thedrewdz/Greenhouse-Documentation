# Skills Index

This folder contains Codex-discoverable reusable skills for both Greenhouse documentation domains.

## Workflow Skills

- ba-po/
  - **Primary entry point for all new feature work.** Phase 1 (Discovery): distills a concept into a well-formed epic with long-form documentation. Phase 2 (Grooming): breaks the epic into single-stack, dependency-ordered tasks ready for development. Grills relentlessly through both phases.

## Role Skills

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

## Standards References

- documentation/
  - Documentation standards reference: required spec structure, style rules, and consistency rules. Cited by other skills — not a standalone workflow skill. For the full discovery and grooming workflow, use `ba-po/`.

## Retired Skills

- grill-with-docs/ — Retired. Superseded by `ba-po/`, which incorporates plan interrogation and docs grilling as part of the full discovery workflow.

## Usage Guidance

1. Start with `ba-po` for all new feature work — discovery through grooming.
2. Use role and cross-cutting engineering skills as needed for the implementation lifecycle.
3. For implementation in consumer repositories, pair these docs skills with repository-local implementation skills.
4. Keep terms aligned with the selected CONTEXT file and ADRs.
5. Enforce `spec-status.md` entry and exit gates in `.agent-output/specs/<spec-name>/` for every stage.

## Domain Docs Convention

- Read CONTEXT.md first for canonical shared terms.
- Record hard-to-reverse architectural trade-offs in adr/.


