---
name: spec-kit
description: Wrapper for spec-kit CLI operations - intelligent delegation to spec-kit commands with workflow discipline, TodoWrite tracking, and error handling
---

# Spec-Kit Integration

## Overview

This plugin integrates with spec-kit CLI to provide specification-driven development workflows in Claude Code.

**spec-kit is a REQUIRED dependency** - it provides the templates, scripts, and tooling that power the SDD workflow.

This skill:
- Delegates to spec-kit CLI commands
- Adds TodoWrite tracking for workflow progress
- Handles errors gracefully
- Provides context-aware guidance
- Integrates spec-kit with SDD workflows

## Prerequisites

### Required: Install spec-kit CLI

spec-kit must be installed and accessible in your PATH:

```bash
# Check if spec-kit is installed
which speckit

# Or check version
speckit --version
```

**If spec-kit is not installed:**

Install spec-kit following the instructions at the spec-kit repository. The plugin will not function without it.

### Required: Initialize spec-kit in your project

Before using SDD workflows, you must initialize spec-kit in your project:

```bash
# Initialize spec-kit in current project
speckit init
```

**This creates:**
- `.specify/` directory with templates and scripts
- `.specify/templates/` - Spec, plan, tasks, checklist templates
- `.specify/scripts/` - Shell scripts for automation
- `.specify/memory/` - Project constitution and context
- Configuration files

All SDD skills and commands expect these local project files to exist.

## When to Use

- When spec-kit CLI command would be helpful
- To validate spec format/structure
- To initialize spec-kit in project
- For spec-kit-specific operations

**Note:** Most SDD skills call this internally. Direct use is for spec-kit-specific tasks.

## Available Spec-Kit Commands

### 1. Initialize Spec-Kit

```bash
speckit init
```

**Creates:**
- `.specify/` directory structure
- Templates (spec, plan, tasks, checklist)
- Scripts (feature creation, setup, context management)
- Default configuration

**Use when:**
- First time using SDD in a project
- Setting up new project

### 2. Create Specification

```bash
speckit specify
```

**Interactive spec creation.**

**Use when:**
- Creating new spec (alternative to manual)
- Want spec-kit's guided workflow

**Called by:** `sdd:spec`, `sdd:brainstorm`

### 3. Create Constitution

```bash
speckit constitution
```

**Interactive constitution creation.**

**Use when:**
- Creating project constitution
- Want spec-kit's constitution template

**Called by:** `sdd:constitution`

### 4. Validate Specification

```bash
speckit validate specs/features/[feature].md
```

**Validates spec format and structure.**

**Use when:**
- Checking spec correctness
- Before implementation
- After spec changes

**Called by:** `sdd:review-spec`, `sdd:evolve`

### 5. Generate Plan

```bash
speckit plan specs/features/[feature].md
```

**Generates implementation plan from spec.**

**Use when:**
- Creating implementation plan
- Exploring spec structure

**Called by:** `sdd:writing-plans`

## Local Project Structure

After running `speckit init`, your project will have:

```
.specify/
├── templates/
│   ├── spec-template.md          # Feature specification template
│   ├── plan-template.md          # Implementation plan template
│   ├── tasks-template.md         # Task breakdown template
│   ├── checklist-template.md     # Quality checklist template
│   └── agent-file-template.md    # Agent context file template
├── scripts/
│   └── bash/
│       ├── create-new-feature.sh  # Create feature branch and spec
│       ├── check-prerequisites.sh # Check project prerequisites
│       ├── setup-plan.sh         # Set up implementation plan
│       ├── update-agent-context.sh # Update agent context files
│       └── common.sh             # Common utilities
└── memory/
    └── constitution.md           # Project constitution
```

## Workflow Integration

### Pattern 1: Spec Creation with Spec-Kit

```bash
# User invokes sdd:spec

# Skill delegates to spec-kit
speckit specify

# Add SDD validation on top
run sdd:review-spec
```

