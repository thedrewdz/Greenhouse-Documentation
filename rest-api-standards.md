# REST API Standards

Canonical naming and design rules for the Main Unit's HTTP/REST API — the loopback API the UI
and other local clients consume. Read this when adding or changing any REST endpoint.

## Purpose and Scope

This document exists so every Main Unit endpoint looks and behaves the same way, so a client can
learn the shape once and reuse that knowledge across the whole API.

**In scope:** synchronous HTTP/REST endpoints exposed by the Main Unit services process
(`/api/...`), consumed over loopback by the UI and other local clients (see ADR 0001).

**Out of scope:**

- **Async / event-driven contracts** — MQTT topics, telemetry, heartbeat, and command payloads
  are governed by [mqtt-topics.md](mqtt-topics.md). The naming principles here still apply where
  they make sense.
- **Error-body and response-envelope formats** — each spec defines its own request/response and
  error shapes today; this document does not mandate a platform-wide body format. It covers
  routes, verbs, named commands, and status codes only.

Because this API is **local-first, loopback-only, and has a single in-repo consumer**, the
enterprise concerns in a public/partner API standard do **not** apply here: no URL versioning, no
API gateway / rate-limiting tier, no partner/public auth tiers. Breaking changes are coordinated
in-repo across `Greenhouse-Services` and `Greenhouse-WebUI` rather than through version negotiation.

## Design Philosophy

- **Resource-oriented.** Model nouns (resources). Express behaviour through HTTP verbs and, where
  a verb does not fit, through **named commands** (below) — never through verb-shaped collection
  URLs like `/create-edge-unit`.
- **Predictable.** Uniform route structure and consistent use of the status-code table below.
- **Contract-first.** The API contract in the spec is written and reviewed before code and is the
  source of truth for the UI.

## Route Naming Conventions

Base path: `/api/<resource-collection>`. The service is implied by the loopback host; it is not
repeated inside the path.

**Do not expose:**

- Internal database IDs where avoidable — prefer stable domain identifiers (e.g. an Edge Unit's
  `device-id`) over auto-increment integer primary keys.
- File extensions (`.json`) — content type is negotiated via headers, not the path.
- Implementation details — `/edge-units/get-from-sqlite` is never acceptable.

| Rule | Correct | Incorrect |
|---|---|---|
| Plural nouns for collections | `/edge-units`, `/onboarding`, `/automation-rules` | `/edge-unit`, `/automation-rule` |
| No verbs in the path except named commands | `POST /edge-units`, `POST /edge-units/{device-id}/decommission` | `POST /create-edge-unit`, `POST /edge-units/create` |
| Kebab-case path segments | `/automation-rules`, `/edge-units` | `/automationRules`, `/automation_rules`, `/AutomationRules` |
| Nest only when the child cannot exist independently of the parent; **max 2 levels** | `/edge-units/{device-id}/slots` | `/edge-units/{device-id}/slots/{slot}/modules/{id}/telemetry` |
| camelCase for query params and JSON fields | `/edge-units?mappingStatus=pending-mapping` | `/edge-units?mapping_status=pending-mapping` |
| Path params identify a resource; query params filter/sort/paginate | `GET /edge-units/{device-id}`, `GET /edge-units?mappingStatus=pending-mapping` | `GET /edge-units/find-by-status?status=pending` |

**Greenhouse note on path-parameter casing.** Existing endpoints use `snake_case` path parameters
(e.g. `GET /api/edge-units/{device_id}`). New endpoints should keep path parameters consistent
within a resource family; where introducing a new resource, prefer the kebab-case convention above
(`{device-id}`). This document does not require renaming shipped path parameters.

## HTTP Verbs

