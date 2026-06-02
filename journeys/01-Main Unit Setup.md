# Main Unit Setup User Journey

## Goal

Using a connected touch screen and, optionally, a keyboard, ensure that the Main Unit can receive, store, and retrieve all basic setup information needed to be functional.

This journey has two steps:

- Network configuration
- General configuration

This journey is only for Main Unit first-run setup.
It does not include Edge Unit discovery, Edge Unit onboarding, BLE provisioning, or Edge Unit slot mapping.

This is a Day 1 requirement that will evolve slightly in time.

## Pre-Conditions/Assumptions

- The Main Unit has a connected touch screen so the user can interact with it directly.
- A keyboard may be connected, but the journey should remain usable from the touch screen.
- The setup UI is available locally on the Main Unit, even before the unit has joined a network.
- The system can determine whether general configuration already exists.
- The system can store and retrieve general configuration from local persistence.
- The system can determine whether the Main Unit is currently connected to a network.
- The system can request a network connection using credentials supplied by the user.
- The user manually enters the network name and password for Phase 1.
- Network scanning and network changes from the unit are deferred.
- Editing general configuration after setup is covered by a separate user journey.

## Routing Rules

**Given** the **Main Unit** starts up.
**When** general configuration is found in the database.
**Then** skip setup and proceed to the normal application experience.

If general configuration exists but the unit does not have a network connection, use the Network Recovery journey instead of the setup journey.

**Given** the **Main Unit** starts up.
**When** general configuration is not found in the database and the unit is not connected to a network.
**Then** Main Unit Setup is required, and the first step is Network Connection.

**Given** the **Main Unit** starts up.
**When** general configuration is not found in the database and the unit is already connected to a network.
**Then** Main Unit Setup is required, and the first step is General Information.

## Journey

**Given** the **Main Unit** starts up.
**When** the main configuration is not found in the database.
**Then** Main Unit Setup is required, and the setup user journey begins.

**Given** the Main Unit enters the setup user journey.
**When** the setup user journey begins and the Main Unit is not connected to any form of network.
**Then** The first step in the journey is presented, being the Network Connection step.

### 1: Network Connection

**Given** that the Main Unit Setup journey is underway, 
**When** the unit is not connected to a network of any kind and the Network Connection step is presented, 
**Then** 

- Require the user to enter the network name
- Allow the user to enter the network password
- Provide a `Next` button, or some call to action.

**Given** the Network Connection Step is presented,
**When** the user clicks the `Next` / CTA button. 
**Then** validate the user's input.

Minimum validation:

- Network name is required.
- Network password may be blank to support open networks.
- Leading and trailing whitespace should be ignored for the network name.

**Given** the user clicks the `Next` / CTA button. 
**When** the user's input is invalid. 
**Then** Alert the user and allow them to re-enter the required values. 

**Given** the user clicks the `Next` / CTA button. 
**When** the user's input is valid. 
**Then** Disable the `Next` / CTA button. 

**Given** the Network Connection Step is presented,
**When** the user has entered the network name and password, and it has been validated, and the `Next` button has been disabled. 
**Then** 

- Do not store these values in the application database
- Immediately use them to connect the unit to the network
- Wait for the result

**Given** the user has entered network connection information. 
**When** an attempt is made to join the network using the provided information, and the attempt fails. 
**Then**

- Alert the user
- Clear the input fields
- Re-enable the `Next` / CTA button. 
- Wait for the user to re-enter correct values

**Given** the user has entered network connection information.
**When** an attempt is made to join the network using the provided information, and the attempt succeeds.
**Then** 

- Proceed to the next step of the setup journey.
- If the form re-uses the same controls, remember to re-enable the `Next` / CTA button. 

### 2: General Information

**Given** the Main Unit is connected to a network. 
**When** the General Information step is presented.
**Then** require the user to provide the following information:

- "Greenhouse Name", with help text like "Orchid Palace", or "Vegetable Garden"
- "Greenhouse Location", with help text like "Back Garden", "Next to the garage", or "51st Street"
- "Description", (optional) with help text like, "Hydroponics based grow beds with controlled lighting."
- `Done` button.

**Given** the General Information step is presented. 
**When** the user clicked the CTA. 
**Then** Disable the CTA button so that it cannot be clicked a second time. 

**Given** the General Information step is presented. 
**When** the user clicked the CTA. 
**Then** validate the input.

Minimum validation:

- Greenhouse Name is required.
- Greenhouse Name maximum length is 50 characters.
- Greenhouse Location is required.
- Greenhouse Location maximum length is 50 characters.
- Description is optional.
- Description maximum length is 100 characters.

**Given** the user clicked the CTA. 
**When** the input provided is invalid. 
**Then** 

- Alert the user.
- Re-enable the CTA button. 
- Allow the user to modify the values they have entered.

**Given** the user clicked the CTA. 
**When** the input provided is valid. 
**Then** use the `WriteGeneralConfiguration` use case and store the information in the local database.

**Given** the general configuration has been stored successfully.
**When** setup completes.
**Then**

- Mark setup as complete.
- Load the stored configuration into application state.
- Redirect the user to the normal application experience.
- On future startup, skip this setup journey unless the configuration is missing or reset.

## Success Criteria

- The user can complete setup from the connected touch screen.
- The Main Unit can connect to the selected network, unless already connected.
- The application stores the greenhouse name, location, and optional description in local persistence.
- Wi-Fi credentials are not stored in the application database.
- After setup completes, the normal application experience starts.
- On the next application startup, setup is skipped when configuration already exists.

## Deferred Journeys

- Scanning and selecting available Wi-Fi networks.
- Editing general configuration after setup.
- Edge Unit onboarding and reconfiguration (covered by `04-Edge Unit Onboarding and Reconfiguration.md` and `../specs/spec-edge-unit-onboarding-ble.md`).



