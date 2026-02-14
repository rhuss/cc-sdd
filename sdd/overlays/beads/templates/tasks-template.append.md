
<!-- SDD-TRAIT:beads -->
## Beads Task Management

This project uses beads (`bd`) for persistent task tracking across sessions:
- Run `/sdd:beads-task-sync` to create bd issues from this file
- `bd ready --json` returns unblocked tasks (dependencies resolved)
- `bd close <id>` marks a task complete
- `bd sync` persists state to git
- `bd create "DISCOVERED: ..." --labels discovered` tracks new work
- Run `/sdd:beads-task-sync --reverse` to update checkboxes from bd state
