---
name: init
description: Deterministic, non-interactive initialization and update of spec-kit for Claude Code environments. Single source of truth for all specify CLI setup.
---

# Spec-Kit Initialization

## Overview

Deterministic, non-interactive initialization of spec-kit for Claude Code environments. This skill is the single source of truth for all `specify` CLI setup operations.

**Performance is critical.** This skill is called as a precondition by every SDD workflow skill. The entire check runs as a single script invocation.

## Argument Handling

Check if `--update` or `--refresh` was passed as an argument:

- **If `--update` is present**: Pass `--update` to the script (upgrades CLI + refreshes templates)
- **If `--refresh` is present**: Pass `--refresh` to the script (re-downloads templates only)
- **Otherwise**: Run the script with no arguments (fast check, init if needed)

## How to Run

The script is at `sdd/scripts/sdd-init.sh` within this plugin's root directory. Since this SKILL.md is at `sdd/skills/init/SKILL.md`, the script is two directories up at `sdd/scripts/sdd-init.sh`.

Use the absolute path derived from the plugin's installation location. For example, if this plugin is installed at `/path/to/cc-superpowers-sdd/`, run:

```bash
/path/to/cc-superpowers-sdd/sdd/scripts/sdd-init.sh
```

For refresh (re-download templates only):

```bash
/path/to/cc-superpowers-sdd/sdd/scripts/sdd-init.sh --refresh
```

For update (upgrade CLI + refresh templates):

```bash
/path/to/cc-superpowers-sdd/sdd/scripts/sdd-init.sh --update
```

**The script must be run from the project's working directory** (not the plugin directory), since it checks for `.specify/` and `.claude/commands/` relative to `pwd`.

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
      "Bash(*/sdd/scripts/sdd-init.sh*)"
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

## Remember

- **Always use the script.** Do not replicate its logic with inline bash commands.
- **One call, one result.** The script handles the fast path (already initialized) and slow path (needs setup) internally.
- **Do NOT call `specify version` separately.** The script skips it on the fast path for speed.
- This skill is infrastructure, not workflow.
- Workflow skills delegate here via `{Skill: spec-kit}` which calls `{Skill: sdd:init}`.
