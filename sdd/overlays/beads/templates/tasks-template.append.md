
<!-- SDD-TRAIT:beads -->
## Beads Task Management

This project uses beads (`bd`) for persistent task tracking across sessions:
- `bd ready --json` returns unblocked tasks (dependencies resolved)
- `bd done <id>` marks a task complete
- `bd sync` persists state to git
- `bd create --title "DISCOVERED: ..." --labels discovered` tracks new work
- `bd list --status open` shows remaining work
Tasks from this file are bootstrapped as beads issues via `{Skill: sdd:beads-execute}`.
