---
name: plan
description: Generate implementation plan and tasks from a validated specification - wraps /speckit.plan and /speckit.tasks with superpowers discipline
---

# Generate Implementation Plan and Tasks

## Overview

This skill generates implementation artifacts (plan.md, tasks.md) from a validated specification. It wraps the `/speckit.plan` and `/speckit.tasks` commands while adding superpowers discipline.

**This skill provides value over calling /speckit.* directly by:**
1. Ensuring spec-kit is initialized
2. Validating the spec before planning
3. Running spec review to catch issues early
4. Verifying generated artifacts are complete
5. Coverage matrix validation (requirement to task to test mapping)
6. Red flag scanning (detecting vague language, missing file paths, TBD items)
7. Task quality enforcement (Actionable, Testable, Atomic, Ordered)

## When to Use

**Use this skill when:**
- Spec exists and you need to generate plan.md and tasks.md
- Preparing for implementation
- Updating plan/tasks after spec changes

**Don't use this skill when:**
- No spec exists → Use `sdd:brainstorm` or `sdd:spec` first
- Ready to implement → Use `sdd:implement` (which will check for plan/tasks)

## Prerequisites

Ensure spec-kit is initialized:

{Skill: spec-kit}

If spec-kit prompts for restart, pause this workflow and resume after restart.

## The Process

### 1. Spec Selection

If no spec is specified, discover available specs:

```bash
# List all specs in the project
fd -t f "spec.md" specs/ 2>/dev/null | head -20
```

**If multiple specs found:** Present list and ask user to select one using AskUserQuestion.

**If single spec found:** Confirm with user: "Found [spec path]. Generate plan for this spec?"

**If no specs found:**
```
No specs found in specs/ directory.

To create a spec first:
- Use `sdd:brainstorm` to refine ideas into a spec
- Use `sdd:spec` to create a spec from clear requirements

Cannot generate plan without a spec.
```

### 2. Validate Spec Before Planning

**Before generating plan, validate the spec is ready:**

Use `sdd:review-spec` to check:
- Completeness (all sections filled)
- Clarity (no ambiguous language)
- Implementability (can generate plan from this)

**If review finds critical issues:**
```
Spec has issues that should be fixed before planning:
[List issues]

Fix these issues first, then run /sdd:plan again.
```

**STOP and wait for user to fix issues.**

**If review passes or only minor issues:**
Proceed to planning.

### 3. Validate Branch Name

**IMPORTANT: Spec-kit requires branches named `NNN-feature-name`** (e.g., `002-operator-config`).
The numeric prefix must match the spec directory number. Branches with prefixes like `feature/`, `spec/`, or `fix/` will fail.

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" =~ ^[0-9]{3}- ]]; then
  echo "Branch '$BRANCH' matches spec-kit convention"
else
  echo "WARNING: Branch '$BRANCH' does NOT match spec-kit convention (must be NNN-feature-name)"
fi
```

**If branch does NOT match, ask user using AskUserQuestion:**
1. Switch to a properly named branch: `git checkout -b NNN-feature-name` (e.g., `002-operator-config`)
2. Use current branch (spec-kit commands may fail with branch validation errors)

### 4. Generate Plan

**Call the Skill tool to generate the implementation plan:**

```
Skill(skill: "speckit.plan")
```

This creates `specs/[feature-name]/plan.md` with:
- Implementation approach
- Technical decisions
- File structure
- Architecture overview

**Verify plan was created:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/plan.md" ]; then
  echo "plan.md created successfully"
else
  echo "ERROR: plan.md was not created"
fi
```

**Post-generation check: Error/Edge Case and Success Criteria Coverage**

After plan.md is generated, read both the spec and the plan, then verify:

1. **Error case coverage**: Every error case listed in the spec has a corresponding handling approach in the plan.
2. **Edge case coverage**: Every edge case from the spec is addressed in the plan.
3. **Success criteria reference**: The plan references the spec's success criteria and has verification approaches for each.

If any are missing, note the gaps and add them to the plan before proceeding.

### 5. Generate Tasks

**Call the Skill tool to generate the task breakdown:**

```
Skill(skill: "speckit.tasks")
```

This creates `specs/[feature-name]/tasks.md` with:
- Task phases (Setup, Tests, Core, Integration, Polish)
- Task dependencies
- Parallel execution markers
- File paths for each task

**Verify tasks were created:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/tasks.md" ]; then
  echo "tasks.md created successfully"
else
  echo "ERROR: tasks.md was not created"
fi
```

**Post-generation check: Task Quality Standards**

After tasks.md is generated, verify every task meets these criteria:

- **Actionable**: Clear what to do (not "figure out..." or "investigate...")
- **Testable**: Can verify completion objectively
- **Atomic**: One clear outcome per task
- **Ordered**: Dependencies between tasks are respected, phases are sequenced correctly

Also check:
- Every task specifies concrete file paths (not "somewhere" or "TBD")
- Phase ordering is logical (setup before core, tests before integration)
- No tasks duplicate work already covered by other tasks

If tasks fail these checks, note the issues and refine before proceeding.

### 6. Verify Artifact Consistency

**Run consistency check using the Skill tool:**

```
Skill(skill: "speckit.analyze")
```

This verifies:
- Plan covers all spec requirements
- Tasks implement all plan items
- No orphaned tasks or missing coverage

**Coverage Matrix Output**

After the consistency check, produce an explicit coverage matrix mapping every spec requirement to its implementing tasks and tests:

```
Requirement 1 → Tasks [X,Y], Tests [A,B]     ✓
Requirement 2 → Tasks [Z],   Tests [C,D]     ✓
NFR 1         → Tasks [W],   Validation [E]  ✓
...
```

Any requirement without task coverage or test coverage must be flagged and resolved before proceeding.

**If consistency check fails:**
Report issues and suggest fixes.

### 7. Scan for Plan Quality Issues

**Red flag scan**: Search plan.md and tasks.md for vague or incomplete language:

```bash
SPEC_DIR="specs/[feature-name]"
rg -i "figure out|tbd|todo|implement later|somehow|somewhere|not sure|maybe|probably" "$SPEC_DIR/plan.md" "$SPEC_DIR/tasks.md" || echo "No red flags found"
```

Review any matches. Each is a potential gap:
- "Figure out..." = missing research, needs concrete approach
- "TBD" = incomplete planning, must be resolved
- "Implement later" = deferred work that should be scoped explicitly
- Missing file paths = tasks are not actionable

**NFR validation check**: For each non-functional requirement in the spec, verify the plan includes:
- A concrete measurement method (not just "should be fast")
- A validation approach (how will you verify the NFR is met?)
- Acceptance thresholds where applicable (response time < 200ms, etc.)

If any NFR lacks a measurement method, add one before proceeding.

**Resolve all red flags and NFR gaps before moving to the next step.**

### 8. Generate Review Summary and Brief

After plan and tasks are complete, generate review documents for stakeholders.

**Read source documents:**
- Read `specs/[feature-name]/spec.md`
- Read `specs/[feature-name]/plan.md`

**Extract and synthesize:**

1. **Feature Overview** (3-5 sentences from spec Purpose section)

2. **Scope Boundaries**
   - In scope: From spec requirements
   - Out of scope: From spec "Out of Scope" section
   - Why: Brief justification for boundaries

3. **Critical Decisions** - Identify choices with trade-offs:
   - Architecture approach chosen
   - Technology or library selections
   - Design patterns adopted
   - Integration approach with existing systems
   - For each: Choice made, alternatives considered, trade-off, feedback requested

4. **Areas of Potential Disagreement** - Explicitly identify:
   - Trade-offs where reasonable people might disagree
   - Assumptions that could be challenged
   - Scope decisions (inclusions/exclusions) that might be questioned
   - Unconventional approaches taken
   - For each: What was decided, why it might be controversial, alternative view, feedback requested

5. **Naming Decisions** - Extract all named elements:
   - API endpoint paths
   - Field names in contracts/schemas
   - Error codes and messages
   - Configuration keys
   - Command names

6. **Schema Definitions** - Condense key structures:
   - Request/response formats
   - Configuration schemas
   - Data models

7. **Architecture Choices** - From plan.md:
   - Overall pattern
   - Key components
   - Integration points

8. **Open Questions** - Pull from spec and plan:
   - Areas needing stakeholder input
   - Deferred decisions

9. **Risk Areas** - High-impact concerns

**Create review-summary.md:**

Write to `specs/[feature-name]/review-summary.md` using this structure:

```markdown
# Review Summary: [Feature Name]

**Spec:** specs/[feature-name]/spec.md | **Plan:** specs/[feature-name]/plan.md
**Generated:** YYYY-MM-DD

> Distilled decision points for reviewers. See full spec/plan for details.

---

## Feature Overview
[3-5 sentences on purpose and scope]

## Scope Boundaries
- **In scope:** [What this includes]
- **Out of scope:** [What this explicitly excludes]
- **Why these boundaries:** [Brief justification]

## Critical Decisions

### [Decision Title]
- **Choice:** [What was decided]
- **Alternatives:** [What else was considered]
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

## Schema Definitions

### [Schema Name]
[Condensed structure - key fields only]

## Architecture Choices

- **Pattern:** [Brief description]
- **Components:** [Key components]
- **Integration:** [What it touches]

## Open Questions

- [ ] [Question needing stakeholder input]

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| ... | High/Med/Low | ... |

---
*Share this with reviewers. Full context in linked spec and plan.*
```

**Also create review_brief.md:**

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
- Maximum 2 pages (~800-1000 words) each
- Prioritize: Disagreement Areas > Decisions > Scope > Overview
- Be explicit about potential pushback points
- Be ruthless: Summarize, don't transcribe

**Verify:**

```bash
SPEC_DIR="specs/[feature-name]"
if [ -f "$SPEC_DIR/review-summary.md" ]; then
  echo "review-summary.md created"
  wc -w "$SPEC_DIR/review-summary.md"
