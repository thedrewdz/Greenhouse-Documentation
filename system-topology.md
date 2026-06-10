# System Topology

# High-Level Topology

The Greenhouse Automation Platform uses a distributed local-first hardware architecture centered around MQTT messaging.

Core physical components include:
- Main Unit
- Sensor Edge Units
- Actuator Edge Units
- Local Database
- Automation Engine
- Web Interface
- Decoupled Main Unit runtime services
- Future AI Services
- Optional Cloud Services

---

# Topology Principles

For software layer ownership, dependency direction, ports, adapters, and test architecture, read [architecture.md](architecture.md).

## Local-First

All critical automation executes locally.

Internet connectivity is optional.

The system must continue operating during:
- ISP outages
- cloud outages
- WAN instability

---

## Message-Oriented Design

Subsystems communicate using MQTT.

Advantages:
- decoupling
- scalability
- resilience
- asynchronous communication
- distributed extensibility

---

## Deterministic Control

The automation engine is authoritative.

AI systems:
- suggest
- analyze
- recommend

but do not directly operate hardware.

---

# Main Unit

## Hardware

Recommended:
- Raspberry Pi 4
or
- Raspberry Pi 5

Bluetooth baseline for onboarding:
- Raspberry Pi 4B includes integrated Bluetooth (BLE-capable) and is the Phase 1 onboarding baseline.

Optional future support:
- x86 mini-PC
- industrial host appliance
- NAS-hosted deployment

---

## Responsibilities

The Main Unit handles:
- MQTT broker
- device registration
- automation rules
- telemetry ingestion
- historical persistence
- optional web UI
- optional web API
- notifications
- OTA coordination
- AI orchestration
- future cloud synchronization

After setup is complete, the Main Unit runtime must be able to start and operate without the web UI. The automation engine, MQTT handling, command dispatch, and persisted state remain backend/runtime responsibilities.

Onboarding and provisioning responsibilities:
- host BLE onboarding service for unprovisioned Edge Units
- exchange WiFi credentials and bootstrap MQTT endpoint with new Edge Units
- confirm onboarding success after first heartbeat

---

## Core Software Stack

### Operating System

Preferred:
- Raspberry Pi Debian Bookworm

---

### Containerization

Deployment uses:
- Phase 1 - No containerization
- Phase 2 - consider containerization (Docker, Docker Compose)

Advantages:
- reproducibility
- isolation
- easy upgrades
- simplified deployment

---

## Backend

Preferred:
- ASP.NET Core

Reasons:
- strong architecture support
- performance
- dependency injection
- clean API development
- excellent async support

---

## Database

Initial:
- SQLite

Future:
- PostgreSQL

Telemetry storage may later move toward:
- TimescaleDB
- InfluxDB

if higher scale becomes necessary.

---

## MQTT Broker

Preferred broker:
- Mosquitto

Responsibilities:
- telemetry transport
- device messaging
- command routing
- event publication
- discovery

---

# Edge Units

- Edge Units consist of a single MPU with a set number of edge slots attached.
- An edge unit could have any combination of sensor units or actuator units attached.
- Sensor and Actuator units are light MPU driven interfaces that are purpose built for the sensor actuator they drive.

## Platform

- ESP32

## Onboarding Channel (Phase 1)

- Preferred onboarding channel: BLE
- Wired provisioning remains optional for recovery and manufacturing workflows.
- Edge Unit provisioning mode is only active before successful onboarding or after explicit factory reset.

---

## Responsibilities

Sensor Edge Units:
- read sensors
- publish telemetry
- publish heartbeat/status
- support OTA updates
- maintain local buffering during outages

---

## Example Sensors

- temperature
- humidity
- soil moisture
- CO2
- pH
- EC/TDS
- water level
- flow sensors
- light intensity

---

# Actuator Edge Units

## Platform

- ESP32

---

## Responsibilities

Actuator Edge Units:
- subscribe to commands
- execute operations
- report state
- fail safely
- support OTA updates

---

## Example Actuators

- pumps
- solenoid valves
- fans
- vents
- heaters
- grow lights
- humidifiers
- nutrient dosing pumps

---

# Automation Engine

The automation engine is responsible for:
- evaluating rules
- executing commands
- enforcing safety constraints
- scheduling operations

Rules are:
- deterministic
- auditable
- user-visible

---

# Rule Model

Rules should eventually support:
- threshold triggers
- schedules
- hysteresis
- debounce logic
- time windows
- logical conditions
- sensor aggregation

Example:
- "If soil moisture < 30% for 5 minutes, run pump for 20 seconds."

---

# AI Integration

Future AI systems may:
- analyze telemetry
- identify anomalies
- recommend rules
- generate notifications
- provide conversational assistance

AI services remain advisory.

---

# Future Vision System

Future camera systems may support:
- plant growth analysis
- disease detection
- pest detection
- canopy monitoring
- time-lapse imaging

These systems should remain modular and isolated from critical automation.

---

# Security Model

Initial deployment assumes:
- isolated local network
- trusted LAN environment

Future security features:
- authentication
- TLS
- device certificates
- role-based access
- encrypted remote access

---

# Scalability Goals

The topology should support:
- one greenhouse
- multiple greenhouses
- distributed growing sites

without redesigning the communication model.

---

# Future Expansion Areas

Potential future modules:
- mobile applications
- cloud sync
- weather integration
- predictive irrigation
- energy optimization
- inventory tracking
- nutrient recipe management
- AI plant diagnostics
