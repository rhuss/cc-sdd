
<!-- SDD-TRAIT:beads -->
## Beads Auto-Sync (MANDATORY)

After tasks.md has been written, you MUST sync tasks to beads immediately.
This is a required step, not optional. Do not skip it.

```bash
"<sdd-beads-sync-command>" "$SPEC_DIR/tasks.md"
```

Report the sync results:
- Number of bd issues created
- Number of dependencies mapped
- Any errors encountered

If `bd` is not installed, report the error clearly (do not skip silently).
If the sync script fails, report the error but do not delete the generated tasks.md.
