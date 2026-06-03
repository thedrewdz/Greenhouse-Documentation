# Skill: Documentation Agent

Used by role: [../roles/documentation-agent.md](../roles/documentation-agent.md)

## Purpose

Produce complete, detailed, consistent, and concise documentation that is easy for humans to read and reliable for downstream code-generation agents.

## Output Artifact Contract

- This role may write directly to this docs repository.
- Write durable spec artifacts to `specs/<spec-name>/` using templates in `templates/`.
- Consume promoted artifacts that the Retrospective Agent copied from `.agent-output/specs/<spec-name>/` in implementation repositories.

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
2. Read `spec.md` status in the Spec Control section.
3. If status is `blocked`, resolve blockers first or keep status `blocked` with updated rationale.
4. If the plan is ambiguous, run the Plan Interrogation Method until major decisions are explicit.
5. Normalize terms and decide canonical wording.
6. Create or update `specs/<spec-name>/spec.md` using `templates/spec.md` when behavior contracts change.
7. Rewrite sections to be explicit, testable, and implementation-ready.
8. Add examples and acceptance criteria where missing.
9. If needed, update `specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md` to close documented feedback loops.
10. Run a final consistency pass across related documents.
11. Record open questions and assumptions.
12. Update Spec Control fields (`Status`, `Status Updated At`, `Status Updated By`, `Status Reason`) and append Status History:
13. Set status to `ready-for-implementation` only when the quality gate passes and no ambiguous implementation blockers remain.
14. Keep or set status `new` when drafting is incomplete.
15. Set status to `blocked` when unresolved contradictions or missing required decisions prevent safe implementation.
16. Prepare implementation handoff summary.

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
- Spec status reflects current readiness and has a traceable history entry.

## Output Checklist

- Updated document(s) with explicit scope and constraints.
- Resolved conflict list (what changed and why).
- Open questions list (only true blockers).
- Optional follow-up patch suggestions for adjacent docs.
- Updated artifacts remain in `specs/<spec-name>/` and conform to templates.
