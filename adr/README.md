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
| 0001 — Main Unit UI and services run as independent processes | accepted | The Main Unit runs the services brain and the operator UI as two independent processes communicating only over loopback REST + WebSocket/SSE. | Main Unit (`/services`, `/ui`) | Services autostarts and runs headless with zero dependency on the UI; comms restricted to loopback; services publishes OpenAPI. | Supersedes the `services-old` single-host Blazor Server model | `adr/0001-main-unit-ui-services-separation.md` |
| 0002 — Flutter (via flutter-pi) for the Main Unit touchscreen UI | accepted, pending hardware spike | The Main Unit touchscreen UI is a Flutter app rendered via flutter-pi (no browser engine on-device), consuming the services API over loopback. | Main Unit (`/ui`) | Pi 4 target; flutter-pi release/AOT; no X11/Wayland/browser; Pi 5 requires re-validation; pin versions; Sony embedder fallback. | — | `adr/0002-main-unit-flutter-flutter-pi-ui.md` |

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

