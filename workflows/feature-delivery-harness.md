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

## Merge Approval

A pull request is **approved**, and may be merged, when both hold:

1. **Checks are green.** Every required status check on the head commit has concluded successfully. A repository with no checks cannot satisfy this condition — see the table below.
2. **An independent review verdict is recorded**, naming the reviewing actor and the exact commit SHA reviewed, where that actor did not author the commits under review.

GitHub does not permit the author of a pull request to approve it. Where the reviewing pass runs under the same GitHub account as the authoring pass, record the verdict as a pull request comment in this form instead of a GitHub approval — the comment is the audit record:

```text
Review verdict: approved
Reviewed commit: <sha>
Reviewing pass: <stage-4 session or actor identifier>
Blocking findings: none
```

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
- After review completion, decide if the active pull request is safe to merge to `main`.
- If not safe, emit concrete implementation feedback and do not merge.
- If safe, record the review verdict as defined in [Merge Approval](#merge-approval), then first sync the latest `main` into the branch and resolve conflicts (so `main` is never merged from a stale branch), then merge the pull request to `main`.
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
- Entry gate execution status: `ready-for-qa` or `qa-in-progress`.
- Exit execution status: `complete` on `Go`; `ready-for-implementation` on `Conditional-Go` or `No-Go` when remaining issues are fixable in implementation; `blocked` only when QA cannot safely continue because docs, prerequisites, or process state are unresolved.

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
- If the spec is marked `complete`, confirm implementation was delivered via pull request and merged to the implementation repository `main` branch.
- If PR linkage or merge-to-main confirmation is missing, set status to `blocked` with explicit follow-up.
- Entry gate execution status: `complete` or `blocked`.
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
