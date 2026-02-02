---
name: implement
description: Execute implementation from spec package with full superpowers discipline - wraps /speckit.implement with pre/post quality gates
---

# Spec-Driven Implementation with Superpowers Discipline

## Overview

This skill wraps `/speckit.implement` with superpowers discipline, adding quality gates before and after implementation.

**Value over calling `/speckit.implement` directly:**

| Phase | What sdd:implement adds |
|-------|------------------------|
| **PRE** | Spec-kit init, spec discovery, package verification, branch setup |
| **IMPLEMENTATION** | Invokes /speckit.implement |
| **POST** | Code review against spec, verification before completion, evolution if needed |

## When to Use

**Use this skill when:**
- Complete spec package exists (spec.md, plan.md, tasks.md)
- Ready to implement with full quality gates

**Don't use this skill when:**
- No spec exists → Use `sdd:brainstorm` or `sdd:spec`
- Spec exists but no plan/tasks → Use `sdd:plan`
- Debugging existing code → Use `systematic-debugging`

## The Three-Phase Process

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: PRE-IMPLEMENTATION (sdd:implement handles)        │
├─────────────────────────────────────────────────────────────┤
│  1. Initialize spec-kit                                      │
│  2. Discover and select spec                                 │
│  3. Verify spec package complete                             │
│  4. Set up feature branch                                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2: IMPLEMENTATION (/speckit.implement handles)        │
├─────────────────────────────────────────────────────────────┤
│  - Load plan and tasks                                       │
│  - Execute TDD cycles                                        │
│  - Track progress                                            │
│  - Mark tasks complete                                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3: POST-IMPLEMENTATION (sdd:implement handles)        │
├─────────────────────────────────────────────────────────────┤
│  1. Code review against spec (sdd:review-code)               │
│  2. Verification before completion                           │
│  3. Evolution if deviations found (sdd:evolve)               │
│  4. Final summary and commit guidance                        │
└─────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: Pre-Implementation

### 1.1 Initialize Spec-Kit

{Skill: spec-kit}

If spec-kit prompts for restart, pause and resume after restart.

### 1.2 Discover and Select Spec

If no spec specified:

```bash
# List all specs in the project
fd -t f "spec.md" specs/ 2>/dev/null | head -20
```

**If multiple specs:** Ask user to select using AskUserQuestion.
**If single spec:** Confirm with user.
**If no specs:** Stop and suggest `sdd:brainstorm` or `sdd:spec`.

### 1.3 Verify Spec Package

```bash
SPEC_DIR="specs/[feature-name]"

# All three must exist
[ -f "$SPEC_DIR/spec.md" ] && echo "✓ spec.md"
[ -f "$SPEC_DIR/plan.md" ] && echo "✓ plan.md"
[ -f "$SPEC_DIR/tasks.md" ] && echo "✓ tasks.md"
```

**If plan.md or tasks.md missing:**
```
Spec package incomplete. Missing: [list files]

Use /sdd:plan to generate plan.md and tasks.md.
```
**STOP.** Do not proceed without complete package.

### 1.4 Set Up Feature Branch

Check current git state:

```bash
git branch --show-current
git status --short
```

**Ask user using AskUserQuestion:**
1. Create feature branch: `git checkout -b feature/[name]`
2. Create git worktree: `git worktree add ../feature-[name] -b feature/[name]`
3. Use current branch (proceed as-is)

---

## PHASE 2: Implementation

### 2.1 Invoke /speckit.implement

**This is MANDATORY. Do not manually implement.**

```
/speckit.implement
```

The `/speckit.implement` command handles:
- Loading plan.md and tasks.md
- Executing tasks in order
- TDD approach for each task
- Progress tracking
- Marking tasks complete

**Wait for /speckit.implement to complete before proceeding to Phase 3.**

---

## PHASE 3: Post-Implementation

### 3.1 Code Review Against Spec

**Invoke sdd:review-code skill:**

{Skill: sdd:review-code}

This checks:
- All spec requirements implemented
- No extra features beyond spec
- Error handling matches spec
- Edge cases covered

**Output:** Compliance score and list of deviations.

### 3.2 Handle Deviations

**If deviations found:**

Ask user using AskUserQuestion:
1. **Update spec** - Spec was incomplete, code is correct → Use `sdd:evolve`
2. **Fix code** - Code diverged, spec is correct → Fix implementation
3. **Document and proceed** - Minor deviation, acceptable

**If "Update spec" selected:**
```
{Skill: sdd:evolve}
```

### 3.3 Verification Before Completion

**Invoke verification skill:**

{Skill: sdd:verification-before-completion}

This runs:
1. All tests pass
2. Spec compliance validated
3. No unaddressed deviations
4. All success criteria from spec met

**If verification fails:** Loop back to fix issues.

### 3.4 Final Summary

Present completion summary:

```markdown
## Implementation Complete

**Spec:** specs/[feature-name]/spec.md
**Branch:** feature/[feature-name]

### Results
- Tasks completed: [N]/[N]
- Tests passing: [N]
- Spec compliance: [X]%

### Deviations
[List any documented deviations]

### Code Review
[Summary from sdd:review-code]

### Next Steps
- [ ] Review changes: `git diff`
- [ ] Commit: `git add . && git commit`
- [ ] Push: `git push -u origin feature/[name]`
- [ ] Create PR: `gh pr create`
```

---

## Checklist

### Phase 1: Pre-Implementation
- [ ] Initialize spec-kit
- [ ] Discover and select spec
- [ ] Verify spec package (spec.md, plan.md, tasks.md)
- [ ] Set up feature branch

### Phase 2: Implementation
- [ ] Invoke `/speckit.implement`
- [ ] Wait for completion

### Phase 3: Post-Implementation
- [ ] Code review against spec (sdd:review-code)
- [ ] Handle any deviations (sdd:evolve if needed)
- [ ] Verification before completion
- [ ] Present final summary

---

## Integration with Other Skills

**This skill INVOKES:**
- `{Skill: spec-kit}` - Pre-implementation init
- `/speckit.implement` - Core implementation
- `{Skill: sdd:review-code}` - Post-implementation review
- `{Skill: sdd:verification-before-completion}` - Final verification
- `{Skill: sdd:evolve}` - If deviations need reconciliation

**This skill is the recommended entry point for implementation.**

Users CAN call `/speckit.implement` directly, but they will miss:
- Spec-kit initialization
- Spec discovery
- Branch setup guidance
- Post-implementation code review
- Verification before completion
- Evolution workflow for deviations

---

## Error Handling

**If /speckit.implement is not available:**
```
The /speckit.implement command is not installed.

Run: specify init
Then restart Claude Code to load the new commands.
```

**If /speckit.implement fails:**
- Report the error
- Suggest checking plan.md and tasks.md format
- Offer to run `/speckit.analyze` to check consistency

**If post-implementation review fails:**
- Present issues clearly
- Offer options: fix code, update spec, or proceed anyway
- Document decision

---

## Remember

**This skill provides the FULL SDD workflow.**

Calling `/speckit.implement` directly skips important quality gates:
- No automatic spec-kit init
- No spec discovery
- No post-implementation review
- No verification before completion

**For complete spec-driven development, always use `/sdd:implement`.**
