# Repository Session Handoff

This file is a maintainer-only scratchpad for this repository's own session state.

Do not treat this file as product documentation, architecture guidance, or agent policy.
Agents consuming documentation in this repo should not read this file.

For canonical guidance, use:

- AGENTS.md
- CONTEXT.md

## Current Session Notes

- Date: 2026-06-02
- Owner: Copilot session
- Goal: Clarify Edge Unit runtime configuration persistence expectations for WiFi and MQTT onboarding settings.
- Completed:
	- Updated onboarding specs to require persisting accepted provisioning values in NVS-backed storage.
	- Added explicit persistence requirements for wifi_ssid, wifi_password, mqtt_broker_uri, and optional heartbeat_interval_ms.
	- Added acceptance criteria that persisted config is loaded on boot and can be overwritten by newer valid payloads.
	- Updated heartbeat skeleton spec to allow runtime configuration sourced from build defaults and or NVS.
	- Added explicit heartbeat-spec configuration persistence requirements including update-at-any-time allowance and write-failure fallback behavior.
	- Confirmed no new standalone NVS skill is needed for now; keep guidance embedded in existing docs and skills.
- Blockers: none.
- Next actions:
	- If recurring firmware tasks require repeatable NVS migration and recovery guidance, add a short Configuration Persistence subsection to skills/esp-idf-firmware-practices.md.

## Template

Use this structure for future session entries:

- Date:
- Owner:
- Goal:
- In-progress work:
- Blockers:
- Next actions:


