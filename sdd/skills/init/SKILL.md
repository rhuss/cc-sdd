---
name: init
description: Deterministic, non-interactive initialization and update of spec-kit for Claude Code environments. Single source of truth for all specify CLI setup.
---

# Spec-Kit Initialization

## Overview

Deterministic, non-interactive initialization of spec-kit for Claude Code environments. This skill is the single source of truth for all `specify` CLI setup operations.

## CRITICAL: Correct Invocation

The ONLY correct way to initialize spec-kit in Claude Code (non-TTY) environments:

```bash
specify init --here --ai claude --force
```

**NEVER call bare `specify init`** without these flags. The bare command prompts interactively (directory selection, AI provider arrow-key selector, confirmation) and hangs in non-TTY environments.

| Flag | Purpose |
|------|---------|
| `--here` | Use current directory (skips directory picker) |
| `--ai claude` | Select AI provider (skips arrow-key selector) |
| `--force` | Overwrite existing config (skips confirmation) |

## Argument Handling

Check if `--update` was passed as an argument:

- **If `--update` is present**: Execute the **Update Protocol** below
- **Otherwise**: Execute the **Standard Initialization Protocol**

## Standard Initialization Protocol

### Step 1: Check specify CLI Installation

```bash
which specify
```

**If NOT found:**

```
The 'specify' CLI is required but not installed.

Install with:
  uv pip install specify-cli

IMPORTANT: The CLI command is 'specify' (not 'speckit').
           The package is 'specify-cli' (not 'spec-kit').
```

**STOP and wait for user to install.**

**If found:**
```bash
specify version
```

Proceed to step 2.

### Step 2: Check Project Initialization

```bash
[ -d .specify ] && echo "initialized" || echo "not-initialized"
```

**If NOT initialized:**

```
specify CLI is installed.

This project needs initialization...
Running: specify init --here --ai claude --force
```

```bash
specify init --here --ai claude --force
```

**Check for errors:**
- Permission denied: suggest running with proper permissions
- Command failed: display error and suggest manual troubleshooting
- Success: proceed to step 3

**If already initialized:**
Skip to step 3.

### Step 3: Check for Slash Commands (Restart Detection)

After `specify init` runs, check if local commands were installed:

```bash
if [ -d .claude/commands ]; then
  ls .claude/commands/ | grep -q speckit
  if [ $? -eq 0 ]; then
    echo "commands-installed"
  fi
fi
```

**If commands were newly installed:**

```
Project initialized successfully!

RESTART REQUIRED

spec-kit has installed local slash commands in:
  .claude/commands/speckit.*

To load these new commands, please:
1. Save your work
2. Close this conversation
3. Restart Claude Code application
4. Return to this project
5. Continue your workflow

After restart, you'll have access to:
- /sdd:* commands (from this plugin)
- /speckit.* commands (from local spec-kit installation)

[Workflow paused - resume after restart]
```

**STOP workflow.** User must restart before continuing.

**If no new commands installed:**
Proceed to step 4.

### Step 4: Verify Installation

Quick sanity check:

```bash
[ -f .specify/templates/spec-template.md ] && \
[ -d .claude/commands ] && \
ls .claude/commands/speckit.* >/dev/null 2>&1 && \
echo "verified" || echo "incomplete"
```

**If verification fails:**

```
.specify/ exists but slash commands or templates are missing.

Running: specify init --here --ai claude --force
```

```bash
specify init --here --ai claude --force
```

Then prompt restart if new commands were installed.

**If verification succeeds:**
Proceed to step 5.

### Step 5: Ensure Constitution Symlink

The `/speckit.constitution` command expects the constitution at `.specify/memory/constitution.md`, but the canonical location is `specs/constitution.md`. Ensure a symlink bridges the two:

```bash
if [ -f "specs/constitution.md" ] && [ ! -e ".specify/memory/constitution.md" ]; then
  mkdir -p .specify/memory
  ln -s ../../specs/constitution.md .specify/memory/constitution.md
  echo "symlink-created: .specify/memory/constitution.md -> specs/constitution.md"
elif [ -f ".specify/memory/constitution.md" ] && [ ! -L ".specify/memory/constitution.md" ] && [ ! -f "specs/constitution.md" ]; then
  mv .specify/memory/constitution.md specs/constitution.md
  ln -s ../../specs/constitution.md .specify/memory/constitution.md
  echo "moved-and-linked: constitution.md -> specs/constitution.md"
else
  echo "constitution-ok"
fi
```

**After symlink step:**
- Set session flag: "sdd_init_done"
- Return success to calling skill
- Calling skill continues with its workflow

## Update Protocol

Triggered when `--update` argument is present.

### Step 1: Detect Installation Method

```bash
if command -v brew &>/dev/null && brew list specify-cli &>/dev/null 2>&1; then
  echo "install-method: homebrew"
elif uv pip show specify-cli &>/dev/null 2>&1; then
  echo "install-method: uv"
elif pip show specify-cli &>/dev/null 2>&1; then
  echo "install-method: pip"
else
  echo "install-method: unknown"
fi
```

### Step 2: Update CLI

Based on detection from step 1:

**Homebrew (macOS):**
```bash
brew upgrade specify-cli
```

**uv (preferred):**
```bash
uv pip install --upgrade specify-cli
```

**pip:**
```bash
pip install --upgrade specify-cli
```

**Unknown:**
```
Cannot determine installation method.

Please update manually:
  uv pip install --upgrade specify-cli
```

### Step 3: Verify Updated Version

```bash
specify version
```

Report the new version to the user.

### Step 4: Refresh Project Setup

```bash
specify init --here --ai claude --force
```

This updates slash commands and templates to the latest version.

### Step 5: Report and Restart

Check if new or updated commands were installed:

```bash
ls .claude/commands/speckit.* 2>/dev/null
```

Report changes to user. If commands were added or updated, prompt restart:

```
Update complete!

Version: [new version]
Commands refreshed in .claude/commands/

RESTART REQUIRED to load updated slash commands.
Please restart Claude Code and continue your workflow.
```

## Session Tracking

```bash
# Check if already initialized this session
# Use an environment variable or similar mechanism
# If "sdd_init_done" flag is set, skip to step 4 (verify)
```

Subsequent calls in the same session skip the full protocol and only verify critical paths.

## Remember

- **NEVER** call bare `specify init` without flags
- **ALWAYS** use `specify init --here --ai claude --force`
- This skill is infrastructure, not workflow
- Workflow skills delegate here via `{Skill: spec-kit}` which calls `{Skill: sdd:init}`
