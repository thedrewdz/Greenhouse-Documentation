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
| Todo | `f75ad846` |
| Ready For Dev | `1e580093` |
| In Development | `47fc9ee4` |
| In Review | `a7a0e5d1` |
| Done | `98236657` |

**Documentation hole found — create standalone Todo issue in the docs repo:**
```bash
gh issue create -R thedrewdz/Greenhouse-Documentation \
  --title "Doc: <title>" --label "documentation" \
  --body "<description>. Identified during: <current-issue-url>"
# The add-to-project workflow boards it at Todo status automatically.
```

**Record branch name on the issue description (idempotent — safe to re-run):**
```powershell
$branch = "<branch-name>"
$body = gh issue view <issue-number> -R thedrewdz/<repo> --json body --jq '.body'
$body = $body -replace '(?s)\n\n## Branch\n`[^`]*`', ''
$body += "`n`n## Branch`n``$branch``"
gh issue edit <issue-number> -R thedrewdz/<repo> --body $body
```

**Record PR name and URL on the issue description (idempotent — safe to re-run):**
```powershell
$pr = gh pr list --head <branch-name> -R thedrewdz/<repo> --json url,title --jq '.[0]' | ConvertFrom-Json
$body = gh issue view <issue-number> -R thedrewdz/<repo> --json body --jq '.body'
$body = $body -replace '(?s)\n\n## Pull Request\n\[.*?\]\(.*?\)', ''
$body += "`n`n## Pull Request`n[$($pr.title)]($($pr.url))"
gh issue edit <issue-number> -R thedrewdz/<repo> --body $body
```

**Verify board item status (use after every status transition to confirm it applied):**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 1000 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.id -eq "<item-id>" } \
  | Select-Object -ExpandProperty status
```

**Verify all sub-issues are closed before marking Done:**
```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '[.[] | select(.state=="open")] | length'
# Must return 0 before advancing to Done.
```

## Preflight

Before coding, complete all checks:

1. Determine the branch name for this task. The format is `feature/<issue-number>-<short-kebab-title>` (e.g. `feature/42-edge-unit-heartbeat`). `<issue-number>` is the **GitHub issue number** — never a task alias, epic label, or human-readable shorthand. **If this task has sub-issues (subtasks), use the parent task's issue number and title for the branch name.** Use no other prefix. Do not proceed until the branch name conforms to this format.
2. Fetch the latest remote state and check whether the branch already exists:
   ```bash
   git fetch origin
   git branch -a | grep <branch-name>
   ```
3. **Branch does not exist** — create it from the latest `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b <branch-name>
   ```
4. **Branch already exists** — check it out and rebase onto the latest `main`:
   ```bash
   git checkout <branch-name>
   git rebase origin/main
   ```
5. Record the branch name on the issue description under a `## Branch` heading (see Board Operations). This makes the branch discoverable by all downstream agents.
6. Resolve any rebase conflicts before commencing work. Stop only if conflicts cannot be resolved safely.
7. Read the board item, its comments, and linked sub-issues for prior findings and open follow-up notes.
8. Confirm no open defect sub-issues exist before starting new work on this task.

## Subtask Execution

When an implementation task (epic or issue) has sub-issues (subtasks), these rules govern execution:

- **One branch for all subtasks.** All subtasks are worked on the same feature branch, named after the **parent** issue: `feature/<parent-issue-number>-<parent-kebab-title>`. Do not create a separate branch per subtask.
- **Complete all subtasks in one session.** A single implementation session must complete all subtasks under a parent. Do not end a session with some subtasks finished and others pending.
- **Dependency order over board order.** Board order applies only to top-level tasks and epics. Between subtasks, dependency dictates execution order. A subtask may not be started before its declared dependencies are done, but subtasks without dependencies may begin immediately regardless of board position.
- **Set each subtask to In Development at start.** When beginning work, set every sub-issue that will be completed in this session to **In Development** as well as the parent task (see Workflow step 3).
- **Finalize with parent In Review.** When all subtasks pass quality gates: commit and push all changes, create or update the pull request, set each subtask to **In Review**, then set the **parent** task to **In Review**.

## Workflow

1. Read the spec referenced in the board item, repo `AGENTS.md`, and relevant technical skills.
2. Continue only when the board item status is **Ready For Dev** or **In Development**. If not, comment on the issue with the required upstream action and stop.
3. Set the board item to **In Development** and verify the status change using the board verify command (see Board Operations). If this task has sub-issues that will be completed in this session, set **all** of them to **In Development** as well (see Subtask Execution). **Do not write any code until all status updates are confirmed.**
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Map each planned change to an architectural layer before coding.
6. For recurring integration message streams, such as heartbeat, acknowledgements, and state updates, define handling through a cross-cutting messaging abstraction instead of feature-lifecycle-specific application services.
7. Implement only documented behavior.
8. Add or update tests with implementation changes.
9. Run local verification.
10. For each defect found during local verification, fix it before advancing. Do not file sub-issues for defects — defect tracking is the responsibility of the test and QA agents.
11. If a documentation hole is discovered at any point, stop immediately. Comment on the board item describing the gap, file a new standalone issue in `Greenhouse-Documentation` referencing the current task URL (see Board Operations), set the board item to **Todo**, and stop. Do not continue implementation against incomplete or ambiguous documentation.
12. If any other blocker prevents progress — such as an unresolved architectural decision, missing dependency, or unavailable external service — stop immediately. Comment on the board item describing the blocker and the action needed to unblock it. Set the board item to **Todo**. Do not leave the board item at **Ready For Dev** or **In Development** while blocked.
13. When the quality gate passes and no open defect sub-issues remain, commit all outstanding changes with a message referencing the issue number, then push the feature branch:
    ```bash
    git add -A
    git commit -m "<description> (#<issue-number>)"
    git push origin <branch-name>
    ```
14. Create a pull request targeting `main`. If this is feedback remediation and a PR already exists, update its description with a summary of the changes made in this pass. Record the PR name and URL on the issue description under a `## Pull Request` heading (see Board Operations).
15. If the task has sub-issues, set each sub-issue to **In Review**. Then set the board item (or parent task) to **In Review** (see Board Operations and Subtask Execution).

## Hazard-Class Sweep

A defect is almost always an instance of a class — an undrained pipe, an unobserved task, an unbounded buffer, a teardown that only runs on one exception type. A fix that addresses only the site the issue names leaves the class in place.

Before finalizing a defect fix:

- **Enumerate every site of the same hazard in the repository**, not only the one the issue names. Search for the shared mechanism — the helper, the API call, the pattern — not the reported symptom.
- **Fix and cover every site found.** A sibling site fixed as a rider on another issue's branch gets the same regression test as the named site. This is where rigor is silently dropped.
- **File and link any site deliberately left unfixed** before the pull request merges, with the reason.

Traceable to Greenhouse-Services#41: the issue named `RunSessionAsync`, while the identical undrained-stderr hazard in `ScanAsync` went unnoticed for four days until a human comment widened the scope. When `ScanAsync` was then fixed in the same pass, it shipped without a regression test (#69) and introduced a new unbounded-buffer defect (#66) — neither of which happened at the named site.

## Infrastructure Abstraction Rules

This codebase follows **Ports and Adapters (Hexagonal Architecture)**. The core distinction is between *mechanism* and *policy*.

A **mechanism** is a generic, long-lived capability: publishing a message, recording telemetry, reading a BLE characteristic, persisting state. Mechanisms are stable contracts owned by an inner layer (`IMessagingService`, `ITelemetryService`, `IBleService`, `IStorageRepository`). Their operations are generic — `Publish`, `Log`, `Read`, `Write` — never named after a specific feature or workflow.

A **policy** is a specific business rule composed on top of a mechanism: "send a heartbeat every 30 s", "log errors to Azure", "onboard an edge unit over BLE". Policies are use cases in the application layer. They depend on mechanism contracts, never on concrete adapters.

**Rules:**
- Every infrastructure capability must be expressed as a stable, generic contract in an inner layer. If the operation name describes a specific feature or workflow, it belongs in a use case, not in the contract.
- Implement each contract exactly once per transport or vendor in the infrastructure layer. Wire at the composition root.
- Use cases depend only on contracts. They must not hold references to adapter types or own the lifecycle of the underlying service.
- Long-running services (brokers, BLE stacks, telemetry sinks, connection pools) are started at the composition root and live for the process lifetime. A use case calls into them; it does not start, stop, or wrap them.
- When the same mechanism supports multiple policies, route through a shared instance — do not create a new adapter per use case.

**Naming convention:**
- Contracts: `I<Capability>Service` or `I<Capability>Repository` (e.g. `IMessagingService`, `ITelemetryService`)
- Adapters: `<Transport/Vendor><Capability>Service` (e.g. `MqttMessagingService`, `AzureTelemetryService`)
- Use cases: `<Verb><Noun>` with an optional framework suffix (e.g. `OnboardEdgeUnit`, `PublishHeartbeatHandler`, `LogErrorCommand`)

## Final Self-Check

- [ ] Code is complete.
- [ ] Relevant tests are run and/or limitations are documented.
- [ ] All defects found during implementation are fixed; no known defects remain.
- [ ] If a documentation hole was found, work stopped immediately, the hole was filed in `Greenhouse-Documentation`, and the board item was returned to **Todo**.
- [ ] If any other blocker was encountered, work stopped immediately, the blocker was commented on the issue, and the board item was returned to **Todo**.
- [ ] If subtasks exist: all were completed in this session, all are set to **In Review**, and the parent task is set to **In Review**.
- [ ] No open sub-issues remain, or carry-forward rationale is recorded as a comment on the issue.

## Architecture Execution Checklist

Before finalizing implementation, verify:

- Each new or changed file is in the correct layer or module.
- Cross-layer collaboration happens through abstractions owned by stable inner layers.
- Infrastructure implementations are placed in infrastructure modules and wired through composition points.
- Presentation-layer code does not depend directly on infrastructure implementation types.
- Business orchestration is not moved into presentation or infrastructure layers.
- Each infrastructure capability is expressed as a generic, long-lived contract in an inner layer; no use case names or owns infrastructure operations.

If any check fails, fix placement or abstraction boundaries before continuing.

## Quality Gate

- Behavior matches the spec referenced in the board item.
- Prior feedback from comments and sub-issues has been resolved or explicitly carried forward with rationale.
- No silent contract changes exist.
- Verification evidence is captured.
- Architecture execution checklist is fully satisfied.
- Infrastructure abstraction rules are fully satisfied.
- For a defect fix: every site of the same hazard class is enumerated, and each is either fixed and covered or filed and linked (see Hazard-Class Sweep).
- Board item is set to **In Review** on passing, or **Todo** if an early stop occurred.
- All defects found during implementation are fixed before advancing.
- Any documentation hole found causes an immediate stop; the hole is filed in `Greenhouse-Documentation` and the board item is returned to **Todo**.
- Any other blocker causes an immediate stop with a comment; the board item is returned to **Todo** — never left at **Ready For Dev** or **In Development** while blocked.
- If subtasks exist: all were completed in this session on the parent's feature branch; each subtask and the parent task are set to **In Review**.
- No open sub-issues remain before marking the parent task **Done**.
- Changes are pushed upstream.
- A new pull request exists when work is not feedback remediation.
