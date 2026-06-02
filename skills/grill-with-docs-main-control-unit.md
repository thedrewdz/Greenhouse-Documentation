# Skill: Grill with Docs for Main Unit

## Purpose

Stress-test plans against existing Main Unit language and decisions, then update glossary and ADR records inline as decisions crystallize.

Use the same Plan Interrogation Method terminology and behavior as skills/documentation.md.

## Use This Skill When

- A plan is fuzzy and needs precise terminology.
- A feature design touches domain language, flow boundaries, or hard-to-reverse decisions.
- You need to challenge assumptions before code implementation.

## Workflow

1. Read AGENTS, CONTEXT, relevant journeys, and affected ADRs.
2. If the plan is ambiguous, run the Plan Interrogation Method (Core).
3. Ask questions one at a time and wait for feedback on each question before continuing.
4. For each question asked, provide a recommended answer.
5. If a question can be answered by exploring the codebase or docs, explore first and ask only what remains unresolved.
6. Cross-check claims against existing docs and code behavior.
7. Resolve terminology conflicts immediately.
8. Update CONTEXT when canonical terms are clarified.
9. Propose an ADR only when hard to reverse, surprising, and trade-off driven.

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

## Challenge Rules

- Call out terminology drift against CONTEXT.
- Replace fuzzy terms with one canonical term per concept.
- Test design assumptions with concrete scenarios and edge cases.
- Surface contradictions between stated behavior and documented contracts.

## Documentation Rules

- Keep CONTEXT glossary-only and free of implementation detail.
- Keep ADRs concise and decision-focused.
- Create files lazily only when there is concrete content to record.

## Quality Gate

- Terminology is consistent across touched docs.
- Open questions are explicit and decision-ready.
- New ADRs include clear context, decision, and rationale.

