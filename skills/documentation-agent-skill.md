# Skill: Documentation Agent

Used by role: [../roles/documentation-agent.md](../roles/documentation-agent.md)

## Purpose

Produce complete, detailed, consistent, and concise documentation that is easy for humans to read and reliable for downstream code-generation agents.

## Output Artifact Contract

- This role may write directly to this docs repository.
- Write durable spec artifacts to `specs/<spec-name>/` using templates in `templates/`.
- Create or update canonical milestone status at `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
- Consume promoted artifacts that the Retrospective Agent copied from `.agent-output/specs/<spec-name>/` in implementation repositories.
- If an expected artifact is not required for the task, create it with `Not required` and a concrete reason.

## Use This Skill When

- Creating new technical documentation from product or architecture requirements.
- Refining draft docs that are unclear, inconsistent, or incomplete.
- Aligning multiple documents into a single coherent source of truth.
- Preparing specifications that another agent will implement in code.

## Do Not Use This Skill When

- The task is pure code implementation without documentation changes.
- The request is exploratory brainstorming with no defined scope.
- A one-line note or temporary scratch text is sufficient.

## Documentation Standards

- Write for two audiences at once: humans first, code-generation agents second.
- Prefer short sections with explicit headings and scannable lists.
- Keep terminology stable across all files.
- Remove ambiguity: define inputs, outputs, constraints, and edge cases.
- Make requirements testable: include acceptance criteria where relevant.
- Separate current behavior from future intent.
- Mark deferred items explicitly so they are not misread as in-scope.

## Plan Interrogation Method (Core)

Use this method whenever a user provides a plan, direction, architecture, or requirements set.

- Interview the user relentlessly about every relevant aspect until shared understanding is reached.
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

- why the question matters
- a recommended default answer based on current evidence
- what would change if the user chooses a different answer

## Required Structure for Spec-Style Docs

1. Purpose and scope.
2. Preconditions and assumptions.
3. Definitions and canonical terms.
4. Behavior and workflows.
5. Data contracts and schemas.
6. Validation rules and error handling.
7. Non-functional constraints (performance, safety, security).
8. Acceptance criteria.
9. Out-of-scope / deferred work.
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

1. Read all in-scope docs and identify conflicts, gaps, and duplicates.
2. Pull latest remote changes (`git pull --ff-only`) and stop on conflicts.
3. Check `.agent-output/specs/<spec-name>/` for incoming artifacts before commencing.
4. Read canonical status from `specs/<spec-name>/status.md`.
5. Read execution status from `.agent-output/specs/<spec-name>/spec-status.md` when available.
6. If either status is `blocked`, resolve blockers first or keep status `blocked` with updated rationale.
7. If the plan is ambiguous, run the Plan Interrogation Method until major decisions are explicit.
8. Normalize terms and decide canonical wording.
9. Create or update `specs/<spec-name>/spec.md` using `templates/spec.md` when behavior contracts change.
10. Rewrite sections to be explicit, testable, and implementation-ready.
11. Add examples and acceptance criteria where missing.
12. If needed, update `specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md` to close documented feedback loops.
13. Run a final consistency pass across related documents.
14. Record open questions and assumptions.
15. Create or update `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
16. Set canonical status in `status.md`:
17. Set `ready-for-dev` when quality gate passes and no ambiguous implementation blockers remain.
18. Keep or set `new` when drafting is incomplete.
19. Set `blocked` when unresolved contradictions or missing required decisions prevent safe implementation.
20. Set `in-dev` when execution status indicates implementation lifecycle activity.
21. Append canonical Status History in `status.md`.
22. Prepare implementation handoff summary.

## Quality Gate (Must Pass)

- Completeness: no critical missing behavior for the stated scope.
- Consistency: no conflicting requirements across related docs.
- Clarity: no ambiguous terms such as "reasonable" without bounds.
- Correctness: examples and schemas are syntactically valid.
- Concision: no repeated sections that say the same thing.
- Implementability: another agent can build from this without guessing.
- No ambiguous requirements remain for the next implementation step.
- Acceptance criteria are testable.
- Terminology is canonical and consistent with CONTEXT.md.
- Canonical status in `specs/<spec-name>/status.md` reflects current readiness and has a traceable history entry.

## Output Checklist

- Updated document(s) with explicit scope and constraints.
- Updated canonical status at `specs/<spec-name>/status.md`.
- Resolved conflict list (what changed and why).
- Open questions list (only true blockers).
- Optional follow-up patch suggestions for adjacent docs.
- Updated artifacts remain in `specs/<spec-name>/` and conform to templates.
