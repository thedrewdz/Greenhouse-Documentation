# QA Evaluation

Run a QA-focused evaluation pass on implemented features to validate scenario behavior, resilience, and acceptance criteria.

## QA Evaluation Scope

- Scope is defined by the accepted `spec.md` and dossier acceptance criteria.
- Include core happy-path behavior.
- Include negative-path and degraded-state behavior.
- Include recovery behavior where the feature requires it.

## Evaluation Method

1. Map feature to acceptance criteria in specs and spec dossiers.
2. Execute happy-path and negative-path scenarios.
3. Validate expected user-visible states and recovery actions.
4. Record mismatches between docs and implementation behavior.
5. Classify issues by severity and reproducibility.

## Output Format

- Scenario checklist with pass/fail per item.
- Defect list with severity, repro steps, expected vs actual behavior.
- Spec mismatch list for documentation feedback.
- Release recommendation: go, conditional-go, or no-go.

## Feedback Loop Requirement

When QA finds repeated ambiguity across scenarios:

- Propose updates to specs and spec dossiers.
- Route issues to documentation agent for clarification.
- Re-run QA checks after docs and code are updated.
