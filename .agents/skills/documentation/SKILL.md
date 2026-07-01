---
name: documentation
description: Use this skill when creating, refining, aligning, or reviewing Greenhouse documentation, specifications, canonical docs, glossary terms, implementation-ready requirements, acceptance criteria, or plan interrogation for ambiguous requirements.
---

# Documentation Skill

Produce complete, detailed, consistent, and concise documentation that is easy for humans to read and reliable for downstream code-generation agents.

Used by custom agent: [../../../.codex/agents/documentation-agent.toml](../../../.codex/agents/documentation-agent.toml)

## Output Artifact Contract

- This role may write directly to this docs repository.
- Write durable spec artifacts to `specs/<spec-name>/` using templates in `templates/`.
- Create or update canonical milestone status at `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
- Consume promoted artifacts that the Retrospective Agent copied from `.agent-output/specs/<spec-name>/` in implementation repositories.
- If an expected artifact is not required for the task, create it with `Not required` and a concrete reason.

## Documentation Standards

- Write for two audiences at once: humans first, code-generation agents second.
- Prefer short sections with explicit headings and scannable lists.
- Keep terminology stable across all files.
- Remove ambiguity: define inputs, outputs, constraints, and edge cases.
- Make requirements testable: include acceptance criteria where relevant.
- Separate current behavior from future intent.
- Mark deferred items explicitly so they are not misread as in-scope.
- For recurring integration message traffic, such as heartbeat, document cross-cutting runtime handling explicitly and require a shared messaging abstraction contract, such as `register(channel, callback)`, instead of feature-lifecycle-specific application service splits.

## Plan Interrogation Method

Use this method whenever a user provides a plan, direction, architecture, or requirements set.

- Interview the user about every relevant aspect until shared understanding is reached.
- Walk each branch of the design tree and resolve dependencies between decisions one by one.
- For each question asked, provide a recommended answer.
- Ask questions one at a time and wait for user feedback before asking the next question.
- If a question can be answered by exploring the codebase or docs, explore first and only ask what remains unresolved.

### One-Question Rule

- Never ask a bundled list of unrelated questions in one turn.
- Ask the single highest-leverage unresolved question first.
- After the user responds, update assumptions and continue to the next question.

### Recommendation Rule

For every question, include:

- Why the question matters.
- A recommended default answer based on current evidence.
- What would change if the user chooses a different answer.

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

## Workflow

1. Read `DOCS-MAP.md`, then read all in-scope docs identified by the map and task context.
2. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
3. Check `.agent-output/specs/<spec-name>/` for incoming artifacts before commencing.
4. Read canonical status from `specs/<spec-name>/status.md`.
5. Read execution status from `.agent-output/specs/<spec-name>/spec-status.md` when available.
6. If either status is `blocked`, resolve blockers first or keep status `blocked` with updated rationale.
7. If the plan is ambiguous, run the Plan Interrogation Method until major decisions are explicit.
8. Normalize terms and decide canonical wording.
9. Create or update `specs/<spec-name>/spec.md` using `templates/spec.md` when behavior contracts change.
10. Rewrite sections to be explicit, testable, and implementation-ready.
11. Add examples and acceptance criteria where missing.
12. If needed, append to or resolve `specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md` to close documented feedback loops.
13. Run a final consistency pass across related documents.
14. Record open questions and assumptions.
15. Create or update `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
16. Set canonical status in `status.md`: `ready-for-dev` when quality gate passes and no ambiguous implementation blockers remain, `new` when drafting is incomplete, `blocked` when unresolved contradictions or missing required decisions prevent safe implementation, or `in-dev` when execution status indicates implementation lifecycle activity. Set this immediately when the gate passes — do not defer it to a later pass.
17. Append canonical Status History in `status.md`.
18. **Readiness propagation.** After setting a spec to `ready-for-dev`, check whether it belongs to a parent epic on the board.
    - Identify the sibling specs tracked under the same epic (from the spec's GitHub issue body or the epic's sub-issue list).
    - Read the `status.md` for each sibling spec.
    - If every sibling spec is `ready-for-dev` and the epic itself has no unresolved open questions, missing spec artifacts, or outstanding grooming gaps, set the epic's **Status** field on the Greenhouse Delivery project board to `Ready For Dev` using the GraphQL `updateProjectV2ItemFieldValue` mutation. Do not use a label for this — `Ready For Dev` is a board Status option, not a label.
    - If any sibling spec is still `new` or `blocked`, do not update the epic — note the remaining blockers in the handoff summary instead.
19. Prepare implementation handoff summary.

## Quality Gate

- Completeness: no critical missing behavior for the stated scope.
- Consistency: no conflicting requirements across related docs.
- Clarity: no ambiguous terms such as "reasonable" without bounds.
- Correctness: examples and schemas are syntactically valid.
- Concision: no repeated sections that say the same thing.
- Implementability: another agent can build from this without guessing.
- No ambiguous requirements remain for the next implementation step.
- Acceptance criteria are testable.
- Terminology is canonical and consistent with `CONTEXT.md`.
- Canonical status in `specs/<spec-name>/status.md` reflects current readiness and has a traceable history entry.
- `ready-for-dev` is set in the same pass that the quality gate first passes — never left as `new` when the gate is satisfied.
- If all sibling specs under a parent epic are `ready-for-dev`, the epic tracking issue is updated to reflect readiness.

## Output Checklist

- Updated documents with explicit scope and constraints.
- Updated canonical status at `specs/<spec-name>/status.md`.
- Resolved conflict list: what changed and why.
- Accepted documentation feedback items resolved through durable docs, skills, templates, or workflow updates.
- Open questions list containing only true blockers.
- Optional follow-up patch suggestions for adjacent docs.
- Updated artifacts remain in `specs/<spec-name>/` and conform to templates.
- If readiness propagation was evaluated: explicit note on whether the parent epic was updated and why (all siblings ready, or which siblings are still blocking).