fi
if [ -f "$SPEC_DIR/review_brief.md" ]; then
  echo "review_brief.md created"
  wc -w "$SPEC_DIR/review_brief.md"
fi
```

### 9. Summary and Next Steps

**Present summary to user:**

```markdown
## Plan Generation Complete

**Artifacts created:**
- specs/[feature-name]/spec.md (requirements)
- specs/[feature-name]/plan.md (implementation approach)
- specs/[feature-name]/tasks.md (work breakdown)
- specs/[feature-name]/review-summary.md (for reviewers)
- specs/[feature-name]/review_brief.md (reviewer guide)

### Plan Overview
[Brief summary of plan approach]

### Task Summary
- Total tasks: [N]
- Setup phase: [N] tasks
- Test phase: [N] tasks
- Core phase: [N] tasks
- Integration phase: [N] tasks
- Polish phase: [N] tasks

### Review Summary Highlights
- [N] critical decisions documented
- [N] areas of potential disagreement identified
- [N] naming decisions captured
- [N] open questions for stakeholders

### Consistency Check
[PASS/FAIL with details]

### Next Steps
**For team review:** Share `review_brief.md` or `review-summary.md` with stakeholders before implementation.

**Ready to implement:** Use `/sdd:implement` to start.
```

### Creating Spec PR

When creating a PR for spec review, include the review summary in the PR description:

**PR Title:** `RFC: [Feature Name] Specification`

**PR Body Template:**

```markdown
## Specification for Review

This PR contains the specification package for [Feature Name].

### Quick Summary

[Extract 3-5 key points from review-summary.md:]
- **Purpose:** [One sentence from Feature Overview]
- **Key Decision:** [Most significant decision from Critical Decisions]
- **Open Question:** [Most important question from Open Questions]

### Review Focus

Please focus your review on [`review-summary.md`](specs/[feature-name]/review-summary.md).

This document distills the key decisions and areas needing feedback.
Full context is available in the linked spec and plan.

### Artifacts

- [spec.md](specs/[feature-name]/spec.md) - Requirements (WHAT/WHY)
- [plan.md](specs/[feature-name]/plan.md) - Implementation approach (HOW)
- [tasks.md](specs/[feature-name]/tasks.md) - Work breakdown
- [review_brief.md](specs/[feature-name]/review_brief.md) - **Start here for review**
- [review-summary.md](specs/[feature-name]/review-summary.md) - Detailed review summary
```

**Create PR using:**

```bash
gh pr create --title "RFC: [Feature Name] Specification" --body "..."
```

## Checklist

Use TodoWrite to track:

- [ ] Discover and select spec
- [ ] Run spec review (sdd:review-spec)
- [ ] Invoke /speckit.plan
- [ ] Verify plan.md created
- [ ] Check error/edge case coverage against spec
- [ ] Check success criteria are referenced
- [ ] Invoke /speckit.tasks
- [ ] Verify tasks.md created
- [ ] Verify task quality (Actionable, Testable, Atomic, Ordered)
- [ ] Run consistency check (/speckit.analyze)
- [ ] Produce coverage matrix (requirement to task to test)
- [ ] Run red flag scan (vague language, TBD, missing paths)
- [ ] Validate NFR measurement methods
- [ ] Generate review summary (review-summary.md)
- [ ] Generate review brief (review_brief.md)
- [ ] Present summary and next steps

## Integration with Superpowers Skills

**This skill invokes:**
- `sdd:review-spec` - Validate spec before planning
- `/speckit.plan` - Generate implementation plan
- `/speckit.tasks` - Generate task breakdown
- `/speckit.analyze` - Verify consistency

**This skill is called by:**
- `sdd:spec` - After spec creation (optionally)
- Users directly when plan/tasks need regeneration

## Error Handling

**If /speckit.plan fails:**
```
Failed to generate plan.md.

Possible causes:
1. Spec is incomplete or malformed
2. /speckit.plan command not available (run: specify init)

Check the spec and try again.
```

**If /speckit.tasks fails:**
```
Failed to generate tasks.md.

Possible causes:
1. plan.md is required but missing
2. /speckit.tasks command not available (run: specify init)

Ensure plan.md exists and try again.
```

## Remember

**Plan and tasks are derived from spec:**
- If spec changes, regenerate plan and tasks
- Never manually edit plan.md or tasks.md
- Always use this skill or /speckit.* commands to regenerate

**Quality gates matter:**
- Spec review before planning catches issues early
- Consistency check ensures complete coverage
- Coverage matrix maps every requirement to tasks and tests
- Red flag scanning catches vague language before it becomes implementation confusion
- Task quality standards (Actionable, Testable, Atomic, Ordered) prevent ambiguous work items
- NFR validation ensures non-functional requirements have concrete measurement methods
- These steps are why /sdd:plan is better than calling /speckit.* directly
