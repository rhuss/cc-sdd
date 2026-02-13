
<!-- SDD-TRAIT:beads -->
## Beads Memory Integration

This project uses beads for persistent agent memory and task execution.
Delegate implementation execution to {Skill: sdd:beads-execute} which handles:
- Bootstrapping beads issues from tasks.md
- Using `bd ready --json` for dependency-aware task scheduling
- Running `bd sync` for git-backed state persistence
- Tracking discovered work via `bd create`
