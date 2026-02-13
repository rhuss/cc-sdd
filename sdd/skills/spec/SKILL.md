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

<HARD-GATE>
You MUST invoke /speckit.specify via the Skill tool before creating any spec file manually.
Writing spec markdown directly without first calling the Skill tool is a FAILURE of this skill.
The manual fallback path is ONLY for when the Skill tool call for speckit.specify has returned an error.

HOW TO INVOKE: Use the Skill tool with skill="speckit.specify" and pass the feature description as args.
Example: Skill(skill: "speckit.specify", args: "Add user authentication with OAuth2 support")

This is a BLOCKING REQUIREMENT. You MUST call the Skill tool BEFORE writing any spec content.
</HARD-GATE>

## Anti-Rationalization: Do Not Bypass spec-kit

If you catch yourself thinking:
- "I can just write the spec markdown directly" → WRONG. Call `Skill(skill: "speckit.specify")` first.
- "The spec-kit commands probably aren't available" → WRONG. Try them. The Skill tool will report errors.
- "Manual creation is faster" → WRONG. spec-kit ensures proper structure and directory layout.
- "I already know the template format" → WRONG. spec-kit may have been updated with new fields.
- "I'll just create the directory and file myself" → WRONG. speckit.specify handles branch creation, numbering, and file scaffolding.

The manual fallback exists for when the Skill tool call genuinely fails, not as a convenience shortcut.

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

## CRITICAL: Use /speckit.* via the Skill Tool

All `/speckit.*` operations MUST be invoked via the Skill tool. Claude MUST NOT:
- Generate specs internally (use `Skill(skill: "speckit.specify", args: "<description>")` instead)
- Create spec markdown directly (spec-kit handles this)
- Generate plans internally (use `Skill(skill: "speckit.plan")` instead)
- Generate tasks internally (use `Skill(skill: "speckit.tasks")` instead)

**How to invoke each command:**

| Operation | Skill Tool Call |
|-----------|----------------|
| Create spec | `Skill(skill: "speckit.specify", args: "<feature description>")` |
| Generate plan | `Skill(skill: "speckit.plan")` |
| Generate tasks | `Skill(skill: "speckit.tasks")` |
| Find gaps | `Skill(skill: "speckit.clarify")` |
| Check consistency | `Skill(skill: "speckit.analyze")` |

**If a Skill tool call fails:**
Fall back to creating files manually using templates in `.specify/templates/`.
You MUST call the Skill tool first and observe the failure before using this fallback.

**FAILURE PROTOCOL:**
- If a Skill tool call fails → report the error and suggest alternatives
- If output is unexpected → STOP and report the issue
- If Skill tool returns error → use manual creation with templates

**Examples of CORRECT behavior:**
```
CORRECT - Always call Skill tool first:
✓ Skill(skill: "speckit.specify", args: "Add comment system with threading")
✓ Skill(skill: "speckit.plan")

CORRECT - Fallback only after Skill tool error:
✓ "Skill call for speckit.specify failed: [error]. Falling back to manual creation using .specify/templates/spec-template.md"

WRONG - Never skip the Skill tool call:
✗ Reading template and writing spec.md directly
✗ Creating specs/ directory and files manually without trying Skill tool first
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

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Initialize spec-kit** - run {Skill: spec-kit}, verify specify CLI is installed
2. **Gather requirements** - extract from user input, ask clarifying questions
3. **Check project context** - review existing specs, constitution, related features
4. **Invoke speckit.specify via Skill tool** - `Skill(skill: "speckit.specify", args: "<description>")` (report error if it fails)
5. **Run speckit.clarify via Skill tool** - `Skill(skill: "speckit.clarify")` to identify underspecified areas
6. **Validate against constitution** - check alignment with project principles
7. **Review spec soundness** - use sdd:review-spec
8. **Generate implementation artifacts** - `Skill(skill: "speckit.plan")` and `Skill(skill: "speckit.tasks")`
9. **Generate review brief** - create review_brief.md
10. **Commit spec package** - git add and commit all artifacts

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

**Check for constitution (can be in either location):**
```bash
# Check both possible locations
if [ -f ".specify/memory/constitution.md" ]; then
  cat .specify/memory/constitution.md
elif [ -f "specs/constitution.md" ]; then
  cat specs/constitution.md
else
  echo "no-constitution"
fi
```

**Look for related features:**
- Similar functionality already specced
- Integration points
- Shared components

### 3. Create Specification

**MANDATORY: Call Skill tool for speckit.specify first:**

{Skill: speckit.specify}

Pass the feature description as args: `Skill(skill: "speckit.specify", args: "<gathered requirements summary>")`

This creates the spec at `specs/[NNNN]-[feature-name]/spec.md`, handles branch creation, numbering, and template scaffolding.

**ONLY if the Skill tool call fails with an error:**
1. Report the exact error to the user
2. Then fall back to creating the spec manually using `.specify/templates/spec-template.md`
3. Note in the output that spec-kit was unavailable

Do NOT skip straight to manual creation. You MUST call the Skill tool and observe the result.

**After creation, run clarification check (RECOMMENDED):**

Call `Skill(skill: "speckit.clarify")` to identify underspecified areas. Present results to user and update spec if needed.

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

**If constitution exists (check both locations):**

```bash
if [ -f ".specify/memory/constitution.md" ]; then
  cat .specify/memory/constitution.md
elif [ -f "specs/constitution.md" ]; then
  cat specs/constitution.md
