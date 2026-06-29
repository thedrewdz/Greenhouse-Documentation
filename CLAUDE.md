# CLAUDE

This file is the Claude / Claude Code entry point for the Greenhouse Documentation repository.

## Canonical Policy

@AGENTS.md

AGENTS.md is the canonical, cross-agent policy for this repository.
All rules, precedence order, naming conventions, quality gates, and workflow guidance in AGENTS.md apply fully to Claude and Claude Code.

## What This Repository Is

This repository is the central documentation hub for the Greenhouse platform.
It is documentation-only. No production code lives here.

Claude Code may write and edit documentation files in this repository.
Claude Code must not introduce a top-level `docs/` folder.
All docs live at the repository root or in named subdirectories as defined by the existing structure.

## Incremental Documentation Loading

**Do not read all documentation up front.**

This is the required pattern â€” load only what the task needs:

1. Always read first:
   - `CONTEXT.md` â€” canonical platform terminology.
   - `DOCS-MAP.md` â€” routing map; use it to choose the smallest relevant doc set.
   - `adr/README.md` â€” ADR digest and ADR loading rules.

2. Then use `DOCS-MAP.md` to identify and load only the docs that match the task.

3. Load ADR files only for touched areas.

4. Do not load platform orientation, spec dossiers, or skill files that are not relevant to the task.

This pattern preserves context and prevents conflicting guidance from non-applicable docs.

## Instruction Precedence

When instructions overlap, follow this order:

1. `AGENTS.md` (canonical cross-agent policy)
2. `CONTEXT.md`
3. `DOCS-MAP.md`
4. `.agents/skills/README.md` and `.agents/skills/*/SKILL.md`
5. `workflows/*.md`
6. `.codex/agents/*.toml`
7. `adr/*.md`
8. Canonical docs for touched areas
9. `agent-handoff.md` (session scratchpad only â€” never durable guidance)

## Agent Profiles

Role profiles for Claude Code live under `.claude/agents/`.

Read `.claude/agents/README.md` to understand the delivery loop and choose the right profile.
Load only the profile that matches the current task â€” do not load all profiles at once.

Available profiles:

- `.claude/agents/documentation-agent.md` â€” specs, canonical docs, terminology, acceptance criteria, doc feedback resolution.
- `.claude/agents/implementation-agent.md` â€” implementing accepted specs in a code repository.
- `.claude/agents/test-agent.md` â€” writing tests, closing coverage gaps, reporting residual risk.
- `.claude/agents/code-review-agent.md` â€” reviewing code against spec, architecture, and contracts.
- `.claude/agents/qa-agent.md` â€” scenario validation and release recommendation.
- `.claude/agents/retrospective-agent.md` â€” promoting artifacts, updating guardrails, closing spec lifecycle.

To activate a profile in Claude Code, use an `@`-include:

```
@.claude/agents/documentation-agent.md
```

These profiles are the Claude equivalent of the Codex subagent definitions in `.codex/agents/`.
The skills they reference in `.agents/skills/` are shared and tool-neutral.

## Skills

Reusable skills for this repository live under `.agents/skills/`.

Read `.agents/skills/README.md` to select the right skill for the task.
Load only the matching `SKILL.md`, not all skills.

Available skills:

- `.agents/skills/documentation/SKILL.md` â€” documentation, specs, terminology, acceptance criteria, plan interrogation.
- `.agents/skills/grill-with-docs/SKILL.md` â€” stress-test plans against glossary, ADRs, and docs.
- `.agents/skills/implementation/SKILL.md` â€” implementation-stage execution and artifact/status rules.
- `.agents/skills/test/SKILL.md` â€” test-stage coverage and loopback rules.
- `.agents/skills/code-review-agent/SKILL.md` â€” review-stage artifacts and status rules.
- `.agents/skills/code-review-gate/SKILL.md` â€” strict review checks and blocking finding rules.
- `.agents/skills/qa/SKILL.md` â€” QA-stage validation and release recommendation rules.
- `.agents/skills/retrospective/SKILL.md` â€” artifact promotion, guardrail updates, doc feedback consolidation.
- `.agents/skills/solid/SKILL.md` â€” software design, SOLID, clean code, testing, boundary discipline.

Skill reference files are loaded only when the corresponding `SKILL.md` instructs it.

## Tooling Notes for Claude Code

- Codex subagent profiles live under `.codex/agents/*.toml`. Claude Code does not use these directly but must not modify them without an explicit instruction to do so.
- `.agents/skills/` naming is tool-neutral and works for both Codex and Claude Code.
- `.claude/agents/` and `.codex/agents/` define the same six roles. When updating a role's behaviour, update both.
- `agent-handoff.md` is a repo-maintainer session scratchpad. Do not treat it as durable domain guidance and do not duplicate policy there.
- When scope is ambiguous, use the Plan Interrogation Method defined in `.agents/skills/documentation/SKILL.md` â€” ask one question at a time, provide a recommended answer for each, and wait for a response before continuing.

## Repository Tool Bridges

| Tool | File |
|---|---|
| Claude / Claude Code | `CLAUDE.md` (this file) |
| OpenAI Codex | `AGENTS.md` + `.codex/agents/` |
| GitHub Copilot | `.github/copilot-instructions.md` |

All bridges point to `AGENTS.md` as the canonical source of policy.
