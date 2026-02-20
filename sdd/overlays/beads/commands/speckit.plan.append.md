
<!-- SDD-TRAIT:beads -->
## Beads Task Sync (MANDATORY)

After tasks.md is generated, you MUST sync tasks to beads immediately.
Do not move on to review or PR creation until this step completes.

```bash
"<sdd-beads-sync-command>" "$SPEC_DIR/tasks.md"
```

Report the sync results: number of bd issues created, dependencies mapped, errors encountered.

If `bd` is not installed, report the error clearly. Do not skip silently.
If the sync script fails, report the error. Do not proceed to implementation without synced beads issues.
