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

## Task types and status flows

Every GitHub issue is either a **documentation task** or an **implementation task**. The owning
repository determines the type.

### Documentation tasks

Issues filed in `thedrewdz/Greenhouse-Documentation`.

**Feature epics** (multi-stack work that produces implementation tasks):
- Status progression: **Todo → In Discovery → Ready For Grooming → In Grooming → Ready For Dev**
- Sub-tasks created during grooming in code repositories then progress through the implementation task flow.
- The epic itself closes when all sub-tasks reach **Done**.

**Documentation-only tasks** (no implementation tasks required):
- Status progression: **Todo → In Grooming → Done**
- `In Grooming` is the active working state.
- Executed directly against the `main` branch — no feature branch or pull request required.
- Closed by committing directly to `main` with `Closes #N` in the commit message.

- Use the `ba-po` skill for all discovery, epic creation, and grooming work.

### Implementation tasks

Issues filed in any code repository (`services`, `ui`, `edge`, `peripherals`).

- Status progression: **Todo → Ready For Dev → In Development → In Review → [ Ready For Dev → In Development → In Review (× n) ] → Done**
- The loop (→ Ready For Dev → In Development → In Review) repeats until quality gates pass.
- Executed on a short-lived feature branch; merged to `main` only via a reviewed pull request.
- Use the `implementation` skill for all implementation tasks.

### Feature origination rule

Every new feature must begin life as a **documentation task** in `thedrewdz/Greenhouse-Documentation`.
Use the `ba-po` skill to run discovery (Phase 1) and grooming (Phase 2). Discovery produces:

- The epic issue in `Greenhouse-Documentation` with long-form spec dossier, and
- Board status advances from **In Discovery** to **Ready For Grooming**.

Grooming produces:

- Implementation sub-tasks filed in their respective code repositories, and
- Board status advances to **Ready For Dev** for each task and the epic.

No implementation task should be created without the `ba-po` skill having completed grooming and set the spec to `ready-for-dev`.

## Single prioritized view

All issues across the Greenhouse repositories flow into one user-level project board,
**Greenhouse Delivery** — https://github.com/users/thedrewdz/projects/1

- A per-repo workflow (`.github/workflows/add-to-project.yml`) adds every newly-opened issue
  to the board automatically. Do **not** rely on manual board adds.
- **Priority = manual rank**: an item's position in the board's `Backlog` view is the source
  of truth for "what's next" (top = highest). The board's **Priority** field (P0–P3) is
  *severity metadata* for filtering, not the ordering key.
- The **Type** field (Bug / Feature / Update / Tech-debt / Standards) classifies the work.
- **Board order applies to top-level tasks and epics only.** Subtasks (sub-issues) are not
  ordered by board position — they are executed in dependency order (see Subtask execution rules below).
- Work proceeds one top-level item at a time, top-down.

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

### Subtask execution rules (implementation tasks)

When an implementation task (epic or issue) has sub-issues, the following rules govern execution:

- **Same feature branch for all subtasks.** All subtasks are worked on the same feature branch,
  named after the **parent** issue: `feature/<parent-issue-number>-<parent-kebab-title>`. Do not
  create separate branches per subtask.
- **Complete all subtasks together.** A single implementation session must complete all subtasks.
  Do not close a session with some subtasks finished and others pending.
- **Dependency order over board order.** Dependencies between subtasks dictate the order they are
  executed. Complete subtasks in dependency order, ignoring their position on the board. Board
  order only applies to top-level tasks and epics.
- **Set parent to In Review when all subtasks are done.** When all subtasks have been completed
  and pass quality gates: commit and push all changes, create or update the pull request, set
  each subtask to **In Review**, then set the **parent** task to **In Review**.

## Relationship to spec status

Canonical milestone status still lives in `specs/<spec-name>/status.md` and execution status in
`.agent-output/specs/<spec-name>/spec-status.md` (see the delivery harness). The board issue is
the cross-repo, prioritized handle on that work — it does not replace the dossier status, it
surfaces it. A spec that is `ready-for-dev` should have a tracking issue so it is not missed.

## Rules of thumb

- Do not begin non-trivial work that lacks an issue.
- All new features must begin as a documentation task before implementation tasks are created.
- Use the `ba-po` skill for discovery, epic creation, and grooming. Use the `implementation` skill for all code work.
- If you discover new work mid-task, file a follow-up issue rather than silently expanding scope.
- Close issues through PRs (`Closes #N`) — or, for documentation-only changes committed
  directly to `main` per [branching-strategy.md](branching-strategy.md), via `Closes #N` in the
  commit — so the board's *Done* automation fires.
- Never put secrets in issue titles or bodies.
