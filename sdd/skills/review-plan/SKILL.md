---
name: review-plan
description: Post-planning quality validation - coverage matrix, red flag scanning, task quality enforcement, NFR validation, and review-summary.md generation
---

# Post-Planning Quality Validation

## Overview

This skill validates plan and task quality after `/speckit.plan` and `/speckit.tasks` have run. It checks coverage, scans for red flags, enforces task quality standards, and generates `review-summary.md`.

## Prerequisites

{Skill: spec-kit}

**Both plan.md and tasks.md MUST exist before running this skill.** If either is missing, stop with an error:

```bash
SPEC_DIR="specs/[feature-name]"
[ -f "$SPEC_DIR/plan.md" ] && echo "plan.md found" || echo "ERROR: plan.md missing - run /speckit.plan first"
[ -f "$SPEC_DIR/tasks.md" ] && echo "tasks.md found" || echo "ERROR: tasks.md missing - run /speckit.tasks first"
```

If either file is missing, stop and instruct the user to generate the missing artifact.

## 1. Task Quality Enforcement

After tasks.md exists, verify every task meets these criteria:

- **Actionable**: Clear what to do (not "figure out..." or "investigate...")
- **Testable**: Can verify completion objectively
- **Atomic**: One clear outcome per task
- **Ordered**: Dependencies between tasks are respected, phases are sequenced correctly

Also check:
- Every task specifies concrete file paths (not "somewhere" or "TBD")
- Phase ordering is logical (setup before core, tests before integration)
- No tasks duplicate work already covered by other tasks

If tasks fail these checks, note the issues and suggest refinements.

## 2. Coverage Matrix

Produce a coverage matrix mapping every spec requirement to its implementing tasks:

```
Requirement 1 → Tasks [X,Y]     ✓
Requirement 2 → Tasks [Z]       ✓
NFR 1         → Tasks [W]       ✓
...
```

Flag any requirement without task coverage. All requirements must have at least one implementing task.

Also verify:
- Every error case in the spec has a handling approach
- Every edge case from the spec is addressed
- Success criteria have verification approaches

## 3. Red Flag Scanning

Search plan.md and tasks.md for vague or incomplete language:

```bash
SPEC_DIR="specs/[feature-name]"
rg -i "figure out|tbd|todo|implement later|somehow|somewhere|not sure|maybe|probably" "$SPEC_DIR/plan.md" "$SPEC_DIR/tasks.md" || echo "No red flags found"
```

Review any matches:
- "Figure out..." = missing research, needs concrete approach
- "TBD" = incomplete planning, must be resolved
- "Implement later" = deferred work, scope explicitly
- Missing file paths = tasks are not actionable

## 4. NFR Validation

For each non-functional requirement in the spec, verify the plan includes:
- A concrete measurement method (not just "should be fast")
- A validation approach (how will you verify the NFR is met?)
- Acceptance thresholds where applicable

If any NFR lacks a measurement method, flag it.

## 5. Generate review-summary.md

After validation passes, generate `specs/[feature-name]/review-summary.md`:

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
| ... | ... | ... |

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

**Constraints:**
- Maximum ~800-1000 words
- Prioritize: Disagreement Areas > Decisions > Scope > Overview
- Be explicit about potential pushback points
- Summarize, don't transcribe

## 6. Present Results

Report to the user:
- Task quality check results (pass/issues)
- Coverage matrix summary
- Red flag scan results
- NFR validation results
- Path to generated review-summary.md

## Integration

**This skill is invoked by:**
- The superpowers trait overlay for `/speckit.plan` (after task generation)
- Users directly via `/sdd:review-plan`

**This skill invokes:**
- `{Skill: spec-kit}` for initialization
