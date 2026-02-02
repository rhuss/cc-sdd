---
name: spec
description: Create specifications directly from clear requirements - uses spec-kit tools to create formal, executable specs following WHAT/WHY principle (not HOW)
---

# Direct Specification Creation

## Overview

Create formal specifications directly when requirements are clear and well-defined.

**Use this instead of brainstorm when:**
- Requirements are already clear
- User provides detailed description
- Feature scope is well-defined
- No exploratory dialogue needed

**This skill creates specs using spec-kit tools and ensures WHAT/WHY focus (not HOW).**

## When to Use

**Use this skill when:**
- User provides clear, detailed requirements
- Feature scope is well-defined
- User wants to skip exploratory dialogue
- Requirements come from external source (PRD, ticket, etc.)

**Don't use this skill when:**
- Requirements are vague or exploratory → Use `sdd:brainstorm`
- Spec already exists → Use `sdd:implement` or `sdd:evolve`
- Making changes to existing spec → Use `sdd:spec-refactoring`

## Prerequisites

Ensure spec-kit is initialized:

{Skill: spec-kit}

If spec-kit prompts for restart, pause this workflow and resume after restart.

## CRITICAL: spec-kit CLI is REQUIRED

This skill MUST use spec-kit CLI commands. Claude MUST NOT:
- Generate specs internally (use `specify specify` instead)
- Create spec markdown directly (spec-kit handles this)
- Generate plans internally (use `specify plan` instead)
- Generate tasks internally (use `specify tasks` instead)

**FAILURE PROTOCOL:**
- If any spec-kit command fails → STOP and report the error
- If output is unexpected → STOP and report the issue
- If files are missing → STOP and suggest the correct specify command
- **NEVER "manually proceed"** with the workflow
- **NEVER "work around"** spec-kit by doing things directly
- **NEVER say "let me manually..."** and continue

The correct response to any issue is: STOP, diagnose, and either FIX with specify or ASK the user.

**Examples of FORBIDDEN behavior:**
```
❌ "The directory structure is different, let me manually create the spec..."
❌ "specify specify failed, I'll write the spec.md directly..."
❌ "The template is missing, let me manually set up the structure..."
```

**Examples of CORRECT behavior:**
```
✓ "specify specify failed with error X. Please check spec-kit installation."
✓ "The spec directory doesn't exist. Run: specify specify 'feature description'"
✓ "plan.md was not created. Run: specify plan specs/feature/spec.md"
```

## Critical: Specifications are WHAT and WHY, NOT HOW

**Specs define contracts and requirements, not implementation.**

### ✅ Specs SHOULD include:
- **Requirements**: What the feature must do
- **Behaviors**: How the feature should behave (user-observable)
- **Contracts**: API structures, file formats, data schemas
- **Error handling rules**: What errors must be handled and how they should appear to users
- **Success criteria**: Measurable outcomes
- **Constraints**: Limitations and restrictions
- **User-visible paths**: File locations, environment variables users interact with

### ❌ Specs should NOT include:
- **Implementation algorithms**: Specific sorting algorithms, data structure choices
- **Code**: Function signatures, class hierarchies, pseudocode
- **Technology choices**: "Use Redis", "Use React hooks", "Use Python asyncio"
- **Internal architecture**: How components communicate internally
- **Optimization strategies**: Caching mechanisms, performance tuning

### 📋 Example: What belongs where

**SPEC (WHAT/WHY):**
```markdown
## Requirements
- FR-001: System MUST validate email addresses before storing
- FR-002: System MUST return validation errors within 200ms
- FR-003: Invalid emails MUST return 422 status with error details

## Error Handling
- Invalid format: Return `{"error": "Invalid email format", "field": "email"}`
- Duplicate email: Return `{"error": "Email already exists"}`
```

**PLAN (HOW):**
```markdown
## Validation Implementation
- Use regex pattern: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- Cache validation results in Redis (TTL: 5 min)
- Database query: `SELECT COUNT(*) FROM users WHERE email = ?`
```

### Why this matters:
- **Specs remain stable** - Implementation details change, requirements don't
- **Implementation flexibility** - Can change HOW without changing WHAT
- **Clearer reviews** - Easy to see if requirements are met vs implementation quality
- **Better evolution** - When code diverges from spec, know which to update

## The Process

### 1. Gather Requirements

**Extract from user input:**
- What needs to be built
- Why it's needed (purpose/problem)
- Success criteria
- Constraints and dependencies
- Error cases and edge conditions

**Ask clarifying questions** (brief, targeted):
- Only if critical information is missing
- Keep questions focused and specific
- Don't turn this into full brainstorming session