### Pattern 2: Spec Validation

```bash
# User runs sdd:review-spec

# Skill uses spec-kit validation
speckit validate [spec-file]

# Add SDD soundness checks
check implementability
check testability
```

### Pattern 3: Plan Generation

```bash
# User runs sdd:writing-plans

# Skill delegates to spec-kit
speckit plan [spec-file]

# Enhance with SDD requirements
add file paths
add test strategy
add validation
```

## The Process

### 1. Check Availability

```bash
# Check if spec-kit is available
which speckit

# If not available, ERROR
```

**If not available:**
- Stop workflow
- Instruct user to install spec-kit
- Provide installation instructions

### 2. Check Project Initialization

```bash
# Check if project is initialized
[ -d .specify ]

# If not initialized, prompt to run
speckit init
```

### 3. Determine Appropriate Command

**Based on user intent:**

| User Intent | Spec-Kit Command | SDD Enhancement |
|------------|------------------|-----------------|
| Create spec | `speckit specify` | + Validation |
| Create constitution | `speckit constitution` | + Review |
| Validate spec | `speckit validate` | + Soundness checks |
| Generate plan | `speckit plan` | + Implementation details |
| Initialize project | `speckit init` | + SDD setup |

### 4. Execute Command

**With error handling:**

```bash
# Execute command
speckit [command] [args]

# Capture output and errors
# Provide helpful feedback
```

**Common errors:**

**Spec-kit not found:**
```
Error: speckit command not found

spec-kit is required for SDD workflows.

Please install spec-kit and ensure it's in your PATH.

Installation: [link to spec-kit docs]
```

**Project not initialized:**
```
Error: .specify directory not found

This project has not been initialized with spec-kit.

Run: speckit init
```

**Invalid spec format:**
```
Error: Spec validation failed

Spec-kit validation errors:
- Missing required section: Purpose
- Invalid format for requirements

Fix these issues and re-run validation.
```

### 5. Add SDD Workflow Discipline

**After spec-kit command:**

- Run SDD validation (even if spec-kit validation passed)
- Create TodoWrite tasks if checklist workflow
- Integrate with git (commit specs)
- Link to next workflow step

### 6. Provide Next Steps

**Guide user:**

```
Spec created with spec-kit ✓
SDD validation complete ✓

Next steps:
1. Review spec for soundness (sdd:review-spec) [if not auto-done]
2. Create implementation plan (sdd:implement)
3. Or refine spec further
```

## Checklist

Use TodoWrite for spec-kit workflows:

**For spec creation:**
- [ ] Check spec-kit availability
- [ ] Check project initialization
- [ ] Run `speckit specify`
- [ ] Validate with SDD soundness checks
- [ ] Commit spec to git
- [ ] Offer next steps

**For validation:**
- [ ] Run `speckit validate`
- [ ] Add SDD-specific checks
- [ ] Report results
- [ ] Recommend fixes if issues

**For plan generation:**
- [ ] Run `speckit plan`
- [ ] Enhance with file paths
- [ ] Add test strategy
- [ ] Validate against spec
- [ ] Save plan

## Integration Points

**This skill is called by:**
- `sdd:spec` (for spec creation)
- `sdd:brainstorm` (for spec creation)
- `sdd:constitution` (for constitution creation)
- `sdd:review-spec` (for validation)
- `sdd:writing-plans` (for plan generation)

**This skill calls:**
- Spec-kit CLI commands
- Git (for commits)
- TodoWrite (for tracking)
- Local project scripts and templates

## Remember

**spec-kit is a required dependency.**

- Plugin does NOT bundle templates or scripts
- Templates and scripts live in local project (`.specify/`)
- Must run `speckit init` in each project
- Single source of truth: spec-kit repository

**Integration provides complete workflow:**

- spec-kit provides tooling and artifacts
- SDD adds workflow enforcement and discipline
- Together: powerful spec-driven development

**The goal is great specs with clear separation of concerns.**
