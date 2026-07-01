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
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
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
2. Confirm a pull request exists for this task's implementation branch and has been approved. If no approved PR exists, comment on the issue with the required step and stop.
3. Confirm all defect sub-issues are closed. If any remain open, comment on the issue and stop — do not mark Done.
4. Review all findings recorded as comments and sub-issues across the full SDLC for this task.
5. Identify repeated or systemic failure patterns.
6. For each systemic process or documentation gap, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
7. Propose and apply guardrail updates directly to affected specs, skills, or workflow docs in this repository when the change is clear and bounded.
8. Document the rationale for each guardrail change as a comment on the issue.
9. Merge the approved pull request to `main`.
10. Close the delivery issue and set the board item to **Done** (see Board Operations).

## Quality Gate

- All sub-issues are verified closed before marking Done.
- Systemic failures are identified and filed as new Todo issues in `Greenhouse-Documentation`.
- Guardrail updates are traceable to real findings and applied directly to affected docs.
- Board item is set to **Done** only after all checks above pass.
