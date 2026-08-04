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

**List defect sub-issues with their state (to judge fixed vs unfixed):**
```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '.[] | {number, state, title}'
# Openness alone does not decide the status — see Pull Request Ownership below.
```

## Pull Request Ownership

**This pass does not merge the pull request, and does not set any board item to Done.** Stage 6 (Retrospective) owns both — see [Pull Request Ownership](../../../workflows/feature-delivery-harness.md#pull-request-ownership).

This pass has exactly two terminal transitions:

- **In Review** when critical acceptance criteria have test evidence and every defect sub-issue is closed **or** fixed on the branch with its acceptance criteria met.
- **Ready For Dev** when a defect sub-issue is open **and unfixed**, or when coverage gaps need implementation work.

**Decide on fixed-versus-unfixed, never on issue openness.** A defect sub-issue closes when the pull request merges, not when the fix lands, so on a second pass over a task every sub-issue is simultaneously open and fixed. Gating **Ready For Dev** on openness is a loop with no exit — see [Defect Sub-Issue Gates](../../../workflows/feature-delivery-harness.md#defect-sub-issue-gates). If this pass cannot tell whether an open sub-issue is fixed, it says so on the issue and holds at the current status rather than guessing.

Pulling the latest task branch is a different operation and is still required — see step 1.

## Workflow

1. Pull latest remote changes with `git pull --ff-only` and stop on conflicts.
2. Continue only when the board item status is **In Review**. If not, comment on the issue with the required upstream action and stop.
3. Set the board item to **In Development** (see Board Operations).
4. Read all comments and linked sub-issues on the board item to resolve any prior findings before starting new work.
5. Read the spec referenced in the board item and map acceptance criteria to concrete tests.
6. Validate happy, negative, and degraded paths.
7. Add or update tests to cover gaps.
8. Record remaining untested risks as comments on the board item.
9. For each direct defect found (a test failure caused by a code bug), file a sub-issue in the current repository, attach it to the parent task, and return the parent board item to **Ready For Dev** (see Board Operations). Do not advance while a defect sub-issue is unfixed. For a defect with no parent task, file it standalone and promote it per [Defect Intake and Promotion](../../../workflows/feature-delivery-harness.md#defect-intake-and-promotion).
10. For each documentation hole found, file a new standalone issue in `Greenhouse-Documentation` at default **Todo** status referencing the current task URL (see Board Operations).
11. If failures or coverage gaps require implementation work, comment on the issue with concrete feedback and set the board item to **Ready For Dev**.
12. If critical acceptance criteria have test evidence and every defect sub-issue is closed or fixed-and-awaiting-merge, set the board item to **In Review** (see Board Operations and Pull Request Ownership).
13. If testing cannot be completed because docs, acceptance criteria, or prerequisites are missing or contradictory, file a new standalone issue in `Greenhouse-Documentation` and comment on the board item with the blocker.
14. Push resulting changes upstream.

## Test Integrity Rules

A green run is only evidence if it states what it actually exercised.

**A conditional test reports Skipped, never Passed.** A test that returns early because a precondition is unmet — wrong OS, missing tool, absent hardware — reports **Passed** and is indistinguishable from a test that ran. Use the framework's skip mechanism (xUnit `Assert.Skip`, `[SkippableFact]`, or the equivalent), never a bare `return`. Traceable to Greenhouse-Services#70: a Linux-only subprocess teardown test used a bare `return` and reported `Failed: 0, Passed: 26, Skipped: 0` on a Windows host, so the host that could not run it looked identical to the host that could.

**A stand-in is named in the evidence, together with what it does not prove.** Where a test substitutes something for an external dependency — a shell script for `bluetoothctl`, a fake for the broker, loopback for a device — the evidence recorded on the board item names the substitution and states which behavior of the real dependency remains unverified. Passing against a stand-in is never reported as cross-process or on-device validation. Traceable to Greenhouse-Services#41, whose deadlock fix is proven against a host shell and still awaits a real BlueZ session (#54).

**A fix applied at more than one site is covered at every site.** When the same hazard is fixed in several places, each place needs its own regression test. The site named in the issue reliably gets one; a sibling site fixed as a rider on that branch reliably does not. Traceable to Greenhouse-Services#69.

## Quality Gate

- Critical acceptance criteria have test evidence.
- Test integrity rules are satisfied: no conditional test reports Passed without running, every stand-in is named with its residual risk, and every site of a multi-site fix has coverage.
- Negative-path behavior is covered where relevant.
- Remaining risks are recorded as comments on the board item.
- Fixable failures or coverage gaps return the board item to **Ready For Dev** with concrete feedback commented on the issue.
- Documentation or prerequisite blockers are filed as new issues in `Greenhouse-Documentation`.
- Board item is set to **In Review** on passing, or **Ready For Dev** if a defect sub-issue is open **and unfixed**. Openness alone is not the test.
- All defects are filed — as sub-issues under a parent, or standalone and promoted when they meet the intake bar.
- All documentation holes are filed as new Todo issues in `Greenhouse-Documentation`.
- This pass performed no merge and set no item to **Done**.
- Changes are pushed upstream.
