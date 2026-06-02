# Empty Dashboard User Journey

## Goal

When the Main Unit is configured but no Edge Units are connected yet, show a useful dashboard state that explains why the system has limited functionality and points the user toward onboarding an Edge Unit.

## Pre-Conditions/Assumptions

- General configuration already exists.
- The Main Unit can load the normal dashboard.
- No sensor Edge Unit, actuator Edge Unit, or hybrid Edge Units have been registered.
- No automation rules have been created.
- The dashboard should remain useful even before Edge Units are connected.

## Journey

**Given** the Main Unit has completed setup.
**When** the dashboard loads and no Edge Units are registered.
**Then** show the normal dashboard shell with an empty Edge Units section.

The empty Edge Units section should:

- Reserve the area where connected Edge Units will appear later.
- Explain that no Edge Units are connected yet.
- Prompt the user to onboard an Edge Unit.
- Avoid presenting this as an error condition.

Suggested message:

```text
Onboard an Edge Unit to unlock telemetry, control, and automation.
```

**Given** the dashboard loads and no automation rules exist.
**When** the dashboard displays the rules section.
**Then** show an empty rules state rather than hiding the section entirely.

The empty rules section should:

- Reserve the area where automation rules will appear later.
- Explain that rules can be created after Edge Units are available.
- Avoid asking the user to create rules before any Edge Units exist.

## Success Criteria

- The dashboard does not feel broken or unfinished when no Edge Units are connected.
- The user can see where connected units and rules will appear later.
- The user is prompted to onboard an Edge Unit.
- The dashboard avoids actions that cannot be completed until Edge Units exist.

## Deferred Journeys

- Edge Unit onboarding and reconfiguration (see `04-Edge Unit Onboarding and Reconfiguration.md`).
- Creating automation rules.
- Viewing live telemetry from connected units.


