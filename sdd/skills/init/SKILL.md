---
name: init
description: Run the sdd-init.sh script. Do not check for CLI tools or explore the filesystem.
---

# Step 1: Run the Script

Do not run any other commands before this. No `which`, no `--version`, no `Search`, no `Glob`, no `Grep`, no `ls`, no `find`. The script handles everything.

Derive the plugin root from this file's path (`skills/init/SKILL.md` -> plugin root is `../../`). Then run:

```bash
<plugin-root>/scripts/sdd-init.sh [--refresh|--update]
```

Arguments: `--update` (upgrade CLI + refresh), `--refresh` (re-download templates), or no args (fast check + init if needed). Run from the project's working directory (not the plugin directory).

# Step 2: Interpret Output

| Output | Exit Code | Action |
|--------|-----------|--------|
| `READY` | 0 | Proceed to **Step 3** (Trait Configuration below) |
| `NEED_INSTALL` | 2 | Show the script's output to the user and STOP |
| `RESTART_REQUIRED` | 3 | Show the script's output to the user and STOP |
| `ERROR: ...` | 1 | Show error, suggest troubleshooting |

Do NOT run any verification commands after the script. Do NOT call `specify version`, `specify --version`, or `specify check`.

# Step 3: Trait Configuration

Only reach this step if the script output was `READY`.

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

# Auto-Approval

To eliminate permission prompts, add to `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(*/scripts/sdd-init.sh*)",
      "Bash(*/scripts/apply-traits.sh*)"
    ]
  }
}
```
