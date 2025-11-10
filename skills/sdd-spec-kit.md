---
name: sdd-spec-kit
description: Wrapper for spec-kit CLI operations - intelligent delegation to spec-kit commands with workflow discipline, TodoWrite tracking, and error handling
---

# Spec-Kit CLI Integration

## Overview

Intelligent wrapper around spec-kit CLI that adds superpowers workflow discipline.

Spec-kit provides excellent tooling for specification management. This skill:
- Delegates to spec-kit CLI where beneficial
- Adds TodoWrite tracking
- Handles errors gracefully
- Provides context-aware guidance
- Integrates with SDD workflows

## When to Use

- When spec-kit CLI command would be helpful
- To validate spec format/structure
- To initialize spec-kit in project
- For spec-kit-specific operations

**Note:** Most SDD skills call this internally. Direct use is for spec-kit-specific tasks.

## Prerequisites

### Check if Spec-Kit is Available

```bash
which speckit
# or
speckit --version
```

**If not available:**
- Skill works without spec-kit (degraded mode)
- Recommend installation if frequent spec work
- Fall back to manual spec management

### Configuration

Check `.claude/settings.json`:

```json
{
  "sdd": {
    "spec_kit": {
      "enabled": true,
      "path": "speckit"  // or full path
    }
  }
}
```

## Available Spec-Kit Commands

### 1. Initialize Spec-Kit

```bash
speckit init
```

**Creates:**
- `.speckit/` directory
- Default configuration
- Template structure

**Use when:**
- First time using spec-kit in project
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

**Called by:** `sdd:reviewing-spec`, `sdd:evolve`

### 5. Generate Plan

```bash
speckit plan specs/features/[feature].md
```

**Generates implementation plan from spec.**

**Use when:**
- Creating implementation plan
- Exploring spec structure

**Called by:** `sdd:writing-plans`

## Workflow Integration

### Pattern 1: Spec Creation with Spec-Kit

```bash
# User invokes sdd:spec

# Skill checks if spec-kit available
if spec-kit available:
    # Use spec-kit for creation
    speckit specify
    # Add SDD validation on top
    run sdd:reviewing-spec
else:
    # Fall back to manual spec creation
    create markdown file
    # Still run SDD validation
    run sdd:reviewing-spec
```

### Pattern 2: Spec Validation

```bash
# User runs sdd:reviewing-spec

# Skill uses spec-kit validation
if spec-kit available:
    speckit validate [spec-file]
    # Add SDD soundness checks
    check implementability
    check testability
else:
    # Manual validation only
    check structure manually
    check completeness manually
```

### Pattern 3: Plan Generation

```bash
# User runs sdd:writing-plans

# Skill may use spec-kit
if spec-kit available AND spec-kit plan works well:
    speckit plan [spec-file]
    # Enhance with SDD requirements
    add file paths
    add test strategy
    add validation
else:
    # Generate plan manually
    parse spec
    create plan from scratch
```

## The Process

### 1. Check Availability

```bash
# Check if spec-kit is available
which speckit

# Check configuration
cat .claude/settings.json | grep spec_kit
```

**If not available:**
- Note in output
- Offer degraded mode
- Recommend installation if frequent use

### 2. Determine Appropriate Command

**Based on user intent:**

| User Intent | Spec-Kit Command | SDD Enhancement |
|------------|------------------|-----------------|
| Create spec | `speckit specify` | + Validation |
| Create constitution | `speckit constitution` | + Review |
| Validate spec | `speckit validate` | + Soundness checks |
| Generate plan | `speckit plan` | + Implementation details |
| Initialize project | `speckit init` | + SDD setup |

### 3. Execute Command

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

This skill integrates with spec-kit CLI for enhanced spec management.

Options:
1. Install spec-kit: https://github.com/github/spec-kit
2. Continue without spec-kit (degraded mode)

Continuing in degraded mode...
```

**Invalid spec format:**
```
Error: Spec validation failed

Spec-kit validation errors:
- Missing required section: Purpose
- Invalid format for requirements

Fix these issues and re-run validation.
```

**Configuration error:**
```
Error: Spec-kit configuration invalid

Check .speckit/config.yaml for errors.

