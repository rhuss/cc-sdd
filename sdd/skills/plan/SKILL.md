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

### Explicit Installation Check (MANDATORY)

**Before proceeding, run these checks:**

```bash
# Check if specify CLI is installed
which specify
```

**If `specify` is NOT found:**
```
The 'specify' CLI is required but not installed.

Install with:
  uv pip install specify-cli

IMPORTANT: The CLI command is 'specify' (not 'speckit').
           The package is 'specify-cli' (not 'spec-kit').

After installation, run: specify init
```

**STOP and wait for user to install.**

**If `specify` IS found, check project initialization:**

```bash
# Check if project is initialized
[ -d .specify ] && echo "initialized" || echo "not-initialized"
```

**If NOT initialized:**
```bash
specify init
```

**If `.claude/commands/speckit.*` files were created, inform user:**
```
RESTART REQUIRED: New slash commands installed.
Please restart Claude Code to load /speckit.* commands.
```

**STOP and wait for restart.**

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

**Invoke `/speckit.plan` to generate the implementation plan:**

```
/speckit.plan
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

### 5. Generate Tasks

**Invoke `/speckit.tasks` to generate the task breakdown:**

```
/speckit.tasks
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

### 6. Verify Artifact Consistency

**Run consistency check using `/speckit.analyze`:**

```
/speckit.analyze
```

This verifies:
- Plan covers all spec requirements
- Tasks implement all plan items
- No orphaned tasks or missing coverage

**If consistency check fails:**
Report issues and suggest fixes.

### 7. Generate Review Summary and Brief

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

### 8. Summary and Next Steps

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
- [ ] Invoke /speckit.tasks
- [ ] Verify tasks.md created
- [ ] Run consistency check (/speckit.analyze)
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
- These steps are why /sdd:plan is better than calling /speckit.* directly
