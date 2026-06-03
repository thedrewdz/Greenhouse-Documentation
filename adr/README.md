# Architecture Decision Records

Use this folder to capture architectural decisions that are hard to reverse and worth preserving.

## ADR Digest (Quick Reference)

Purpose:

- Provide a fast scan index for agents and maintainers.
- Reduce context load during planning.
- Point to canonical ADR files for full detail.

Source of truth:

- Full ADR files are canonical.
- This digest is a navigation aid, not the authoritative record.

### Anti-Drift Rule

- Any change to an ADR file must include a same-commit update to this digest entry.
- If digest and ADR conflict, the ADR is correct and the digest must be fixed immediately.

### Required Digest Fields

For each ADR, include:

- ADR ID and title
- Status
- Decision summary (one sentence)
- Affected domains or components
- Constraints and non-negotiables
- Supersedes and superseded-by links (if any)
- Canonical file path

### Agent Usage Rule

1. Read this digest first.
2. Read full ADR files for entries that match touched components or constraints.
3. Always read full ADR files when status is proposed, deprecated, or superseded.

### Current Digest

| ADR | Status | Decision Summary | Affected Domains/Components | Constraints / Non-Negotiables | Supersedes / Superseded By | Canonical File |
|---|---|---|---|---|---|---|
| No local ADR files currently tracked in this repository. | n/a | ADR content is maintained in domain repositories as applicable. | n/a | Keep this digest aligned with any ADRs added here later. | n/a | n/a |

## Naming

- Use sequential numbering with a short slug.
- Format: `0001-short-title.md`, `0002-short-title.md`, `0003-short-title.md`.
- When adding a new ADR, increment from the highest existing number.

## Minimal Template

```md
# {Short title of the decision}

{1-3 sentences: context, decision, and why.}
```

ADRs should stay short. Record the decision and reasoning without unnecessary ceremony.

## Optional Sections

Use these only when they add clear value:

- Status (proposed, accepted, deprecated, superseded)
- Considered options
- Consequences

## When to Write an ADR

Create an ADR only when all are true:

1. The decision is hard to reverse.
2. The decision is surprising without context.
3. The decision came from a real trade-off.

