---
name: verification-before-completion
description: Extended verification including tests AND spec compliance - runs tests, validates spec compliance, checks for drift, blocks completion on failures
---

# Verification Before Completion (Spec-Aware)

## Overview

Verify implementation is complete by running tests AND validating spec compliance.

**Key Additions from Standard Verification:**
- Step 1: Run tests (existing behavior)
- **Step 2: Validate spec compliance** (new)
- **Step 3: Check for spec drift** (new)
- Blocks completion if EITHER tests OR spec compliance fails

## When to Use

- After implementation and code review
- Before claiming work is complete
- Before committing/merging/deploying
- As final gate in `sdd:implement` workflow

## The Process

### 1. Run Tests

**Execute all tests:**
```bash
# Run full test suite
npm test  # or pytest, go test, etc.
```

**Check results:**
- All tests passing?
- No flaky tests?
- Coverage adequate?

**If tests fail:**
- ❌ **STOP - Fix tests before proceeding**
- Do not skip this step
- Do not claim completion

### 2. Validate Spec Compliance

**Load spec:**
```bash
cat specs/features/[feature-name].md
```

**Check each requirement:**

```markdown
Functional Requirement 1: [From spec]
  ✓ / ✗ Implemented
  ✓ / ✗ Tested
  ✓ / ✗ Matches spec behavior

Functional Requirement 2: [From spec]
  ...
```

**Verify:**
- All requirements implemented
- All requirements tested
- All behavior matches spec
- No missing features
- No extra features (or documented)

**Calculate compliance:**
```
Spec Compliance: X/X requirements = XX%
```

**If compliance < 100%:**
- ❌ **STOP - Use `sdd:evolve` to reconcile**
- Document all deviations
- Do not proceed until resolved

### 3. Check for Spec Drift

**Compare:**
- What spec says NOW
- What code does NOW
- Any divergence?

**Common drift sources:**
- Spec updated but code not
- Code changed but spec not
- Undocumented additions
- Forgotten requirements

**If drift detected:**
- Document each instance
- Use `sdd:evolve` to reconcile
- Do not proceed with drift

### 4. Verify Success Criteria

**From spec, check each criterion:**

```markdown
Success Criteria (from spec):
- [ ] Criterion 1: [Description]
      Status: ✓ Met / ✗ Not met
      Evidence: [How verified]

- [ ] Criterion 2: [Description]
      ...
```

**All criteria must be met.**

If any criterion not met:
- ❌ **STOP - Criterion not met**
- Implement missing piece
- Re-verify

### 5. Generate Verification Report

**Report structure:**

```markdown
# Verification Report: [Feature Name]

**Date:** YYYY-MM-DD
**Spec:** specs/features/[feature].md

## Test Results

**Status:** ✅ PASS / ❌ FAIL

```
[Test output]
```

**Summary:**
- Total: X tests
- Passed: X
- Failed: X
- Coverage: XX%

## Spec Compliance

**Status:** ✅ COMPLIANT / ❌ NON-COMPLIANT

**Compliance Score:** XX%

### Requirements Status
- Functional: X/X (XX%)
- Error Cases: X/X (XX%)
- Edge Cases: X/X (XX%)
- Non-Functional: X/X (XX%)

### Deviations
[List any deviations found]

## Spec Drift Check

**Status:** ✅ NO DRIFT / ⚠️ DRIFT DETECTED

[Details if drift found]

## Success Criteria

**Status:** ✅ ALL MET / ❌ INCOMPLETE

- [✓] Criterion 1
- [✓] Criterion 2
...

## Overall Status

✅ **VERIFIED - Ready for completion**

OR

❌ **NOT VERIFIED - Issues must be resolved**

**Blocking Issues:**
- [Issue 1]
- [Issue 2]

**Next Steps:**
[What needs to be done]
```

### 6. Make Go/No-Go Decision

**All conditions must be true:**
- [x] All tests passing
- [x] Spec compliance 100%
- [x] No spec drift
- [x] All success criteria met

**If ALL true:**
- ✅ **VERIFIED - Proceed to completion**
- Safe to commit/merge/deploy

**If ANY false:**
- ❌ **NOT VERIFIED - Block completion**
- Fix issues before proceeding
- Re-run verification after fixes

## Verification Checklist

Use TodoWrite to track:

- [ ] Run full test suite
- [ ] Verify all tests passing
- [ ] Load specification
- [ ] Validate spec compliance for all requirements
- [ ] Check for spec drift
- [ ] Verify all success criteria met
- [ ] Generate verification report
- [ ] Make go/no-go decision
- [ ] If not verified: Document blocking issues
- [ ] If verified: Proceed to completion

## Example: Verification PASS

