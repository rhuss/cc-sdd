
<!-- SDD-TRAIT:beads -->
## Beads Memory Integration

This project uses beads for persistent agent memory and task execution.
Delegate implementation execution to {Skill: sdd:beads-execute} which handles:
- Bootstrapping beads issues from tasks.md via sync script
- Using `bd ready --json` for dependency-aware task scheduling
- Using `bd close <id>` to mark tasks complete (NOT tasks.md directly)
  - Use `-r "reason"` to add a close reason (do NOT use `--comment`, it does not exist)
  - Use `bd comments add <id> "text"` for detailed notes
- Running `bd sync` for git-backed state persistence
- Tracking discovered work via `bd create` (crisp titles under 80 chars, details in comments)

**IMPORTANT**: Do NOT update tasks.md after each task. Task state lives in bd
during implementation. A single reverse sync at the end updates tasks.md.

**JSON parsing**: Always use `jq` to parse bd JSON output. NEVER use inline Python one-liners (they break on shell escaping). Use bd's built-in `--type`, `--label`, and `--assignee` flags to filter before piping to jq. NEVER use `2>&1` when piping to jq (stderr corrupts JSON). Always wrap jq filters with `if type == "object" and .error then error(.error) else ... end` to handle bd error responses gracefully.
