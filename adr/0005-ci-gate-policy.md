# CI gate policy for governed repositories

Status: accepted
Date: 2026-08-04

## Context

While grooming the CI merge-gate batch (2026-08-04), three cross-repository decisions were taken. Each decision was recorded only in issue bodies, where it would not be found by the next reader and would be re-litigated. This ADR is the durable home for all three.

A fourth gap was also confirmed: the required-checks table in `feature-delivery-harness.md` recorded checks as `present` without any branch protection enforcing them. Verified 2026-08-04:

```
$ gh api repos/thedrewdz/Greenhouse-Services/branches/main/protection   → HTTP 404
$ gh api repos/thedrewdz/Greenhouse-Firmware/branches/main/protection   → HTTP 404
$ gh api repos/thedrewdz/Greenhouse-WebUI/branches/main/protection      → HTTP 404
```

A check that reports but is not required by branch protection does not gate a merge. The `present` label read as though the gate was live, which is the more dangerous half of the problem.

## Decisions

### 1. Required status checks are enforced by branch protection with no admin bypass

Branch protection is applied to `main` in every governed repository that has a live check — Greenhouse-Services and Greenhouse-Firmware as of 2026-08-05. Configuration:

- The named check or checks are the only required status check contexts. A repository may need more than one — `Greenhouse-Firmware` requires two, because its guard workflow reports as two separate jobs.
- `strict: true` — the branch must be up to date before the check is treated as sufficient. This ensures the check ran against the actual merge result, not a stale head.
- Admin enforcement **on** — there is no bypass path, including for the maintainer.
- No required reviewers — this is a single-maintainer project. The merge gate is check-gated, not reviewer-gated. See Merge Approval in `workflows/feature-delivery-harness.md`.
- Force-push and deletion disabled.

The script that applies this is `scripts/set-branch-protection.ps1`. It takes `-Repo` and `-Check` as parameters, is idempotent, and prints the resulting protection state. Running it twice against the same repository produces the same state and no error.

#### Consequence: protecting a repository makes `main` PR-only there

With `build-and-test` required and admin enforcement on, direct pushes to `main` in Greenhouse-Services and Greenhouse-Firmware stop working — including docs-only pushes. The documentation-only exemption in `branching-strategy.md` applies to this documentation repository; it does not extend to documentation files committed inside a code repository. Greenhouse-Services#60 (`AGENTS.md`/`README.md`) is the concrete example of a push that the new protection will block.

#### Which repositories and when

| Repository | Check | Protect when |
|---|---|---|
| `Greenhouse-Services` | `build-and-test` | Immediately — check is live on `main` |
| `Greenhouse-Firmware` | `no-new-c-in-firmware`, `host-tests` | Immediately — checks report on pull requests targeting `main` (the workflow is `pull_request`-only, so `main`'s head carries no run) |
| `Greenhouse-WebUI` | `flutter analyze` + `flutter test` | After Greenhouse-WebUI#24 lands |
| `Greenhouse-Peripherals` | sketch compilation | After Greenhouse-Peripherals#2 lands |

Classic branch protection (not repository rulesets) is used because it is sufficient and expressible in a single `gh api` call.

### 2. NuGet restore-time vulnerability advisories do not gate pull requests

The `dotnet restore` step surfaces advisory warnings at the point of restore. These are deliberately excluded from the PR gate.

Rationale:

- Advisory severity can change at any time, independent of the code under review. A PR that was green at raise time can turn red due to an upstream advisory change with no code change, which ties merge approval to a condition the author cannot control.
- The `Restore` step and the `Build`/`Test` steps are asymmetric in failure semantics: a restore advisory is a supply-chain signal worth acting on, but not within the latency window of a PR; a build or test failure is a code defect that must block a merge.
- Advisories are surfaced by a scheduled audit job instead (Greenhouse-Services#62), which runs independently of PRs and routes findings to the maintainer without blocking in-flight work.

This is not an oversight. The asymmetry between `Restore` warnings and `Build`/`Test` failures is intentional.

### 3. All `uses:` references are pinned to a commit SHA with Dependabot proposing bumps

Every `uses:` reference in every workflow file across the governed repositories is pinned to a full commit SHA. Dependabot is configured to propose version bumps as pull requests, which the maintainer reviews and merges normally.

Rationale:

- An un-pinned `uses: actions/checkout@v4` resolves to whatever the tag points at when the workflow runs. A tag can be force-pushed; the same reference can execute different code on different runs without any change to the repository.
- Pinning to a SHA freezes the exact code the action runs. The only way to change it is a reviewed commit to the workflow file.
- Dependabot bumps are a routine, low-friction path to staying current. The maintainer does not have to track action releases manually.

This applies to all Greenhouse repositories, current and future. Adding a new workflow file means pinning its actions at creation time, not as a later cleanup.

## Affected domains

- All Greenhouse repositories — current and future. When a new repository is created, these three decisions apply from day one: SHA-pin all `uses:` references, configure Dependabot, and run the protection script as soon as the repository has a live required check.
- `workflows/feature-delivery-harness.md` — required-checks table and Merge Approval runbook
- `branching-strategy.md` — docs-only exemption scope

## Constraints and non-negotiables

- Admin enforcement is on. There is no bypass, including for the maintainer.
- The script (`scripts/set-branch-protection.ps1`) is the canonical way to apply and re-apply protection. One-off UI clicks are not acceptable because re-applying to a new repository must be a command, not a memory exercise.
- The Enforced column in the required-checks table must match what `gh api .../branches/main/protection` actually returns at the time of the commit. It is not aspirational.

## Supersedes / Superseded By

None.
