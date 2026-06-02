# User Journeys

This folder contains user journey stories for the Greenhouse Automation Platform.

Use these documents to describe how real users interact with the system across setup, monitoring, automation, maintenance, troubleshooting, and future expansion scenarios.

Current journeys:

- `01-Main Unit Setup.md`
- `02-Network Recovery.md`
- `03-Empty Dashboard.md`
- `04-Edge Unit Onboarding and Reconfiguration.md`

Detailed onboarding contract:

- `../specs/spec-edge-unit-onboarding-ble.md`

Terminology note:

- Use "setup" for Main Unit first-run flow.
- Use "onboarding/reconfiguration" for Edge Unit flows.
- Use "provisioning mode" for an unprovisioned Edge Unit advertising over BLE.

Suggested journey structure:

```text
# Journey: Short Descriptive Name

## User

Who is using the system?

## Goal

What outcome is the user trying to achieve?

## Context

What does the user already have, know, or need?

## Journey

1. User action.
2. System response.
3. User decision or next action.

## Success Criteria

What must be true when the journey is complete?

## Notes

Open questions, constraints, edge cases, or future considerations.
```


