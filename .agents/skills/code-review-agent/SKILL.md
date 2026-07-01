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
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
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

**Verify all sub-issues are closed before marking Done:**
```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '[.[] | select(.state=="open")] | length'
# Must return 0 before advancing to Done.
```

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
10. For each blocking defect found, file a sub-issue in the current repository, attach it to the parent task, and return the parent board item to **Ready For Dev** (see Board Operations).
11. If blocking findings exist, comment on the issue with concrete implementation feedback.
12. If no blocking findings remain and no open defect sub-issues exist, proceed to merge safety decision.
13. If review cannot safely continue because docs, prerequisites, or merge state are unresolved, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.
14. If not safe to merge to `main`, record concrete implementation feedback as a comment on the issue and do not merge.
15. If safe to merge to `main`, merge the pull request to `main`.

## Quality Gate

- Findings are specific and actionable.
- Severity and risk are explicit.
- All documentation holes are filed as new Todo issues in `Greenhouse-Documentation`.
- All blocking defects are filed as sub-issues; board item is **Ready For Dev** until they are closed.
- No open sub-issues remain before marking the parent task **Done**.
- Pull request decision is explicit: feedback commented on the issue when unsafe, merged to `main` when safe.
