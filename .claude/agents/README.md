# Claude Agent Profiles

This folder contains Claude-native role profiles for the Greenhouse delivery workflow.

Each file defines one role: its primary skill, what it owns, what it may and may not change, its required outputs, and its re-entry behaviour within the delivery loop.

These profiles are the Claude equivalent of the Codex subagent definitions in `.codex/agents/`.
The underlying skills they reference in `.agents/skills/` are shared and tool-neutral.

## Profiles

| File | Role | Use when |
|---|---|---|
| `documentation-agent.md` | Documentation Agent | Writing or refining specs, canonical docs, terminology, acceptance criteria |
| `implementation-agent.md` | Implementation Agent | Implementing accepted specs in a code repository |
| `test-agent.md` | Test Agent | Writing tests, closing coverage gaps, reporting residual risk |
| `code-review-agent.md` | Code Review Agent | Reviewing code against spec, architecture, and contracts |
| `qa-agent.md` | QA Agent | Scenario validation and release recommendation |
| `retrospective-agent.md` | Retrospective Agent | Promoting artifacts, updating guardrails, closing spec lifecycle |

## Usage

Load only the profile that matches the current task. Do not load all profiles at once.

To activate a role in Claude Code, use an `@`-include at the start of your prompt:

```
@.claude/agents/documentation-agent.md
```

Or reference the profile explicitly when directing Claude:

> Act as the Documentation Agent as defined in `.claude/agents/documentation-agent.md`.

## Delivery Loop Order

The roles map to stages in `workflows/feature-delivery-harness.md`:

```
Documentation â†’ Implementation â†’ Test â†’ Code Review â†’ QA â†’ Retrospective
```

Each role's re-entry behaviour and status gate rules are defined in its own profile file.

## Relationship to Codex Agents

| Claude profile | Codex equivalent |
|---|---|
| `.claude/agents/documentation-agent.md` | `.codex/agents/documentation-agent.toml` |
| `.claude/agents/implementation-agent.md` | `.codex/agents/implementation-agent.toml` |
| `.claude/agents/test-agent.md` | `.codex/agents/test-agent.toml` |
| `.claude/agents/code-review-agent.md` | `.codex/agents/code-review-agent.toml` |
| `.claude/agents/qa-agent.md` | `.codex/agents/qa-agent.toml` |
| `.claude/agents/retrospective-agent.md` | `.codex/agents/retrospective-agent.toml` |

When updating a role's behaviour, update both the `.md` and the `.toml` to keep them in sync.
