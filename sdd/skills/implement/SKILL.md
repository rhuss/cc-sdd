---
name: implement
description: Execute implementation from existing spec package (spec.md, plan.md, tasks.md) using TDD with spec compliance checking
---

# Spec-Driven Implementation

## Overview

Execute implementation from a complete spec package using Test-Driven Development, with continuous spec compliance checking throughout.

This skill expects a complete spec package to already exist:
- `spec.md` - Requirements (WHAT)
- `plan.md` - Implementation approach (HOW)
- `tasks.md` - Task breakdown

## MANDATORY: Use /speckit.implement

**This skill MUST invoke `/speckit.implement` to execute implementation.**

### Prerequisite: Verify speckit.implement command exists

Before invoking, verify the local command is available:

```bash
# Check if speckit.implement command exists
if [ -f .claude/commands/speckit.implement.md ]; then
  echo "✓ speckit.implement command available"
else
  echo "❌ speckit.implement command NOT found"
  echo ""
  echo "The /speckit.implement command must be installed."
  echo "Run: specify init"
  echo "Then restart Claude Code to load the new commands."
fi
```

**If command is missing: STOP. Do not proceed.** Run `specify init` and restart.

### Invoke the command

After verifying the spec package exists AND the command is available, invoke:

```
/speckit.implement
```

**Do NOT manually implement steps from this document.**
**Do NOT read plan.md and tasks.md and "follow" them yourself.**
**Do NOT proceed with TDD cycles without invoking /speckit.implement.**

The `/speckit.implement` command handles the actual implementation workflow.
This skill (`sdd:implement`) is the entry point that ensures prerequisites are met.

**Critical Rule:** Implementation MUST match spec. Any deviation triggers spec evolution workflow.

## When to Use

**Use this skill when:**
- Complete spec package exists (spec.md, plan.md, tasks.md)
- Spec is validated and reviewed
- Ready to write code

**Don't use this skill when:**
- No spec exists → Use `sdd:spec` or `sdd:brainstorm` first
- Spec exists but no plan/tasks → Run `sdd:spec` to generate them
- Spec/code mismatch exists → Use `sdd:evolve`
- Debugging existing code → Use `systematic-debugging`

## Technical Prerequisites

Ensure spec-kit is initialized:

{Skill: spec-kit}

If spec-kit prompts for restart, pause this workflow and resume after restart.

## Spec Selection

If no spec is specified, discover available specs:

```bash
# List all specs in the project
fd -t f "spec.md" specs/ 2>/dev/null | head -20
```

**If specs found:** Present list and ask user to select one using AskUserQuestion.

Example:
```
Found 3 specs in this project:
1. specs/0001-user-auth/spec.md
2. specs/0002-api-gateway/spec.md
3. specs/0003-notification-service/spec.md

Which spec would you like to implement?
```

**If no specs found:** Inform user and suggest creating one first:
```
No specs found in specs/ directory.

To create a spec first:
- Use `sdd:brainstorm` to refine ideas into a spec
- Use `sdd:spec` to create a spec from clear requirements

Cannot proceed with implementation without a spec.
```

## Spec Package Verification

Before implementation can begin, verify the complete spec package exists:

```bash
SPEC_DIR="specs/[feature-name]"

echo "Verifying spec package..."

# Check spec.md
if [ ! -f "$SPEC_DIR/spec.md" ]; then
  echo "❌ MISSING: spec.md"
  echo "Use sdd:spec to create the spec package first."
  exit 1
fi
echo "✓ spec.md exists"

# Check plan.md
if [ ! -f "$SPEC_DIR/plan.md" ]; then
  echo "❌ MISSING: plan.md"
  echo "The spec package is incomplete."
  echo "Use /speckit.plan or sdd:spec to generate it."
  exit 1
fi
echo "✓ plan.md exists"

# Check tasks.md
if [ ! -f "$SPEC_DIR/tasks.md" ]; then
  echo "❌ MISSING: tasks.md"
  echo "The spec package is incomplete."
  echo "Use /speckit.tasks or sdd:spec to generate it."
  exit 1
fi
echo "✓ tasks.md exists"

echo "✓ Spec package complete"
```

**If any file is missing: STOP. Do not proceed. Do not generate internally.**

The spec package must be created via `sdd:spec` or manually with spec-kit CLI.

## CRITICAL: Spec Package Required

This skill requires a complete spec package. Claude MUST NOT:
- Generate plans internally (they come from `sdd:spec` or `/speckit.plan`)
- Generate tasks internally (they come from `sdd:spec` or `/speckit.tasks`)
- Create any spec artifacts by hand
- "Manually proceed" when something is unexpected