**If requirements are vague:**
Stop and use `sdd:brainstorm` instead.

### 2. Check Project Context

**Review existing specs:**
```bash
ls -la specs/features/
# Or: ls -la specs/[NNNN]-*/
```

**Check for constitution:**
```bash
cat .specify/memory/constitution.md
```

**Look for related features:**
- Similar functionality already specced
- Integration points
- Shared components

### 3. Create Specification (MUST use spec-kit CLI)

**Use spec-kit CLI (REQUIRED):**

```bash
# Interactive spec creation using spec-kit template
specify specify "[feature description]"
```

**Do NOT create spec markdown directly. Always use `specify specify`.**

**This will:**
- Create feature directory (e.g., `specs/0001-feature-name/`)
- Initialize spec.md from template
- Set up directory structure (docs/, checklists/, contracts/)

**After creation, run clarification check (RECOMMENDED):**

```bash
specify clarify specs/[feature-name]/spec.md
```

This identifies underspecified areas. Present results to user and update spec if needed.

**Fill in the spec following template structure:**
- Purpose - WHY this feature exists
- Functional Requirements - WHAT it must do
- Non-Functional Requirements - Performance, security, etc.
- Success Criteria - Measurable outcomes
- Error Handling - What can go wrong
- Edge Cases - Boundary conditions
- Constraints - Limitations
- Dependencies - What this relies on
- Out of Scope - What this doesn't do

**Follow WHAT/WHY principle:**
- Focus on observable behavior
- Avoid implementation details
- Use user/system perspective
- Keep technology-agnostic where possible

### 4. Validate Against Constitution

**If constitution exists:**

```bash
cat .specify/memory/constitution.md
```

**Check alignment:**
- Does spec follow project principles?
- Are patterns consistent with constitution?
- Does error handling match standards?
- Are architectural decisions aligned?

**Note any deviations** and justify them in spec.

### 5. Review Spec Soundness

**Before finishing, validate using spec-kit:**

```bash
specify validate specs/[feature-name]/spec.md
```

Then use `sdd:review-spec` skill to check:
- Completeness (all sections filled)
- Clarity (no ambiguous language)
- Implementability (can generate plan from this)
- Testability (success criteria measurable)

**If review finds issues:**
- Fix critical issues before proceeding
- Document any known gaps
- Mark unclear areas for clarification

### 6. Generate Implementation Artifacts

After spec is validated, generate the implementation plan and tasks:

**Generate plan (REQUIRED):**

```bash
specify plan specs/[feature-name]/spec.md
```

This creates `specs/[feature-name]/plan.md` from the spec.

**Generate tasks (REQUIRED):**

```bash
specify tasks specs/[feature-name]/spec.md
```

This creates `specs/[feature-name]/tasks.md` with dependency ordering.

**VERIFICATION CHECKPOINT (MANDATORY):**

```bash
SPEC_DIR="specs/[feature-name]"

if [ ! -f "$SPEC_DIR/plan.md" ]; then
  echo "❌ FAILURE: plan.md not created"
  echo "Run: specify plan $SPEC_DIR/spec.md"
  exit 1
fi

if [ ! -f "$SPEC_DIR/tasks.md" ]; then
  echo "❌ FAILURE: tasks.md not created"
  echo "Run: specify tasks $SPEC_DIR/spec.md"
  exit 1
fi

echo "✓ All artifacts generated"
```

**If verification fails: STOP. Do not continue. Do not "manually proceed".**
Report the failure and suggest the correct specify command to fix it.

**Run final consistency check:**

```bash
specify analyze specs/[feature-name]/
```

This validates cross-artifact consistency between spec, plan, and tasks.

**The complete spec package now includes:**
- `spec.md` - What to build (requirements)
- `plan.md` - How to build it (implementation approach)
- `tasks.md` - Work breakdown (actionable items)

### 7. Commit Spec Package

**Create git commit for the complete spec package:**

```bash
git add specs/[feature-dir]/
git commit -m "Add spec package for [feature-name]

Includes:
- spec.md (requirements)
- plan.md (implementation plan)
- tasks.md (task breakdown)"
```

**Spec package is now source of truth** for this feature.

## Next Steps

After spec package creation:

1. **Implement the feature** (plan and tasks are ready):
   ```
   Use sdd:implement
   ```

2. **Or refine spec further** if issues found during review

## Remember

**Spec is contract, not design doc:**
- Defines WHAT and WHY
- Defers HOW to implementation
- Remains stable as code evolves
- Is source of truth for compliance

**Keep specs:****
- Technology-agnostic
- User-focused
- Measurable
- Implementable

**The goal:**
A clear, unambiguous specification that serves as the single source of truth for implementation and validation.
