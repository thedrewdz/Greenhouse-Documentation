# Spec: Main Unit Setup

## Purpose and Scope

Define the Main Unit first-run flow for network setup and general greenhouse configuration.

This spec replaces the former Main Unit setup journey document. It does not cover Edge Unit onboarding or reconfiguration.

## Preconditions and Assumptions

- The Main Unit has a connected touch screen.
- A keyboard may be connected, but the flow must remain usable from touch only.
- The setup UI is available locally before the Main Unit joins a network.
- The system can determine whether general configuration already exists.
- The system can store and retrieve general configuration from local persistence.
- The system can determine whether the Main Unit is currently connected to a network.
- The user manually enters the network name and password in Phase 1.
- Network scanning and network changes from the unit are deferred.

## Behavior and Workflow

### Routing Rules

- If general configuration exists, skip setup and proceed to the normal application experience.
- If general configuration exists but the Main Unit is offline, use the Network Recovery spec instead.
- If general configuration does not exist and the Main Unit is offline, the first step is Network Connection.
- If general configuration does not exist and the Main Unit is already online, the first step is General Information.

### Network Connection

- Require the user to enter the network name.
- Allow the user to enter the network password.
- Ignore leading and trailing whitespace in the network name.
- Allow an empty password for open networks.
- Validate input before attempting to connect.
- Do not store Wi-Fi credentials in the application database.
- Use the submitted credentials immediately to connect the Main Unit to the network.
- If connection fails, alert the user, clear the fields, and allow retry.
- If connection succeeds, continue to General Information.

### General Information

- Require greenhouse name.
- Require greenhouse location.
- Allow optional description.
- Enforce a 50 character maximum for greenhouse name.
- Enforce a 50 character maximum for greenhouse location.
- Enforce a 100 character maximum for description.
- Store the configuration with the WriteGeneralConfiguration use case.
- Mark setup complete after the data is stored successfully.
- Load the stored configuration into application state.
- Redirect the user to the normal application experience.

## Acceptance Criteria

- The user can complete setup from the connected touch screen.
- The Main Unit can connect to the selected network, unless already connected.
- The application stores the greenhouse name, location, and optional description in local persistence.
- Wi-Fi credentials are not stored in the application database.
- After setup completes, the normal application experience starts.
- On later startup, setup is skipped when configuration already exists.

## Deferred Work

- Scanning and selecting available Wi-Fi networks.
- Editing general configuration after setup.
- Edge Unit onboarding and reconfiguration.