fi
```

**Check alignment:**
- Does spec follow project principles?
- Are patterns consistent with constitution?
- Does error handling match standards?
- Are architectural decisions aligned?

**Note any deviations** and justify them in spec.

### 5. Review Spec Soundness

**Before finishing, use `sdd:review-spec` skill to check:**
- Completeness (all sections filled)
- Clarity (no ambiguous language)
- Implementability (can generate plan from this)
- Testability (success criteria measurable)

**If review finds issues:**
- Fix critical issues before proceeding
- Document any known gaps
- Mark unclear areas for clarification

### 6. Generate Implementation Artifacts

After spec is validated, generate the implementation plan and tasks.

**Check branch name first:**

Spec-kit requires branches named `NNN-feature-name` (e.g., `002-operator-config`). Branches with prefixes like `feature/`, `spec/`, or `fix/` will fail validation.

```bash
BRANCH=$(git branch --show-current)
if [[ ! "$BRANCH" =~ ^[0-9]{3}- ]]; then
  echo "WARNING: Branch '$BRANCH' does not match spec-kit convention (NNN-feature-name)"
  echo "Consider: git checkout -b NNN-feature-name"
fi
```

If the branch name is wrong, ask the user to switch before proceeding.

**Generate plan:**

Call `Skill(skill: "speckit.plan")` to generate the implementation plan from the spec.

This creates `specs/[feature-name]/plan.md` from the spec.

**Generate tasks:**

Call `Skill(skill: "speckit.tasks")` to generate the task list with dependency ordering.

This creates `specs/[feature-name]/tasks.md`.

**ONLY if Skill tool calls fail:**
Report the error to the user, then generate plan and tasks manually based on the spec requirements.

**VERIFICATION CHECKPOINT:**

```bash
SPEC_DIR="specs/[feature-name]"

if [ ! -f "$SPEC_DIR/plan.md" ]; then
  echo "⚠️  plan.md not yet created"
fi

if [ ! -f "$SPEC_DIR/tasks.md" ]; then
  echo "⚠️  tasks.md not yet created"
fi
```

**Run final consistency check (optional):**

If `/speckit.analyze` is available, invoke it to validate cross-artifact consistency between spec, plan, and tasks.

**The complete spec package now includes:**
- `spec.md` - What to build (requirements)
- `plan.md` - How to build it (implementation approach)
- `tasks.md` - Work breakdown (actionable items)
- `review_brief.md` - Reviewer guide (generated in next step)

### 6.5. Generate review_brief.md

After plan and tasks are complete, generate a brief for reviewers.

**Read source documents:**
- Read `specs/[feature-name]/spec.md`
- Read `specs/[feature-name]/plan.md`

**Extract and synthesize:**

1. **Feature Overview** (3-5 sentences from spec Purpose section)

2. **Scope Boundaries**
   - In scope: From spec requirements
   - Out of scope: From spec "Out of Scope" section
   - Why: Brief justification for boundaries

3. **Critical Decisions** - Identify choices with trade-offs

4. **Areas of Potential Disagreement** - Explicitly identify:
   - Trade-offs where reasonable people might disagree
   - Assumptions that could be challenged
   - Scope decisions (inclusions/exclusions) that might be questioned
   - Unconventional approaches taken
   - For each: What was decided, why it might be controversial, alternative view, feedback requested

5. **Naming Decisions** - Extract named elements

6. **Schema Definitions** - Condense key structures

7. **Open Questions** - Areas needing stakeholder input

8. **Risk Areas** - High-impact concerns

**Create review_brief.md:**

Write to `specs/[feature-name]/review_brief.md` using this template:

```markdown
# Review Brief: [Feature Name]

**Spec:** specs/[feature-name]/spec.md | **Plan:** specs/[feature-name]/plan.md
**Generated:** YYYY-MM-DD

> Reviewer's guide to scope and key decisions. See full spec/plan for details.

---

## Feature Overview
[3-5 sentences on purpose, scope, and key outcomes]

## Scope Boundaries
- **In scope:** [What this includes]
- **Out of scope:** [What this explicitly excludes]
- **Why these boundaries:** [Brief justification]

## Critical Decisions

### [Decision Title]
- **Choice:** [What was decided]
- **Trade-off:** [Key trade-off made]
- **Feedback:** [Specific question for reviewer]

## Areas of Potential Disagreement

> Decisions or approaches where reasonable reviewers might push back.

### [Topic]
- **Decision:** [What was decided]
- **Why this might be controversial:** [Reason]
- **Alternative view:** [What someone might prefer]
- **Seeking input on:** [Specific question]

## Naming Decisions

| Item | Name | Context |
|------|------|---------|
| API Endpoint | `/api/v1/...` | ... |
| Field | `field_name` | ... |
| Error Code | `ERROR_NAME` | ... |

## Schema Definitions (Condensed)

[Key request/response structures only]

## Open Questions

- [ ] [Question needing stakeholder input]

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| ... | High/Med/Low | ... |

---
*Share with reviewers before implementation.*
```

**Constraints:**
- Maximum 2 pages (~800-1000 words)
- Prioritize: Disagreement Areas > Decisions > Scope > Overview
- Be explicit about potential pushback points

**Verify:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/review_brief.md" ]; then
  echo "review_brief.md created"
  wc -w "$SPEC_DIR/review_brief.md"
fi
```

### 7. Commit Spec Package

**Create git commit for the complete spec package:**

```bash
git add specs/[feature-dir]/
git commit -m "Add spec package for [feature-name]

Includes:
- spec.md (requirements)
- plan.md (implementation plan)
- tasks.md (task breakdown)
- review_brief.md (reviewer guide)"
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
