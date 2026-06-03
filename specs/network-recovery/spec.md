# Spec: Network Recovery

## Purpose and Scope

Define the recovery flow for a configured Main Unit that starts without a network connection.

This is not first-run setup. It is an operational recovery flow for an already configured Main Unit.

## Preconditions and Assumptions

- General configuration already exists.
- The Main Unit has a connected touch screen.
- The setup UI or dashboard is available locally, even while offline.
- The system can determine whether the Main Unit is currently connected to a network.
- The system can request a network connection using credentials supplied by the user.
- The user manually enters the network name and password in Phase 1.
- Network scanning is deferred.

## Behavior and Workflow

- If a configured Main Unit starts online, proceed to the normal application experience.
- If a configured Main Unit starts offline, proceed to the normal application experience and show a network connection alert.
- The alert must explain that the unit is offline and that network-dependent features may be unavailable.
- The alert must provide an action to connect to a different network.
- The recovery flow must allow the user to enter a network name and optional password.
- The recovery flow must validate input before attempting to connect.
- Do not store the submitted Wi-Fi credentials in the application database.
- If connection fails, alert the user, clear the fields, and allow retry.
- If connection succeeds, remove the alert and return to the normal application experience.

## Acceptance Criteria

- A configured Main Unit can start while offline.
- The user is clearly alerted that the unit is not connected to a network.
- The user can manually enter a different network name and optional password.
- Wi-Fi credentials are not stored in the application database.
- After a successful connection, the user returns to the normal application experience.
- After a successful connection, the network alert is no longer shown.

## Deferred Work

- Scanning and selecting available Wi-Fi networks.
- Editing general configuration after setup.