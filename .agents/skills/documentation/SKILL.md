---
name: documentation
description: Use this skill when creating, refining, aligning, or reviewing Greenhouse documentation, specifications, canonical docs, glossary terms, implementation-ready requirements, acceptance criteria, or plan interrogation for ambiguous requirements.
---

# Documentation Skill

Produce complete, detailed, consistent, and concise documentation that is easy for humans to read and reliable for downstream code-generation agents.

Used by custom agent: [../../../.codex/agents/documentation-agent.toml](../../../.codex/agents/documentation-agent.toml)

## Board Operations

Documentation tasks — including grooming tasks, which are a type of documentation work — use this skill and follow the status flow:

**Todo → In Grooming → Done**

`In Grooming` is the active working state. Changes are committed directly to `main` — no feature branch or pull request is required.

**Find the board item ID for the current task:**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.content.number -eq <issue-number> -and $_.repository -like "*Greenhouse-Documentation*" } \
  | Select-Object -ExpandProperty id
```

**Set board status:**
```bash
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS \
  --id <item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo \
  --single-select-option-id <option-id>
```

| Status | Option ID |
|---|---|
| Todo | `f75ad846` |
| In Grooming | `a01c3971` |
| Done | `98236657` |

**Verify board item status (use after every status transition to confirm it applied):**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.id -eq "<item-id>" } \
  | Select-Object -ExpandProperty status
```

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
3. Set the board item to **In Grooming** and verify the status change using the board verify command (see Board Operations). **Do not begin writing until the status update is confirmed.**
4. Check `.agent-output/specs/<spec-name>/` for incoming artifacts before commencing.
5. Read canonical status from `specs/<spec-name>/status.md`.
6. Read execution status from `.agent-output/specs/<spec-name>/spec-status.md` when available.
7. If either status is `blocked`, resolve blockers first or keep status `blocked` with updated rationale.
8. If the plan is ambiguous, run the Plan Interrogation Method until major decisions are explicit.
9. Normalize terms and decide canonical wording.
10. Create or update `specs/<spec-name>/spec.md` using `templates/spec.md` when behavior contracts change.
11. Rewrite sections to be explicit, testable, and implementation-ready.
12. Add examples and acceptance criteria where missing.
13. If needed, append to or resolve `specs/<spec-name>/doc-feedback.md` using `templates/doc-feedback.md` to close documented feedback loops.
14. Run a final consistency pass across related documents.
15. Record open questions and assumptions.
16. Create or update `specs/<spec-name>/status.md` from `templates/spec-canonical-status.md`.
17. Set canonical status in `status.md`: `ready-for-dev` when quality gate passes and no ambiguous implementation blockers remain, `new` when drafting is incomplete, `blocked` when unresolved contradictions or missing required decisions prevent safe implementation, or `in-dev` when execution status indicates implementation lifecycle activity. Set this immediately when the gate passes — do not defer it to a later pass.
18. Append canonical Status History in `status.md`.
19. **Readiness propagation.** After setting a spec to `ready-for-dev`, check whether it belongs to a parent epic on the board.
    - Identify the sibling specs tracked under the same epic (from the spec's GitHub issue body or the epic's sub-issue list).
    - Read the `status.md` for each sibling spec.
    - If every sibling spec is `ready-for-dev` and the epic itself has no unresolved open questions, missing spec artifacts, or outstanding grooming gaps, set the epic's **Status** field on the Greenhouse Delivery project board to `Ready For Dev` using the GraphQL `updateProjectV2ItemFieldValue` mutation. Do not use a label for this — `Ready For Dev` is a board Status option, not a label.
    - If any sibling spec is still `new` or `blocked`, do not update the epic — note the remaining blockers in the handoff summary instead.
20. Prepare implementation handoff summary.
21. Commit all changes directly to `main`:
    ```bash
    git add -A
    git commit -m "<description> (Closes #<issue-number>)"
    git push origin main
    ```
22. Set the board item to **Done** and verify the status change using the board verify command (see Board Operations).

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
- Board item was set to **In Grooming** before any writing began.
- All changes are committed directly to `main` — no feature branch created.
- Board item is set to **Done** after the commit is pushed.

## Output Checklist

- Updated documents with explicit scope and constraints.
- Updated canonical status at `specs/<spec-name>/status.md`.
- Resolved conflict list: what changed and why.
- Accepted documentation feedback items resolved through durable docs, skills, templates, or workflow updates.
- Open questions list containing only true blockers.
- Optional follow-up patch suggestions for adjacent docs.
- Updated artifacts remain in `specs/<spec-name>/` and conform to templates.
- If readiness propagation was evaluated: explicit note on whether the parent epic was updated and why (all siblings ready, or which siblings are still blocking).
- All changes committed directly to `main` with `Closes #<issue-number>` in the commit message.
- Board item advanced to **Done**.
