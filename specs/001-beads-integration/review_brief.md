# Review Brief: Beads Integration for SDD Implementation

**Spec:** specs/001-beads-integration/spec.md | **Plan:** specs/001-beads-integration/plan.md
**Generated:** 2026-02-13

> Reviewer's guide to scope and key decisions. See full spec/plan for details.

---

## Feature Overview

Adds a `--with-beads` flag to `/sdd:implement` that uses the beads issue tracker as the runtime execution engine instead of speckit.implement. This gives the implementation phase persistent memory across Claude Code sessions, dependency-aware task ordering via beads' DAG, and the ability to track discovered work. Without the flag, behavior is unchanged.

The change modifies a single file: `sdd/skills/implement/SKILL.md`.

## Scope Boundaries

- **In scope:** Flag routing, tasks.md parsing and conversion to beads issues, beads-driven execution loop, multi-session resume, sync-back to tasks.md
- **Out of scope:** Modifying speckit.implement, new skills, beads installation, multi-agent coordination
- **Why these boundaries:** Surgical change with zero regression risk for existing users

## Critical Decisions

### Phase Gate Strategy
- **Choice:** Last sequential task in Phase N blocks Phase N+1 (not all tasks)
- **Trade-off:** Cleaner dependency graph vs. strict "all tasks complete" gating
- **Feedback:** Is this the right granularity?

### Resume Detection
- **Choice:** Match beads issue titles against tasks.md task IDs with 50% threshold
- **Trade-off:** Simple and robust vs. potential false positives from similar task sets
- **Feedback:** Should we use spec-path metadata instead?

## Areas of Potential Disagreement

### Growing SKILL.md vs. New Skill
- **Decision:** All beads logic lives in the existing implement SKILL.md
- **Alternative:** Factor beads into a separate `implement-beads` skill
- **Seeking input on:** Is the single-file approach acceptable?

### Discovered Work: SHOULD vs. MUST
- **Decision:** FR-012 uses SHOULD, making discovered work tracking best-effort
- **Alternative:** Promote to MUST for guaranteed tracking
- **Seeking input on:** Should this be mandatory?

## Naming Decisions

| Item | Name | Context |
|------|------|---------|
| Flag | `--with-beads` | CLI argument to /sdd:implement |
| Discovered prefix | `DISCOVERED:` | Beads issue title prefix |
| Sync-back heading | `## Discovered During Implementation` | Appended to tasks.md |

## Open Questions

- [ ] Resume detection: title matching vs. metadata-based?
- [ ] Discovered work: MUST or SHOULD?

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| SKILL.md size growth | Medium | Clear section headers, conditional branching |
| Beads CLI version drift | Low | Use stable `--json` API |

---
*Share with reviewers before implementation.*
