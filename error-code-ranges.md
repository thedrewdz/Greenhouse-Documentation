# Error Code Ranges

Canonical, solution-wide allocation of numeric error-code ranges. Every code a Greenhouse component
reports to another component or to an operator comes from exactly one range below.

## Why this document exists

Four code families were allocated independently, in four different documents, with no shared registry.
The result was predictable: the `1xxx` block was already the Edge Unit device-response set when a Main
Unit range was proposed at `1xxx` during grooming on 2026-08-04, and the collision was caught only
because someone happened to grep. A range allocated in the document that needs it is a range nobody
else can see.

**Allocate a new range here first.** Then define its codes in the contract document that owns the
message carrying them.

## Allocation

| Range | Origin | Vocabulary | Defined in |
|---|---|---|---|
| `0` | either | Success. Reserved across every range — never reused for a failure. | — |
| `1xxx` | **Edge Unit** | Device command and read response errors: `unknown_command`, `invalid_payload`, `invalid_slot`, `unsupported_capability`, `invalid_state`, `device_fault` | [mqtt-topics.md](mqtt-topics.md) § Response Payload Contract |
| `2xxx` | **Edge Unit** | BLE provisioning status response: `unsupported_schema_version`, `device_id_mismatch`, `wifi_ssid_empty`, `mqtt_broker_uri_invalid`, `internal_persistence_error` | [specs/edge-unit-onboarding/spec.md](specs/edge-unit-onboarding/spec.md) § Validation Rules and Error Handling |
| `3xxx` | **Edge Unit** | Runtime configuration ack: `unsupported_schema_version`, `device_id_mismatch`, `invalid_mapping_payload`, `mapping_version_conflict`, `internal_apply_error` | [specs/edge-unit-configuration/spec.md](specs/edge-unit-configuration/spec.md) § Runtime Configuration Ack |
| `4xxx` | **Main Unit** | The Main Unit's own onboarding and provisioning failures: credentials unavailable, broker address unavailable, BLE transport failure, empty or malformed status response, heartbeat timeout, internal error | [specs/edge-unit-onboarding/spec.md](specs/edge-unit-onboarding/spec.md) § Main Unit Failure Reporting |
| `5xxx`–`9xxx` | — | Unallocated. | — |

## Rules

- **A range has exactly one origin.** `1xxx`, `2xxx`, and `3xxx` are Edge Unit vocabularies; `4xxx` is
  the Main Unit's. A component must never emit a code from a range it does not own — doing so tells an
  operator to inspect the wrong unit, which for an Edge Unit means physical access to hardware that is
  working correctly.
- **The range identifies the origin, and that is the point.** A client decides which unit to name in an
  operator-facing message by reading the range, never by pattern-matching the message text.
- **`x099` is the internal-error code within each family.** `2099`, `3099`, `4099`. A failure with no
  more specific code uses its family's `x099` — never a null code, and never a neighbouring family's
  code because it reads closest.
- **Codes are stable once published.** Add new codes; do not renumber or repurpose existing ones.
  Firmware and Main Unit releases are not deployed together, so a renumbered code means two versions
  disagreeing about what a failure was.
- **`0` always means success**, in every range.
- Ranges are allocated in blocks of 1000. Do not sub-allocate a partial block to a second owner.

## Adding a code

1. Confirm the failure belongs to an existing range's origin and vocabulary. If it does not, allocate a
   new range in the table above first.
2. Define the code in the contract document that owns the message it travels in, using the next free
   number in the family. Keep `x099` reserved.
3. State when it is raised, precisely enough that two implementations cannot disagree.
4. If the code replaces an interim convention — a borrowed code, or a null — say so where it is defined,
   so a reader of old behaviour finds the correction.
