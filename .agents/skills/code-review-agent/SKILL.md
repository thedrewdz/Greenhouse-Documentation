---
name: code-review-agent
description: Use this skill for structured code review agent work after implementation, reviewing pull requests against an accepted spec, architecture boundaries, contracts, and tests.
---

# Code Review Agent Skill

Run a structured review pass focused on correctness, contracts, architecture, and maintainability.

Used by custom agent: [../../../.codex/agents/code-review-agent.toml](../../../.codex/agents/code-review-agent.toml)

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
| Done | `98236657` |

**Defect found — create sub-issue and return parent to Ready For Dev:**
```bash
gh issue create -R thedrewdz/<repo> --title "<title>" --label "bug" \
  --body "<description>. Parent task: #<parent-number>"
gh api -X POST repos/thedrewdz/<repo>/issues/<parent-number>/sub_issues \
  -f sub_issue_id=<new-issue-number>
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <parent-item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 1e580093
```

**Documentation hole found — create standalone Todo issue in the docs repo:**
```bash
gh issue create -R thedrewdz/Greenhouse-Documentation \
  --title "Doc: <title>" --label "documentation" \
  --body "<description>. Identified during: <current-issue-url>"
```

**Standalone defect with no parent task — file and promote:**
```bash
gh issue create -R thedrewdz/<repo> --title "<title>" --label "bug" \
  --body "<reproduction, root cause, testable acceptance criteria>"
# Promote to Ready For Dev only if the report carries reproduction, root cause, and
# acceptance criteria — see Defect Intake and Promotion in the harness. Otherwise leave
# at Todo and state which of the three is missing.
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <new-item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 1e580093
```

**Defect is well-formed but blocked on an upstream decision:** hold it and declare the blocker in both issue bodies rather than promoting it. Meeting the three-point bar means the defect is understood, not that it is actionable. See [Declaring a blocking decision](../../../workflows/feature-delivery-harness.md#declaring-a-blocking-decision).

## Pull Request Ownership

**This pass does not merge the pull request, and does not set any board item to Done.** Stage 6 (Retrospective) owns both — see [Pull Request Ownership](../../../workflows/feature-delivery-harness.md#pull-request-ownership).

This pass has exactly two terminal transitions: **Ready For Dev** when blocking findings exist, **In Review** when none do.

Pulling the latest task branch is a different operation and is still required — see step 1.

## Review and Fix Separation

**This pass raises findings. It does not fix them.** Every finding — blocking or not, however small or obvious the fix looks — is filed and routed to a separate implementation pass. See [Review and Fix Separation](../../../workflows/feature-delivery-harness.md#review-and-fix-separation) for why, and do not treat a request for speed as an instruction to fix in place.

When this pass is re-reviewing fixes to its own earlier findings, finding nothing new that blocks is an **exit**. Do not manufacture another round.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Continue only when the board item status is **In Review**. If not, comment on the issue with the required upstream action and stop.
3. Set the board item to **In Review** (see Board Operations).
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Compare the code diff to the spec referenced in the board item.
6. Check contract compatibility and boundary rules.
7. Validate test adequacy at a review level.
8. Classify findings as blocking or non-blocking.
9. For each documentation hole found, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
10. For each blocking defect found under a parent task, file a sub-issue in the current repository, attach it to the parent, and return the parent board item to **Ready For Dev** (see Board Operations). For a blocking defect with no parent task, file it standalone and promote it per [Defect Intake and Promotion](../../../workflows/feature-delivery-harness.md#defect-intake-and-promotion).
11. If blocking findings exist, comment on the issue with concrete implementation feedback and set the board item to **Ready For Dev**. Stop there.
12. If review cannot safely continue because docs, prerequisites, or merge state are unresolved, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.
13. If no blocking findings remain and every defect sub-issue is closed or fixed-and-awaiting-merge, record that outcome on the issue as prose — what was examined, what was found, residual risks — and set the board item to **In Review**. Hand off to Stage 5. Do not merge.

Use the fixed-versus-unfixed test in [Defect Sub-Issue Gates](../../../workflows/feature-delivery-harness.md#defect-sub-issue-gates), not issue openness, when deciding between **Ready For Dev** and **In Review**.

No verdict block, approval vocabulary, or SHA-scoped approval record is required. The merge gate is required checks green, evaluated by Stage 6 — see [Merge Approval](../../../workflows/feature-delivery-harness.md#merge-approval).

## Quality Gate

- No code was changed by this pass.
- Findings are specific and actionable.
- Severity and risk are explicit.
- All documentation holes are filed as new Todo issues in `Greenhouse-Documentation`.
- All blocking defects are filed — as sub-issues under a parent, or standalone and promoted when they meet the intake bar.
- The **Ready For Dev** decision was made on whether a defect is *unfixed*, not on whether its issue is open.
- The board item is set to **Ready For Dev** on blocking findings, or **In Review** when none remain. It was not set to **Done**.
- No merge was performed by this pass.