Common issues:
- Invalid YAML syntax
- Missing required fields
- Incorrect paths
```

### 4. Add SDD Workflow Discipline

**After spec-kit command:**

- Run SDD validation (even if spec-kit validation passed)
- Create TodoWrite tasks if checklist workflow
- Integrate with git (commit specs)
- Link to next workflow step

### 5. Provide Next Steps

**Guide user:**

```
Spec created with spec-kit ✓
SDD validation complete ✓

Next steps:
1. Review spec for soundness (sdd:reviewing-spec) [if not auto-done]
2. Create implementation plan (sdd:implement)
3. Or refine spec further
```

## Checklist

Use TodoWrite for spec-kit workflows:

**For spec creation:**
- [ ] Check spec-kit availability
- [ ] Run `speckit specify` (if available)
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

## Examples

### Example 1: Spec Creation with Spec-Kit

```
You: Creating spec with spec-kit integration...

Checking spec-kit availability...
✓ Spec-kit found at /usr/local/bin/speckit

Running: speckit specify

[Spec-kit interactive prompts]

Feature name: User Profile API
Purpose: Allow users to update their profile information
...

Spec created by spec-kit: specs/features/user-profile-api.md

Adding SDD validation...

Running sdd:reviewing-spec...
✓ Structure complete
✓ Requirements clear
✓ Success criteria defined

Spec created and validated ✓

Committed to git ✓

Ready for implementation planning?
```

### Example 2: Spec Creation WITHOUT Spec-Kit

```
You: Creating spec...

Checking spec-kit availability...
✗ Spec-kit not found

Note: Spec-kit is not installed. Proceeding with manual spec creation.

(Install spec-kit for enhanced workflows: https://github.com/github/spec-kit)

Creating spec at specs/features/user-profile-api.md...

[Manual spec creation using template]

Spec created ✓

Running SDD validation...
✓ Structure complete
✓ Requirements clear

Ready for implementation planning?
```

### Example 3: Spec Validation

```
You: Validating spec with spec-kit...

Running: speckit validate specs/features/user-profile-api.md

Spec-kit validation: ✓ PASS

Adding SDD soundness checks...

Checking implementability...
✓ Can generate implementation plan
✓ All dependencies identified

Checking testability...
✓ Success criteria measurable
✓ Requirements verifiable

Overall: ✓ SOUND

Spec is valid and ready for implementation.
```

## Degraded Mode (Without Spec-Kit)

**When spec-kit not available:**

**Still functional:**
- Manual spec creation (using templates)
- Manual validation (SDD checks)
- Manual plan generation (from spec parsing)

**Not available:**
- Spec-kit format validation
- Spec-kit templates
- Spec-kit-specific features

**Recommendation:**
- For occasional spec work: Degraded mode fine
- For frequent spec work: Install spec-kit

## Integration Points

**This skill is called by:**
- `sdd:spec` (for spec creation)
- `sdd:brainstorm` (for spec creation)
- `sdd:constitution` (for constitution creation)
- `sdd:reviewing-spec` (for validation)
- `sdd:writing-plans` (for plan generation)

**This skill calls:**
- Spec-kit CLI commands
- Git (for commits)
- TodoWrite (for tracking)
- File operations (for manual fallback)

## Configuration Options

```json
{
  "sdd": {
    "spec_kit": {
      "enabled": true,
      "path": "speckit",
      "prefer_manual": false,
      "validate_always": true,
      "fallback_on_error": true
    }
  }
}
```

**Options:**
- `enabled`: Use spec-kit if available
- `path`: Path to spec-kit binary
- `prefer_manual`: Skip spec-kit even if available
- `validate_always`: Always run spec-kit validation
- `fallback_on_error`: Use manual mode if spec-kit errors

## Remember

**Spec-kit is a tool, not a requirement.**

- SDD works with or without spec-kit
- Spec-kit enhances workflow when available
- Manual mode is fully functional

**Integration adds discipline:**

- Spec-kit provides tooling
- SDD adds workflow enforcement
- Together: powerful spec-driven development

**Graceful degradation:**

- Always provide fallback
- Never block on spec-kit unavailability
- Recommend installation but don't require

**The goal is great specs, not specific tooling.**