**FAILURE PROTOCOL:**
- If spec package is incomplete → STOP and tell user to run `sdd:spec`
- If paths don't match expectations → STOP and diagnose the issue
- If artifacts are missing → STOP and suggest using `/speckit.*` commands or `sdd:spec`

**Examples of CORRECT behavior:**
```
✓ "The spec package is incomplete. Use /speckit.plan and /speckit.tasks to generate artifacts."
✓ "The branch naming doesn't match expectations. Please check the spec directory structure."
✓ "Missing tasks.md. Use sdd:spec to create a complete spec package."
```

## Workflow Prerequisites

**Before starting implementation:**
- [ ] Spec exists in `specs/features/[feature-name].md`
- [ ] Spec validated for soundness (`sdd:review-spec`)
- [ ] Spec validated against constitution (if exists)
- [ ] No open questions in spec that block implementation

**If prerequisites not met:** Stop and address them first.

## The Process

### 1. Verify Spec Package (this skill's responsibility)

Run the Spec Package Verification from above. Ensure all three files exist:
- `spec.md`
- `plan.md`
- `tasks.md`

**If any file is missing: STOP and tell the user to run `sdd:spec` first.**

### 2. Invoke /speckit.implement (MANDATORY)

**After verification passes, invoke the /speckit.implement command:**

```
/speckit.implement
```

**This is the ONLY way to proceed.** The /speckit.implement command handles:
- Reading and understanding the spec
- Loading implementation artifacts
- Setting up workspace
- TDD implementation cycles
- Spec compliance checking

**Do NOT manually perform these steps. Invoke the command.**

### 3. (Handled by speckit.implement) Set Up Isolated Workspace

**Check for existing feature branch:**

```bash
FEATURE_NAME="[feature-name]"
BRANCH_NAME="feature/$FEATURE_NAME"

# Check if branch exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "✓ Feature branch exists: $BRANCH_NAME"
else
  echo "⚠️  No feature branch found: $BRANCH_NAME"
fi
```

**If no feature branch exists: ASK the user.**

Use AskUserQuestion with options:
1. **Create feature branch** - `git checkout -b feature/[feature-name]`
2. **Create git worktree** - `git worktree add ../feature-[name] -b feature/[name]`
3. **Use current branch** - Continue on current branch (user's choice)

**Do NOT automatically create branches or proceed without asking.**

**After branch setup (if using worktree):**

```bash
git worktree add ../feature-[name] -b feature/[name]
cd ../feature-[name]
```

**Or for simple feature branch:**

```bash
git checkout -b feature/[feature-name]
```

**Before proceeding, ensure:**
- Clean working directory (no uncommitted changes)
- On the correct branch for implementation

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

**This skill (sdd:implement) handles:**
- [ ] Verify spec package exists (spec.md, plan.md, tasks.md)
- [ ] Invoke `/speckit.implement`

**The /speckit.implement command handles everything else:**
- [ ] Read and understand spec
- [ ] Load plan and tasks
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

Verifying spec package...

$ SPEC_DIR="specs/user-profile-api"
$ [ -f "$SPEC_DIR/spec.md" ] && echo "✓ spec.md exists"
✓ spec.md exists
$ [ -f "$SPEC_DIR/plan.md" ] && echo "✓ plan.md exists"
✓ plan.md exists
$ [ -f "$SPEC_DIR/tasks.md" ] && echo "✓ tasks.md exists"
✓ tasks.md exists

✓ Spec package complete

Now invoking /speckit.implement to execute the implementation...

/speckit.implement

[/speckit.implement takes over and handles all implementation steps]
```

**What happens if spec package is incomplete:**

```
User: Let's implement the user profile API from the spec

You: I'm using sdd:implement to build this feature from the spec.

Verifying spec package...

$ SPEC_DIR="specs/user-profile-api"
$ [ -f "$SPEC_DIR/spec.md" ] && echo "✓ spec.md exists"
✓ spec.md exists
$ [ -f "$SPEC_DIR/plan.md" ] && echo "✓ plan.md exists"
[no output]
$ [ -f "$SPEC_DIR/tasks.md" ] && echo "✓ tasks.md exists"
[no output]

❌ Spec package is incomplete.

Missing files:
- plan.md
- tasks.md

The spec package must be created via sdd:spec first.
Run: sdd:spec to generate the complete package, or use:
  /speckit.plan
  /speckit.tasks
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

## Integration with spec-kit CLI and Skills

**This skill (sdd:implement) is an entry point that:**
1. Verifies the spec package exists
2. Invokes `/speckit.implement` to do the actual work

**This skill INVOKES:**
- `/speckit.implement` - The actual implementation workflow (MANDATORY)

**This skill does NOT:**
- Generate `plan.md` or `tasks.md` (created by `sdd:spec`)
- Manually read artifacts and follow steps
- Perform TDD cycles directly

**The /speckit.implement command orchestrates:**
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
