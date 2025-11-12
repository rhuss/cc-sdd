---
name: implement
description: Use when spec exists and is validated - generates implementation plan FROM spec, executes with TDD, and verifies spec compliance throughout
---

# Spec-Driven Implementation

## Overview

Implement features from validated specifications using Test-Driven Development, with continuous spec compliance checking throughout.

This is the core SDD implementation workflow: Spec → Plan → TDD → Verify.

**Critical Rule:** Implementation MUST match spec. Any deviation triggers spec evolution workflow.

## When to Use

**Use this skill when:**
- Spec exists and is validated
- Ready to write code
- Starting implementation of new feature

**Don't use this skill when:**
- No spec exists → Use `sdd:spec` or `sdd:brainstorm` first
- Spec/code mismatch exists → Use `sdd:evolve`
- Debugging existing code → Use `systematic-debugging`

## Technical Prerequisites

Ensure spec-kit is initialized:

{Skill: spec-kit}

If spec-kit prompts for restart, pause this workflow and resume after restart.

## Workflow Prerequisites

**Before starting implementation:**
- [ ] Spec exists in `specs/features/[feature-name].md`
- [ ] Spec validated for soundness (`sdd:review-spec`)
- [ ] Spec validated against constitution (if exists)
- [ ] No open questions in spec that block implementation

**If prerequisites not met:** Stop and address them first.

## The Process

### 1. Read and Understand Spec

**Load the spec:**
```bash
cat specs/features/[feature-name].md
```

**Extract key information:**
- Functional requirements (what to build)
- Success criteria (how to verify)
- Error handling (what can go wrong)
- Dependencies (what's needed)
- Constraints (limitations)

**Validate understanding:**
- Summarize spec back to user
- Confirm no ambiguities remain
- Identify any implementation questions

### 2. Generate Implementation Plan FROM Spec

**Use `sdd:writing-plans` skill** to create plan.

**The plan MUST:**
- Derive directly from spec requirements
- Include all functional requirements
- Cover all error cases
- Address all edge cases
- Reference spec sections explicitly

**Plan structure:**
```markdown
# Implementation Plan: [Feature Name]

**Source Spec:** specs/features/[feature-name].md
**Date:** YYYY-MM-DD

## Requirements Coverage

### Functional Requirement 1: [From spec]
**Implementation approach:**
- [ ] Task 1
- [ ] Task 2
...

[Repeat for all functional requirements]

## Error Handling Implementation

[For each error case in spec]
- **Error:** [From spec]
- **Implementation:** [How to handle]

## Test Strategy

[How we'll verify each requirement]

## Files to Create/Modify

[List with file paths]

## Verification Steps

- [ ] All tests pass
- [ ] Spec compliance check passes
- [ ] Code review against spec
```

**Save plan:** `docs/plans/[date]-[feature]-implementation.md`

### 3. Set Up Isolated Workspace

**Use `using-git-worktrees`** (optional but recommended):

```bash
git worktree add ../feature-[name] -b feature/[name]
cd ../feature-[name]
```

**Or work in current branch:**
- Ensure clean working directory
- Create feature branch if needed

### 4. Implement with Test-Driven Development

**Use `test-driven-development` skill.**

**For each requirement in spec:**

1. **Write test first** (based on spec requirement)
   - Test validates spec requirement directly
   - Include error cases from spec
   - Include edge cases from spec

2. **Watch it fail**
   - Confirms test is testing the right thing
   - Red phase of TDD

3. **Write minimal code to pass**
   - Implement spec requirement
   - Don't add features not in spec
   - Green phase of TDD

4. **Refactor**
   - Clean up while keeping tests green
   - Refactor phase of TDD

5. **Verify spec compliance**
   - Does code match spec requirement?
   - Check implementation against spec section
   - Document any necessary deviations

**Track progress with TodoWrite:**
- Mark requirements as in_progress/completed
- One requirement at a time
- Don't skip or batch

### 5. Continuous Spec Compliance Checking

**During implementation, regularly check:**

```bash
# Compare implementation to spec
# For each functional requirement:
# - ✓ Implemented as specified
# - ✗ Deviation detected → document reason
```

**If deviation needed:**
- Document WHY spec cannot be followed
- Note what changed and reason
- Will trigger `sdd:evolve` during review

### 6. Code Review Against Spec

**Use `sdd:review-code` skill.**

**Review checks:**
- Code implements all spec requirements
- No extra features beyond spec
- Error handling matches spec
- Edge cases covered per spec
- Tests validate spec requirements

**Output:**
- Compliance score (% of requirements met)
- List of deviations with reasons
- Recommendations: approve or evolve

### 7. Verification Before Completion

**Use `sdd:verification-before-completion` skill.**

**Verification steps:**
1. All tests pass
2. Spec compliance validation passes
3. No unaddressed deviations
4. All success criteria met (from spec)

**If verification fails:** Fix issues before claiming completion.

## Checklist

Use TodoWrite to track:

- [ ] Read and understand spec
- [ ] Generate implementation plan from spec
- [ ] Set up workspace (worktree or branch)
- [ ] For each requirement: TDD cycle (test, fail, implement, pass, refactor)
- [ ] Check spec compliance continuously
- [ ] Request code review against spec
- [ ] Run verification (tests + spec compliance)
- [ ] Address any deviations (evolve spec or fix code)
- [ ] Commit implementation
- [ ] Clean up workspace

## Example Flow

```
User: Let's implement the user profile API from the spec

You: I'm using sdd:implement to build this feature from the spec.

Reading spec: specs/features/user-profile-api.md

The spec defines:
- PUT /api/users/:id/profile endpoint
- Fields: name (2-50 chars), bio (max 500), avatar_url
- Auth: JWT required
- Errors: 401, 403, 404, 422
- Success criteria: authenticated users can update profiles

Generating implementation plan from spec...
[Uses sdd:writing-plans]

Plan created: docs/plans/2025-11-10-user-profile-api-implementation.md

Plan includes:
1. Create route handler (src/api/users/profile.ts)
2. Add validation middleware (src/middleware/validate-profile.ts)
3. Update service layer (src/services/user.ts)
4. Add tests (tests/api/users/profile.test.ts)

Ready to implement with TDD. Starting...

[Uses test-driven-development]

Test 1: Should reject unauthenticated requests (Spec: Error Handling)

Writing test...
```typescript
test('PUT /api/users/:id/profile returns 401 without JWT', async () => {
  const response = await request(app)
    .put('/api/users/123/profile')
    .send({ name: 'Test' });

  expect(response.status).toBe(401);
  expect(response.body.error).toBe('Authentication required');
});
```

Running test... ❌ FAIL (expected - no auth implemented yet)

Implementing auth middleware...
[Adds JWT validation]

Running test... ✅ PASS

Spec compliance check:
✓ Matches spec requirement: "User must be authenticated with valid JWT"
✓ Error message matches spec: "Authentication required"

---

Test 2: Should validate name length (Spec: Functional Requirements #2)

Writing test...
```typescript
test('PUT /api/users/:id/profile validates name length', async () => {
  const token = generateTestJWT({ sub: '123' });

  // Too short
  let response = await request(app)
    .put('/api/users/123/profile')
    .set('Authorization', `Bearer ${token}`)
    .send({ name: 'A' });

  expect(response.status).toBe(422);

  // Too long
  response = await request(app)
    .put('/api/users/123/profile')
    .set('Authorization', `Bearer ${token}`)
    .send({ name: 'A'.repeat(51) });

  expect(response.status).toBe(422);

  // Valid
  response = await request(app)
    .put('/api/users/123/profile')
    .set('Authorization', `Bearer ${token}`)
    .send({ name: 'Valid Name' });

  expect(response.status).toBe(200);
});
```

Running test... ❌ FAIL

Implementing validation...
[Adds name length validation]

Running test... ✅ PASS

Spec compliance check:
✓ Matches spec: "name: string, 2-50 characters"

---

[Continues through all requirements...]

All requirements implemented ✓

Requesting code review against spec...
[Uses sdd:review-code]

Code Review Results:
✓ All functional requirements implemented (6/6)
✓ All error cases handled (4/4)
✓ All edge cases covered (3/3)
✓ Tests validate spec requirements

Spec Compliance: 100%

Deviations detected: 1
- Added `updated_at` field to response (not in spec)
  Reason: Standard practice for update endpoints
  Recommendation: Update spec (minor addition)

Running verification...
[Uses sdd:verification-before-completion]

✅ All tests passing (24/24)
✅ Spec compliance validated
⚠️  Minor deviation: updated_at field

Recommendation: Use sdd:evolve to update spec with updated_at field

You: Should I update the spec to include the updated_at field?
```

## Handling Deviations

**When code deviates from spec:**

1. **Document the deviation** during implementation
2. **Note the reason** (technical constraint, better approach, etc.)
3. **Continue implementation** (don't block on it)
4. **Trigger evolution** during review
5. **Use `sdd:evolve`** to reconcile

**Never:**
- Silently deviate without documentation
- Force-fit code to incorrect spec
- Skip spec compliance checks

## Integration with Superpowers Skills

**This skill orchestrates:**
- `sdd:writing-plans` - Generate plan from spec
- `test-driven-development` - TDD implementation
- `sdd:review-code` - Spec compliance review
- `sdd:verification-before-completion` - Tests + spec validation
- `sdd:evolve` - If deviations need reconciliation

**Also compatible with:**
- `using-git-worktrees` - Isolated workspace
- `systematic-debugging` - If bugs found during implementation

## Success Criteria

**Implementation is complete when:**
- [ ] All spec requirements implemented
- [ ] All tests passing
- [ ] Spec compliance 100% (or deviations reconciled)
- [ ] Code review passed
- [ ] Verification passed
- [ ] All success criteria from spec met

## Common Pitfalls

**Avoid:**
- Implementing features not in spec
- Skipping TDD (spec doesn't mean no tests!)
- Ignoring error cases from spec
- Deviating without documentation
- Claiming completion before verification

**Instead:**
- Implement only what's in spec (YAGNI)
- TDD for every requirement
- Test all error cases from spec
- Document all deviations
- Verify before completing

## Remember

**The spec is your contract.**

- Don't add features not in spec
- Don't skip requirements from spec
- Don't ignore error cases in spec
- Don't deviate silently

**If spec is wrong or incomplete:**
- Document the issue
- Continue implementation
- Use `sdd:evolve` to fix spec

**Quality gates exist for a reason:**
- TDD ensures testability
- Code review ensures compliance
- Verification ensures correctness

**Follow the process. Ship quality code that matches the spec.**
