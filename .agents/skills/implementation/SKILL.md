---
name: implementation
description: Use this skill when implementing accepted specs in a consumer repository, preserving documented behavior, contracts, architecture boundaries, test coverage, and messaging abstractions.
---

# Implementation Skill

Implement accepted specs while preserving contracts and architecture boundaries.

Used by custom agent: [../../../.codex/agents/implementation-agent.toml](../../../.codex/agents/implementation-agent.toml)

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
# Create the defect issue in the same repo as the current task
gh issue create -R thedrewdz/<repo> --title "<title>" --label "bug" \
  --body "<description>. Parent task: #<parent-number>"
# Attach as sub-issue (use the number returned by the create command)
gh api -X POST repos/thedrewdz/<repo>/issues/<parent-number>/sub_issues \
  -f sub_issue_id=<new-issue-number>
# Return the parent board item to Ready For Dev
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS --id <parent-item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo --single-select-option-id 1e580093
```

**Documentation hole found — create standalone Todo issue in the docs repo:**
```bash
gh issue create -R thedrewdz/Greenhouse-Documentation \
  --title "Doc: <title>" --label "documentation" \
  --body "<description>. Identified during: <current-issue-url>"
# The add-to-project workflow boards it at Todo status automatically.
```

**Verify all sub-issues are closed before marking Done:**
```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '[.[] | select(.state=="open")] | length'
# Must return 0 before advancing to Done.
```

## Preflight

Before coding, complete all checks:

1. Pull latest `main` into your current working branch.
2. Resolve merge conflicts before commencing spec work.
3. Stop only if merge conflicts cannot be resolved safely.
4. Read the board item, its comments, and linked sub-issues for prior findings and open follow-up notes.
5. Confirm no open defect sub-issues exist before starting new work on this task.

## Workflow

1. Read the spec referenced in the board item, repo `AGENTS.md`, and relevant technical skills.
2. Continue only when the board item status is **Ready For Dev** or **In Development**. If not, comment on the issue with the required upstream action and stop.
3. Set the board item to **In Development** (see Board Operations).
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Map each planned change to an architectural layer before coding.
6. For recurring integration message streams, such as heartbeat, acknowledgements, and state updates, define handling through a cross-cutting messaging abstraction instead of feature-lifecycle-specific application services.
7. Implement only documented behavior.
8. Add or update tests with implementation changes.
9. Run local verification.
10. For each direct defect found, file a sub-issue in the current repository, attach it to the parent task, and return the parent board item to **Ready For Dev** (see Board Operations). Do not advance while any defect sub-issue is open.
11. For each documentation hole or bug found, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
12. When the quality gate passes and no open defect sub-issues remain, push changes upstream.
13. Create a pull request targeting `main`. If this is feedback remediation and a PR already exists, update its description with a summary of the changes made in this pass.
14. Set the board item to **In Review** (see Board Operations).

## Cross-Cutting Messaging Rules

- Treat recurring integration message traffic as a runtime-wide concern, not a setup-only or feature-only concern.
- Do not create lifecycle-scoped orchestration services such as `SetupApplicationService` or `EdgeUnitConfigurationApplicationService` to own continuous message ingestion.
- Define a messaging abstraction in an inner stable layer, such as `IMessagingService`, and depend on that abstraction from application/use-case code.
- Implement transport-specific behavior in infrastructure, such as `BrokerMessagingService`, `MqttMessagingService`, or `AmqpMessagingService`, and wire it at composition boundaries.
- Feature workflows register handlers through the abstraction, such as `register(channel, callback)`, rather than directly subscribing through a transport client.
- Heartbeat handling must remain active for the lifetime of the Main Unit process and must not be modeled as a one-off setup transaction.
- If one channel or topic can trigger multiple workflows, keep subscription ownership centralized and route through callbacks or handlers.

## Final Self-Check

- [ ] Code is complete.
- [ ] Relevant tests are run and/or limitations are documented.
- [ ] All defects found are filed as sub-issues; board item is **In Review** (or **Ready For Dev** if defect sub-issues remain open).
- [ ] All documentation holes found are filed as new Todo issues in `Greenhouse-Documentation`.
- [ ] No open sub-issues remain, or carry-forward rationale is recorded as a comment on the issue.

## Architecture Execution Checklist

Before finalizing implementation, verify:

- Each new or changed file is in the correct layer or module.
- Cross-layer collaboration happens through abstractions owned by stable inner layers.
- Infrastructure implementations are placed in infrastructure modules and wired through composition points.
- Presentation-layer code does not depend directly on infrastructure implementation types.
- Business orchestration is not moved into presentation or infrastructure layers.
- Recurring integration message ingestion is routed through a shared messaging abstraction and not through setup-only or feature-lifecycle-specific application service classes.

If any check fails, fix placement or abstraction boundaries before continuing.

## Quality Gate

- Behavior matches the spec referenced in the board item.
- Prior feedback from comments and sub-issues has been resolved or explicitly carried forward with rationale.
- No silent contract changes exist.
- Verification evidence is captured.
- Architecture execution checklist is fully satisfied.
- Cross-cutting messaging rules are fully satisfied.
- Board item is set to **In Review** on passing, or remains at **Ready For Dev** if open defect sub-issues exist.
- All defects are filed as sub-issues before advancing status.
- All documentation holes are filed as new Todo issues in `Greenhouse-Documentation`.
- No open sub-issues remain before marking the parent task **Done**.
- Changes are pushed upstream.
- A new pull request exists when work is not feedback remediation.
