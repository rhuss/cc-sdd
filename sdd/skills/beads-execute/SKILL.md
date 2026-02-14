---
name: beads-execute
description: Beads-driven task execution - bootstraps issues from tasks.md, uses bd ready for scheduling, bd sync for persistence
---

# Beads-Driven Task Execution

## Overview

This skill handles implementation execution through beads, providing persistent memory and dependency-aware task scheduling across sessions.

## Prerequisites

Check that the `bd` CLI is available and the database is initialized:

```bash
if ! command -v bd &>/dev/null; then
  echo "ERROR: beads CLI (bd) is not installed."
  echo ""
  echo "Install beads to use this feature:"
  echo "  See https://github.com/beads-project/beads for installation instructions"
  echo ""
  echo "Without beads, use /speckit.implement directly for standard task execution."
  exit 1
fi

# Initialize database if not present (safety net for cases where
# sdd-traits.sh enable was not run, e.g. manual trait config edits)
if ! bd list --json &>/dev/null; then
  bd init
  echo "Initialized beads database."
fi
```

If `bd` is not available, report the error and stop. Do not fall back to non-beads execution within this skill.

## 1. Bootstrap Beads Issues from tasks.md

Use the sync script to programmatically create bd issues from tasks.md:

```bash
SPEC_DIR="specs/[feature-name]"

# Run forward sync to create issues, map dependencies, add bd markers
"<sdd-beads-sync-command>" "$SPEC_DIR/tasks.md"
```

This handles:
- Creating phase epics and child task issues
- Mapping sequential and inter-phase dependencies
- Marking already-completed tasks as closed
- Inserting `(bd-XXXX)` markers into tasks.md for traceability
- Idempotent re-runs (skips already-synced tasks)

## 2. Dependency-Aware Task Scheduling

Use `bd ready` to get the next unblocked task:

```bash
# Get next ready task (all dependencies resolved)
NEXT=$(bd ready --json | jq -r '.[0]')

while [ "$NEXT" != "null" ] && [ -n "$NEXT" ]; do
  TASK_ID=$(echo "$NEXT" | jq -r '.id')
  TASK_TITLE=$(echo "$NEXT" | jq -r '.title')

  echo "Working on: $TASK_TITLE"

  # Execute the task (implementation work happens here)
  # ... task-specific implementation ...

  # Mark task complete
  bd close "$TASK_ID"

  # Sync state to git
  bd sync

  # Get next ready task
  NEXT=$(bd ready --json | jq -r '.[0]')
done
```

## 3. Git-Backed State Persistence

After completing each task (or group of parallel tasks), persist state:

```bash
bd sync
```

This ensures:
- Task completion state survives session restarts
- Other agents can see which tasks are done
- Progress is recoverable if a session is interrupted

## 4. Discovered Work Tracking

During implementation, new tasks may emerge. Create bd issues for them but do NOT edit tasks.md directly:

```bash
# When implementation reveals new work not in tasks.md
bd create "DISCOVERED: [description]" --labels "discovered"
```

Discovered work should be:
- Clearly labeled as discovered (not in original tasks.md)
- Given appropriate dependencies
- Completed before the phase it belongs to is considered done

The reverse sync at completion will add discovered issues to tasks.md automatically.

## 5. Completion

When `bd ready --json` returns an empty list and all issues are done:

```bash
# Verify all issues are resolved
bd list --status open
# Should return empty

# Reverse sync to update tasks.md with all status changes and discovered work
"<sdd-beads-sync-command>" "$SPEC_DIR/tasks.md" --reverse

# Final sync
bd sync
```

Report the beads execution summary:
- Total tasks executed
- Discovered work items
- Any blocked tasks remaining

## Integration

**This skill is invoked by:**
- The beads trait overlay for `/speckit.implement`

**This skill requires:**
- `bd` CLI installed and available
- tasks.md with parseable task structure
