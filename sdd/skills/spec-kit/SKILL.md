---
name: spec-kit
description: Technical integration layer for spec-kit - handles automatic initialization, installation validation, project setup, and ensures proper file/directory layout. Called by all SDD workflow skills.
---

# Spec-Kit Technical Integration

## CRITICAL NAMING - READ THIS FIRST

| What | Correct Name | WRONG Names |
|------|--------------|-------------|
| CLI command | `specify` | ~~speckit~~, ~~spec-kit~~ |
| Package name | `specify-cli` | ~~spec-kit~~, ~~speckit~~ |
| Slash commands | `/speckit.*` | (these are correct) |

**Installation:** `uv pip install specify-cli` or `pip install specify-cli`

## Purpose

This skill is the **single source of truth** for all spec-kit technical integration:
- Automatic initialization and setup
- Installation validation
- Project structure management
- Slash command availability
- Layout and file path enforcement

**This is a low-level technical skill.** Workflow skills (brainstorm, implement, etc.) call this skill for setup, then proceed with their specific workflows.

## CRITICAL: Understanding the Tool Architecture

**The `specify` CLI is a setup tool only.** It has three commands:
- `specify init` - Initialize a project with spec-kit templates and commands
- `specify check` - Check that required tools are installed
- `specify version` - Display version information

**All spec operations are done via `/speckit.*` slash commands**, which are installed by `specify init`:
- `/speckit.specify` - Create specifications
- `/speckit.plan` - Generate implementation plans
- `/speckit.tasks` - Generate task lists
- `/speckit.clarify` - Find underspecified areas
- `/speckit.analyze` - Cross-artifact consistency check
- `/speckit.checklist` - Generate quality checklists
- `/speckit.implement` - Execute implementation
- `/speckit.constitution` - Create project constitution

**NEVER call `specify validate`, `specify plan`, etc. - these commands don't exist!**

## Automatic Initialization Protocol

**IMPORTANT: This runs automatically when called by any workflow skill.**

Every SDD workflow skill calls this skill first via `{Skill: spec-kit}`. When called, execute this initialization sequence once per session.

### Session Tracking

```bash
# Check if already initialized this session
# Use an environment variable or similar mechanism
# If "sdd_init_done" flag is set, skip to step 4
```

### Step 1: Check specify CLI Installation

```bash
which specify
```

**If NOT found:**

Provide installation instructions:
```
The 'specify' CLI is required to initialize spec-kit.

Installation options (preferred first):
1. uv: uv pip install specify-cli
2. pip: pip install specify-cli
3. Manual: Visit https://github.com/anthropics/specify

After installation, run: specify init
```

**If found:**
```bash
# Get version for logging
specify version
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
specify CLI is installed

This project needs initialization...
Running: specify init
```

Execute initialization:
```bash
specify init
```

**Check for errors:**
- Permission denied: suggest running with proper permissions
- Command failed: display error and suggest manual init
- Success: proceed to step 3

**If already initialized:**
Skip to step 3.

### Step 3: Check for Slash Commands (Restart Detection)

After `specify init` runs, check if local commands were installed:

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
# Verify key files exist
[ -f .specify/templates/spec-template.md ] && \
[ -d .claude/commands ] && \
ls .claude/commands/speckit.* >/dev/null 2>&1 && \
echo "verified" || echo "incomplete"
```

**If verification fails:**
```
.specify/ exists but slash commands are missing.

Please run: specify init --force

Then restart Claude Code to load the new commands.
```

**STOP workflow.**

**If verification succeeds:**
- Set session flag: "sdd_init_done"
- Return success to calling skill
- Calling skill continues with its workflow

## Available Slash Commands

After `specify init`, these `/speckit.*` commands are available:

| Command | Purpose | Creates |
|---------|---------|---------|
| `/speckit.specify` | Create specification interactively | `specs/[NNNN]-[name]/spec.md` |
| `/speckit.plan` | Generate implementation plan | `specs/[name]/plan.md` |
| `/speckit.tasks` | Generate task list | `specs/[name]/tasks.md` |
| `/speckit.clarify` | Find underspecified areas | (analysis output) |
| `/speckit.analyze` | Cross-artifact consistency | (analysis output) |
| `/speckit.checklist` | Generate quality checklist | checklist file |
| `/speckit.implement` | Execute implementation | code files |
| `/speckit.constitution` | Create project constitution | `.specify/memory/constitution.md` |

**Usage in skills:**

When a skill needs to create a spec, plan, or tasks, it should:
1. Check that `/speckit.*` commands are available
2. Invoke the appropriate slash command
3. If commands not available, fall back to manual creation following templates

**Example:**
```
To create a spec, invoke: /speckit.specify

