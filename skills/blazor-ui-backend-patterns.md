# Skill: Blazor UI and Backend Patterns

## Purpose

Guide agents to build appliance-style Main Unit UI flows with clean backend interaction patterns.

## Use This Skill When

- Implementing setup, dashboard, onboarding, or recovery pages.
- Designing component-to-service interactions in Blazor Server.
- Improving validation, error handling, and loading states.

## UI Rules

- Keep components focused on rendering, input capture, and user feedback.
- Use service calls for workflows and state transitions.
- Prefer explicit status states: idle, validating, connecting, failed, complete.
- Use clear retry paths for network and onboarding operations.

## Backend Interaction Rules

- Validate inputs before starting network or persistence operations.
- Disable CTA buttons during in-flight operations.
- Return actionable error messages from services to UI.
- Keep cancellation token support for long-running operations.

## Quality Gate

- No transport or database code in Razor components.
- Setup and Edge Unit onboarding flows remain separated.
- UI remains usable on a touch-first 1024x600 target.