```
You: Running verification before completion...

Step 1: Running tests...

$ npm test

✅ All tests passing (24/24)
✅ Coverage: 95%

Step 2: Validating spec compliance...

Reading spec: specs/features/user-profile-api.md

Checking requirements:
✓ Functional Requirement 1: PUT endpoint - Implemented & tested
✓ Functional Requirement 2: Validation - Implemented & tested
✓ Functional Requirement 3: Auth - Implemented & tested
✓ Functional Requirement 4: Authorization - Implemented & tested
✓ Functional Requirement 5: Response format - Implemented & tested
✓ Functional Requirement 6: Partial updates - Implemented & tested

✓ Error Case 1: Missing JWT - Handled & tested
✓ Error Case 2: User not found - Handled & tested
✓ Error Case 3: Validation failure - Handled & tested
✓ Error Case 4: Authorization failure - Handled & tested

✓ Edge Case 1: Empty update - Handled & tested
✓ Edge Case 2: Invalid avatar URL - Handled & tested
✓ Edge Case 3: Special characters in name - Handled & tested

Spec Compliance: 13/13 = 100% ✅

Step 3: Checking for spec drift...

Comparing spec to implementation...
No drift detected ✅

Step 4: Verifying success criteria...

From spec:
✓ Authenticated users can update their profile
✓ Validation errors return 422 with clear messages
✓ Users cannot update other users' profiles
✓ All edge cases handled gracefully

All criteria met ✅

=== VERIFICATION REPORT ===

✅ Tests: PASS (24/24)
✅ Spec Compliance: 100%
✅ Spec Drift: None
✅ Success Criteria: All met

**OVERALL: ✅ VERIFIED**

Implementation is complete and verified. Ready for commit/merge.
```

## Example: Verification FAIL

```
You: Running verification before completion...

Step 1: Running tests...

$ npm test

❌ Tests FAILED (22/24 passing, 2 failing)

Failures:
1. "Should handle database connection errors"
   Error: Connection retry not implemented

2. "Should return 503 when database unavailable"
   Error: Returns 500 instead of 503

**BLOCKING: Tests must pass before proceeding**

Step 2: Validating spec compliance...

Reading spec: specs/features/user-profile-api.md

Checking requirements:
[checks requirements...]

❌ Non-Functional Requirement 1: Database retry logic
   Status: Not implemented
   Spec says: "3 retry attempts with exponential backoff"
   Code does: Single attempt, no retry

Spec Compliance: 12/13 = 92% ❌

Step 3: Checking success criteria...

From spec:
✓ Authenticated users can update their profile
✓ Validation errors return 422
✗ Handles database failures gracefully (missing retry logic)
✓ Users cannot update other users' profiles

=== VERIFICATION REPORT ===

❌ Tests: FAIL (2 failures)
❌ Spec Compliance: 92% (missing retry logic)
❌ Success Criteria: 3/4 met

**OVERALL: ❌ NOT VERIFIED**

**Blocking Issues:**
1. Database retry logic not implemented (from spec)
2. Tests failing for error handling
3. Returns wrong HTTP status (500 vs 503)

**Next Steps:**
1. Implement database retry logic per spec
2. Fix HTTP status code
3. Re-run verification

**DO NOT PROCEED until all issues resolved.**
```

## Common Failure Scenarios

### Scenario: Tests Pass but Spec Compliance Fails

```
✅ Tests: 24/24 passing
❌ Spec Compliance: 85%
❌ BLOCKED

Issue: Tests don't cover all spec requirements

Action: Add tests for uncovered requirements, re-verify
```

### Scenario: Spec Compliant but Tests Fail

```
❌ Tests: 20/24 passing
✅ Spec Compliance: 100%
❌ BLOCKED

Issue: Implementation exists but has bugs

Action: Fix bugs, ensure tests pass, re-verify
```

### Scenario: Both Pass but Drift Detected

```
✅ Tests: 24/24 passing
✅ Spec Compliance: 100%
⚠️  Spec Drift: Spec updated after implementation
❌ BLOCKED

Issue: Spec changed, code doesn't reflect changes

Action: Update code or revert spec, re-verify
```

## Quality Gates

**This skill enforces quality gates:**

1. **All tests must pass** (from superpowers)
2. **100% spec compliance required** (new)
3. **No spec drift allowed** (new)
4. **All success criteria must be met** (new)

**No exceptions. No shortcuts.**

These gates exist to prevent:
- Incomplete implementations
- Untested code
- Spec/code divergence
- False claims of completion

## Remember

**Verification is not optional.**

- Don't skip verification "just this once"
- Don't claim completion without verification
- Don't ignore failing gates

**Verification failures are information.**

- Tests failing? Code has bugs
- Spec compliance failing? Missing features
- Drift detected? Synchronization problem
- Criteria not met? Work incomplete

**Fix issues, don't rationalize past them.**

**Evidence before assertions. Always.**
