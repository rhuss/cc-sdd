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
which specify
```

**If NOT found:**

The `specify` CLI is not installed. Run initialization to bootstrap it:

```bash
specify init
```

This will:
- Download and install the spec-kit CLI components
- Create the `.specify/` directory structure
- Install templates and scripts

If `specify init` fails (command not found), provide installation instructions:
```
❌ ERROR: 'specify' command not found

The specify CLI needs to be installed first.

Installation options (preferred first):
1. uv: uv pip install specify-cli
2. pip: pip install specify-cli
3. npm: npm install -g @anthropic/specify
4. Manual: Visit https://github.com/anthropics/specify

After installation, run: specify init
```

**If found:**
```bash
# Get version for logging
specify --version
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
specify CLI is installed ✓

This project needs initialization...
Running: specify init
```

Execute initialization:
```bash
specify init
```

**Check for errors:**
- Permission denied → suggest running with proper permissions
- Command failed → display error and suggest manual init
- Success → proceed to step 3

**If already initialized:**
Skip to step 3.

### Step 3: Check for New Commands (Restart Detection)

After `specify init` runs, check if local commands were installed:

```bash
# Check if spec-kit installed Claude Code commands
if [ -d .claude/commands ]; then
  ls .claude/commands/ | grep -q specify
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

Please run: specify init --force

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
- Run `specify specify` directly
```

### Path Resolution Priority

When resolving a spec path:

1. **Exact path if provided** (e.g., `specs/0001-auth/spec.md`)
2. **Match by feature name in numbered directory** (e.g., `auth` → `specs/0001-auth/spec.md`)
3. **Match by feature name in features directory** (e.g., `auth` → `specs/features/auth.md`)

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

### Standard Discovery Instructions for Skills

Skills that require a spec should include this at workflow start:

```markdown
## Spec Selection

If no spec is specified, discover available specs:

\`\`\`bash
# List all specs in the project
fd -t f "spec.md" specs/ 2>/dev/null | head -20
\`\`\`

**If specs found:** Present list and ask user to select one.
**If no specs found:** Inform user and suggest using `sdd:brainstorm` or `sdd:spec` first.
```

## Local Command Detection

When a project has been initialized with spec-kit, local slash commands may be available:

```bash
# Check for local spec-kit commands
if ls .claude/commands/speckit.* 2>/dev/null | grep -q specify; then
  echo "Local spec-kit commands available:"
  ls .claude/commands/speckit.* | xargs -n1 basename | sed 's/\.md$//'
fi
```

**Available local commands (when installed):**
- `/speckit.plan` - Generate implementation plan from spec
- `/speckit.tasks` - Generate task list from spec
- `/speckit.validate` - Validate spec format
- `/speckit.clarify` - Find underspecified areas
- `/speckit.analyze` - Cross-artifact consistency check

**Preference order:**
1. Use local `/speckit.*` commands when available (more integrated)
2. Fall back to `specify` CLI commands via bash
3. NEVER generate internally

When local commands are detected, inform the user they can invoke these directly for more control over the workflow.

## Spec-Kit CLI Commands

Wrapper helpers for common spec-kit commands:

### Initialize Project

```bash
# Already covered in automatic initialization
specify init
```

### Create Specification

```bash
# Interactive spec creation
specify specify [feature-description]

# Uses template from .specify/templates/spec-template.md
# Creates: specs/[NNNN]-[feature-name]/spec.md
```

### Validate Specification

```bash
# Validate spec format and structure
specify validate <spec-file>

# Example:
specify validate specs/0001-user-auth/spec.md
```

### Generate Plan

```bash
# Generate implementation plan from spec
specify plan <spec-file>

# Example:
specify plan specs/0001-user-auth/spec.md

# Creates: specs/0001-user-auth/plan.md
```

### Generate Tasks

```bash
# Generate task list with dependency ordering from spec
specify tasks <spec-file>

# Example:
specify tasks specs/0001-user-auth/spec.md

# Creates: specs/0001-user-auth/tasks.md
```

### Clarify Specification

```bash
# Identify underspecified areas in a spec
specify clarify <spec-file>

# Example:
specify clarify specs/0001-user-auth/spec.md

# Output: List of areas that need more detail
# Use this after creating a spec to find gaps
```

### Analyze Artifacts

```bash
# Cross-artifact consistency check
specify analyze <feature-dir>

# Example:
specify analyze specs/0001-user-auth/

# Checks consistency between:
# - spec.md (requirements)
# - plan.md (implementation approach)
# - tasks.md (task list)
# Reports any mismatches or gaps
```

### Create Constitution

```bash
# Interactive constitution creation
specify constitution

# Creates .specify/memory/constitution.md
```

## Error Handling

### spec-kit CLI Errors

**Command not found after installation:**
- Check PATH configuration
- Suggest shell restart
- Provide which specify output

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

## Command Summary

| Command | Purpose | Creates |
|---------|---------|---------|
| `specify init` | Initialize project | `.specify/` directory |
| `specify specify` | Create specification | `specs/[NNNN]-[name]/spec.md` |
| `specify validate` | Validate spec format | (validation only) |
| `specify plan` | Generate implementation plan | `specs/[name]/plan.md` |
| `specify tasks` | Generate task list | `specs/[name]/tasks.md` |
| `specify clarify` | Find underspecified areas | (analysis only) |
| `specify analyze` | Cross-artifact consistency | (analysis only) |
| `specify constitution` | Create project constitution | `.specify/memory/constitution.md` |

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
