---
name: sdd:beads-task-sync
description: Sync tasks.md with beads issues - creates bd issues from tasks, maps dependencies, updates checkboxes
argument-hint: "[<spec-dir>] [--reverse | --status | --dry-run]"
---

# Beads Task Sync

Run the beads sync script to synchronize tasks.md with bd issues.

## Detect tasks file

If a spec-dir argument is provided, use `<spec-dir>/tasks.md`.
Otherwise, detect from the current feature branch or most recent spec directory under `specs/`.

## Execute sync

Run the sync script from `<sdd-context>`:

```bash
"<sdd-beads-sync-command>" "<tasks-file>" [flags]
```

Pass through any flags provided by the user:
- `--reverse`: Update tasks.md checkboxes from bd issue status
- `--status`: Show sync status without making changes
- `--dry-run`: Preview what would be created without executing

If no flags are given, perform a forward sync (create bd issues from tasks.md).

## Report results

Display the sync summary output from the script.
