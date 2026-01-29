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

### 3. Create Specification

**Use spec-kit tools:**

```bash
# Interactive spec creation using spec-kit template
speckit specify "[feature description]"

# Or use spec-kit scripts directly
.specify/scripts/bash/create-new-feature.sh --json "[feature description]"
```

**This will:**
- Create feature directory (e.g., `specs/0001-feature-name/`)
- Initialize spec.md from template
- Set up directory structure (docs/, checklists/, contracts/)

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

**Before finishing, validate:**

Use `sdd:review-spec` skill to check:
- Completeness (all sections filled)
- Clarity (no ambiguous language)
- Implementability (can generate plan from this)
- Testability (success criteria measurable)

**If review finds issues:**
- Fix critical issues before proceeding
- Document any known gaps
- Mark unclear areas for clarification

### 6. Commit Spec

**Create git commit:**

```bash
git add specs/[feature-dir]/
git commit -m "Add spec for [feature-name]"
```

**Spec is now source of truth** for this feature.

## Next Steps

After spec creation:

1. **Review spec soundness** (if not already done):
   ```
   Use sdd:review-spec
   ```

2. **Implement the feature**:
   ```
   Use sdd:implement
   ```

3. **Or refine spec further** if issues found

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
