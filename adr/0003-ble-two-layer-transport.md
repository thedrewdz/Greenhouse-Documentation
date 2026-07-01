# BLE Uses a Two-Layer Transport: Low-Level IBleTransport Plus Application Port IEdgeUnitProvisioningTransport

BLE is the Phase 1 provisioning transport for Edge Unit onboarding. A single-layer approach
(one application port that exposes raw BLE operations) would leak GATT UUIDs and BLE-specific
types into application use cases, violating the boundary rule that application code must work
with Greenhouse concepts, not transport shapes.

The decided architecture is two layers:

1. `IBleTransport` — a low-level infrastructure-internal interface in `Greenhouse.Bluetooth`
   that exposes scan, connect, read characteristic, write characteristic, and disconnect. It is
   not an application port. Application code must never reference it.

2. `IEdgeUnitProvisioningTransport` — the application-layer port in `Greenhouse.Core` that
   exposes `ScanForProvisionableUnitsAsync` and `ProvisionUnitAsync` using only Greenhouse
   domain types (`ProvisioningPayload`, `ProvisioningResult`, `ProvisionableUnit`).

`BleEdgeUnitProvisioningAdapter` in `Greenhouse.Bluetooth` implements
`IEdgeUnitProvisioningTransport` by using `IBleTransport` internally. All GATT UUID constants
are private to `Greenhouse.Bluetooth`. Serialisation of the provisioning payload to JSON and
deserialisation of the BLE status response are also owned by this adapter.

This layering means `BleEdgeUnitProvisioningAdapter` is testable by mocking `IBleTransport`
without real hardware. It also means the BLE stack (BlueZ today, another stack on a different
board) can be swapped by replacing only `BlueZBleTransport` without touching the adapter or
any application code.

`Greenhouse.Bluetooth` and `Greenhouse.Bluetooth.Tests` are first-class projects in the
solution, alongside `Greenhouse.Mqtt` and `Greenhouse.Storage`.
