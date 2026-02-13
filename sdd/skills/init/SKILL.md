---
name: init
description: Deterministic, non-interactive initialization and update of spec-kit for Claude Code environments. Single source of truth for all specify CLI setup.
---

# Spec-Kit Initialization

## STOP: Read This First

**Do NOT explore.** Do NOT run `which`, `Search`, `Glob`, `Grep`, `find`, or any discovery commands. Do NOT search for `speckit`, `spec-kit`, or `.speckit`. The CLI is called `specify` (not `speckit`). The init script handles all CLI detection internally.

**Your ONLY action**: Run the init script. Nothing else.

1. Derive the plugin root from this file's path: this file is `skills/init/SKILL.md`, so the plugin root is `../../` relative to this file's directory.
2. Check arguments: `--update` (upgrade CLI + refresh), `--refresh` (re-download templates), or no args (fast check + init if needed).
3. Run this single Bash command from the project's working directory:

```bash
<plugin-root>/scripts/sdd-init.sh [--refresh|--update]
```

Then interpret the output per the table below. That's it. Do not run anything else before or after (except Trait Configuration if output is READY).

## Interpreting Script Output

The script prints a status keyword as its last meaningful line and uses exit codes:

| Output | Exit Code | Meaning | Action |
|--------|-----------|---------|--------|
| `READY` | 0 | Fully initialized | Return success, calling skill continues |
| `NEED_INSTALL` | 2 | `specify` CLI not found | Show install instructions from output, STOP |
| `RESTART_REQUIRED` | 3 | New slash commands installed | Show restart instructions from output, STOP |
| `ERROR: ...` | 1 | Something failed | Show error from output, suggest troubleshooting |

**When output is `READY`:** The calling skill can proceed immediately. Do NOT run any additional verification commands.

**When output is `NEED_INSTALL`:** Display the script's output to the user and STOP. Wait for user to install.

**When output is `RESTART_REQUIRED`:** Display the script's output to the user and STOP. User must restart Claude Code.

## Auto-Approval

To eliminate permission prompts for this script, add it to the project's allowed commands in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(*/scripts/sdd-init.sh*)"
    ]
  }
}
```

## CRITICAL: Correct Invocation (Reference)

The script uses these flags internally when calling `specify init`. This is documented here for reference only. The LLM should NOT call `specify init` directly; always use the script.

```bash
specify init --here --ai claude --force
```

**NEVER call bare `specify init`** without these flags. The bare command prompts interactively and hangs in non-TTY environments.

| Flag | Purpose |
|------|---------|
| `--here` | Use current directory (skips directory picker) |
| `--ai claude` | Select AI provider (skips arrow-key selector) |
| `--force` | Overwrite existing config (skips confirmation) |

## Trait Configuration

After the init script reports `READY`, configure SDD traits. Traits inject discipline overlays into spec-kit command and template files.

**Derive the plugin root** from this SKILL.md file's location: this file is at `skills/init/SKILL.md`, so the plugin root is `../../` relative to this file (the directory containing `scripts/`, `skills/`, `commands/`, `overlays/`).

### First-Time Setup (no `.specify/sdd-traits.json`)

If `.specify/sdd-traits.json` does not exist:

1. Use `AskUserQuestion` with `multiSelect: true` to ask:
   - **Question**: "Which SDD traits do you want to enable?"
   - **Header**: "Traits"
   - **Options**:
     - Label: "sdd", Description: "SDD quality gates on speckit commands (review-spec, review-code, verification)"
     - Label: "beads", Description: "Beads memory integration for persistent task execution across sessions"
2. Write `.specify/sdd-traits.json` using the Write tool with this schema:
   ```json
   {
     "version": 1,
     "traits": {
       "sdd": true_or_false,
       "beads": true_or_false
     },
     "applied_at": "ISO8601_timestamp"
   }
   ```
3. Run `<plugin-root>/scripts/apply-traits.sh` via Bash tool from the project working directory.
4. Report which traits were enabled and how many overlays were applied.

### Re-Init (`.specify/sdd-traits.json` already exists)

If `.specify/sdd-traits.json` already exists:

1. Read the file and display current trait settings to the user (e.g., "Current traits: sdd: enabled, beads: disabled").
2. Use `AskUserQuestion` to ask:
   - **Question**: "Traits are already configured. What would you like to do?"
   - **Header**: "Re-init"
   - **Options**:
     - Label: "Keep current", Description: "Keep existing trait settings and reapply overlays"
     - Label: "Reconfigure", Description: "Choose new trait settings"
3. If "Keep current": run `<plugin-root>/scripts/apply-traits.sh` to ensure overlays are applied.
4. If "Reconfigure": prompt for new trait selections (same as first-time setup), write updated config, run `apply-traits.sh`.

## Auto-Approval for apply-traits.sh

To eliminate permission prompts for the traits script, add to `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(*/scripts/apply-traits.sh*)"
    ]
  }
}
```

## Remember

- **NEVER run `which`, `Search`, `Glob`, `find`, or any exploratory commands.** The script detects everything.
- **The CLI is `specify`.** Not `speckit`. Not `spec-kit`. Not `spec_kit`. Only `specify`.
- **Always use the script.** Do not replicate its logic with inline bash commands.
- **One call, one result.** The script handles the fast path (already initialized) and slow path (needs setup) internally.
- **Do NOT call `specify version` separately.** The script skips it on the fast path for speed.
- This skill is infrastructure, not workflow.
- Workflow skills delegate here via `{Skill: spec-kit}` which calls `{Skill: sdd:init}`.
- **After init script completes with READY**, always proceed to the Trait Configuration section above.
