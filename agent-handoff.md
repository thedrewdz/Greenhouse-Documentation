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

### Session Addendum (Spec Artifact Promotion Flow)

- Date: 2026-06-03
- Owner: Copilot session
- Goal: Ensure all agent skills produce template-based spec artifacts in implementation repos and close the loop into durable docs without split ownership.
- Completed:
	- Standardized non-documentation agent output location to `.agent-output/specs/<spec-name>/`.
	- Updated role and skill contracts so implementation, test, code-review, and QA stages generate template-shaped artifacts in local implementation repos.
	- Added missing lifecycle templates for this flow:
		- `templates/test-gap-report.md`
		- `templates/promotion-log.md`
	- Consolidated artifact promotion ownership into Retrospective Agent.
	- Removed separate Review Agent role/skill to eliminate overlap.
	- Updated workflow so Retrospective stage includes artifact promotion from `.agent-output/specs/<spec-name>/` into `specs/<spec-name>/`.
	- Clarified Retrospective Agent may update other existing docs within `specs/<spec-name>/` as needed to keep dossier consistency.
	- Updated repo indexes and references to remove `review-agent` links and align with consolidated ownership.
- Blockers: none.
- Next actions:
	- Optional: tighten `roles/code-review-agent.md` wording to explicitly state no artifact-promotion responsibility.
	- Optional: add a concise promotion checklist to `AGENTS.md` so the contract appears in the highest-precedence policy file.

### Session Addendum (Spec Status Lifecycle and Stage Gates)

- Date: 2026-06-03
- Owner: Copilot session
- Goal: Add explicit spec lifecycle status tracking and enforce stage-entry gating so agents only execute when handoff readiness is met.
- Completed:
	- Added Spec Control section to `templates/spec.md` with:
		- status field
		- status metadata (`updated at`, `updated by`, `reason`)
		- allowed status values
		- transition rules
		- status history log format
	- Defined canonical statuses:
		- `new`
		- `ready-for-implementation`
		- `implementation-in-progress`
		- `ready-for-test`
		- `test-in-progress`
		- `ready-for-review`
		- `review-in-progress`
		- `ready-for-qa`
		- `qa-in-progress`
		- `complete`
		- `blocked`
	- Updated role skills to enforce status entry gates and explicit status transitions:
		- `skills/documentation-agent-skill.md`
		- `skills/implementation-agent-skill.md`
		- `skills/test-agent-skill.md`
		- `skills/code-review-agent-skill.md`
		- `skills/qa-agent-skill.md`
		- `skills/retrospective-agent-skill.md`
	- Added canonical lifecycle and per-stage entry/exit status rules to `workflows/feature-delivery-harness.md`.
	- Updated index-level reminders in:
		- `skills/README.md`
		- `specs/README.md`
	- Explicitly enforced implementation-stage behavior:
		- implementation must stop with handoff failure when spec status is not `ready-for-implementation` (or `implementation-in-progress` for resumed work), including when status is `new`.
- Blockers: none.
- Next actions:
	- Optional: add a short status decision matrix to `roles/*.md` files for quick operator reference.
	- Optional: seed one live dossier under `specs/<spec-name>/spec.md` with the new Spec Control section as an example migration.

### Session Addendum (UI-Independent Backend and Onboarding API)

- Date: 2026-06-10
- Owner: Codex documentation session
- Goal: Clarify that the Main Unit backend runs independently from the web UI and that the UI is a thin Blazor client over backend REST APIs.
- Completed:
	- Updated architecture docs to require a headless-capable Main Unit runtime that can maintain state, process MQTT, dispatch commands, and expose backend APIs without the web UI running.
	- Split UI and backend responsibilities:
		- `Greenhouse.Runtime` owns long-lived runtime services.
		- `Greenhouse.Api` exposes backend REST API endpoints.
		- `Greenhouse.UI` is a thin Blazor dashboard that calls backend APIs and does not host API endpoints or lifecycle-critical services.
	- Documented REST expectations for UI-facing calls:
		- requests are stateless
		- repeated mutating calls must not duplicate backend work
		- backend services may be stateful, but state is exposed as backend-owned resources
	- Added `IMessagingService` as the generic, message-content-agnostic runtime messaging abstraction.
	- Refactored Edge Unit onboarding documentation so the backend owns BLE scan, discovered-device candidates, selected-device handoff, provisioning, heartbeat wait, timeout, cancellation, and completion.
	- Simplified onboarding API examples away from session identifiers:
		- `GET /api/onboarding`
		- `POST /api/onboarding/scan`
		- `POST /api/onboarding/{device_id}/start`
		- `POST /api/onboarding/{device_id}/provision`
		- `POST /api/onboarding/{device_id}/cancel`
	- Preserved Edge Unit credential persistence behavior: accepted provisioning values are persisted after valid BLE payload acceptance.
- Blockers: none.
- Next actions:
	- Decide whether a socket-based read channel is needed after the polling-based Phase 1 API is implemented.
	- When implementation begins, ensure UI code does not reference backend implementation projects, BLE adapters, MQTT adapters, repositories, or application services directly.

## Template

Use this structure for future session entries:

- Date:
- Owner:
- Goal:
- In-progress work:
- Blockers:
- Next actions:


