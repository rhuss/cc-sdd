# Review Summary: Brainstorm Persistence

**Spec:** specs/004-brainstorm-persistence/spec.md | **Plan:** specs/004-brainstorm-persistence/plan.md
**Generated:** 2026-02-20

> Distilled decision points for reviewers. See full spec/plan for details.

---

## Feature Overview

Extends the brainstorm skill to persist structured summary documents in a `brainstorm/` directory at the project root. Each `/sdd:brainstorm` session produces a numbered markdown file capturing problem framing, approaches considered, decisions made, and open threads. A `00-overview.md` index aggregates all sessions, open threads, and parked ideas into a single navigable view. This fills the gap between ephemeral conversation and formal spec by preserving the reasoning trail.

## Scope Boundaries

- **In scope:** Document creation at session end, overview index management, incomplete session save prompts, revisit detection for existing topics
- **Out of scope:** Template files in `.specify/templates/`, trait overlay mechanism, retroactive doc generation, cross-linking from spec back to brainstorm, search/filtering beyond the overview
- **Why these boundaries:** The feature is a core skill change (not trait-driven) that adds persistent output to an existing workflow. Keeping it contained to a single file modification (`SKILL.md`) minimizes complexity.

## Critical Decisions

### Flat directory at project root (not per-feature)

- **Choice:** Single `brainstorm/` directory at project root, shared across all features
- **Alternatives:** Per-feature inside `specs/NNNN-feature/brainstorm/`, or grouped by feature at `brainstorm/feature-name/`
- **Trade-off:** Flat structure is simpler and provides chronological project-wide view, but loses per-feature grouping. The overview index compensates by tracking which brainstorms led to which specs.
- **Feedback:** Is the flat structure sufficient, or would per-feature grouping be more useful as the project grows?

### Structured summary, not conversation transcript

- **Choice:** AI writes a distilled summary at session end (problem framing, approaches, decisions, open threads)
- **Alternatives:** Raw Q&A transcript, or hybrid with inline Q&A evidence
- **Trade-off:** Summaries are more useful for future reference but lose conversational nuance. The decision was user-driven.
- **Feedback:** Does the proposed document structure capture enough context to be useful months later?

### No template file

- **Choice:** Document structure defined inline in the skill prompt, not as a `.specify/templates/` file
- **Alternatives:** Formal template file managed by overlay/trait system
- **Trade-off:** Lightweight and avoids overlay complexity, but less discoverable and harder to customize per-project
- **Feedback:** Should this be a template file for consistency with the rest of spec-kit?

## Areas of Potential Disagreement

### Overview as full rebuild vs. incremental update

- **Decision:** Overview regeneration always does a full rebuild by scanning all documents (idempotent)
- **Why this might be controversial:** Full rebuild is wasteful for projects with many brainstorm documents. An incremental approach (update the specific entry) would be more efficient.
- **Alternative view:** Incremental updates with periodic full rebuilds as a consistency check
- **Seeking input on:** Is idempotent full-rebuild the right default, or should this be incremental with a `--rebuild` flag?

### Skill autonomy concern

- **Decision:** Brainstorm persistence is added to the existing brainstorm skill, not a separate skill
- **Why this might be controversial:** Constitution Principle VI (Skill Autonomy) says each skill should have "a clear, single purpose." Adding document management to a brainstorming skill could be seen as scope creep.
- **Alternative view:** Create a separate `brainstorm-persist` skill that the brainstorm skill delegates to
- **Seeking input on:** Is persistence a natural extension of the brainstorm skill's purpose, or a distinct responsibility?

## Naming Decisions

| Item | Name | Context |
|------|------|---------|
| Directory | `brainstorm/` | At project root, holds all brainstorm documents |
| Overview | `00-overview.md` | Zero-prefixed to sort first; contains index + threads |
| Documents | `NN-topic-slug.md` | Sequential number + topic slug (e.g., `01-auth-system.md`) |
| Statuses | active/parked/abandoned/spec-created | Lifecycle states for brainstorm documents |

## Architecture Choices

- **Pattern:** Extend existing skill prompt with new sections and checklist steps
- **Components:** Single file modification (`sdd/skills/brainstorm/SKILL.md`)
- **Integration:** Hooks into existing workflow at context exploration (revisit detection), spec creation (capture spec path), and transition (document + overview writing)

## Open Questions

- [ ] Should the brainstorm document include a link back from the spec to the brainstorm? (Currently out of scope, but could be useful)

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skill file becomes too long | Med | Keep new sections focused; document structure is a template, not prose |
| AI ignores new steps (same pattern as beads) | High | Use imperative language ("MUST"), numbered steps, hard gates where possible |
| Revisit detection false positives | Low | Simple keyword matching; user always has final say via AskUserQuestion |

---
*Share this with reviewers. Full context in linked spec and plan.*
