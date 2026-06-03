# Spec: Empty Dashboard

## Purpose and Scope

Define the dashboard state shown when the Main Unit is configured but no Edge Units or automation rules are present yet.

This spec replaces the former empty dashboard journey document.

## Preconditions and Assumptions

- General configuration already exists.
- The Main Unit can load the normal dashboard.
- No Edge Units have been registered yet.
- No automation rules have been created yet.
- The dashboard should remain useful even before Edge Units are connected.

## Behavior and Workflow

- Show the normal dashboard shell with an empty Edge Units section.
- Reserve the area where connected Edge Units will appear later.
- Explain that no Edge Units are connected yet.
- Prompt the user to onboard an Edge Unit.
- Do not present the empty state as an error.
- Show an empty rules state rather than hiding the section entirely.
- Reserve the area where automation rules will appear later.
- Explain that rules can be created after Edge Units are available.
- Do not ask the user to create rules before any Edge Units exist.

Suggested message:

```text
Onboard an Edge Unit to unlock telemetry, control, and automation.
```

## Acceptance Criteria

- The dashboard does not feel broken or unfinished when no Edge Units are connected.
- The user can see where connected units and rules will appear later.
- The user is prompted to onboard an Edge Unit.
- The dashboard avoids actions that cannot be completed until Edge Units exist.

## Deferred Work

- Edge Unit onboarding and reconfiguration.
- Creating automation rules.
- Viewing live telemetry from connected units.