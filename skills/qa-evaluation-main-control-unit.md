# Skill: Main Unit QA Evaluation

## Purpose

Run a QA-focused evaluation pass on implemented features to validate user-flow behavior, resilience, and acceptance criteria.

## Use This Skill When

- A feature is implemented and ready for scenario validation.
- You need a release-readiness check beyond unit and integration tests.
- You want a fourth-agent QA pass in the feedback loop.

## QA Evaluation Scope

- Main Unit setup flow behavior.
- Network recovery behavior.
- Edge Unit onboarding and reconfiguration routing behavior.
- Dashboard empty states and runtime status handling.
- MQTT offline and reconnect resilience from user perspective.

## Evaluation Method

1. Map feature to acceptance criteria in journeys/specs.
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

- Propose updates to journeys/specs.
- Route issues to documentation agent for clarification.
- Re-run QA checks after docs and code are updated.

