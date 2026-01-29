---
name: writing-plans
description: Generate implementation plans FROM specifications - reads spec as input, extracts requirements, creates step-by-step tasks with validation against spec
---

# Writing Implementation Plans from Specifications

## Overview

Generate detailed implementation plans derived FROM specifications, not from scratch.

The spec is the source of truth. The plan translates spec requirements into concrete, actionable implementation tasks.

**Key Difference from Standard Writing-Plans:**
- **Input is SPEC** (not blank slate)
- Plan MUST cover all spec requirements
- Plan validates against spec for completeness
- Tasks reference spec sections explicitly

## When to Use

**Use this skill when:**
- Spec exists and is validated
- Ready to create implementation plan
- Called by `sdd:implement` workflow
- Need to break spec into tasks

**Don't use this skill when:**
- No spec exists → Create spec first
- Plan already exists → Review/update existing plan
- Just clarifying approach → Use brainstorming

## Prerequisites

- [ ] Spec exists and is complete
- [ ] Spec validated for soundness
- [ ] No blocking open questions in spec
- [ ] Ready to start implementation

## The Process

### 1. Read and Parse Specification

**Load the spec:**
```bash
cat specs/features/[feature-name].md
```

**Extract all elements:**
- **Functional requirements** (what to build)
- **Non-functional requirements** (how it should perform)
- **Success criteria** (how to verify)
- **Error handling** (what can go wrong)
- **Edge cases** (boundary conditions)
- **Dependencies** (what's needed)
- **Constraints** (limitations)

**Create requirements checklist:**
- Number each requirement
- Reference spec section
- Mark coverage status

### 2. Understand Project Context

**Check existing codebase:**
```bash
# Find related files
rg "[relevant-terms]"

# Check architecture
ls -la src/

# Review dependencies
cat package.json  # or requirements.txt, go.mod, etc.
```

**Identify:**
- Where new code should live
- Existing patterns to follow
- Components to reuse
- Integration points

### 3. Design Implementation Strategy

**For each functional requirement, determine:**

**Approach:**
- How will this be implemented?
- What components are needed?
- What patterns apply?

**Files:**
- What files to create?
- What files to modify?
- Full file paths

**Dependencies:**
- What needs to exist first?
- What can be done in parallel?
- What's the critical path?

**Testing:**
- How will this be tested?
- What test files needed?
- What edge cases to cover?

### 4. Create Implementation Plan

**Use this structure:**

```markdown
# Implementation Plan: [Feature Name]

**Source Spec:** specs/features/[feature-name].md
**Date:** YYYY-MM-DD
**Estimated Effort:** [time estimate if relevant]

## Overview

[Brief summary of what we're implementing and why]

## Requirements Coverage

### Functional Requirement 1: [Quote from spec]
**Spec Reference:** specs/features/[feature].md#[section]

**Implementation Approach:**
[How we'll implement this requirement]

**Tasks:**
- [ ] [Specific actionable task]
- [ ] [Another task]

**Files to Create/Modify:**
- `path/to/file.ext` - [What changes]

**Tests:**
- [ ] [Test case for this requirement]

---

### Functional Requirement 2: [Quote from spec]
[Repeat structure]

---

[Continue for ALL functional requirements]

## Non-Functional Requirements

[For each non-functional requirement from spec]

### [Requirement Name]: [Quote from spec]
**Spec Reference:** specs/features/[feature].md#[section]

**Implementation:**
[How we'll achieve this]

**Validation:**
[How we'll measure/verify this]

## Error Handling Implementation

[For each error case in spec]

### Error: [From spec]
**Spec Reference:** specs/features/[feature].md#error-handling

**Implementation:**
```
[Code approach or pseudocode]
```

**Test Cases:**
- [ ] [Test for this error case]

## Edge Cases Implementation

[For each edge case in spec]

### Edge Case: [From spec]
**Expected Behavior:** [From spec]

**Implementation:**
[How we'll handle this]

**Test:**
- [ ] [Test for edge case]

## Dependencies

**Required Before Implementation:**
- [ ] [Dependency 1 from spec]
- [ ] [Dependency 2 from spec]

**Integration Points:**
- [Component/service 1]: [How we integrate]
- [Component/service 2]: [How we integrate]

## Implementation Order

**Phase 1: Foundation**
1. [Task]
2. [Task]

**Phase 2: Core Functionality**
1. [Task]
2. [Task]

**Phase 3: Error Handling**
1. [Task]
2. [Task]

**Phase 4: Edge Cases & Polish**
1. [Task]
2. [Task]

## Test Strategy

**Unit Tests:**
- [ ] [Component/function to test]
- [ ] [Another component/function]

**Integration Tests:**
- [ ] [Integration scenario]
- [ ] [Another scenario]

**Spec Compliance Tests:**
- [ ] [Verify requirement 1]
- [ ] [Verify requirement 2]

## Files to Create

- `path/to/new/file1.ext` - [Purpose]
- `path/to/new/file2.ext` - [Purpose]

## Files to Modify

- `path/to/existing/file1.ext` - [What changes]
- `path/to/existing/file2.ext` - [What changes]

## Success Criteria

[From spec, repeated here for reference]
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Spec Validation Checklist

**All requirements covered:**
- [ ] All functional requirements have tasks
- [ ] All non-functional requirements addressed
- [ ] All error cases have implementation approach
- [ ] All edge cases have handling strategy
- [ ] All dependencies identified
- [ ] All success criteria have verification plan

**Plan completeness:**
- [ ] All tasks are specific and actionable
- [ ] All file paths are complete (not "TBD")
- [ ] All requirements reference spec sections
- [ ] Test strategy covers all requirements
- [ ] Implementation order is logical

## Notes

[Any additional context, decisions, or considerations]
```

### 5. Validate Plan Against Spec

**Completeness check:**

For each requirement in spec:
- [ ] Plan has implementation approach
- [ ] Plan has specific tasks
- [ ] Plan has test coverage
- [ ] Plan references spec section

**Coverage matrix:**
```
Requirement 1 → Tasks [1,2,3], Tests [A,B]     ✓
Requirement 2 → Tasks [4,5], Tests [C,D]       ✓
Requirement 3 → Tasks [6], Tests [E,F,G]       ✓
...
```

**If any requirement uncovered:** Add tasks before proceeding.

### 6. Review for Implementability

**Check that plan:**
- Has concrete file paths (not "somewhere")
- Has specific tasks (not vague "implement X")
- Has realistic order (dependencies respected)
- Has test coverage (every requirement tested)

**Red flags:**
- "Figure out how to..."
- "Implement [vague concept]"
- "TBD"
- Missing file paths
- No test strategy

### 7. Save and Commit Plan

**Save plan:**
```bash
# Location
docs/plans/[date]-[feature]-implementation.md
```

**Commit plan:**
```bash
git add docs/plans/[date]-[feature]-implementation.md
git commit -m "Add implementation plan for [feature]

Generated from spec: specs/features/[feature].md

Coverage:
- [N] functional requirements
- [N] error cases
- [N] edge cases

Estimated [N] tasks

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Checklist

Use TodoWrite to track:

- [ ] Read and parse specification completely
- [ ] Extract all requirements, errors, edge cases
- [ ] Understand project context and codebase
- [ ] Design implementation strategy
- [ ] Create implementation plan with all sections
- [ ] Validate plan coverage against spec (100%)
- [ ] Review plan for implementability
- [ ] Ensure all file paths are complete
- [ ] Ensure all tasks are specific and actionable
- [ ] Save plan to docs/plans/
- [ ] Commit plan to git

## Example

```
[Called from sdd:implement]

You: Generating implementation plan from spec...

Reading spec: specs/features/user-profile-api.md

Extracting requirements:
- Functional: 6 requirements
- Non-functional: 3 requirements
- Error cases: 4
- Edge cases: 3
- Dependencies: 2

Understanding project context...
- Existing API routes in: src/api/
- Validation middleware in: src/middleware/
- User service in: src/services/user.ts
- Tests in: tests/api/

Creating implementation plan...

# Implementation Plan: User Profile Update API

**Source Spec:** specs/features/user-profile-api.md
**Date:** 2025-11-10

## Overview

Implement REST API endpoint for authenticated users to update their profiles.
Includes validation, error handling, and partial update support.

## Requirements Coverage

### Functional Requirement 1: PUT endpoint accepts requests
**Spec Reference:** specs/features/user-profile-api.md#functional-requirements

**Implementation Approach:**
Create Express route handler at PUT /api/users/:id/profile using
existing route structure in src/api/users/

**Tasks:**
- [ ] Create route file at src/api/users/profile.ts
- [ ] Register route in src/api/users/index.ts
- [ ] Add route handler function

**Files to Create/Modify:**
- `src/api/users/profile.ts` - New route handler
- `src/api/users/index.ts` - Register route

**Tests:**
- [ ] Test route responds to PUT requests
- [ ] Test route path is /api/users/:id/profile

---

### Functional Requirement 2: Validate request body
**Spec Reference:** specs/features/user-profile-api.md#functional-requirements

**Implementation Approach:**
Create validation middleware using existing validation pattern.
Validate: name (2-50 chars), bio (max 500), avatar_url (URL format).

**Tasks:**
- [ ] Create validation schema in src/middleware/validation/profile.ts
- [ ] Add validation middleware to route
- [ ] Return 422 on validation errors

**Files to Create/Modify:**
- `src/middleware/validation/profile.ts` - Validation schema
- `src/api/users/profile.ts` - Apply middleware

**Tests:**
- [ ] Test name length validation (too short)
- [ ] Test name length validation (too long)
- [ ] Test bio length validation
- [ ] Test avatar_url format validation

[... continues for all requirements ...]

## Spec Validation Checklist

**All requirements covered:**
- [x] All 6 functional requirements have tasks
- [x] All 3 non-functional requirements addressed
- [x] All 4 error cases have implementation
- [x] All 3 edge cases handled
- [x] All 2 dependencies identified
- [x] All 5 success criteria have verification

Plan validated against spec ✓
Coverage: 100%

Saving plan to: docs/plans/2025-11-10-user-profile-api-implementation.md

Plan created ✓
Committed to git ✓

Plan has 24 tasks across 4 phases.
Ready to implement with TDD?
```

## Quality Standards

**Every plan MUST have:**
- Complete file paths (no "TBD")
- Specific tasks (not vague)
- Test coverage (every requirement)
- Error handling (every error case)
- Edge case coverage (every edge case)
- Spec references (every requirement linked)

**Every task MUST be:**
- Actionable (clear what to do)
- Testable (can verify completion)
- Atomic (one clear outcome)
- Ordered (dependencies respected)

## Common Pitfalls

**Avoid:**
- Creating plan before spec exists
- Missing spec requirements in plan
- Vague tasks ("implement feature")
- Missing file paths
- No test strategy
- Skipping error cases
- Ignoring edge cases

**Instead:**
- Always start from spec
- Cover 100% of spec requirements
- Make tasks concrete and specific
- Provide complete file paths
- Test every requirement
- Handle every error case
- Cover every edge case

## Remember

**The plan is a bridge from spec to code.**

- Spec says WHAT
- Plan says HOW and WHERE and WHEN
- Code implements the plan

**A good plan makes implementation smooth.**
**A poor plan causes confusion and rework.**

**Validate against spec before proceeding.**
**100% coverage is non-negotiable.**
