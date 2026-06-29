# Main Unit UI and services run as independent processes

Status: accepted
Date: 2026-06-29

## Context

The Main Unit hosts both the platform brain (domain logic, MQTT, storage, onboarding) and a local operator UI on a single resource-constrained device (initially a Raspberry Pi 4). The device must keep operating when the UI is absent, stopped, or has failed.

A prior attempt (the sunset `services-old`) ran the UI and the brain in one ASP.NET Core host using Blazor Server: the UI host directly referenced and constructed the domain/MQTT services in its own `Program.cs`, so the two could not start, stop, fail, or evolve independently.

## Decision

Run the Main Unit as two independent processes on the same device:

- A **headless services daemon** owns all domain logic, MQTT, storage, and onboarding and exposes a local API. It autostarts on boot and has no compile-time or runtime dependency on the UI.
- A **separate UI process** consumes that API. It can be disabled or stopped with no effect on the services daemon.

Communication is restricted to the **loopback interface**: REST for request/response, and a WebSocket/SSE channel for the limited live-push cases. SignalR is an allowed option for that push channel but is not required.

## Considered options

- Single host that renders the UI and owns the services (the `services-old` Blazor Server model) — rejected: it is precisely the coupling that prevented independent operation.
- Two processes over a local network boundary — chosen.

## Consequences

- The services daemon defines its API as a stable contract and publishes **OpenAPI**, so either side can be generated from and verified against it.
- Domain/MQTT/Bluetooth registration that lived in the UI's `Program.cs` moves entirely into the services daemon; the UI knows only the API base URL and the push endpoint.
- Deployment is two process units (e.g. systemd): `greenhouse-services` (enabled) and `greenhouse-ui` (optional).
- The frontend technology is recorded separately in ADR 0002 and can change without revisiting this separation.
