# Skill: MQTT Contract Integration in .NET

## Purpose

Guide agents to implement MQTT publish, subscribe, and routing behavior in .NET while preserving canonical topic and payload contracts.

## Use This Skill When

- Implementing `IConnectedService`, `ICommandPublisher`, or `IMessageRouter` behavior.
- Adding heartbeat, ack, or read-response handling.
- Extending command publishing and response ingestion.

## Contract Rules

- Use canonical topics from `mqtt-topics.md`.
- Keep payload naming in snake_case at MQTT boundary.
- Validate required fields before processing payloads.
- Normalize malformed payloads into diagnostics, not fatal exceptions.

## Integration Rules

- Reconnect without crashing the web app.
- Re-subscribe required topics after reconnect.
- Keep serializer/codec logic centralized.
- Avoid direct MQTT client calls from UI layer.

## Quality Gate

- Published command payloads match documented schema.
- Heartbeat routing updates runtime state and topology decisions.
- Connection failures are observable and recoverable.
