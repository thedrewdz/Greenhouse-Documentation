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

### Session Addendum (Onboarding Happy Path)

- Date: 2026-06-03
- Owner: Copilot session
- Goal: Tighten minimum onboarding specs so Main Unit and Edge Unit can implement Phase 1 happy path with explicit failure handling.
- Completed:
	- Added canonical BLE onboarding error code set to `specs/edge-unit-onboarding/spec.md` and referenced it from `specs/edge-unit-configuration/spec.md`.
	- Defined Edge Unit bootstrap retry behavior with explicit timing defaults:
		- 5 total attempts per stage (WiFi and MQTT)
		- backoff delays `1s, 2s, 4s, 8s` with +/-20% jitter
		- re-enter BLE Provisioning Mode after fifth failed attempt
	- Clarified first-heartbeat behavior:
		- bootstrap heartbeat may be minimal for Phase 1 onboarding completion
		- full heartbeat fields required after onboarding
	- Clarified Main Unit completion/failure behavior:
		- onboarding complete on first valid heartbeat from selected `device_id`
		- persist that first valid heartbeat as current Edge Unit state
		- no auto-retry on timeout; user must explicitly retry
		- retry returns to onboarding view and restarts BLE scanning as a new session
	- Clarified Edge Unit does not require explicit Main Unit ACK in Phase 1; publish-success caveat documented.
- Blockers: none.
- Next actions:
	- Optionally pin explicit onboarding session timeout value in `specs/edge-unit-configuration/spec.md` if UI/backend teams need a single default.
	- Optionally add a lightweight future hardening note for wrong-broker detection (deferred; not required for happy path).

## Template

Use this structure for future session entries:

- Date:
- Owner:
- Goal:
- In-progress work:
- Blockers:
- Next actions:


