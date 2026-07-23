---
name: ba-po
description: Use this skill when distilling a concept into an epic with long-form documentation (Phase 1: Discovery), or when breaking a grooming-ready epic into single-stack, dependency-ordered tasks ready for development (Phase 2: Grooming). This is the entry point for all new feature work.
---

# BA/PO Skill: Discovery and Grooming

Take a concept from raw idea to a full set of implementation-ready tasks across two sequential phases:

- **Phase 1 — Discovery:** Distill a concept into a well-formed epic with long-form specification. Grill relentlessly until the epic is unambiguous and ready for grooming.
- **Phase 2 — Grooming:** Break the epic into single-stack, dependency-ordered tasks. Grill relentlessly until every task is implementation-ready and on the board.

Both phases may run in one session or across sessions. Phase 1 ends at **Ready For Grooming**; Phase 2 ends at **Ready For Dev** (or **Done** for documentation-only epics).

## Board Status Reference

| Status | Option ID |
|---|---|
| Todo | `f75ad846` |
| In Discovery | `e9e67acb` |
| Ready For Grooming | `7932c987` |
| In Grooming | `a01c3971` |
| Ready For Dev | `1e580093` |
| In Development | `47fc9ee4` |
| In Review | `a7a0e5d1` |
| Done | `98236657` |

## Stack → Repository Map

| Stack | Repository |
|---|---|
| `services` | `Greenhouse-Services` |
| `ui` | `Greenhouse-WebUI` |
| `edge` | `Greenhouse-Firmware` |
| `peripherals` | `Greenhouse-Peripherals` |
| `documentation` | `Greenhouse-Documentation` |

## Board Operations

**Find board item ID:**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.content.number -eq <issue-number> -and $_.repository -like "*<repo>*" } \
  | Select-Object -ExpandProperty id
```

**Set board status:**
```bash
gh project item-edit --project-id PVT_kwHOClcYbc4BcGuS \
  --id <item-id> \
  --field-id PVTSSF_lAHOClcYbc4BcGuSzhWx6Oo \
  --single-select-option-id <option-id>
```

**Verify board status (run after every status transition):**
```bash
gh project item-list 1 --owner thedrewdz --format json --limit 100 \
  | ConvertFrom-Json | Select-Object -ExpandProperty items \
  | Where-Object { $_.id -eq "<item-id>" } \
  | Select-Object -ExpandProperty status
```

## Plan Interrogation Method

Use in both phases whenever scope, intent, or requirements are ambiguous.

- Ask one question at a time. Never bundle unrelated questions.
- For every question include:
  - Why this question matters.
  - A recommended default answer based on current evidence.
  - What changes if the user chooses a different answer.
- After each response, update assumptions and continue to the next unresolved question.
- If a question can be answered by exploring docs or code, explore first and ask only what remains unresolved.
- Do not stop early. Continue until the relevant phase exit gate is fully satisfied.

---

## Phase 1: Discovery

### Trigger

The user brings a concept, idea, or direction. No existing board item is required.

### Startup

1. Read `CONTEXT.md`, `DOCS-MAP.md`, and `adr/README.md`.
2. Read any ADRs and existing specs relevant to the concept.
3. Use the Plan Interrogation Method. Work through the Discovery Grilling Topics below one question at a time until the exit gate is satisfied.

### Discovery Grilling Topics

Work through every topic. Each unresolved topic becomes a question.

1. **Problem statement:** What specific user or operator problem does this solve? Who is affected and how often?
2. **Persona:** Which user role benefits most — operator, technician, administrator?
3. **Business value:** Why does this matter now? What is the cost or risk of not building it?
4. **System boundaries:** Which stacks are involved (`services`, `ui`, `edge`, `peripherals`)? Which are explicitly out of scope?
5. **Affected contracts:** Which MQTT topics, REST endpoints, I2C interfaces, or data schemas are introduced or changed?
6. **Dependencies:** Does this depend on existing features, specs, or ADRs that must be complete first? Are those stable?
7. **Non-functional constraints:** Are there performance, safety, security, or hardware constraints to honour?
8. **Explicit out-of-scope:** What related work is deferred or excluded?
9. **Open questions:** Are there decisions that genuinely cannot be made yet? Name them and state why they are blocked.
10. **Acceptance criteria:** Define at least one testable acceptance criterion per major behavior before leaving Phase 1.

### Phase 1 Exit Gate

Do not advance until every item is true:

- Problem statement is concrete and user-focused, not a solution description.
- At least one testable acceptance criterion exists per major behavior.
- All stacks that are in scope are named; all stacks that are out of scope are confirmed.
- All contracts introduced or changed are identified by name.
- All dependencies are named and their stability confirmed.
- All open questions are either resolved or explicitly deferred with a stated reason and owner.
- No ambiguous requirements remain. Every requirement passes: "can an implementation agent build this without guessing?"
- Documentation standards from `.agents/skills/documentation/SKILL.md` (Style Rules and Consistency Rules) are satisfied.

### Phase 1 Output

Execute in order. Do not skip steps.

1. Pull latest remote changes:
   ```bash
   git pull --ff-only
   ```
2. Create the spec dossier at `specs/<spec-name>/spec.md` using `templates/spec.md`.
3. Create canonical status at `specs/<spec-name>/status.md` using `templates/spec-canonical-status.md`. Set status: `new`.
4. Create the GitHub epic issue:
   ```bash
   gh issue create -R thedrewdz/Greenhouse-Documentation \
     --title "<concise imperative title>" \
     --label "enhancement" \
     --body "<problem statement, system boundaries, success criteria, link to spec at specs/<spec-name>/>"
   ```
5. Find the board item ID for the new issue (see Board Operations).
6. Set the epic to **In Discovery** and verify. Do not proceed until the status update is confirmed.
7. Commit the spec dossier:
   ```bash
   git add -A
   git commit -m "discovery: <epic title> (#<issue-number>)"
   git push origin main
   ```
8. Set the epic to **Ready For Grooming** and verify.
9. Present a Phase 1 summary to the user. Confirm they want to continue to Phase 2 before proceeding.

---

## Phase 2: Grooming

### Trigger

An epic is at **Ready For Grooming**. This skill either continues directly from Phase 1 or is invoked against an existing epic at that status.

### Startup

1. Read the epic issue body, comments, and its spec at `specs/<spec-name>/spec.md`.
2. Read `CONTEXT.md`, `DOCS-MAP.md`, and all ADRs relevant to the epic.
3. Set the epic to **In Grooming** and verify before writing anything.

### Grooming Rules

#### Single-Stack Constraint

Every implementation task must belong to exactly one stack. A task that touches both `services` and `ui` must be split into two separate tasks. Never create a cross-stack implementation task.

#### Cross-Stack Dependency Ordering

When an epic spans multiple stacks, tasks must be sequenced so that dependencies are satisfied. Default ordering:

1. `documentation` tasks first — specs and contracts must be complete before any implementation starts.
2. `peripherals` tasks — I2C interface and canonicalization must exist before Edge can consume it.
3. `edge` tasks — firmware must exist before Services handles its telemetry or commands.
4. `services` tasks — the REST API contract must exist before UI can consume it.
5. `ui` tasks last — the UI is a client of the services API.

State any exception to this order explicitly in the task body and in the spec.

#### Documentation-Only Epics

If Phase 2 determines that no implementation tasks are required in any code stack, execute the documentation work directly — update or create all affected docs — then commit, close the epic issue, and set the epic to **Done**. Do not create implementation sub-tasks.

### Grooming Grilling Topics

For each proposed task, work through every topic before marking it ready:

1. **Scope:** Is the task atomic enough to complete in a single implementation session? If not, split it.
2. **Stack ownership:** Which single stack owns this task? If the answer involves more than one stack, the task must be split.
3. **Acceptance criteria:** Are the criteria specific and testable? Can a QA agent validate them without guessing?
4. **Dependencies:** Does this task depend on another task in this epic or on an external issue? Is the ordering explicit?
5. **Documentation gaps:** Is the spec complete enough for an implementation agent to proceed without asking questions? If not, update the spec before continuing.
6. **Contracts:** Are all API endpoints, MQTT topics, I2C interfaces, or data schemas required by this task documented and stable?

### Phase 2 Exit Gate

Do not set any task to Ready For Dev until every item is true:

- Every implementation task is single-stack.
- Every task has specific, testable acceptance criteria.
- All inter-task dependencies are declared and sequenced correctly.
- No task requires a contract that is undocumented or unstable.
- `specs/<spec-name>/spec.md` reflects the full task decomposition and dependency map.
- No documentation gaps remain that would block an implementation agent.

### Phase 2 Output

For each task in dependency order:

1. Create a sub-issue in the owning repository:
   ```bash
   gh issue create -R thedrewdz/<repo> \
     --title "<concise imperative title>" \
     --label "enhancement" \
     --body "Stack: <stack>\nDepends on: #<issue> (if any)\n\n<what must be built, acceptance criteria, link to spec at specs/<spec-name>/>"
   ```
2. Attach the new issue as a sub-issue of the parent epic.
3. Set each task to **Ready For Dev** and verify.

After all tasks are created and verified:

4. Update `specs/<spec-name>/spec.md` with the complete task list, assigned stacks, and dependency map.
5. Update `specs/<spec-name>/status.md` — set status to `ready-for-dev`. Append a status history entry.
6. Commit all changes:
   ```bash
   git add -A
   git commit -m "grooming: <epic title> — tasks ready for dev (#<issue-number>)"
   git push origin main
   ```
7. Set the epic to **Ready For Dev** and verify.

### Grooming Output Checklist

- All tasks are sub-issues of the epic.
- Each task is single-stack with explicit, testable acceptance criteria.
- Task dependencies are declared and sequencing satisfies the cross-stack ordering rule.
- `specs/<spec-name>/spec.md` contains the full task decomposition and dependency map.
- `specs/<spec-name>/status.md` is `ready-for-dev` with a history entry.
- All changes committed to `main` with `#<issue-number>` in the commit message.
- Epic is at **Ready For Dev** on the board.
