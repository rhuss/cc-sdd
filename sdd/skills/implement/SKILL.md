---
name: implement
description: Execute implementation from spec package with full superpowers discipline - wraps /speckit.implement with pre/post quality gates
---

# Spec-Driven Implementation with Superpowers Discipline

## Flag Detection

Parse the ARGUMENTS for the `--with-beads` flag:

```
BEADS_MODE = false
If ARGUMENTS contain "--with-beads":
  BEADS_MODE = true
```

When `BEADS_MODE` is true, Phase 2 uses beads-driven execution (Path B) instead of `/speckit.implement` (Path A). All other phases remain unchanged.

## Overview

This skill wraps `/speckit.implement` with superpowers discipline, adding quality gates before and after implementation.

**Value over calling `/speckit.implement` directly:**

| Phase | What sdd:implement adds |
|-------|------------------------|
| **PRE** | Spec-kit init, spec discovery, package verification, branch setup |
| **IMPLEMENTATION** | Invokes /speckit.implement (or beads-driven loop with `--with-beads`) |
| **POST** | Code review against spec, verification before completion, evolution if needed |

## When to Use

**Use this skill when:**
- Complete spec package exists (spec.md, plan.md, tasks.md)
- Ready to implement with full quality gates
- Add `--with-beads` for multi-session implementation with persistent task tracking via beads

**Don't use this skill when:**
- No spec exists → Use `sdd:brainstorm` or `sdd:spec`
- Spec exists but no plan/tasks → Use `sdd:plan`
- Debugging existing code → Use `systematic-debugging`

## The Process

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
                     ┌── BEADS_MODE? ──┐
                     │                 │
                   false             true
                     │                 │
                     ↓                 ↓
┌──────────────────────┐  ┌──────────────────────────────────┐
│  PHASE 2: Path A     │  │  PHASE 1.5: Beads Bootstrap      │
│  /speckit.implement   │  │  - Verify bd CLI, bd init        │
│  (unchanged)          │  │  - Resume detection              │
└──────────┬───────────┘  │  - Parse tasks.md                │
           │              │  - Create beads issues + deps     │
           │              │  - DAG verification               │
           │              └──────────────┬───────────────────┘
           │                             ↓
           │              ┌──────────────────────────────────┐
           │              │  PHASE 2B: Beads Execution Loop   │
           │              │  - bd ready -> implement -> close │
           │              │  - Handle discovered work         │
           │              │  - Loop until all done            │
           │              └──────────────┬───────────────────┘
           │                             ↓
           │              ┌──────────────────────────────────┐
           │              │  PHASE 2.5: Sync-Back            │
           │              │  - Update tasks.md checkboxes     │
           │              │  - Append discovered tasks        │
           │              │  - bd sync                        │
           │              └──────────────┬───────────────────┘
           │                             │
           └──────────┬─────────────────┘
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

**IMPORTANT: Spec-kit requires branches named `NNN-feature-name`** (e.g., `002-operator-config`).
The numeric prefix must match the spec directory number (e.g., spec in `specs/002-operator-config/` requires branch `002-operator-config` or `002-some-other-name`).

Branches with prefixes like `feature/`, `spec/`, or `fix/` will fail spec-kit validation.

Check current git state:

```bash
git branch --show-current
git status --short
```

**Determine the spec number from the selected spec directory** (e.g., `specs/002-operator-config` → prefix is `002`).

**Check if current branch already matches `^[0-9]{3}-` pattern:**

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" =~ ^[0-9]{3}- ]]; then
  echo "Branch '$BRANCH' matches spec-kit convention"
else
  echo "Branch '$BRANCH' does NOT match spec-kit convention (must be NNN-feature-name)"
fi
```

**If branch does NOT match, ask user using AskUserQuestion:**
1. Create feature branch: `git checkout -b NNN-feature-name` (e.g., `002-operator-config`)
2. Create git worktree: `git worktree add ../NNN-feature-name -b NNN-feature-name`
3. Use current branch (proceed as-is, but spec-kit commands may fail)

---

## PHASE 2: Implementation

**Phase 2 has two paths. Choose based on BEADS_MODE:**

### Path A: Standard Implementation (BEADS_MODE = false)

#### 2A.1 Invoke speckit.implement via Skill Tool

**This is MANDATORY. Do not manually implement.**

```
Skill(skill: "speckit.implement")
```

The `speckit.implement` command handles:
- Loading plan.md and tasks.md
- Executing tasks in order
- TDD approach for each task
- Progress tracking
- Marking tasks complete

**Wait for /speckit.implement to complete before proceeding to Phase 3.**

### Path B: Beads-Driven Implementation (BEADS_MODE = true)

> Path B is documented in the sections below: Phase 1.5 (Beads Bootstrap), Phase 2B (Beads Execution Loop), and Phase 2.5 (Sync-Back).

**Skip to Phase 1.5 below.** After Phase 1.5 completes, Phase 2B runs the beads execution loop, then Phase 2.5 syncs back to tasks.md. Finally, proceed to Phase 3.

---

## PHASE 1.5: Beads Bootstrap (only when BEADS_MODE = true)

> This phase runs between Phase 1 and Phase 2B. It converts tasks.md into beads issues with dependencies.

### 1.5.1 Verify bd CLI and Initialize Beads

Verify the `bd` CLI is available:

```bash
bd --version
```

**If `bd` is not found**, STOP with this error:

```
Error: beads CLI (bd) is not installed.

