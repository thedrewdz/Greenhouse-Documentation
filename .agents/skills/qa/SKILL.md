---
name: qa
description: Use this skill when performing QA agent work or scenario-level validation after review, including acceptance criteria checks, defect recording, and release readiness.
---

# QA Skill

Validate scenario-level behavior and release readiness.

Used by custom agent: [../../../.codex/agents/qa-agent.toml](../../../.codex/agents/qa-agent.toml)

For standalone QA evaluation guidance, read [references/qa-evaluation.md](references/qa-evaluation.md) when the work requires scenario checklist design or release-readiness framing beyond the role workflow.

## Board Operations

The Greenhouse Delivery board (project `1`, owner `thedrewdz`) is the **primary status authority**. Update it at every stage transition. The board item, its comments, and its sub-issues are the complete record of the work.

**Find the board item ID for the current task:**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 1000 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.content.number -eq <issue-number> -and $_.repository -like "*<repo>*" } \
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
| Ready For Dev | `1e580093` |
| In Development | `47fc9ee4` |
| In Review | `a7a0e5d1` |

**Done is deliberately absent from this table. This pass cannot set it** — see Pull Request Ownership below.

**Defect found under a parent task — create sub-issue and return parent to Ready For Dev:**
```bash
gh issue create -R thedrewdz/<repo> --title "<title>" --label "bug" \
  --body "<description>. Parent task: #<parent-number>"
gh api -X POST repos/thedrewdz/<repo>/issues/<parent-number>/sub_issues \
  -f sub_issue_id=<new-issue-number>
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <parent-item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 1e580093
```

**Defect found with no parent task — file standalone and promote it:**
```bash
gh issue create -R thedrewdz/<repo> --title "<title>" --label "bug" \
  --body "<reproduction steps, root cause or symptom and code path, testable acceptance criteria>"
# Promote to Ready For Dev only when the report carries all three. Otherwise leave it at
# Todo and state on the issue which of the three is missing.
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <new-item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 1e580093
```

**Documentation hole found — create standalone Todo issue in the docs repo:**
```bash
gh issue create -R thedrewdz/Greenhouse-Documentation \
  --title "Doc: <title>" --label "documentation" \
  --body "<description>. Identified during: <current-issue-url>"
```

**List defect sub-issues with their state (to judge fixed vs unfixed):**
```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '.[] | {number, state, title}'
# Openness alone does not decide the status — see Pull Request Ownership below.
```

## Pull Request Ownership

**This pass does not merge the pull request, and does not set any board item to Done.** Stage 6 (Retrospective) owns both — see [Pull Request Ownership](../../../workflows/feature-delivery-harness.md#pull-request-ownership). A `Go` verdict sets the board item to **In Review** and hands off to Stage 6; it does not close the work. Setting **Done** here would mark a task complete with its branch unmerged and its retrospective never run.

This pass has three terminal outcomes and no others:

| Verdict | Board item |
|---|---|
| `Go` | **In Review** |
| `Conditional-Go` / `No-Go`, software-fixable | **Ready For Dev** |
| `Conditional-Go`, **not** software-fixable | **holds at In Review** — see Deferred Validation |

**Decide Ready For Dev on fixed-versus-unfixed, never on issue openness.** A defect sub-issue closes when the pull request merges, not when the fix lands, so on a second pass every sub-issue is simultaneously open and fixed. See [Defect Sub-Issue Gates](../../../workflows/feature-delivery-harness.md#defect-sub-issue-gates).

Pulling the latest task branch is a different operation and is still required — see step 1.

## Deferred Validation

A `Conditional-Go` has two shapes and only one is remediable by a developer. Do not collapse them.

**Software-fixable** — a defect, a coverage gap, an acceptance mismatch. Set **Ready For Dev** with concrete feedback.

**Not software-fixable** — the code is complete, its acceptance criteria are met, the suite is green, and the only unmet condition is a validation step no implementation pass can perform: no hardware, no device, no physical access. Then:

- Record the execution status as `qa-deferred` and **hold the board item at In Review**.
- File or link a tracking issue naming the exact blocking prerequisite and the validation still owed. The issue is the record; a comment alone does not satisfy this.
- **Never record `Go`.** Stand-in coverage — a shell script for `bluetoothctl`, a fake broker, loopback for a device — is named as a stand-in, together with the behavior of the real dependency that remains unverified. It is never reported as cross-process or on-device validation.
- **Never set Ready For Dev.** There is no software work outstanding. Regressing the item misreports finished work as unfinished and queues it for a developer who cannot clear it.

The two failure modes this prevents, both of which make the board less trustworthy: over-reporting, where `Go` is chosen because it was the only branch that closed cleanly; and under-reporting, where completed mergeable work is hidden behind a status claiming it needs development. Traceable to Greenhouse-Services#41, whose honest verdict fitted none of the three original branches, and whose outcome was an undocumented judgement call.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Continue only when the board item status is **In Review**. If not, comment on the issue with the required upstream action and stop.
3. Set the board item to **In Review** (see Board Operations).
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Read the spec referenced in the board item and build a scenario checklist from its acceptance criteria.
6. Execute scenario validation.
7. Record defects with severity and reproducibility as comments on the board item.
8. Record mismatches between observed behavior and the spec as comments on the board item.
9. For each defect found under a parent task, file a sub-issue in the implementation repository, attach it to the parent, and return the parent board item to **Ready For Dev** (see Board Operations). For a defect with no parent task, file it standalone and promote it when it carries reproduction, root cause, and testable acceptance criteria (see Board Operations).
10. For each spec mismatch, ambiguous acceptance criterion, or missing skill/workflow gap, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
11. If the recommendation is `Go` and every defect sub-issue is closed or fixed-and-awaiting-merge, set the board item to **In Review** and hand off to Stage 6. Do not set **Done** and do not merge (see Pull Request Ownership).
12. If the recommendation is `Conditional-Go` or `No-Go` and the remaining issues are fixable in software, return the board item to **Ready For Dev** with concrete feedback commented on the issue.
13. If the recommendation is `Conditional-Go` and its condition is **not** fixable in software, follow Deferred Validation: hold the board item at **In Review**, record `qa-deferred`, and file or link the tracking issue for the validation still owed.
14. If QA cannot safely continue because docs, acceptance criteria, or prerequisites are unresolved, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible and recorded as comments on the board item.
- Recommendation is evidence-based.
- For features spanning a process boundary (e.g. UI↔services, services↔broker, services↔Edge Unit), the recommendation states explicitly whether live cross-process integration was validated or is deferred with a reason. Mocked/stubbed-only coverage is called out as a residual risk, never presented as end-to-end validation.
- **A `Go` was not recorded where that integration was required and not exercised.** That case is `qa-deferred`, and this gate blocks the verdict itself, not just its wording.
- Board item is set to **In Review** on `Go`, **Ready For Dev** on a software-fixable `Conditional-Go` or `No-Go`, or held at **In Review** on a `qa-deferred` outcome.
- This pass performed no merge and set no item to **Done**.
- A `qa-deferred` outcome has a tracking issue naming the blocking prerequisite and the validation owed.
- All defects are filed — as sub-issues under a parent, or standalone and promoted when they meet the intake bar.
- All documentation holes and spec mismatches are filed as new Todo issues in `Greenhouse-Documentation`.
- The **Ready For Dev** decision was made on whether a defect is *unfixed*, not on whether its issue is open.
