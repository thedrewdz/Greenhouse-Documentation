# Branching Strategy

This document defines the version-control guardrail for the Greenhouse platform.
It applies to **every repository in the solution** — this documentation hub and all implementation repositories (Main Unit `/services`, `/ui`, Edge Unit firmware, peripherals, and any future repo).

## Core Guardrail

- `main` is the integration branch and the source of truth. It must always be in a working state.
- **No feature work is committed directly to `main`.**
- All feature work happens on a short-lived branch created from the latest `main`.
- A branch is merged back into `main` only after the work is **complete and working** — implemented, tested, and past the code review gate — via a pull request.
- Delete the branch after it merges.

This mirrors the [feature delivery harness](workflows/feature-delivery-harness.md): work is implemented and tested on a branch, the Code Review Gate (Stage 4) decides merge safety, and only safe work reaches `main`.

## Branch Naming Convention

Format:

```
<type>/<descriptor>
```

### `<type>`

Must be one of the canonical work types (the same values used in the `Branch And Preflight` section of [templates/implementation-plan.md](templates/implementation-plan.md)):

- `feature` — new behavior or capability.
- `bug-fix` — correcting broken behavior.
- `update` — non-feature changes: docs, dependencies, refactors, config, chores.

### `<descriptor>`

- When the work maps to a spec dossier, use the **spec name** exactly as it appears under `specs/<spec-name>/` (already kebab-case). This keeps the branch traceable to its spec.
- For work without a spec, use a short kebab-case summary (lowercase, hyphen-separated, no spaces, no underscores).

### Examples

- `feature/edge-unit-onboarding`
- `feature/empty-dashboard`
- `bug-fix/heartbeat-timeout`
- `update/mqtt-topic-rename`
- `update/branching-strategy-doc`

## Rules

- Branch from the latest `main`; do not branch from another feature branch.
- One unit of work per branch — keep branches short-lived to limit merge drift.
- Pull/rebase the latest `main` into the branch before opening or updating the pull request, and resolve conflicts before stage work continues.
- The branch `<type>` and `<descriptor>` must match the `Work type` and spec name recorded in the implementation plan.
- Merge to `main` only through a pull request that has passed the Code Review Gate.
- In this documentation repository, the same model applies: only the Documentation Agent and Retrospective Agent write to `main`, and they do so by merging a reviewed branch — not by committing directly.

## Cross-References

- [workflows/feature-delivery-harness.md](workflows/feature-delivery-harness.md) — the delivery loop that consumes this strategy.
- [templates/implementation-plan.md](templates/implementation-plan.md) — records the branch name and work type per spec.
- [AGENTS.md](AGENTS.md) — canonical policy that points here.
