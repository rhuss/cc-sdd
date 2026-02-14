
<!-- SDD-TRAIT:beads -->
## Beads Memory Integration

This project uses beads for persistent agent memory and task execution.
Delegate implementation execution to {Skill: sdd:beads-execute} which handles:
- Bootstrapping beads issues from tasks.md via sync script
- Using `bd ready --json` for dependency-aware task scheduling
- Using `bd close` to mark tasks complete (NOT tasks.md directly)
- Running `bd sync` for git-backed state persistence
- Tracking discovered work via `bd create`

**IMPORTANT**: Do NOT update tasks.md after each task. Task state lives in bd
during implementation. A single reverse sync at the end updates tasks.md.