Install beads: brew install beads
Or see: https://github.com/steveyegge/beads

Cannot proceed with --with-beads without the bd CLI.
```

**Do NOT fall back to speckit.implement silently.** The user explicitly requested beads mode.

If `bd` is available, check if `.beads/` directory exists:

```bash
if [ ! -d ".beads" ]; then
  bd init --quiet
fi
```

The `--quiet` flag suppresses interactive prompts. This creates `.beads/` with `beads.db`, `issues.jsonl`, and config files. This MUST complete before any `bd create` calls.

### 1.5.2 Resume Detection

Check whether beads issues already exist for this spec (indicating a previous session):

**Step 1:** If `.beads/` directory does not exist, this is a first run. Proceed to 1.5.3.

**Step 2:** If `.beads/` exists, query existing issues:

```bash
bd list --json
```

If `bd list --json` fails, treat as first run and proceed to 1.5.3.

**Step 3:** Extract task IDs from beads issue titles. Beads issue titles follow the pattern `T001 Description text`. Parse the `T\d{3}` prefix from each title.

**Step 4:** Parse task IDs from the current tasks.md (see 1.5.3 regex).

**Step 5:** Calculate the match ratio:

```
match_ratio = (number of beads task IDs found in tasks.md) / (total task IDs in tasks.md)
```

**Step 6:** Decision:

- If `match_ratio > 0.50` (more than 50% match): **Resume detected.** Skip conversion (skip 1.5.3, 1.5.4, 1.5.5). Proceed directly to Phase 2B execution loop.
- If `match_ratio <= 0.50` or no matches: **First run for this spec.** Proceed to 1.5.3.

If existing issues do not match (stale issues from a different spec):

```
Found N existing beads issues that don't match current tasks.md.
Creating new issues for current spec alongside existing ones.
```

Do NOT delete or modify the existing stale issues. Create new issues alongside them.

### 1.5.3 Parse tasks.md

Read the tasks.md file and parse each task line using this regex pattern:

```
^- \[([ Xx])\] (T\d{3}) (\[P\] )?(\[US\d+\] )?(.+)$
```

**Captures:**
- Group 1: Checkbox state (space = unchecked, `X` or `x` = checked)
- Group 2: Task ID (`T001`, `T002`, etc.)
- Group 3: Optional parallel marker `[P]`
- Group 4: Optional user story label `[US1]`
- Group 5: Task description (including file path references)

**Phase detection:** Identify phase boundaries by matching headings:

```
^##+ .*Phase|^##+ .*Setup|^##+ .*Foundational|^##+ .*User Story|^##+ .*Polish
```

Group each task under its phase. Maintain the phase ordering and task ordering within each phase.

**Parse error handling:** If a line looks like a task (starts with `- [`) but does not match the regex, report:

```
Parse error at line N: "<line content>"
Expected format: - [ ] T001 [P] [US1] Task description

Suggestion: Run /speckit.tasks to regenerate tasks.md in the correct format.
```

STOP conversion if any parse errors occur. Do not create a partial set of beads issues from an incomplete parse.

### 1.5.4 Create Beads Issues with Dependencies

For each parsed task, create a beads issue:

```bash
bd create "T001 Create project structure per implementation plan" \
  -t task \
  -p <priority> \
  --json
```

**Priority mapping based on phase:**

| Phase | Priority |
|-------|----------|
| Setup / Foundational | 1 (highest) |
| User Story P1 tasks | 2 |
| User Story P2+ tasks | 3 |
| Polish / Integration | 4 |

Capture the beads issue ID from the `--json` output for each created issue. Build a mapping of `task_id -> beads_id` (e.g., `T001 -> abc123`).

**Dependency creation (within a phase):**

- Sequential tasks (no `[P]` marker): Each task is blocked by its predecessor.
  ```bash
  bd dep add <current-beads-id> <previous-beads-id> --type blocking
  ```
- Parallel tasks (`[P]` marker): Share the same predecessor but do NOT block each other.
  ```bash
  # T003 is sequential, T004 [P] and T005 [P] are parallel after T003
  bd dep add <T004-beads-id> <T003-beads-id> --type blocking
  bd dep add <T005-beads-id> <T003-beads-id> --type blocking
  # T004 and T005 do NOT block each other
  ```

**Dependency creation (across phases, "last sequential task as phase gate"):**

Phase N+1 tasks are blocked by the gate task(s) of Phase N:

- If Phase N ends with sequential tasks: the last sequential task is the gate.
- If Phase N ends with parallel tasks: ALL trailing parallel tasks are gates.

```bash
# Phase N gate is T005. Phase N+1 starts with T006.
bd dep add <T006-beads-id> <T005-beads-id> --type blocking
```

**Pre-checked tasks:** For tasks already marked `[X]` in tasks.md, create the issue normally with dependencies, then immediately close it:

```bash
bd create "T001 Already completed task" -t task -p 1 --json
# capture beads_id
bd close <beads_id> --reason "completed"
```

This preserves the dependency graph while ensuring closed tasks don't appear in `bd ready`.

**If `bd create` fails:** STOP conversion. Report how many tasks were created successfully:

```
Error: bd create failed for T005 "Description here"
  Created: 4/10 issues successfully

Suggestion: Run `bd sync` to save current state, then retry /sdd:implement --with-beads
```

Do NOT proceed to the execution loop with a partial set of issues.

### 1.5.5 Bootstrap Summary and DAG Verification

After all issues and dependencies are created, verify the dependency structure:

```bash
bd dep tree <root-task-beads-id> --json
```

Report the bootstrap summary:

```
Beads Bootstrap Complete
  Issues created: N
  Dependencies: M edges
  Phases: K
  Pre-closed (already [X]): P
  DAG depth: D levels

Ready to begin beads-driven implementation.
```

Visually confirm the DAG matches the expected phase structure. If the tree looks incorrect (missing dependencies, unexpected structure), STOP and report the issue before proceeding to Phase 2B.

---

## PHASE 2B: Beads-Driven Execution Loop (only when BEADS_MODE = true)

> This phase replaces Phase 2 Path A. It uses `bd ready` to determine task ordering.

### 2B.1 Get Next Ready Task

```bash
bd ready --json
```

Parse the JSON output to get the next unblocked task. The task with the highest priority (lowest number) should be implemented first. If multiple tasks are ready, pick the one with the lowest priority number (highest urgency).

**If `bd ready` returns empty and NO open issues remain:** All tasks are complete. Proceed to Phase 2.5 (Sync-Back).

**If `bd ready` returns empty but open issues exist:** This indicates a circular dependency. Handle it:

1. Run `bd list --json` to identify all open issues
2. For each open issue, run `bd show <id> --json` to display its blockers
3. Present the dependency chain to the user
4. Ask user using AskUserQuestion:
   - Manually close a blocking issue to break the cycle
   - Stop and investigate the dependency structure

**If `bd ready` fails or returns malformed JSON:** STOP the implementation loop:

```
Error: bd ready returned invalid output.
Raw output: <show raw output>

Suggestion: Check beads health with `bd list --json` and `bd sync`
```

### 2B.2 Implement Task

For the selected ready task:

1. Extract the task description from the beads issue title (everything after the task ID)
2. Read the relevant section from plan.md for implementation context
3. Implement using the same TDD approach as speckit.implement:
   - Write failing test first
   - Implement to make test pass
   - Refactor if needed
4. Verify the implementation against the spec requirements

### 2B.3 Close Beads Issue

After successful implementation:

```bash
bd close <beads-id> --reason "completed"
```

**If `bd close` fails:** Report the error but do NOT mark the task as done. Continue to the next `bd ready` result. The failed close will cause the task to reappear in `bd ready` on the next iteration.

```
Warning: bd close failed for <beads-id> (T005 "Description")
Error: <error message>
Continuing to next task. This task will reappear in bd ready.
```

### 2B.4 Handle Discovered Work

During implementation, if new work is identified (missing utility, unforeseen dependency, bug found):

1. Create a beads issue for the discovered work:
   ```bash
   bd create "DISCOVERED: <description>" -t task -p 2 --json
   ```

2. If it blocks the current task, add a dependency:
   ```bash
   bd dep add <current-task-beads-id> <discovered-beads-id> --type blocking
   ```
   Then implement the discovered task first (it will appear in `bd ready` after adding the dependency).

3. If it does not block the current task, no dependency is needed. It will appear in `bd ready` when its own blockers (if any) are resolved.

### 2B.5 Loop

Return to 2B.1. Continue until `bd ready` returns empty and no open issues remain.

---

## PHASE 2.5: Sync-Back to tasks.md (only when BEADS_MODE = true)

> This phase runs after Phase 2B completes. It synchronizes beads state back to tasks.md.

### 2.5.1 Read All Beads Issues

```bash
bd list --json
```

Parse the JSON output to get all issues with their:
- Beads ID
- Title (contains task ID like `T001`)
- Status (open/closed)

**If `bd list` fails:** Skip sync-back. Report the error and suggest manual sync:

```
Warning: Could not read beads state for sync-back.
Error: <error message>

Manual sync: Run `bd list` and update tasks.md manually.
```

### 2.5.2 Match to tasks.md Entries

For each beads issue:
1. Extract the task ID from the title (`T\d{3}` prefix)
2. Find the matching line in tasks.md
3. Issues without a matching task ID (e.g., titles starting with `DISCOVERED:` or lacking a `T\d{3}` prefix) are classified as discovered work

### 2.5.3 Update Checkbox States

For each matched beads issue:
- If beads status is **closed**: replace `- [ ]` with `- [X]` in tasks.md
- If beads status is **open**: ensure the line shows `- [ ]` (no change if already unchecked)

**Preserve the original task ordering and phase structure.** Only change the checkbox character. Do not reformat, reorder, or alter any other content.

### 2.5.4 Append Discovered Tasks

For beads issues that have no matching task ID in tasks.md:

1. Collect all discovered issues
2. Append a new section at the end of tasks.md:

```markdown
## Discovered During Implementation

- [X] DISCOVERED: Fix race condition in event handler
- [ ] DISCOVERED: Add retry logic for API timeout
```

Each line uses `[X]` if the beads issue is closed, `[ ]` if still open.

### 2.5.5 Run bd sync

After updating tasks.md, persist beads state to the git-tracked JSONL file:

```bash
bd sync
```

This ensures the next session can detect and resume from the current state.

**Sync-back write failure:** If tasks.md cannot be written (permissions, disk full), report the error and print the intended changes to stdout:

```
Error: Could not write to tasks.md
Intended changes:
  T001: [ ] -> [X]
  T003: [ ] -> [X]
  T005: [ ] -> [X]
  Discovered: "Fix race condition in event handler" [X]

Apply these changes manually.
```

Never lose sync-back data silently.

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
- [ ] Push: `git push -u origin NNN-feature-name`
- [ ] Create PR: `gh pr create`
```

---

## Checklist

### Phase 1: Pre-Implementation
- [ ] Initialize spec-kit
- [ ] Discover and select spec
- [ ] Verify spec package (spec.md, plan.md, tasks.md)
- [ ] Set up feature branch

### Phase 2: Implementation (Path A, without --with-beads)
- [ ] Invoke `/speckit.implement`
- [ ] Wait for completion

### Phase 1.5 + 2B + 2.5: Implementation (Path B, with --with-beads)
- [ ] Verify bd CLI available
- [ ] Initialize beads (`bd init --quiet`) if needed
- [ ] Check for resume (existing beads issues)
- [ ] Parse tasks.md and create beads issues with dependencies
- [ ] Verify DAG structure (`bd dep tree`)
- [ ] Execute beads loop (`bd ready` -> implement -> `bd close`)
- [ ] Handle discovered work (new `bd create` calls)
- [ ] Sync-back: update tasks.md checkbox states
- [ ] Sync-back: append discovered tasks section
- [ ] Run `bd sync` to persist state

### Phase 3: Post-Implementation
- [ ] Code review against spec (sdd:review-code)
- [ ] Handle any deviations (sdd:evolve if needed)
- [ ] Verification before completion
- [ ] Present final summary

---

## Integration with Other Skills

**This skill INVOKES:**
- `{Skill: spec-kit}` - Pre-implementation init
- `/speckit.implement` - Core implementation (Path A only)
- `{Skill: sdd:review-code}` - Post-implementation review
- `{Skill: sdd:verification-before-completion}` - Final verification
- `{Skill: sdd:evolve}` - If deviations need reconciliation

**External dependency (Path B only):**
- `bd` CLI (beads issue tracker) - Required when `--with-beads` is specified. Install via `brew install beads`. See https://github.com/steveyegge/beads

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

**If /speckit.implement is not available (Path A):**
```
The /speckit.implement command is not installed.

Run: specify init
Then restart Claude Code to load the new commands.
```

**If /speckit.implement fails (Path A):**
- Report the error
- Suggest checking plan.md and tasks.md format
- Offer to run `/speckit.analyze` to check consistency

**Beads error handling (Path B):** All beads CLI errors are handled inline in their respective phases:
- `bd` CLI not found: Phase 1.5.1
- `bd init` failure: Phase 1.5.1
- `bd list` failure (resume/sync-back): Phase 1.5.2, Phase 2.5.1
- tasks.md parse errors: Phase 1.5.3
- `bd create` failure: Phase 1.5.4
- `bd ready` failure or circular dependency: Phase 2B.1
- `bd close` failure: Phase 2B.3
- Sync-back write failure: Phase 2.5.5

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
