
<!-- SDD-TRAIT:beads -->
## Beads Task Sync

After tasks.md is generated, sync tasks to beads for dependency-aware scheduling:

Run `"$PLUGIN_ROOT/sdd/scripts/sdd-beads-sync.py" "$SPEC_DIR/tasks.md"` to create bd issues from tasks.

This prepares beads for implementation before `/speckit.implement` is invoked.
If `bd` is not available, skip silently (beads sync is not blocking for planning).
