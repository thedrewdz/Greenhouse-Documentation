# Repository Session Handoff

This file is a maintainer-only scratchpad for this repository's own session state.

Do not treat this file as product documentation, architecture guidance, or agent policy.
Agents consuming documentation in this repo should not read this file.

For canonical guidance, use:

- AGENTS.md
- CONTEXT.md

## Current Session Notes

- Date: 2026-06-03
- Owner: Copilot session
- Goal: Reconcile moved embedded docs, fix incorrect references, and restore missing specs as source of truth in this docs repository.
- Completed:
	- Removed stale links to moved embedded skill docs and the moved onboarding ADR.
	- Removed all explicit references to greenhouse-edge repository naming/paths.
	- Removed dead references to deleted .NET-specific skill files from `README.md` and `skills/README.md`.
	- Restored missing spec files under `specs/`:
		- `specs/edge-unit-configuration/spec.md`
		- `specs/edge-unit-onboarding/spec.md`
	- Repaired index links in `README.md` and `specs/README.md` to point at existing spec files.
	- Validated repository markdown references with a full local-link scan (no broken links remaining).
- Blockers: none.
- Next actions:
	- If required, align remaining supplemental docs with current canonical-source policy while preserving spec ownership in this repo.

## Template

Use this structure for future session entries:

- Date:
- Owner:
- Goal:
- In-progress work:
- Blockers:
- Next actions:


