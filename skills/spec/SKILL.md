---
name: spec
description: Use when you have clear requirements and want to create a formal specification directly, bypassing brainstorming - creates validated, executable specs
---

# Direct Specification Creation

## Overview

For users with clear requirements who want to skip brainstorming and create a formal specification directly.

This skill creates executable specifications that become the source of truth for implementation, validated against project constitution (if exists), and checked for soundness before proceeding.

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

### 2. Check Project Context

**Review existing specs:**
```bash
ls -la specs/features/
```

**Check for constitution:**
```bash
cat specs/constitution.md
```

**Look for related features:**
- Similar functionality already specced
- Integration points
- Shared components

### 3. Create Specification

**Choose tool:**
- If spec-kit available: Use `speckit specify`
- Otherwise: Create markdown directly

**Location:** `specs/features/[feature-name].md`

**Use this structure:**

```markdown
# Feature: [Feature Name]

## Purpose
[Concise statement of why this exists - the problem it solves]

## Requirements

### Functional Requirements
[Numbered list of what the feature must do]
1. [Requirement 1]
2. [Requirement 2]
...

### Non-Functional Requirements
[Performance, security, accessibility, etc.]
- [Requirement 1]
- [Requirement 2]
...

## Success Criteria
[How we measure success - must be specific and testable]
- [ ] [Criterion 1]
- [ ] [Criterion 2]
...

## Error Handling
[What can go wrong and how to handle it]
- **Error case:** [Description]
  - **Handling:** [What to do]
...

## Edge Cases
[Boundary conditions and unusual scenarios]
- [Edge case 1]: [Expected behavior]
- [Edge case 2]: [Expected behavior]
...

## Dependencies
[What this feature requires]
- **Internal:** [Other features/components]
- **External:** [Third-party services, APIs]

## Constraints
[Limitations and restrictions]
- [Constraint 1]
- [Constraint 2]
...

## Out of Scope
[What this feature explicitly does NOT do]
- [Non-goal 1]
- [Non-goal 2]
...

## Open Questions
[Anything deferred to implementation or requiring more research]
- [ ] [Question 1]
- [ ] [Question 2]
...

## Acceptance
[Final acceptance criteria for feature completion]
- [ ] All functional requirements implemented
- [ ] All error cases handled
- [ ] All tests passing
- [ ] Spec compliance verified
```

### 4. Validate Against Constitution

**If constitution exists:**

```bash
# Read constitution
cat specs/constitution.md

# Check alignment:
# - Does spec follow project principles?
# - Are error handling patterns consistent?
# - Does it match architectural decisions?
# - Are quality gates defined?
```

**Report violations:**
- List any misalignments
- Suggest corrections
- Ask user to confirm exceptions

**If no constitution exists:**
- Proceed without validation
- Consider recommending constitution creation

### 5. Validate Spec Soundness

**Use `sdd:reviewing-spec` skill** to check:
- Completeness (all sections filled)
- Clarity (no ambiguities)
- Implementability (can generate plan from this)
- Testability (success criteria measurable)

**Fix issues before proceeding.**

### 6. Commit Spec

```bash
git add specs/features/[feature-name].md
git commit -m "Add specification for [feature name]

[Brief description]

Success criteria:
- [Key criterion 1]
- [Key criterion 2]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 7. Offer Next Steps

**Present options:**
- "Spec created and validated. Ready to implement?"
- If yes → Use `sdd:implement`
- If user wants review → User can read spec first
- If issues found → Iterate on spec

## Checklist

Use TodoWrite to track:

- [ ] Extract requirements from user input
- [ ] Check project context (existing specs, constitution)
- [ ] Create specification file with all sections
- [ ] Validate against constitution (if exists)
- [ ] Run spec soundness review
- [ ] Fix any validation issues
- [ ] Commit spec to git
- [ ] Offer next steps

## Example Flow

### Example 1: API Endpoint Spec

```
User: Create a spec for a REST API endpoint to update user profiles.

PUT /api/users/:id/profile
- Accepts: name (2-50 chars), bio (max 500 chars), avatar_url
- Requires: JWT authentication
- Returns: updated user object
- Errors: 401 unauthorized, 404 not found, 422 validation

You: I'm using sdd:spec to create a formal specification.

[Checks for constitution and existing specs]

Creating spec at specs/features/user-profile-api.md...

[Creates spec with structure:]

# Feature: User Profile Update API

## Purpose
Allow authenticated users to update their profile information via REST API.

## Requirements

### Functional Requirements
1. Endpoint accepts PUT requests at `/api/users/:id/profile`
2. Request body must contain valid JSON with optional fields:
   - `name`: string, 2-50 characters
   - `bio`: string, max 500 characters
   - `avatar_url`: valid URL
3. User must be authenticated with valid JWT token
4. User can only update their own profile (id must match JWT subject)
5. Response returns complete updated user object
6. Supports partial updates (omitted fields unchanged)

### Non-Functional Requirements
- Response time < 200ms for successful updates
- Input validation happens before database writes
- Atomic updates (all or nothing)

## Success Criteria
- [ ] Authenticated users can update their profile
- [ ] Validation errors return 422 with clear messages
- [ ] Users cannot update other users' profiles
- [ ] All edge cases handled gracefully

## Error Handling
- **Missing/invalid JWT:** 401 Unauthorized
  - Handling: Return `{"error": "Authentication required"}`
- **User not found:** 404 Not Found
  - Handling: Return `{"error": "User not found"}`
- **Validation failure:** 422 Unprocessable Entity
  - Handling: Return `{"error": "Validation failed", "details": {...}}`
- **Authorization failure:** 403 Forbidden
  - Handling: Return `{"error": "Cannot update other users' profiles"}`

[... continues with all sections ...]

Validating against constitution...
✓ Follows RESTful conventions
✓ Includes auth requirements
✓ Error handling matches project patterns
✓ Validation approach consistent

Running soundness review...
✓ All sections complete
✓ Requirements are testable
✓ Error cases well-defined
✓ Success criteria measurable

Spec created and validated!

Ready to implement this API endpoint?
```

### Example 2: Feature Spec from PRD

```
User: /sdd:spec

Here's the PRD for our new feature:

[Pastes detailed product requirements document]

You: I'm using sdd:spec to create a formal specification from the PRD.

Extracting requirements...

I see the core feature is: [summarize]

Quick clarification - the PRD mentions "real-time updates" but doesn't
specify the latency requirement. Should updates be:

A) Immediate (< 100ms via WebSocket)
B) Near real-time (< 5s via polling)
C) Eventual (< 30s via background sync)

User: A - Immediate via WebSocket

You: Perfect. Creating spec...

[Creates comprehensive spec from PRD + clarification]

Spec created at specs/features/real-time-notifications.md

Validated against constitution ✓
Soundness review passed ✓
Committed to git ✓

Ready to generate implementation plan from this spec?
```

## Using Spec-Kit CLI

If spec-kit is available and enabled:

```bash
# Create spec interactively
speckit specify

# Follow prompts to fill in sections
# Spec-kit handles formatting and validation
```

**Integrate with workflow:**
- Let spec-kit handle creation
- Still validate against constitution
- Still run soundness review
- Still commit to git

## Common Patterns

### API Specification
- Include endpoint path and method
- Define request/response schemas
- Specify auth requirements
- List all error codes

### UI Feature Specification
- Define user interactions
- Specify visual states
- Include accessibility requirements
- Define responsive behavior

### Data Processing Specification
- Define input/output formats
- Specify transformation rules
- Include performance requirements
- Define error handling for bad data

### Integration Specification
- Define external service interactions
- Specify retry/timeout behavior
- Include fallback mechanisms
- Define monitoring/alerting

## Quality Checks

Before marking spec as complete:

**Completeness:**
- [ ] All sections filled (or marked N/A)
- [ ] No "TBD" or placeholder text
- [ ] Dependencies identified
- [ ] Success criteria defined

**Clarity:**
- [ ] No ambiguous language ("should", "might", "probably")
- [ ] Concrete, specific requirements
- [ ] Edge cases explicitly defined
- [ ] Error handling specified

**Testability:**
- [ ] Success criteria measurable
- [ ] Requirements verifiable
- [ ] Acceptance criteria clear

**Implementability:**
- [ ] Can generate implementation plan from spec
- [ ] No unknown dependencies
- [ ] Constraints realistic
- [ ] Scope manageable

## Common Pitfalls

**Avoid:**
- Specs with implementation details ("use Redis")
- Vague requirements ("fast", "user-friendly")
- Missing error handling
- Undefined success criteria
- Scope creep (include everything)

**Instead:**
- Focus on behavior and outcomes
- Be specific and measurable
- Define all error cases
- Make success criteria testable
- Ruthlessly scope (YAGNI)

## Remember

**The spec you create is the source of truth.**

- Implementation plans will be generated from it
- Code will be validated against it
- Tests will verify it
- Reviews will reference it

**Make it clear. Make it complete. Make it correct.**

A good spec enables smooth implementation. A poor spec creates confusion and rework.

**When in doubt, ask. When unsure, clarify. When done, validate.**
