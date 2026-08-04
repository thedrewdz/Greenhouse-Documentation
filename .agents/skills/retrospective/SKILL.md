---
name: retrospective
description: Use this skill after QA to confirm delivery completion, identify recurring failures, apply guardrail updates, and close the board item as Done.
---

# Retrospective Skill

Confirm delivery, improve guardrails, and close the board item.

Used by custom agent: [../../../.codex/agents/retrospective-agent.toml](../../../.codex/agents/retrospective-agent.toml)

## Board Operations

The Greenhouse Delivery board (project `1`, owner `thedrewdz`) is the **primary status authority**. The board item, its comments, and its sub-issues are the complete record of the work.

**Find the board item ID for the current task:**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 1000 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.content.number -eq <issue-number> -and $_.repository -like "*<repo>*" } \
  | Select-Object -ExpandProperty id
```

**Set board status to Done (after confirmed complete with all sub-issues closed):**
```bash
# Verify no open sub-issues remain
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '[.[] | select(.state=="open")] | length'
# Must return 0, then:
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 98236657
```

**Documentation hole or process gap found — create standalone Todo issue in the docs repo:**
```bash
gh issue create -R thedrewdz/Greenhouse-Documentation \
  --title "Doc: <title>" --label "documentation" \
  --body "<description>. Identified during retrospective for: <current-issue-url>"
```

## Workflow

1. Read the board item, all comments, and all sub-issues to understand the full delivery history.
2. Confirm a pull request exists for this task's implementation branch and is **approved** as defined in [Merge Approval](../../../workflows/feature-delivery-harness.md#merge-approval) — every required status check on the head commit green. There is no reviewer condition. If a required check is failing, comment on the issue with the specific unmet condition and stop. A repository with no required checks cannot satisfy this; file the missing check rather than waiving the gate.
3. Confirm every defect sub-issue is closed, or fixed on the branch with its acceptance criteria met so that the merge in step 9 will close it. If any is open **and unfixed**, comment on the issue and stop — do not merge and do not mark Done. See [Defect Sub-Issue Gates](../../../workflows/feature-delivery-harness.md#defect-sub-issue-gates).
4. Review all findings recorded as comments and sub-issues across the full SDLC for this task.
5. Identify repeated or systemic failure patterns.
6. For each systemic process or documentation gap, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
7. Propose and apply guardrail updates directly to affected specs, skills, or workflow docs in this repository when the change is clear and bounded.
8. Document the rationale for each guardrail change as a comment on the issue.
9. If the item arrived at `qa-deferred`, record the deferral and its tracking issue in the retrospective. The owed validation stays open after this delivery closes — do not close the tracking issue.
10. Sync the latest `main` into the branch and resolve conflicts, so `main` is never merged from a stale branch, then merge the pull request to `main`.
11. Verify every sub-issue is now closed, then close the delivery issue and set the board item to **Done** (see Board Operations).

## Pull Request Ownership

**This is the only stage that merges a pull request to `main`, and the only stage that sets a board item to Done** — see [Pull Request Ownership](../../../workflows/feature-delivery-harness.md#pull-request-ownership).

Stages 3 (Test), 4 (Review), and 5 (QA) hand work over at **In Review** and never close it. If an item reaches this stage already at **Done**, or its branch is already merged, that is a process defect: record it as a finding in step 6 before continuing.

## Quality Gate

- The merge happened only after every required status check on the head commit was green. No check was waived.
- No defect sub-issue was open and unfixed at merge time.
- All sub-issues are verified closed after the merge, before marking Done.
- A `qa-deferred` delivery records its deferral and tracking issue, and that issue is left open.
- Systemic failures are identified and filed as new Todo issues in `Greenhouse-Documentation`.
- Guardrail updates are traceable to real findings and applied directly to affected docs.
- Board item is set to **Done** only after all checks above pass.