| Verb | Use | Safe? | Idempotent? |
|---|---|---|---|
| `GET` | Retrieve a resource or collection. | Yes | Yes |
| `POST` | Create a resource, **or** perform a state-changing action via a named command (below). | No | No (creation needs explicit idempotency handling if required) |
| `PUT` | Replace a resource entirely. Use when full replacement is the right model (e.g. an Edge Unit's mapping, the Main Unit config). | No | Yes |
| `PATCH` | Partially update a resource with only the supplied fields. Use when a partial merge is the right model. | No | No |
| `DELETE` | Remove a resource. Use with judgment — see below. | No | Yes |

`PUT` and `PATCH` are available standard verbs; reach for them when replace/merge is genuinely what
the operation is. When the operation is an **action or state transition** rather than a
create/read/replace/merge/delete, express it as a named command instead of overloading a CRUD verb.

### DELETE — Use With Judgment

`DELETE` is appropriate for hard removal of resources with no meaningful business state to preserve —
typically configuration resources. `DELETE` is **not** appropriate when:

- The operation has audit or retention requirements — prefer a `decommission` / `deactivate` command.
- "Removed" is itself a meaningful domain state (e.g. a decommissioned Edge Unit still carries
  telemetry history worth retaining).
- Clients may still need to reference the resource after removal.

```
DELETE /api/setup/main-config              ✅  configuration resource, factory reset
POST   /api/edge-units/{device-id}/decommission   ✅  domain resource, history retained
DELETE /api/edge-units/{device-id}         ❌  discards telemetry/registration history
```

## Named Commands — the extension for actions

Standard verbs cover create, read, replace, merge, and delete. Many Main Unit operations are
**actions or state transitions** that none of those verbs describe cleanly — start a scan, cancel
onboarding, reboot an Edge Unit, enable a rule. A generic update verb pushes intent-resolution onto
both the server and the caller: "update an Edge Unit" could mean re-map its slots, reboot it, or
decommission it — each with different validation, side effects, and authorization. Named commands
make the intent explicit.

**Form:** `POST /<collection>/{id}/<command>`, where `<command>` is a **kebab-case verb** naming the
action. The command is a sub-path of the resource it acts on, not a verb-shaped collection.

```
# Instead of overloading a verb:
PATCH /api/onboarding/{device-id}     { "status": "cancelled" }

# Name the action:
POST  /api/onboarding/{device-id}/cancel
```

**Rules:**

- Use `POST` for the command. The command name carries the intent; the request body carries any
  parameters the action needs.
- Name the command as a verb or verb phrase in kebab-case (`decommission`, `reset-mapping`).
- Keep commands as sub-paths of a resource or collection — never a top-level verb URL.
- A command returns the affected resource representation, or an operation/status resource for
  long-running work (see the async-workflow guidance in
  [architecture/boundaries.md](architecture/boundaries.md)).

**Examples across the Greenhouse domain** (existing and roadmap):

```
POST /api/onboarding/scan                         # begin a BLE scan session
POST /api/onboarding/{device-id}/start            # begin auto-provisioning a selected candidate
POST /api/onboarding/{device-id}/cancel           # cancel the active onboarding session
POST /api/edge-units/{device-id}/decommission     # remove an Edge Unit, retaining history
POST /api/edge-units/{device-id}/reboot           # command a known Edge Unit to restart
POST /api/edge-units/{device-id}/identify          # flash the unit's indicator to locate it
POST /api/automation-rules/{id}/enable            # activate a rule
POST /api/automation-rules/{id}/disable           # deactivate a rule
```

Full-replacement operations still use `PUT` where that is the correct model — e.g.
`PUT /api/edge-units/{device-id}/mapping` replaces the unit's entire slot mapping. Use a named
command only when the operation is an action, not a replacement.

## Status Codes

Do **not** invent custom status codes. Communicate finer-grained meaning through the response body
defined by the endpoint's spec, not through non-standard HTTP codes.

| Code | Meaning | When to use |
|---|---|---|
| `200 OK` | Success | Successful `GET`, `PUT`/`PATCH`, or a command that returns a resource. |
| `201 Created` | Resource created | Successful `POST` that creates a resource. Include a `Location` header and the resource in the body. |
| `202 Accepted` | Accepted for async processing | Request accepted and queued for background work; return a status resource the client can poll. |
| `204 No Content` | Success, no body | Successful `DELETE`, or a write with nothing to return. |
| `400 Bad Request` | Malformed request | Unparseable payload or malformed request the server cannot interpret. |
| `401 Unauthorized` | Missing/invalid credentials | Missing or invalid authentication (where an endpoint requires it). |
| `403 Forbidden` | Authenticated but not permitted | Caller lacks permission for this resource. |
| `404 Not Found` | Resource does not exist | Unknown resource. |
| `409 Conflict` | State conflict | Duplicate create, version mismatch, or an action invalid for the resource's current state. |
| `422 Unprocessable Entity` | Semantically invalid | Well-formed request that fails field or business-rule validation. |
| `429 Too Many Requests` | Rate limit exceeded | Rarely applicable on the loopback API. |
| `500 Internal Server Error` | Unhandled server fault | Unhandled server-side error; do not expose stack traces to the client. |
| `503 Service Unavailable` | Dependency/capacity issue | A required dependency (e.g. the OS network connector) is unavailable. |
| `504 Gateway Timeout` | Upstream timeout | A bounded downstream operation (e.g. a WiFi connection attempt) timed out. |

**Greenhouse note on validation.** The platform uses **`422 Unprocessable Entity`** for field and
business-rule validation failures (well-formed requests that fail validation), consistent with the
shipped setup endpoints. Reserve **`400 Bad Request`** for requests the server cannot parse at all.

## Related Documents

- [architecture/boundaries.md](architecture/boundaries.md) — ports/adapters, DTO translation, the
  UI-to-backend REST rules, and async-workflow state resources.
- [mqtt-topics.md](mqtt-topics.md) — canonical async message contracts (out of scope here).
- [CONTEXT.md](CONTEXT.md) — canonical platform terminology used in resource names.