If /speckit.specify is not available (not initialized),
create the spec manually following .specify/templates/spec-template.md
```

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
# Expected: specs/NNNN-feature-name/plan.md

get_plan_path() {
  local feature_dir=$1  # e.g., "specs/0001-user-auth"
  echo "$feature_dir/plan.md"
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

## Spec Discovery

When a workflow skill requires a spec file and none is specified, use this discovery protocol.

### List Available Specs

```bash
# Find all spec.md files in specs/ directory
fd -t f "spec.md" specs/ 2>/dev/null || find specs/ -name "spec.md" -type f 2>/dev/null

# Also check for direct .md files in specs/features/
ls specs/features/*.md 2>/dev/null
```

### Present Options to User

**If multiple specs found:**
Use AskUserQuestion to let user select which spec to use.

**If single spec found:**
Confirm with user before proceeding: "Found specs/0001-auth/spec.md. Use this spec?"

**If no specs found:**
Inform user and suggest creating one:
```
No specs found in specs/ directory.

To create a spec:
- Use `sdd:brainstorm` to refine ideas into a spec
- Use `sdd:spec` to create a spec from clear requirements
- Use `/speckit.specify` directly (if available)
```

### Path Resolution Priority

When resolving a spec path:

1. **Exact path if provided** (e.g., `specs/0001-auth/spec.md`)
2. **Match by feature name in numbered directory** (e.g., `auth` -> `specs/0001-auth/spec.md`)
3. **Match by feature name in features directory** (e.g., `auth` -> `specs/features/auth.md`)

```bash
# Resolve feature name to spec path
resolve_spec_path() {
  local feature_name=$1

  # Check numbered directory pattern first
  local numbered=$(fd -t f "spec.md" specs/ 2>/dev/null | grep -i "$feature_name" | head -1)
  if [ -n "$numbered" ]; then
    echo "$numbered"
    return
  fi

  # Check features directory
  local features="specs/features/${feature_name}.md"
  if [ -f "$features" ]; then
    echo "$features"
    return
  fi

  # Not found
  echo ""
}
```

## Error Handling

### specify CLI Errors

**Command not found:**
- Provide installation instructions
- Suggest uv or pip installation

**Init fails:**
- Check write permissions
- Check disk space
- Suggest manual troubleshooting

### Slash Command Errors

**Commands not available:**
- Check if `specify init` was run
- Check if restart is needed
- Suggest re-initialization

**Command execution fails:**
- Display error message
- Suggest checking spec format
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
Run: specify init --force
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
- `specify` CLI (for init only)
- `/speckit.*` slash commands (for all operations)
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

## CLI vs Slash Commands Summary

| Task | Tool | Command |
|------|------|---------|
| Initialize project | CLI | `specify init` |
| Check tools | CLI | `specify check` |
| Show version | CLI | `specify version` |
| Create spec | Slash | `/speckit.specify` |
| Generate plan | Slash | `/speckit.plan` |
| Generate tasks | Slash | `/speckit.tasks` |
| Find gaps | Slash | `/speckit.clarify` |
| Check consistency | Slash | `/speckit.analyze` |
| Generate checklist | Slash | `/speckit.checklist` |
| Execute implementation | Slash | `/speckit.implement` |
| Create constitution | Slash | `/speckit.constitution` |

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
- Is specify CLI installed?
- Is project initialized?
- Are /speckit.* commands available?
- Do files exist in correct locations?

**The goal: Zero-config, automatic, invisible setup.**
