# Work Item Tracking

Canonical, solution-wide process for capturing and tracking work across every Greenhouse
repository (this documentation hub, Main Unit `/services` and `/ui`, Edge Unit firmware, and
peripherals).

## Principle

All trackable work — bugs, features, updates, tech-debt, standards gaps — is a **GitHub
issue**. One work item = one issue. Work that lives only in chat, a commit message, or a
local doc is invisible and never gets prioritized. If you identify or are asked to do
non-trivial work, file the issue first (or as you start it), in the repository that owns it.

This complements the [feature delivery harness](workflows/feature-delivery-harness.md): a spec
dossier under `specs/<spec-name>/` remains the durable source of truth for feature-level work,
and the tracking issue is its entry on the board.

## Single prioritized view

All issues across the Greenhouse repositories flow into one user-level project board,
**Greenhouse Delivery** — https://github.com/users/thedrewdz/projects/1

- A per-repo workflow (`.github/workflows/add-to-project.yml`) adds every newly-opened issue
  to the board automatically. Do **not** rely on manual board adds.
- **Priority = manual rank**: an item's position in the board's `Backlog` view is the source
  of truth for "what's next" (top = highest). The board's **Priority** field (P0–P3) is
  *severity metadata* for filtering, not the ordering key.
- The **Type** field (Bug / Feature / Update / Tech-debt / Standards) classifies the work.
- Work proceeds one item at a time, top-down.

## Filing an issue (recipe)

Create the issue in the owning repo and apply a type label:

```bash
gh issue create -R thedrewdz/<repo> \
  --title "<concise imperative title>" \
  --label <bug|enhancement|tech-debt|standards> \
  --body "<context, why it matters, and acceptance criteria; link related issues/docs/spec>"
```

The add-to-project workflow boards it. Triage then sets the board **Type** field, ranks it by
dragging in the `Backlog` view, and (optionally) sets the **Priority** severity. Prefer a body
that is self-contained: the spec/standard it relates to, current state, the required change,
and acceptance criteria.

## Epics and sub-issues

For multi-part efforts, create a tracking **epic** issue and attach the parts as native
**sub-issues** (the board's *Sub-issues progress* field then tracks completion). Keep the
detailed design/evidence dossier in `specs/<spec-name>/` (or `.agent-output/specs/<spec-name>/`
in implementation repos) and link it from the epic.

## Relationship to spec status

Canonical milestone status still lives in `specs/<spec-name>/status.md` and execution status in
`.agent-output/specs/<spec-name>/spec-status.md` (see the delivery harness). The board issue is
the cross-repo, prioritized handle on that work — it does not replace the dossier status, it
surfaces it. A spec that is `ready-for-dev` should have a tracking issue so it is not missed.

## Rules of thumb

- Do not begin non-trivial work that lacks an issue.
- If you discover new work mid-task, file a follow-up issue rather than silently expanding scope.
- Close issues through PRs (`Closes #N`) — or, for documentation-only changes committed
  directly to `main` per [branching-strategy.md](branching-strategy.md), via `Closes #N` in the
  commit — so the board's *Done* automation fires.
- Never put secrets in issue titles or bodies.
