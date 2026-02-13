---
name: init
description: Run the sdd-init.sh script. Do not check for CLI tools or explore the filesystem.
---

# Step 1: Run the Script

Do not run any other commands before this. No `which`, no `--version`, no `Search`, no `Glob`, no `Grep`, no `ls`, no `find`. The script handles everything.

Extract `PLUGIN_ROOT` from the `<sdd-context>` system reminder injected by the UserPromptSubmit hook. Use the value from `<plugin-root>`. Then run:

```bash
"$PLUGIN_ROOT/scripts/sdd-init.sh" [--refresh|--update]
```

Arguments: `--update` (upgrade CLI + refresh), `--refresh` (re-download templates), or no args (fast check + init if needed). Run from the project's working directory (not the plugin directory).

# Step 2: Interpret Output

| Output | Exit Code | Action |
|--------|-----------|--------|
| `READY` | 0 | Proceed to **Step 3** |
| `RESTART_REQUIRED` | 3 | Proceed to **Step 3** (tell user to restart AFTER Step 3) |
| `NEED_INSTALL` | 2 | Show the script's output to the user and STOP |
| `ERROR: ...` | 1 | Show error, suggest troubleshooting |

Do NOT run any verification commands after the script. Do NOT call `specify version`, `specify --version`, or `specify check`.

# Step 3: SDD Configuration

**This step MUST always run when exit code was 0 or 3.**

Use a single `AskUserQuestion` call with TWO questions:

1. First question (`multiSelect: true`):
   - **Question**: "Which SDD traits do you want to enable?"
   - **Header**: "Traits"
   - **Options**:
     - Label: "sdd", Description: "SDD quality gates on speckit commands (review-spec, review-code, verification)"
     - Label: "beads", Description: "Beads memory integration for persistent task execution across sessions"

2. Second question (`multiSelect: false`):
   - **Question**: "How should SDD commands handle permission prompts?"
   - **Header**: "Permissions"
   - **Options**:
     - Label: "Standard (Recommended)", Description: "Auto-approve SDD plugin scripts (sdd-init.sh, sdd-traits.sh)"
     - Label: "YOLO", Description: "Auto-approve everything: Bash, Read, Edit, Write, MCP, specify CLI"
     - Label: "None", Description: "Confirm every SDD command before execution"

After the user responds, apply both selections via Bash:

```bash
"$PLUGIN_ROOT/scripts/sdd-traits.sh" init --enable <selected-traits>
"$PLUGIN_ROOT/scripts/sdd-traits.sh" permissions <none|standard|yolo>
```

If no traits were selected, run `init` without `--enable`.

# Step 4: Final Report

Summarize:
- Which traits are enabled.
- Which auto-approval level was set.
- If the init script exit code was 3 (`RESTART_REQUIRED`), or if permissions changed (`CHANGED` in output), tell the user to restart Claude Code.
