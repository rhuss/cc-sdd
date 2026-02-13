# Review Summary: Beads Integration for SDD Implementation

**Spec:** specs/001-beads-integration/spec.md | **Plan:** specs/001-beads-integration/plan.md
**Generated:** 2026-02-13

> Distilled decision points for reviewers. See full spec/plan for details.

---

## Feature Overview

Adds `--with-beads` flag to `/sdd:implement` that replaces the speckit.implement task execution engine with beads (a git-backed issue tracker). This enables multi-session implementation with persistent memory, dependency-aware task ordering, and discovered work tracking. When the flag is not provided, behavior is identical to the current implementation.

## Scope Boundaries

- **In scope:** Flag detection, tasks.md-to-beads conversion, beads-driven execution loop, resume detection, sync-back to tasks.md, discovered work tracking, error handling for all beads CLI failures
- **Out of scope:** Modifying speckit.implement, creating new skills/commands, auto-installing beads, beads daemon management, multi-agent coordination
- **Why these boundaries:** The change is surgical (one file modification). Beads is an external tool with its own installation path. speckit.implement stays untouched to maintain backward compatibility.

## Critical Decisions

### Phase Gate Dependency Strategy
- **Choice:** "Last sequential task as phase gate" pattern. Phase N+1 is blocked by the last sequential task in Phase N (plus any trailing parallel tasks).
- **Alternatives:** All-to-all edges (every task in Phase N blocks every task in Phase N+1), or explicit user-defined gates.
- **Trade-off:** Fewer dependency edges means cleaner `bd dep tree` output, but subtly different from the strict "all tasks in phase must complete" model.
- **Feedback:** Is this dependency granularity appropriate, or should phase transitions require ALL tasks to complete?

### Resume Detection Threshold
- **Choice:** 50% title match ratio between beads issues and tasks.md task IDs.
- **Alternatives:** Exact match, any match, or metadata-based detection (storing spec path in beads config).
- **Trade-off:** 50% is tolerant of minor task renames but might misidentify similar task sets from different specs.
- **Feedback:** Should we use a higher threshold, or store the spec directory path in beads metadata for exact matching?

## Areas of Potential Disagreement

### Single-File Change
- **Decision:** All changes go into `sdd/skills/implement/SKILL.md`, no new skills or helper scripts
- **Why this might be controversial:** The SKILL.md will grow significantly. Some might prefer extracting beads logic into a separate skill or helper document.
- **Alternative view:** Create `sdd/skills/implement-beads/SKILL.md` as a standalone skill invoked by implement
- **Seeking input on:** Is growing the implement SKILL.md acceptable, or should we factor out beads instructions?

### Beads as SHOULD for Discovered Work
- **Decision:** FR-012 uses SHOULD (not MUST) for creating discovered work issues
- **Why this might be controversial:** This makes the P3 user story (discovered work) partially optional at the agent's discretion
- **Alternative view:** Make it MUST to ensure all discovered work is tracked
- **Seeking input on:** Should discovered work tracking be mandatory or best-effort?

## Naming Decisions

| Item | Name | Context |
|------|------|---------|
| Flag | `--with-beads` | Passed as argument to `/sdd:implement` |
| Discovered prefix | `DISCOVERED:` | Prefix in beads issue titles for non-planned work |
| Sync-back section | `## Discovered During Implementation` | Heading appended to tasks.md |
| Discovered task format | `- [X] DISCOVERED: <title>` | Format for discovered tasks in tasks.md |

## Architecture Choices

- **Pattern:** Conditional branching within existing skill (Path A / Path B)
- **Components:** Flag parser, tasks.md parser, beads bootstrap, execution loop, sync-back
- **Integration:** `bd` CLI via bash commands with `--json` output for machine parsing

## Open Questions

- [ ] Should the resume detection use metadata (spec path stored in beads config) instead of title matching?
- [ ] Should discovered work tracking be MUST or SHOULD?

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| SKILL.md becomes too large to follow | Medium | Clear section headers, conditional branching clearly marked |
| beads CLI behavior changes between versions | Low | Use `--json` output which is stable API |
| Circular dependency detection misses edge cases | Low | Explicit user prompt when bd ready returns empty with open issues |

---
*Share this with reviewers. Full context in linked spec and plan.*
