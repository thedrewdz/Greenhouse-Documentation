# Spec Dossier Scaffold

Use this scaffold when creating a new spec dossier under `specs/<spec-name>/`.

For implementation repositories, mirror the same dossier shape under `.agent-output/specs/<spec-name>/`.

## Required

- `spec.md`
- `status.md` (from `templates/spec-canonical-status.md`)

## Recommended Lifecycle Files

- `implementation-plan.md`
- `test-gap-report.md`
- `review-report.md`
- `qa-report.md`
- `retrospective.md`
- `doc-feedback.md`
- `promotion-log.md`

## Quick Start

1. Create a folder at `specs/<spec-name>/` in the docs repository.
2. In implementation repositories, create `.agent-output/specs/<spec-name>/`.
3. Copy templates from this folder into the appropriate dossier location.
4. Start by filling `spec.md` first in the docs repository.
5. Create `status.md` and set initial status (`new` or `ready-for-dev`) before implementation handoff.
6. Add lifecycle files as each stage completes.

## Suggested Naming

- Use kebab-case folder names.
- Keep one feature per dossier folder.
- Keep contract-only specs in their own dedicated dossier folder.