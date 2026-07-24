---
name: board-triage
description: Use this skill to review the entire project board and produce a prioritized, dependency-aware work order — sequencing items for incremental value, flagging epics that must be groomed before their dependents are needed, and surfacing dependencies that are behind their dependents. This is the Product Owner (PO) counterpart to the ba-po skill: ba-po works one epic in depth; board-triage works the whole board in breadth. Advisory by default; applies changes only on explicit confirmation.
---

# Board Triage Skill: Prioritize and Sequence the Board

Review every item on the board and answer three questions:

1. **What should be worked next** so each completed item delivers usable, incremental value?
2. **What must be groomed now** so grooming never becomes the bottleneck for downstream work?
3. **What is blocked or mis-sequenced** because a dependency is behind the item that needs it?

This skill is **advisory by default**. It reads the board and produces a ranked plan. It applies changes (priority labels, status transitions) **only after explicit user confirmation**.

## Relationship to the ba-po Skill

| | `ba-po` (BA hat) | `board-triage` (PO hat) |
|---|---|---|
| Altitude | One epic, deep | Whole board, broad |
| Owns | Specs, acceptance criteria, task decomposition, dependency ordering *within* an epic | Value ranking and sequencing *across* all epics and tasks |
| Mutates board? | Yes — owns status transitions through the lifecycle | No, unless the user explicitly confirms |

Both are invoked by the **BA/PO Agent**. Use `ba-po` to define and groom a single work item; use `board-triage` to decide which items to pull, groom, or unblock next. See [ba-po/SKILL.md](../ba-po/SKILL.md).

## Board Reference

Reuse the canonical tables in the `ba-po` skill — do not duplicate the IDs here (single source of truth prevents drift):

- **Board Status Reference** (status → option ID): [ba-po/SKILL.md](../ba-po/SKILL.md)
- **Stack → Repository Map**: [ba-po/SKILL.md](../ba-po/SKILL.md)
- **Board Operations** (find item ID, set status, verify status): [ba-po/SKILL.md](../ba-po/SKILL.md)

The lifecycle order is:

```
Todo → In Discovery → Ready For Grooming → In Grooming → Ready For Dev → In Development → In Review → Done
```

## Ingest the Board

Pull every item with its status, stack, and dependency links.

**List all board items** (the `--limit` is a hard ceiling — `gh` truncates silently, it does not warn):
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 1000 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items
```

**Confirm nothing was truncated** — compare the number of items returned against the project's declared total, and raise `--limit` if they differ:
```bash
$total = gh project view 1 --owner thedrewdz --format json | ConvertFrom-Json | Select-Object -ExpandProperty items | Select-Object -ExpandProperty totalCount
$fetched = (gh project item-list 1 --owner thedrewdz --format json --limit 1000 | ConvertFrom-Json | Select-Object -ExpandProperty items).Count
if ($fetched -lt $total) { "TRUNCATED: fetched $fetched of $total — raise --limit" } else { "OK: $fetched of $total" }
```

For each item, resolve:

- **Status** — its board column.
- **Stack / repository** — from the item's repository (see the Stack → Repository Map).
- **Type** — epic (in `Greenhouse-Documentation`) vs implementation task (in a stack repo).
- **Declared dependencies** — parse `Depends on: #<issue>` from the issue body, plus epic ↔ sub-issue links.
- **Spec context** — read `specs/<spec-name>/spec.md` and `status.md` for the dependency map and stated value, when the item links to a spec.

Do not silently cap ingestion. If the board exceeds the fetch limit, raise the limit and state the true item count in the output.

## Analysis Passes

Run all three passes over the ingested board.

### Pass 1 — Dependency Readiness

Build the cross-item dependency graph from declared `Depends on:` links and epic ↔ sub-issue relationships.

Apply the **cross-stack ordering rule** (from `ba-po`): within an epic, work must satisfy `documentation → peripherals → edge → services → ui`.

Flag every case where a dependency is **behind** the item that needs it — e.g. a `ui` task at **Ready For Dev** whose upstream `services` task is still **Todo** or **In Grooming**. Each flag names: the blocked item, the lagging dependency, and the status gap.

### Pass 2 — Grooming Timeliness

Find every epic in **Ready For Grooming** or **In Grooming**.

For each, determine whether its downstream tasks are needed soon (i.e. other in-flight or high-priority work depends on this epic's output). Flag "groom now" epics whose grooming, if delayed, would stall a dependent item. Grooming that gates nothing imminent is lower urgency — say so rather than flagging everything.

### Pass 3 — Incremental-Value Ranking

Rank deliverable items so each completed one ships usable value.

**Elicit value per run** using the Plan Interrogation Method (below) — do not assume a fixed scoring formula. For items whose value or priority is ambiguous, ask the user, one question at a time, with a recommended default. Fold the answers into the ranking. Prefer items that (a) unblock the most downstream work and (b) deliver a coherent slice of user- or operator-visible value on their own.

## Plan Interrogation Method

Use whenever value, priority, or sequencing is ambiguous.

- Ask one question at a time. Never bundle unrelated questions.
- For every question include: why it matters, a recommended default based on current board evidence, and what changes if the user chooses differently.
- After each response, update the ranking and continue to the next unresolved question.
- If a question can be answered by reading the board, issues, or specs, read first and ask only what remains.
- Do not stop early. Continue until the ranking is unambiguous and every flag is explained.

## Output — Triage Report

Produce a single report with three sections:

1. **Work Next** — ranked list of items ready to pull, each with a one-line value/unblock rationale.
2. **Groom Now** — epics that must be groomed before their dependents are needed, in urgency order, each naming what it gates.
3. **Blocked / Mis-sequenced** — items whose dependencies are behind them, each naming the lagging dependency and the status gap.

State the total item count analyzed and any assumptions made. The report is a recommendation — it does not change the board.

## Apply on Confirmation

Do not mutate the board without explicit user confirmation of specific changes.

After the user approves specific changes:

1. Apply each change via the Board Operations commands in `ba-po` (set status, or add/adjust a priority label).
2. **Verify every transition** immediately after making it, using the verify command in `ba-po`. Do not report a change as done until its new state is confirmed.
3. Report exactly what changed and what was verified. If any change failed verification, say so and stop.

Never advance an item past a lifecycle gate that its owning skill controls (e.g. do not push an epic to **Ready For Dev** — that is `ba-po`'s Phase 2 exit gate). Board-triage adjusts priority and surfaces sequencing; it does not bypass the discovery/grooming gates.

## Exit Checklist

- Every board item was ingested; the true count is stated.
- All three passes ran; each flag names the specific items and the gap.
- Value ranking reflects answers gathered this run, not a stale assumption.
- The report clearly separates Work Next, Groom Now, and Blocked / Mis-sequenced.
- No board mutation occurred without explicit confirmation.
- Every applied change was verified against the board.
