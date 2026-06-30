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

## Documentation-Only Changes

Documentation-only changes are exempt from the branch + pull request + Code Review Gate requirement and may be committed directly to `main`.

- A change is **documentation-only** when it touches *only* documentation files (Markdown and other non-executing doc assets) — no source, build, CI/workflow, dependency, or automation-config files.
- Such changes may be committed straight to `main` with a clear message; a branch, pull request, and review gate are not required.
- This exemption does **not** apply when any of the following are true — use the standard branch + PR + review-gate flow instead:
  - the change is bundled with one or more non-documentation files (the whole change then follows the standard flow);
  - the target repository has branch protection that requires a pull request or status checks (never bypass protection); or
  - committing directly would break a GitHub project or automation workflow.
- Documentation quality gates still apply (stable terminology, valid JSON examples, cross-references updated in the same pass). If the change resolves a tracked issue, include `Closes #<n>` in the commit so board automation fires.

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
- Pull/rebase the latest `main` into the branch before opening or updating the pull request — and again immediately before merging the pull request into `main` — resolving conflicts each time. `main` is never merged from a stale branch.
- The branch `<type>` and `<descriptor>` must match the `Work type` and spec name recorded in the implementation plan.
- Merge to `main` only through a pull request that has passed the Code Review Gate.
- In this documentation repository, non-documentation changes follow the same model: write to `main` only by merging a reviewed branch, not by committing directly. Documentation-only changes follow the Documentation-Only Changes exemption above and may be committed directly to `main`.

## Cross-References

- [workflows/feature-delivery-harness.md](workflows/feature-delivery-harness.md) — the delivery loop that consumes this strategy.
- [templates/implementation-plan.md](templates/implementation-plan.md) — records the branch name and work type per spec.
- [AGENTS.md](AGENTS.md) — canonical policy that points here.
