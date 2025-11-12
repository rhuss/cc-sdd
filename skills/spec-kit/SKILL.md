---
name: spec-kit
description: Technical integration layer for spec-kit CLI - handles automatic initialization, installation validation, project setup, and ensures proper file/directory layout. Called by all SDD workflow skills.
---

# Spec-Kit Technical Integration

## Purpose

This skill is the **single source of truth** for all spec-kit technical integration:
- Automatic initialization and setup
- Installation validation
- Project structure management
- CLI command wrappers
- Layout and file path enforcement

**This is a low-level technical skill.** Workflow skills (brainstorm, implement, etc.) call this skill for setup, then proceed with their specific workflows.

## Automatic Initialization Protocol

**IMPORTANT: This runs automatically when called by any workflow skill.**

Every SDD workflow skill calls this skill first via `{Skill: spec-kit}`. When called, execute this initialization sequence once per session.

### Session Tracking

```bash
# Check if already initialized this session
# Use an environment variable or similar mechanism
# If "sdd_init_done" flag is set, skip to step 4
```

### Step 1: Check spec-kit CLI Installation

```bash
which speckit
```

**If NOT found:**
```
❌ ERROR: spec-kit is required but not installed

spec-kit provides the templates, scripts, and tooling for SDD workflows.

Installation:
1. Visit: https://github.com/github/spec-kit
2. Follow installation instructions
3. Ensure 'speckit' is in your PATH
4. Verify: run 'which speckit'

After installation, restart this workflow.
```

**STOP workflow.** Do not proceed without spec-kit.

**If found:**
```bash
# Get version for logging
speckit --version
```

Proceed to step 2.

### Step 2: Check Project Initialization

```bash
# Check if .specify/ directory exists
[ -d .specify ] && echo "initialized" || echo "not-initialized"
```

**If NOT initialized:**

Display message:
```
spec-kit is installed ✓

This project needs initialization...
Running: speckit init
```

Execute initialization:
```bash
speckit init
```

**Check for errors:**
- Permission denied → suggest running with proper permissions
- Command failed → display error and suggest manual init
- Success → proceed to step 3

**If already initialized:**
Skip to step 3.

### Step 3: Check for New Commands (Restart Detection)

After `speckit init` runs, check if local commands were installed:

```bash
# Check if spec-kit installed Claude Code commands
if [ -d .claude/commands ]; then
  ls .claude/commands/ | grep -q speckit
  if [ $? -eq 0 ]; then
    echo "commands-installed"
  fi
fi
```

**If commands were installed:**

Display restart prompt:
```
✅ Project initialized successfully!

⚠️  RESTART REQUIRED ⚠️

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
# Verify key files exist
[ -f .specify/templates/spec-template.md ] && \
[ -f .specify/scripts/bash/common.sh ] && \
echo "verified" || echo "corrupt"
```

**If verification fails:**
```
❌ ERROR: .specify/ exists but appears incomplete

This may be due to a failed initialization.

Please run: speckit init --force

Then restart this workflow.
```

**STOP workflow.**

**If verification succeeds:**
- Set session flag: "sdd_init_done"
- Return success to calling skill
- Calling skill continues with its workflow

## Layout Validation

Use these helpers to validate spec-kit file structure:

### Check Constitution

```bash
# Constitution location (per spec-kit convention)
CONSTITUTION=".specify/memory/constitution.md"

if [ -f "$CONSTITUTION" ]; then
  echo "constitution-exists"
else
  echo "no-constitution"
fi
```

### Get Feature Spec Path

```bash
# Validate feature spec path follows spec-kit layout
# Expected: specs/NNNN-feature-name/spec.md
# Or: specs/features/feature-name.md

validate_spec_path() {
  local spec_path=$1

  # Check if follows spec-kit conventions
  if [[ $spec_path =~ ^specs/[0-9]+-[a-z-]+/spec\.md$ ]] || \
     [[ $spec_path =~ ^specs/features/[a-z-]+\.md$ ]]; then
    echo "valid"
  else
    echo "invalid: spec must be in specs/ directory with proper naming"
  fi
}
```

### Get Plan Path

```bash
# Plan location (per spec-kit convention)
# Expected: specs/NNNN-feature-name/docs/plan.md

get_plan_path() {
  local feature_dir=$1  # e.g., "specs/0001-user-auth"
  echo "$feature_dir/docs/plan.md"
}
```

### Ensure Directory Structure

```bash
# Create spec-kit compliant feature structure
ensure_feature_structure() {
  local feature_dir=$1  # e.g., "specs/0001-user-auth"

  mkdir -p "$feature_dir/docs"
  mkdir -p "$feature_dir/checklists"
  mkdir -p "$feature_dir/contracts"

  echo "created: $feature_dir structure"
}
```

## Spec-Kit CLI Commands

Wrapper helpers for common spec-kit commands:

### Initialize Project

```bash
# Already covered in automatic initialization
speckit init
```

### Create Specification

```bash
# Interactive spec creation
speckit specify [feature-description]

# Uses template from .specify/templates/spec-template.md
```

### Validate Specification

```bash
# Validate spec format and structure
speckit validate <spec-file>

# Example:
speckit validate specs/0001-user-auth/spec.md
```

### Generate Plan

```bash
# Generate implementation plan from spec
speckit plan <spec-file>

# Example:
speckit plan specs/0001-user-auth/spec.md
```

### Create Constitution

```bash
# Interactive constitution creation
speckit constitution

# Creates .specify/memory/constitution.md
```

## Error Handling

### spec-kit CLI Errors

**Command not found after installation:**
- Check PATH configuration
- Suggest shell restart
- Provide which speckit output

**Init fails:**
- Check write permissions
- Check disk space
- Suggest manual troubleshooting

**Validation fails:**
- Display validation errors
- Suggest fixes based on error type
- Reference spec template

### File System Errors

**Permission denied:**
```
Cannot write to project directory.

Please ensure you have write permissions:
  chmod +w .
```

**Path not found:**
```
Expected file not found: <path>

This suggests incomplete initialization.
Run: speckit init --force
```

## Integration Points

**Called by these workflow skills:**
- sdd:brainstorm (at start)
- sdd:implement (at start)
- sdd:evolve (at start)
- sdd:constitution (at start)
- sdd:review-spec (at start)
- All workflow skills that need spec-kit

**Calls:**
- spec-kit CLI (external command)
- File system operations
- No other skills (this is a leaf skill)

## Session Management

**First call in session:**
- Run full initialization protocol
- Check installation, project, commands
- Prompt restart if needed
- Set session flag

**Subsequent calls in session:**
- Check session flag
- Skip initialization if already done
- Optionally re-verify critical paths
- Return success immediately

**Session reset:**
- New conversation = new session
- Re-run initialization protocol
- Ensures project state is current

## Remember

**This skill is infrastructure, not workflow.**

- Don't make decisions about WHAT to build
- Don't route to other workflow skills
- Just ensure spec-kit is ready to use
- Validate paths and structure
- Handle technical errors

**Workflow skills handle:**
- What to create (specs, plans, code)
- When to use which tool
- Process discipline and quality gates

**This skill handles:**
- Is spec-kit installed?
- Is project initialized?
- Do files exist in correct locations?
- Are commands available?

**The goal: Zero-config, automatic, invisible setup.**
