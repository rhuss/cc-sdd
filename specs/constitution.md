# Superpowers-SDD Plugin Constitution

**Project:** cc-superpowers-sdd
**Purpose:** Claude Code plugin merging specification-driven development with process discipline

## Core Principles

### I. Spec-First (NON-NEGOTIABLE)

Specifications are the single source of truth. Every feature starts as a spec. Code validates against specs, not the other way around.

- No implementation without a spec (spec.md, plan.md, tasks.md)
- Specs drive plans, plans drive tasks, tasks drive implementation
- Code reviews check spec compliance, not just code quality
- When code and spec disagree, the disagreement must be resolved explicitly (never silently ignored)

### II. Intent Before Implementation

Specs capture WHAT and WHY, never HOW. Implementation details belong in plan.md, not spec.md.

- Functional requirements describe capabilities, not code structure
- Success criteria are measurable outcomes, not technical metrics
- User stories describe user value, not system internals
- Technology choices live in plan.md after spec is validated

### III. Two-Layer Architecture

The plugin separates concerns into two layers:

- **Technical layer** (spec-kit skill): CLI integration, initialization, project structure. Deterministic, non-interactive, fast. Handles `specify` CLI tool and `/speckit.*` commands.
- **Methodology layer** (SDD skills): Workflow routing, quality gates, process discipline. Enforces the spec-first principle and catches shortcuts.

Skills call downward (methodology calls technical), never upward. The technical layer has no knowledge of SDD workflow.

### IV. Skill Composition

Each skill has a single responsibility. Skills compose by invoking other skills via `{Skill: name}`.

- Every skill lives in `sdd/skills/<skill-name>/SKILL.md`
- Every SKILL.md has YAML frontmatter with `name` and `description`
- Every skill documents: when to use, when not to use, what it invokes, what invokes it
- Slash commands in `sdd/commands/` are thin wrappers that delegate to skills
- No skill should duplicate logic that belongs in another skill

### V. Quality Gates are Mandatory

Hard gates at every phase transition. No gate may be skipped. No rationalization accepted.

- **Before planning**: Spec review validates soundness, completeness, implementability
- **Before implementation**: Spec package verified complete (spec.md + plan.md + tasks.md)
- **After implementation**: Code review checks spec compliance, reports deviation score
- **Before completion**: Verification gate runs tests AND validates spec compliance
- **On mismatch**: Evolution workflow (`sdd:evolve`) reconciles, user decides resolution

### VI. Living Documentation

Specs are not write-once artifacts. They evolve based on implementation reality.

- When code and spec diverge, `sdd:evolve` analyzes the mismatch
- Three resolution paths: update spec (better approach discovered), fix code (deviation from design), clarify spec (ambiguity resolved)
- AI recommends with reasoning, user decides
- After evolution, dependent artifacts (plan.md, tasks.md) are regenerated
- Specs remain accurate project documentation at all times

### VII. Deterministic Initialization

All initialization must be fast, non-interactive, and idempotent.

- `sdd-init.sh` handles all setup checks in a single bash script
- Returns clear status: READY, NEED_INSTALL, RESTART_REQUIRED, ERROR
- No exploration, guessing, or interactive prompts during init
- Init is called automatically by all workflow skills via the spec-kit skill
- Repeated calls produce the same result (idempotent)

### VIII. User Control

AI makes recommendations with reasoning. The user decides on all significant changes.

- Spec evolution: AI recommends, user approves or overrides
- Auto-update configurable (threshold: none, minor, moderate, always)
- All decisions transparent and documented
- No silent spec modifications, no hidden automation

## Development Conventions

### Markdown as Universal Interface

Everything is markdown. Skills, commands, specs, plans, tasks, and the constitution itself.

- SKILL.md for skill definitions (with YAML frontmatter)
- `.md` files for slash commands
- `spec.md`, `plan.md`, `tasks.md` for feature artifacts
- `constitution.md` for project principles

### Branch and Spec Naming

Branch names follow the pattern `NNN-feature-name` where NNN is a zero-padded number matching the spec directory.

- Branch `002-auth-system` links to `specs/002-auth-system/`
- Prefixes like `feature/`, `fix/`, or `spec/` are not valid for spec-kit
- The numeric prefix is how spec-kit locates the correct spec directory

### Tooling

- **Package management**: Use `uv` exclusively. Never use `pip`, `pip install`, or `pip3`. All Python package operations go through `uv` (e.g., `uv pip install`, `uv tool install`, `uv venv`).
- **Virtual environments**: Create in `~/.venvs/<project-name>/`, not project-local `.venv`
- **Commit attribution**: All commits include `Assisted-By: Claude Code`
- **Container runtime**: Use `podman` instead of `docker`

### Writing Style

- No em-dashes or en-dashes in any text content. Rephrase as separate sentences, use commas, or use parentheses instead.
- Kubernetes resources are uppercase: Pod, Service, Deployment, ConfigMap, Secret
- Field names in monospace: `spec.replicas`, `metadata.name`

## Skill Development Standards

### SKILL.md Structure

Every skill file follows this structure:

1. **Frontmatter**: YAML with `name` and `description`
2. **Overview**: What this skill does and its value proposition
3. **When to Use / When Not to Use**: Clear guidance on applicability
4. **Prerequisites**: Skills or tools that must be available
5. **Process**: Step-by-step workflow with checkpoints
6. **Integration**: What this skill invokes and what invokes it
7. **Error Handling**: Failure modes and recovery steps

### Slash Command Convention

- All user-facing commands are prefixed with `/sdd:`
- Commands are thin wrappers: they set context and invoke the corresponding skill
- Command files live in `sdd/commands/<name>.md`
- Internal commands (from spec-kit) use the `/speckit.*` prefix

### Error Messages

Error messages must be actionable. Include:

- What failed
- Why it failed (if known)
- What the user should do next
- Which skill or command to run for recovery

## Governance

- This constitution supersedes ad-hoc decisions and one-off patterns
- All spec reviews and code reviews must check constitution compliance
- Amendments require documented rationale in the Decision Log below
- Complexity must be justified against the relevant principle
- Exceptions are documented in the feature spec with justification

## Decision Log

### 2026-02-13: Initial Constitution Ratified

**Context:** Project has been in active development with established patterns but no formal constitution.
**Decision:** Codified existing principles from `docs/design.md`, skill definitions, and observed conventions.
**Rationale:** Formal constitution enables automated compliance checking during spec review and code review phases.

**Version**: 1.0.0 | **Ratified**: 2026-02-13 | **Last Amended**: 2026-02-13
