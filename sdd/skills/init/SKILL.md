---
name: init
description: Run the sdd-init.sh script. Do not check for CLI tools or explore the filesystem.
---

# SDD Init

The `<sdd-context>` system reminder (injected by the hook) contains two pre-resolved commands. Use them exactly as shown. Do not construct paths yourself. Do not run any other commands.

## Step 1: Run init

Run the command from `<sdd-init-command>` in `<sdd-context>`:

```bash
"<value from sdd-init-command>"
```

This is your FIRST Bash call. Do not run anything before it. No `which`, no `specify`, no file searches.

- If output contains `NEED_INSTALL` (exit 2): show output to user, STOP.
- If output contains `ERROR` (exit 1): show error, STOP.
- If output contains `READY` or `RESTART_REQUIRED` (exit 0 or 3): continue to Step 2 immediately. Do not summarize yet. Do not tell the user to restart yet.

## Step 2: Configure traits and permissions

This step is mandatory. Without it, no traits are enabled and the overlay system does not work.

Use `AskUserQuestion` with TWO questions:

1. (`multiSelect: true`, header: "Traits"): "Which SDD traits do you want to enable?"
   - "sdd": "SDD quality gates on speckit commands (review-spec, review-code, verification)"
   - "beads": "Beads memory integration for persistent task execution across sessions"

2. (`multiSelect: false`, header: "Permissions"): "How should SDD commands handle permission prompts?"
   - "Standard (Recommended)": "Auto-approve SDD plugin scripts (sdd-init.sh, sdd-traits.sh)"
   - "YOLO": "Auto-approve everything: Bash, Read, Edit, Write, MCP, specify CLI"
   - "None": "Confirm every SDD command before execution"

After the user responds, run these using `<sdd-traits-command>` from `<sdd-context>`:

```bash
"<value from sdd-traits-command>" init --enable <selected-traits>
"<value from sdd-traits-command>" permissions <none|standard|yolo>
```

If no traits were selected, run `init` without `--enable`.

## Step 3: Report

Now summarize: which traits are enabled, which permission level was set. If Step 1 said `RESTART_REQUIRED` or Step 2 permissions said `CHANGED`, tell the user to restart Claude Code.
