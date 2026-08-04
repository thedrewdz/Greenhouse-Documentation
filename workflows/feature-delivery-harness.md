# Feature Delivery Harness

Use this workflow for all non-trivial feature work.

## Core Rules

- Follow [branching-strategy.md](../branching-strategy.md): all feature work happens on a short-lived `<type>/<descriptor>` branch off `main` and merges back via a reviewed pull request only once complete and working. Never commit feature work directly to `main`. (Documentation-only changes are exempt and may be committed directly to `main` — see branching-strategy.md.)
- Use spec dossiers in `specs/<spec-name>/` as the durable source of truth for feature-level work.
- Each dossier must contain `spec.md` at minimum.
- In implementation repositories, all non-documentation artifact generation must go to `.agent-output/specs/<spec-name>/`.
- Only Documentation Agent and Retrospective Agent may write directly to this docs repository.
- If a stage discovers ambiguity, create a documentation feedback item and route it back to documentation before continuing.
- Do not silently change contracts in implementation repos.
- Track canonical milestone status in this docs repo at `specs/<spec-name>/status.md`.
- Track execution lifecycle status in implementation repos at `.agent-output/specs/<spec-name>/spec-status.md`.
- Every stage owner must enforce status entry gates before proceeding.
- Every stage must check `.agent-output/specs/<spec-name>/` before commencing.
- Pull latest changes before each stage starts.
- Resolve merge conflicts before stage work begins.
- Stop only if conflicts cannot be resolved safely.
- If an expected output artifact is not required for a stage, create the file anyway with `Not required` and a reason.
- Until an orchestration agent exists, a human or caller advances each stage by invoking the next role after verifying the current status and artifacts.
- Stage reports and `doc-feedback.md` are append-only across repeated implementation loops unless a template explicitly says otherwise.
- A pass that raises a review finding does not fix it — see [Review and Fix Separation](#review-and-fix-separation).
- A pull request may only be merged once approved as defined in [Merge Approval](#merge-approval).
- Stage 2 raises the pull request; **only Stage 6 merges it to `main`**, and only Stage 6 sets a board item to **Done** — see [Pull Request Ownership](#pull-request-ownership).

## Review and Fix Separation

**The harness governs: the pass that raises a finding is never the pass that fixes it.**

This rule exists because the alternative was tried and failed twice in one epic. Greenhouse-Services epic #25 fixed five blocking review findings in the same session that raised them; an independent pass over those fixes then found three further defects in them (#51, #52, #53), including a fix asserted as correct in three places that was disproved by a ten-line probe. A pass cannot reliably review its own reasoning.

Rules:

- Stage 4 raises findings and routes them to `ready-for-implementation`. It does not edit code (see Stage 4 Rules).
- Fixes are a fresh Stage 2 pass **by a different actor than the one that raised the findings**. In a single-maintainer setup, "different actor" means a separate session that reads the filed findings rather than carrying over the reviewing pass's working context.
- Fixes re-enter the loop at Stage 3 (Test) and then Stage 4 (Review), as the existing loopbacks already state.
- **The loop terminates when a Stage 4 pass produces no new blocking findings.** A review that only confirms prior fixes is an exit, not another round. Re-reviewing fixes does not oblige a further round unless it finds something new.
- Findings are still filed as issues the moment they are found. Only the *fixing* moves to a separate pass.

This supersedes any working preference to file and fix a finding in the same session.

## Pull Request Ownership

Each pull request transition has **exactly one owning stage**. A transition performed by any other stage is a process defect, even when the outcome looks correct.

| Transition | Owning stage | Every other stage |
|---|---|---|
| Raise the pull request | Stage 2 (Implementation) | Does not create one; may update the description of an existing one |
| Merge the pull request to `main` | Stage 6 (Retrospective) | Never merges |
| Set the board item to **Done** | Stage 6 (Retrospective) | Never sets **Done** |

Stages 3 (Test), 4 (Review), and 5 (QA) have exactly two terminal board transitions between them:

- **In Review** when the stage passes and the work moves on. A Stage 5 `qa-deferred` outcome also rests here — it holds at **In Review** rather than advancing (see [Deferred validation](#deferred-validation)).
- **Ready For Dev** when findings are fixable in code or tests.

None of the three merges, and none of them closes. This exists because both transitions previously had two claimed owners: Stage 4 merged to `main` while Stage 6 also merged, and Stage 5 set **Done** on a `Go` verdict before any merge had happened. The consequences were a task reaching **Done** with its branch unmerged, and a merge at Stage 4 that skipped Stage 6 entirely — losing artifact promotion and every guardrail update the retrospective would have produced.

### Raising or merging a pull request is not `git pull`

These are different operations and the rule above constrains only the first:

- **Raising** a pull request (`gh pr create`) and **merging** one (`gh pr merge`) are the owned transitions in the table.
- **Pulling the task branch** (`git fetch` / `git pull --ff-only` on the feature branch) is not a pull request operation at all. **Every stage must still do it** before starting work, as each stage's Rules require. Nothing in this section restricts it.

A stage that reads "does not merge the pull request" as "does not pull the branch" will work from stale code. A stage that reads "pull the latest branch" as licence to merge will bypass Stage 6.

## Defect Sub-Issue Gates

Defect sub-issues gate two different transitions, and **"open" is the wrong test for the earlier one**. A defect sub-issue closes when the pull request merges, not when the fix lands on the branch — so between the fix and the merge, every defect sub-issue is simultaneously open and fixed.

Use these tests:

| Transition | Test | Owner |
|---|---|---|
| **Ready For Dev** (send the work back) | A defect sub-issue is open **and unfixed** — no fix commit on the branch, or its acceptance criteria are not met | Stages 3, 4, 5 |
| **In Review** (the work moves on) | Every defect sub-issue is either closed, or fixed on the branch with its acceptance criteria met and awaiting merge | Stages 3, 4, 5 |
| **Done** | Every sub-issue is actually closed, which the merge does | Stage 6 only |

Gating **Ready For Dev** on openness alone is a loop with no exit: the sub-issue cannot close before the pull request merges, the merge cannot happen while the parent sits at **Ready For Dev**, so the parent can never reach **In Review** however many times the work is done correctly. Traceable to Greenhouse-Services#72, whose defect sub-issue #82 was fixed, un-skipped and passing while still open, and whose second test pass had to make an undocumented judgement call to advance it at all.

The **Done** gate keeps its existing query, which is correct because Done genuinely does come after merge:

```bash
gh api repos/thedrewdz/<repo>/issues/<issue-number>/sub_issues \
  --jq '[.[] | select(.state=="open")] | length'
# Must return 0 before Stage 6 advances the item to Done.
```

A stage that cannot determine whether an open sub-issue is fixed states that on the issue and holds at its current status. It does not guess in either direction.

## Defect Intake and Promotion

**A well-formed defect report is already groomed.** It does not need `ba-po` discovery or grooming to become actionable, and requiring that would send a bug with a verified root cause, a reproduction, and written acceptance criteria back through a phase that could not change any of them.

A defect is **groomed** when its report carries all three:

1. Reproduction steps, or the observed failure with enough context to reproduce it.
2. The root cause, or the specific symptom and the code path it occurs on.
3. Testable acceptance criteria — what must be true for the fix to be accepted.

Routing:

- **Defect found under a parent task** — file it as a sub-issue, attach it to the parent, and return the **parent** to **Ready For Dev**. Unchanged.
- **Defect found with no parent task** — file it as a standalone issue. The stage that files it sets it to **Ready For Dev** directly if it meets the three-point bar above.
- **Defect that does not meet the bar** — leave it at **Todo** and state on the issue exactly which of the three is missing.
- **Defect that meets the bar but is blocked on an upstream decision** — hold it and declare the blocker, as below. Meeting the bar means the defect is *understood*; it does not mean it is *actionable*.

The three-point bar tests whether the report is complete. It cannot detect the second reason a defect waits, so both must be checked.

This closes a gap where a standalone defect was boarded at **Todo** by the add-to-project workflow with no owner able to promote it: Stage 2 refuses any item that is not **Ready For Dev**, `ba-po` Phase 2 was the only exit to that status, and `board-triage` is forbidden from bypassing a lifecycle gate another skill owns. Traceable to Greenhouse-Services#72, which sat at **Todo** with full reproduction, root cause, and four acceptance criteria, and was only implemented on an explicit instruction that crossed the gate.

Promotion asserts the report is complete, not that the fix is approved. Stage 2 still owns whether the work is done.

### Declaring a blocking decision

A defect can be perfectly reported and still un-actionable, because the fix needs a contract, spec, or ADR decision that an implementation pass is forbidden to make. Promoting it anyway sends that pass into a guaranteed stop: `implementation` must halt on a documentation hole, file a docs issue, and return the item to **Todo** — the same place, one round trip later.

**Declare the dependency as structured text in both issue bodies.** Not in a comment, and not as prose.

On the **defect**, one line per blocker:

```text
Blocked by: thedrewdz/Greenhouse-Documentation#52
```

On the **decision**, one line per defect it unblocks:

```text
Blocks: thedrewdz/Greenhouse-Services#73
```

Both directions are recorded so the relationship is discoverable from either end without a cross-repository join. Use the fully qualified `owner/repo#number` form — these edges routinely cross repositories, and a bare `#52` resolves to the wrong repository when read from anywhere else.

Rules:

- **Bodies, not comments.** A body is edited when the state changes, so it always shows the current answer. A comment thread is append-only, and the reader has to reconstruct the current state from its whole history.
- **Do not use GitHub sub-issue links for this.** They already carry a different relationship — a defect belonging to a parent delivery task — which [Defect Sub-Issue Gates](#defect-sub-issue-gates) reads to choose between **Ready For Dev** and **In Review**. Overloading them would corrupt a gate that works.
- **Name the decision, not the topic.** `Blocked by:` must resolve to an issue that can close. A topic cannot be queried and cannot close: `Blocked by: Edge Unit management list spec.` — the real form in Greenhouse-Documentation#21 and #23 — names something no tool can follow, and is the failure this convention exists to stop. The same line as `Blocked by: thedrewdz/Greenhouse-Documentation#12` is resolvable.
- **File the decision if it does not exist yet.** A blocker with no issue is not a declaration.
- A pass that closes a decision issue should run the query below and promote what it unblocks. Whether that is an enforced gate, and who owns it, is being decided in Greenhouse-Documentation#57.

#### Finding blocked items

**Do not use `gh search issues` for this.** GitHub's issue search tokenizes the query and does not honour the phrase, so it returns items that do not contain the line at all — verified 2026-08-04: both `gh search issues "Blocked by:"` and `gh search issues 'in:body "Blocked by"'` returned issues with no such line, including ones whose only connection was the word "by". A gate built on it would read as satisfied while missing real dependencies.

Filter locally on a line match instead. **The pattern must tolerate Markdown emphasis around the label** — see the warning below:

```powershell
# Every open item declaring a blocker, across the governed repositories
$repos = 'Greenhouse-Documentation','Greenhouse-Services','Greenhouse-WebUI',
         'Greenhouse-Firmware','Greenhouse-Peripherals'
$label = '(?m)^\s*(?:[*_]{1,2})?Blocked by:?(?:[*_]{1,2})?\s*\S+'
foreach ($repo in $repos) {
  $issues = gh issue list -R "thedrewdz/$repo" --state open --limit 300 `
    --json number,title,body | ConvertFrom-Json
  $issues | Where-Object { $_.body -match $label } |
    ForEach-Object { "$repo#$($_.number)  $($_.title)" }
}
```

```powershell
# Which items does closing <n> unblock? Run before closing a decision issue.
$blocker = [regex]::Escape('thedrewdz/Greenhouse-Documentation#<n>')
$pattern = "(?m)^\s*(?:[*_]{1,2})?Blocked by:?(?:[*_]{1,2})?\s*$blocker"
foreach ($repo in $repos) {
  $issues = gh issue list -R "thedrewdz/$repo" --state open --limit 300 `
    --json number,title,body | ConvertFrom-Json
  $issues | Where-Object { $_.body -match $pattern } |
    ForEach-Object { "$repo#$($_.number)  $($_.title)" }
}
```

**Write the label as plain `Blocked by:` with no emphasis.** A bolded `**Blocked by:**` is the same
declaration to a human and a different string to a matcher, and the first version of this query — anchored
on a bare `^\s*Blocked by:` — silently missed Greenhouse-Documentation#13 and #15 for exactly that reason
while finding their unbolded twins. The pattern above tolerates emphasis because an author cannot be relied
on to omit it, but do not depend on that tolerance: a query that misses a dependency reports "nothing is
blocked" and is worse than no query at all.

Raise `--limit` if a repository ever exceeds 300 open issues; `gh` truncates silently rather than warning.

This exists because the relationship was previously prose. Four defects blocked on four decisions were promoted on 2026-08-04 only because one session closed the decisions and promoted the dependents in the same pass; the link lived nowhere but that session's comments. A promotion that works only when one actor holds both halves in context is not a process (Greenhouse-Documentation#55).

The convention is not defect-specific. Any item may declare a blocker — a spec task waiting on another spec has the same problem, and #21 and #23 are the proof.

Where a blocked defect **sits** on the board while it waits is a separate open question — Greenhouse-Documentation#56, since **Todo** currently also means "not looked at" and "report incomplete".

## Merge Approval

A pull request is **approved**, and may be merged, when one condition holds:

**Required checks are green.** Every required status check on the head commit has concluded successfully. A repository with no checks cannot satisfy this condition — see the table below.

That is the whole gate. There is no independent-reviewer condition.

### Why there is no reviewer condition

The gate previously also required "an independent review verdict, naming the reviewing actor and the exact commit SHA reviewed, where that actor did not author the commits under review". It is removed because on a single-maintainer project it could not be satisfied honestly and blocked delivery either way:

- Every pass runs under the same maintainer. The only way to clear the condition was to switch accounts, which cleared it *mechanically* — Greenhouse-Services PR #64 was cleared by an `APPROVED` review with an empty body, carrying no findings, no scope, and no statement of what was examined. The record could not be audited even in principle.
- Where account switching was not used, the condition was unsatisfiable, so Stage 6 could never run and no task could reach **Done**.

The honest position is that this project's merges are **maintainer-authorised and check-gated**, not independently reviewed. The harness says so plainly rather than performing independence it cannot supply.

Review has not been weakened, because review was never the merge gate's job:

- Stage 4 still runs, and its blocking findings still return the work to `ready-for-implementation`. A pull request with unresolved blocking findings is not mergeable, because the task is not at a status Stage 6 will act on.
- [Review and Fix Separation](#review-and-fix-separation) still holds: the pass that raises a finding is not the pass that fixes it. That rule governs *who fixes*, and is unaffected by removing the merge-time verdict.

A review pass records its findings on the issue and the pull request as normal prose. No mandated verdict block, vocabulary, or SHA-scoped approval record is required.

### Who merges

Only **Stage 6 (Retrospective)** merges a pull request to `main`. See [Pull Request Ownership](#pull-request-ownership).

Required checks per governed repository:

| Repository | Required checks | State |
|---|---|---|
| `Greenhouse-Documentation` | none — documentation-only changes are exempt from pull request entirely (see branching-strategy.md) | n/a |
| `Greenhouse-Services` | `build-and-test` — `dotnet build` + `dotnet test` | present |
| `Greenhouse-Firmware` | `standards-guard` | present |
| `Greenhouse-WebUI` | `flutter analyze` + `flutter test` | **absent — tracked as Greenhouse-WebUI#24, must exist before the repo's first pull request** |
| `Greenhouse-Peripherals` | sketch compilation | **absent — tracked as Greenhouse-Peripherals#2** |

A repository whose required check is absent is **not exempt**; it is blocked from merging until the check exists. Do not work around a missing check by declaring the condition satisfied.

## Canonical Spec Status Lifecycle

Tracked in `specs/<spec-name>/status.md`.

Statuses:

- `new`
- `ready-for-dev`
- `in-dev`
- `complete`
- `blocked`

Primary flow:

- `new` -> `ready-for-dev` -> `in-dev` -> `complete`

Loopbacks:

- Fixable implementation, test, review, or QA failures: return execution status to `ready-for-implementation`
- QA validation that no implementation pass can clear (no hardware, no device, no physical access): `qa-deferred` — see [Deferred validation](#deferred-validation). This is not a loopback; it moves forward to Stage 6 carrying an explicit debt.
- True unresolved prerequisites, contradictory docs, missing decisions, unsafe merge state, or process blockers: `*` -> `blocked`
- Retrospective unblock for doc follow-up: `blocked` -> `new`

Execution lifecycle states remain in `.agent-output/specs/<spec-name>/spec-status.md`.

## Stage 1: Documentation and Planning

Role: Documentation Agent

Inputs:

- User request
- `CONTEXT.md`
- Relevant architecture, spec dossiers, and ADR files

Outputs:

- New or updated `spec.md`
- New or updated `specs/<spec-name>/status.md`
- Acceptance criteria
- Open questions
- Implementation handoff summary
- Durable dossier updates in `specs/<spec-name>/` using templates

Exit criteria:

- The next implementation step is clear enough for a coding agent to act without inventing missing behavior.
- Canonical status in `specs/<spec-name>/status.md` is `ready-for-dev` for accepted work, otherwise `new` or `blocked` with reason.

## Stage 2: Implementation

Role: Implementation Agent

Inputs:

- Accepted `spec.md`
- `AGENTS.md` from the target implementation repo
- Relevant skills

Outputs:

- Code changes
- Tests added or updated with the implementation
- Local verification results
- Deviations from spec and documentation feedback items
- `.agent-output/specs/<spec-name>/implementation-plan.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`
- `.agent-output/specs/<spec-name>/spec-status.md`

Rules:

- Implement only documented behavior.
- Do not redefine glossary terms, contracts, or ADR decisions in code.
- If docs are incomplete or contradictory, log a documentation feedback item.
- If prior test, review, or QA artifacts exist, resolve their actionable implementation feedback before adding unrelated work.
- Pull latest `main` into the current working branch before implementation work.
- Resolve merge conflicts before commencing spec work.
- Stop only if merge conflicts cannot be resolved safely.
- Entry gate execution status: `ready-for-implementation` or `implementation-in-progress`.
- Exit execution status on pass: `ready-for-test`.
- Canonical docs status should remain `ready-for-dev` unless Documentation or Retrospective updates it.

## Stage 3: Test Pass

Role: Test Agent

Inputs:

- `spec.md`
- Code diff
- Existing tests

Outputs:

- Test gap report
- Added or updated tests
- Remaining untested risks
- `.agent-output/specs/<spec-name>/test-gap-report.md`
- `.agent-output/specs/<spec-name>/spec-status.md`

Rules:

- Prefer behavior-focused tests over implementation-detail tests.
- Include negative-path and degraded-state tests where relevant.
- Treat missing or failing tests caused by fixable code behavior as implementation feedback, not a workflow blocker.
- Treat contradictory acceptance criteria, missing expected behavior, or impossible verification setup as `blocked` with a documentation feedback item.
- Use branch from `.agent-output/specs/<spec-name>/implementation-plan.md` as source context.
- Pull the latest task branch before testing. **Do not merge the pull request** and do not set the board item to **Done** — Stage 6 owns both (see [Pull Request Ownership](#pull-request-ownership)).
- Commit and push outputs when complete so downstream stages can consume artifacts.
- Entry gate execution status: `ready-for-test` or `test-in-progress`.
- Exit execution status on pass: `ready-for-review`; on fixable test failure or coverage gap: `ready-for-implementation`; on true documentation/process blocker: `blocked`.

## Stage 4: Code Review Gate

Role: Code Review Agent

Inputs:

- `spec.md`
- Code diff
- Test results
- Relevant skills

Outputs:

- Blocking findings
- Non-blocking findings
- Architecture boundary concerns
- Documentation feedback items
- `.agent-output/specs/<spec-name>/review-report.md`
- `.agent-output/specs/<spec-name>/doc-feedback.md`
- `.agent-output/specs/<spec-name>/spec-status.md`

Rules:

- Do not fix code during review. Raise the finding, file it, and route it to `ready-for-implementation` for a separate pass — see [Review and Fix Separation](#review-and-fix-separation). This holds even when the fix is obvious and even when the caller asks for speed.
- Every repeated or systemic issue must become a documentation or skill feedback item.
- Treat architecture boundary never events as blocking.
- Require a guardrail update action for every blocking boundary finding.
- **This stage does not merge the pull request** and does not set the board item to **Done** — Stage 6 owns both (see [Pull Request Ownership](#pull-request-ownership)). It still pulls the latest task branch before reviewing.
- On blocking findings: file them, comment concrete implementation feedback on the issue, and set the board item to **Ready For Dev**.
- On no blocking findings: record that outcome on the issue as prose and set the board item to **In Review**. No mandated verdict block or approval record is required — see [Merge Approval](#merge-approval).
- When this pass is reviewing fixes to its own earlier findings, it is an exit as soon as it finds nothing new that blocks. Do not manufacture another round.
- Entry gate execution status: `ready-for-review` or `review-in-progress`.
- Exit execution status: `ready-for-qa` when no blocking findings; `ready-for-implementation` when findings are fixable in code or tests; `blocked` only for true documentation/process blockers that cannot be resolved by implementation.

## Stage 5: QA Evaluation

Role: QA Agent

Inputs:

- `spec.md` and its acceptance criteria
- Running behavior or a testable implementation

Outputs:

- Scenario checklist
- Defects
- Spec mismatches
- Release recommendation
- `.agent-output/specs/<spec-name>/qa-report.md`
- `.agent-output/specs/<spec-name>/spec-status.md`

Rules:

- Validate user-visible behavior against acceptance criteria.
- Record doc mismatches as documentation feedback items.
- Treat reproducible defects or acceptance mismatches that can be fixed in code as implementation feedback.
- Treat ambiguous acceptance criteria, missing environment prerequisites, or contradictory docs as `blocked` with a documentation feedback item.
- Pull the latest task branch before validating. **Do not merge the pull request** and **do not set the board item to Done** — Stage 6 owns both (see [Pull Request Ownership](#pull-request-ownership)). A passing `Go` sets the board item to **In Review**.
- A `Go` may not be recorded when the feature spans a process boundary and live cross-process integration was not exercised. That case is a `Conditional-Go` with the deferral named — see Deferred validation below.
- Entry gate execution status: `ready-for-qa` or `qa-in-progress`.
- Exit execution status: `complete` on `Go`; `ready-for-implementation` on `Conditional-Go` or `No-Go` when remaining issues are fixable in implementation; `qa-deferred` on a `Conditional-Go` whose condition is not fixable in software; `blocked` only when QA cannot safely continue because docs, prerequisites, or process state are unresolved.

### Deferred validation

A `Conditional-Go` has two shapes, and only one of them is remediable by a developer:

- **Software-fixable** — a defect, a gap, an acceptance mismatch. Exit `ready-for-implementation`, board item to **Ready For Dev**.
- **Not software-fixable** — the code is complete and its criteria are met, but a validation step could not be performed for a reason no implementation pass can clear: no hardware, no device, no physical access. Exit `qa-deferred`, and the board item **holds at In Review**.

For a `qa-deferred` outcome:

- File or link a tracking issue naming the exact blocking prerequisite and the validation still owed. That issue is the record; a comment alone does not satisfy this.
- Never regress the board item to **Ready For Dev**. There is no software work outstanding, and doing so misreports finished work as unfinished and queues it for a developer who cannot clear it.
- Never present the outcome as a pass. Stand-in coverage is named as a stand-in, with the behavior of the real dependency that remains unverified stated explicitly.
- Stage 6 may proceed on a `qa-deferred` item, but its retrospective must record the deferral and the tracking issue. Closing the delivery does not close the owed validation.

## Stage 6: Retrospective and Artifact Promotion

Role: Retrospective Agent

Inputs:

- Review findings
- QA findings
- Implementation deviations
- Test findings
- Documentation feedback items

Outputs:

- `.agent-output/specs/<spec-name>/retrospective.md`
- Guardrail update proposals
- Promoted artifacts copied into `specs/<spec-name>/` in this docs repository
- `specs/<spec-name>/promotion-log.md`

Rules:

- Do not add vague rules.
- Add only reusable guidance that would have prevented or reduced the issue.
- For every systemic or repeated boundary failure, include at least one concrete guardrail proposal.
- Review all retained artifacts from every implementation loop, not only the final pass.
- Consolidate append-only documentation feedback before deciding which docs, skills, templates, or workflow rules need durable updates.
- Record `promoted`, `rejected`, or `deferred` for each artifact candidate from `.agent-output/specs/<spec-name>/`.
- Promote only artifacts that conform to templates.
- Retrospective Agent may update other existing documents in `specs/<spec-name>/` to keep the dossier consistent after promotion.
- Find the implementation repository where work occurred, then import working documents from `.agent-output/specs/<spec-name>/` into this docs repository for promotion review.
- **This stage is the only owner of merge-to-`main` and of the Done transition** (see [Pull Request Ownership](#pull-request-ownership)). Confirm the pull request is approved as defined in [Merge Approval](#merge-approval) — required checks green — then sync the latest `main` into the branch and resolve conflicts, so `main` is never merged from a stale branch, then merge.
- Do not waive a missing required check. A repository whose check does not exist is blocked from merging until it does; file the missing check.
- If the item arrived at `qa-deferred`, record the deferral and its tracking issue in the retrospective before merging. The owed validation stays open after the delivery closes.
- If PR linkage or merge-to-main confirmation is missing, set status to `blocked` with explicit follow-up.
- Entry gate execution status: `complete`, `qa-deferred`, or `blocked`.
- Canonical docs status update on close: set `complete` when PR merge-to-main is confirmed; set `blocked` when unresolved blockers remain.
- Optional canonical status update: `blocked` -> `new` when blockers are converted into actionable documentation work.

## Stage 7: Durable Documentation Update

Role: Documentation Agent

Inputs:

- Promoted artifacts in `specs/<spec-name>/`
- `promotion-log.md`
- Accepted documentation feedback items

Outputs:

- Durable updates to specs, skills, templates, workflow docs, or ADR-linked guidance

Rules:

- Resolve promoted feedback into canonical docs in this repository.
- Update docs, skills, templates, or workflow rules when accepted feedback identifies a reusable gap.
- Keep terminology and contracts consistent with `CONTEXT.md` and ADRs.

## Recommended Dossier Artifacts

At minimum, each spec folder should include:

- `spec.md`

Recommended supporting artifacts as work progresses:

- `status.md` (in `specs/<spec-name>/`)
- `spec-status.md` (in `.agent-output/specs/<spec-name>/`)
- `implementation-plan.md`
- `test-gap-report.md`
- `review-report.md`
- `qa-report.md`
- `retrospective.md`
- `doc-feedback.md`
- `promotion-log.md`

Template scaffolding is provided in `templates/`.
