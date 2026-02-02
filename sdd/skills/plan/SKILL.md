---
name: plan
description: Generate implementation plan and tasks from a validated specification - wraps /speckit.plan and /speckit.tasks with superpowers discipline
---

# Generate Implementation Plan and Tasks

## Overview

This skill generates implementation artifacts (plan.md, tasks.md) from a validated specification. It wraps the `/speckit.plan` and `/speckit.tasks` commands while adding superpowers discipline.

**This skill provides value over calling /speckit.* directly by:**
1. Ensuring spec-kit is initialized
2. Validating the spec before planning
3. Running spec review to catch issues early
4. Verifying generated artifacts are complete

## When to Use

**Use this skill when:**
- Spec exists and you need to generate plan.md and tasks.md
- Preparing for implementation
- Updating plan/tasks after spec changes

**Don't use this skill when:**
- No spec exists → Use `sdd:brainstorm` or `sdd:spec` first
- Ready to implement → Use `sdd:implement` (which will check for plan/tasks)

## Prerequisites

Ensure spec-kit is initialized:

{Skill: spec-kit}

If spec-kit prompts for restart, pause this workflow and resume after restart.

## The Process

### 1. Spec Selection

If no spec is specified, discover available specs:

```bash
# List all specs in the project
fd -t f "spec.md" specs/ 2>/dev/null | head -20
```

**If multiple specs found:** Present list and ask user to select one using AskUserQuestion.

**If single spec found:** Confirm with user: "Found [spec path]. Generate plan for this spec?"

**If no specs found:**
```
No specs found in specs/ directory.

To create a spec first:
- Use `sdd:brainstorm` to refine ideas into a spec
- Use `sdd:spec` to create a spec from clear requirements

Cannot generate plan without a spec.
```

### 2. Validate Spec Before Planning

**Before generating plan, validate the spec is ready:**

Use `sdd:review-spec` to check:
- Completeness (all sections filled)
- Clarity (no ambiguous language)
- Implementability (can generate plan from this)

**If review finds critical issues:**
```
Spec has issues that should be fixed before planning:
[List issues]

Fix these issues first, then run /sdd:plan again.
```

**STOP and wait for user to fix issues.**

**If review passes or only minor issues:**
Proceed to planning.

### 3. Generate Plan

**Invoke `/speckit.plan` to generate the implementation plan:**

```
/speckit.plan
```

This creates `specs/[feature-name]/plan.md` with:
- Implementation approach
- Technical decisions
- File structure
- Architecture overview

**Verify plan was created:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/plan.md" ]; then
  echo "plan.md created successfully"
else
  echo "ERROR: plan.md was not created"
fi
```

### 4. Generate Tasks

**Invoke `/speckit.tasks` to generate the task breakdown:**

```
/speckit.tasks
```

This creates `specs/[feature-name]/tasks.md` with:
- Task phases (Setup, Tests, Core, Integration, Polish)
- Task dependencies
- Parallel execution markers
- File paths for each task

**Verify tasks were created:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/tasks.md" ]; then
  echo "tasks.md created successfully"
else
  echo "ERROR: tasks.md was not created"
fi
```

### 5. Verify Artifact Consistency

**Run consistency check using `/speckit.analyze`:**

```
/speckit.analyze
```

This verifies:
- Plan covers all spec requirements
- Tasks implement all plan items
- No orphaned tasks or missing coverage

**If consistency check fails:**
Report issues and suggest fixes.

### 6. Summary and Next Steps

**Present summary to user:**

```markdown
## Plan Generation Complete

**Spec:** specs/[feature-name]/spec.md
**Plan:** specs/[feature-name]/plan.md
**Tasks:** specs/[feature-name]/tasks.md

### Plan Overview
[Brief summary of plan approach]

### Task Summary
- Total tasks: [N]
- Setup phase: [N] tasks
- Test phase: [N] tasks
- Core phase: [N] tasks
- Integration phase: [N] tasks
- Polish phase: [N] tasks

### Consistency Check
[PASS/FAIL with details]

### Next Steps
Ready to implement? Use `/sdd:implement` to start.
```

## Checklist

Use TodoWrite to track:

- [ ] Discover and select spec
- [ ] Run spec review (sdd:review-spec)
- [ ] Invoke /speckit.plan
- [ ] Verify plan.md created
- [ ] Invoke /speckit.tasks
- [ ] Verify tasks.md created
- [ ] Run consistency check (/speckit.analyze)
- [ ] Present summary and next steps

## Integration with Superpowers Skills

**This skill invokes:**
- `sdd:review-spec` - Validate spec before planning
- `/speckit.plan` - Generate implementation plan
- `/speckit.tasks` - Generate task breakdown
- `/speckit.analyze` - Verify consistency

**This skill is called by:**
- `sdd:spec` - After spec creation (optionally)
- Users directly when plan/tasks need regeneration

## Error Handling

**If /speckit.plan fails:**
```
Failed to generate plan.md.

Possible causes:
1. Spec is incomplete or malformed
2. /speckit.plan command not available (run: specify init)

Check the spec and try again.
```

**If /speckit.tasks fails:**
```
Failed to generate tasks.md.

Possible causes:
1. plan.md is required but missing
2. /speckit.tasks command not available (run: specify init)

Ensure plan.md exists and try again.
```

## Remember

**Plan and tasks are derived from spec:**
- If spec changes, regenerate plan and tasks
- Never manually edit plan.md or tasks.md
- Always use this skill or /speckit.* commands to regenerate

**Quality gates matter:**
- Spec review before planning catches issues early
- Consistency check ensures complete coverage
- These steps are why /sdd:plan is better than calling /speckit.* directly
