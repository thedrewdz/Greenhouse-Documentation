---
name: test
description: Use this skill when running test agent work after implementation, closing coverage gaps against accepted feature behavior, mapping acceptance criteria to tests, and validating happy and negative paths.
---

# Test Skill

Close test coverage gaps against accepted feature behavior.

Used by custom agent: [../../../.codex/agents/test-agent.toml](../../../.codex/agents/test-agent.toml)

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
3. Set the board item to **In Development** (see Board Operations).
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Read the spec referenced in the board item and map acceptance criteria to concrete tests.
6. Validate happy, negative, and degraded paths.
7. Add or update tests to cover gaps.
8. Record remaining untested risks as comments on the board item.
9. For each direct defect found (a test failure caused by a code bug), file a sub-issue in the current repository, attach it to the parent task, and return the parent board item to **Ready For Dev** (see Board Operations). Do not advance while defect sub-issues are open.
10. For each documentation hole found, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
11. If failures or coverage gaps require implementation work, comment on the issue with concrete feedback and set the board item to **Ready For Dev**.
12. If critical acceptance criteria have test evidence and no open defect sub-issues remain, set the board item to **In Review** (see Board Operations).
13. If testing cannot be completed because docs, acceptance criteria, or prerequisites are missing or contradictory, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.
14. Push resulting changes upstream.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Negative-path behavior is covered where relevant.
- Remaining risks are recorded as comments on the board item.
- Fixable failures or coverage gaps return the board item to **Ready For Dev** with concrete feedback commented on the issue.
- Documentation or prerequisite blockers are filed as new issues in `Greenhouse-Documentation`.
- Board item is set to **In Review** on passing, or **Ready For Dev** if open defect sub-issues exist.
- All defects are filed as sub-issues before advancing status.
- All documentation holes are filed as new Todo issues in `Greenhouse-Documentation`.
- No open sub-issues remain before marking the parent task **Done**.
- Changes are pushed upstream.
