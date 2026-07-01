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
5. Read the spec referenced in the board item and build a scenario checklist from its acceptance criteria.
6. Execute scenario validation.
7. Record defects with severity and reproducibility as comments on the board item.
8. Record mismatches between observed behavior and the spec as comments on the board item.
9. For each defect found, file a sub-issue in the implementation repository, attach it to the parent task, and return the parent board item to **Ready For Dev** (see Board Operations). Do not advance to Done while defect sub-issues are open.
10. For each spec mismatch, ambiguous acceptance criterion, or missing skill/workflow gap, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
11. If the recommendation is `Go` and no open defect sub-issues remain, set the board item to **Done** (see Board Operations).
12. If the recommendation is `Conditional-Go` or `No-Go` and the issues are fixable, return the board item to **Ready For Dev** with concrete feedback commented on the issue.
13. If QA cannot safely continue because docs, acceptance criteria, or prerequisites are unresolved, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.

## Quality Gate

- Scenario coverage is explicit.
- Defects and mismatches are reproducible and recorded as comments on the board item.
- Recommendation is evidence-based.
- Board item is set to **Done** only on a `Go` recommendation with all sub-issues closed.
- All defects are filed as sub-issues before advancing status.
- All documentation holes and spec mismatches are filed as new Todo issues in `Greenhouse-Documentation`.
- No open sub-issues remain before marking the parent task **Done**.
