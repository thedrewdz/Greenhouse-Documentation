# Network Recovery User Journey

## Goal

When the Main Unit already has general configuration but starts without a network connection, alert the user and allow them to connect to a different network from the unit.

This is not first-run setup. It is an operational recovery flow for a configured unit.

## Pre-Conditions/Assumptions

- General configuration already exists.
- The Main Unit has a connected touch screen so the user can interact with it directly.
- The setup UI or dashboard is available locally on the Main Unit, even while the unit is offline.
- The system can determine whether the Main Unit is currently connected to a network.
- The system can request a network connection using credentials supplied by the user.
- The user manually enters the network name and password for Phase 1.
- Network password may be blank to support open networks.
- Network scanning is deferred.

## Routing Rules

**Given** the **Main Unit** starts up.
**When** general configuration exists and the unit is connected to a network.
**Then** proceed to the normal application experience.

**Given** the **Main Unit** starts up.
**When** general configuration exists and the unit is not connected to a network.
**Then** proceed to the normal application experience and show a network connection alert.

## Journey

**Given** the Main Unit has general configuration.
**When** the dashboard loads and the unit is not connected to a network.
**Then** show an alert explaining that the unit is offline.

The alert should:

- Be visible from the normal application experience.
- Explain that automation remains local where possible, but network-dependent features may be unavailable.
- Provide an action to connect to a different network.

**Given** the network alert is visible.
**When** the user chooses to connect to a different network.
**Then** present the Network Connection flow.

### Network Connection

**Given** the Network Connection flow is presented.
**When** the user is asked for network information.
**Then**

- Require the user to enter the network name.
- Allow the user to enter the network password.
- Provide a `Connect` button, or some call to action.

**Given** the Network Connection flow is presented.
**When** the user clicks the `Connect` / CTA button.
**Then** validate the user's input.

Minimum validation:

- Network name is required.
- Network password may be blank to support open networks.
- Leading and trailing whitespace should be ignored for the network name.

**Given** the user clicks the `Connect` / CTA button.
**When** the user's input is invalid.
**Then** alert the user and allow them to re-enter the required values.

**Given** the user clicks the `Connect` / CTA button.
**When** the user's input is valid.
**Then** disable the `Connect` / CTA button.

**Given** the Network Connection flow is presented.
**When** the user has entered and submitted valid network information.
**Then**

- Do not store these values in the application database.
- Immediately use them to connect the unit to the network.
- Wait for the result.

**Given** the user has entered network connection information.
**When** an attempt is made to join the network using the provided information, and the attempt fails.
**Then**

- Alert the user.
- Clear the input fields.
- Re-enable the `Connect` / CTA button.
- Wait for the user to re-enter correct values.

**Given** the user has entered network connection information.
**When** an attempt is made to join the network using the provided information, and the attempt succeeds.
**Then**

- Return the user to the normal application experience.
- Remove the network connection alert.

## Success Criteria

- A configured Main Unit can start while offline.
- The user is clearly alerted that the unit is not connected to a network.
- The user can manually enter a different network name and optional password.
- Wi-Fi credentials are not stored in the application database.
- After a successful connection, the user returns to the normal application experience.
- After a successful connection, the network alert is no longer shown.

## Deferred Journeys

- Scanning and selecting available Wi-Fi networks.
- Editing general configuration after setup.

