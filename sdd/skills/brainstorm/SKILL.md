---
name: brainstorm
description: Use when starting from rough ideas - refines concepts into executable specifications through collaborative questioning, alternative exploration, and incremental validation, use this skill when called from a command
---

# Brainstorming Ideas Into Specifications

## Overview

Help turn rough ideas into formal, executable specifications through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, create the specification using spec-kit (if available) or directly as markdown.

**Key Difference from Standard Brainstorming:**
- **Output is a SPEC**, not a design document
- Spec is the **source of truth** for implementation
- Focus on **"what" and "why"**, defer "how" to implementation phase
- Validate spec soundness before finishing

## Prerequisites

Before starting the brainstorming workflow, ensure spec-kit is initialized:

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

## CRITICAL: Use /speckit.* Slash Commands

This skill should use `/speckit.*` slash commands when available. Claude MUST NOT:
- Generate specs internally (use `/speckit.specify` instead)
- Create spec markdown directly (spec-kit handles this)

If `/speckit.*` commands are not available, fall back to creating specs manually using the template at `.specify/templates/spec-template.md`.

## The Process

### Understanding the idea

**Check context first:**
- Review existing specs (if any) in `specs/` directory
- Check for constitution (`specs/constitution.md`)
- Review recent commits to understand project state
- Look for related features or patterns

**Ask questions to refine:**
- Ask questions one at a time
- Prefer multiple choice when possible
- Focus on: purpose, constraints, success criteria, edge cases
- Identify dependencies and integrations

**Remember:** You're building a SPEC, so focus on WHAT needs to happen, not HOW it will be implemented.

### Exploring approaches

**Propose 2-3 different approaches:**
- Present options conversationally with trade-offs
- Lead with your recommended option
- Explain reasoning clearly
- Consider: complexity, maintainability, user impact

**Questions to explore:**
- What are the core requirements vs. nice-to-have?
- What are the error cases and edge conditions?
- How does this integrate with existing features?
- What are the success criteria?

### Creating the specification

**Once you understand what you're building:**

1. **Announce spec creation:**
   "Based on our discussion, I'm creating the specification..."

2. **Create spec file using /speckit.specify (if available):**

   Invoke `/speckit.specify` to create the spec interactively.

   This creates the spec at `specs/[NNNN]-[feature-name]/spec.md` using the spec-kit template.

   **If `/speckit.specify` is not available:** Create the spec manually following `.specify/templates/spec-template.md`.

3. **Run clarification check (RECOMMENDED):**

   After creating the spec, invoke `/speckit.clarify` to identify any underspecified areas.

   Present clarification results to user for review. If gaps are identified, update the spec before proceeding.

4. **IMPORTANT: Capture implementation insights separately**

   If technical details emerged during brainstorming (technology choices, architecture decisions, trade-off discussions), **create implementation-notes.md** to capture them:

   - Location: `specs/features/[feature-name]/implementation-notes.md`
   - Purpose: Document the "why" behind design decisions
   - Content:
     - Alternative approaches considered
     - Trade-offs discussed
     - Technology choices and rationale
     - Technical constraints discovered
     - Questions answered during brainstorming

   **Why separate from spec:**
   - Spec = WHAT and WHY (requirements, contracts)
   - Implementation notes = Technical context for HOW
   - Keeps spec stable while preserving valuable context
   - Helps future implementers understand decisions

   **Example content:**
   ```markdown
   # Implementation Notes: User Authentication

   ## Design Decisions

   ### Decision: OAuth vs. Magic Links
   - Chose OAuth (Google + GitHub)
   - Rationale: User preference for familiar login flow
   - Rejected magic links: Email deliverability concerns

   ### Decision: JWT in httpOnly cookies
   - Prevents XSS attacks
   - Refresh token rotation for security
   - Trade-off: Slightly more complex than localStorage
   ```

5. **Spec structure** (spec-kit template provides this, but reference for review):

```markdown
# Feature: [Feature Name]

## Purpose
[Why this feature exists - the problem it solves]

## Requirements

### Functional Requirements
- [What the feature must do]
- [Behavior in specific scenarios]
- [Integration points]

### Non-Functional Requirements
- [Performance constraints]
- [Security requirements]
- [Accessibility needs]

## Success Criteria
- [How we know it works]
- [Measurable outcomes]

## Error Handling
- [What can go wrong]
- [How errors should be handled]

## Edge Cases
- [Boundary conditions]
- [Unusual scenarios]

## Dependencies
- [Other features/systems required]
- [External services]

## Out of Scope
- [What this feature explicitly does NOT do]
- [Future considerations]

## Open Questions
- [Anything still unclear]
- [Decisions deferred to implementation]
```

6. **Validate against constitution** (if exists):
   - Read `specs/constitution.md`
   - Check spec aligns with project principles
   - Note any violations and address them

7. **Present spec in sections:**
   - Show 200-300 words at a time
   - Ask: "Does this look right so far?"
   - Be ready to revise based on feedback

### After spec creation

**Validate the spec:**
- Use `sdd:review-spec` to check soundness
- Ensure spec is implementable
- Confirm no ambiguities remain

**Run consistency check (RECOMMENDED):**
If `/speckit.analyze` is available, invoke it to check for cross-artifact consistency.

**Generate review_brief.md:**

After spec is validated, generate a brief for reviewers. Read the spec and synthesize:

1. **Feature Overview** (3-5 sentences from Purpose section)
2. **Scope Boundaries** (in scope, out of scope, justification)
3. **Critical Decisions** (choices with trade-offs)
4. **Areas of Potential Disagreement**:
   - Trade-offs where reasonable people might disagree
   - Assumptions that could be challenged
   - Scope decisions that might be questioned
   - For each: decision, why controversial, alternative view, feedback requested
5. **Naming Decisions** (named elements from spec)
6. **Open Questions** (areas needing stakeholder input)
7. **Risk Areas** (high-impact concerns)

Write to `specs/[feature-name]/review_brief.md` using the template:

```markdown
# Review Brief: [Feature Name]

**Spec:** specs/[feature-name]/spec.md
**Generated:** YYYY-MM-DD

> Reviewer's guide to scope and key decisions. See full spec for details.

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
| ... | ... | ... |

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
- Maximum 2 pages (~800-1000 words)
- Prioritize: Disagreement Areas > Decisions > Scope > Overview
- Be explicit about potential pushback points

**Offer next steps:**
- "Spec created and validated. Ready to implement?"
- If yes → Use `sdd:implement`
- If no → Offer to refine spec or pause

**Commit the spec:**
```bash
git add specs/[NNNN]-[feature-name]/
git commit -m "Add spec for [feature name]

Includes:
- spec.md (requirements)
- review_brief.md (reviewer guide)

Assisted-By: 🤖 Claude Code"
```

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended
- **YAGNI ruthlessly** - Remove unnecessary features from all specs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present spec in sections, validate each
- **Be flexible** - Go back and clarify when something doesn't make sense
- **Separate WHAT from HOW** - Spec focuses on requirements and contracts; implementation notes capture technical decisions
- **Capture context** - If technical details emerge, put them in implementation-notes.md, not the spec
- **Spec, not design** - Focus on WHAT, defer HOW to implementation

## Recommend Constitution (First Time Users)

If no constitution exists and this seems to be early in project:

**After first spec created:**
- "I notice you don't have a constitution yet."
- "A constitution defines project-wide principles like:"
  - Coding standards
  - Architectural patterns
  - Quality gates
  - Error handling approaches
- "Would you like to create one? It ensures consistency across features."
- If yes → Use `sdd:constitution`

**Don't be pushy:** Constitution is optional but recommended.

## Checklist

Use TodoWrite to track:

- [ ] Understand current project context
- [ ] Ask questions to refine idea
- [ ] Explore 2-3 approaches with trade-offs
- [ ] Create specification file
- [ ] Validate against constitution (if exists)
- [ ] Review spec for soundness
- [ ] Commit spec to git
- [ ] Offer next steps (implement or refine)

## Example Flow

```
User: I want to add a comment system to the blog

You: I'm using sdd:brainstorm to refine this idea into a spec.

Let me understand the context first...
[Reviews existing code and specs]

For the comment system, what level of features do you want?

A) Basic - Name, email, comment text only
B) Standard - Above + threading/replies
C) Advanced - Above + reactions, editing, moderation
D) Full - Above + notifications, mentions, markdown

User: B - Standard with threading

You: Great. For threading, should replies be:

A) Unlimited depth (comments on comments on comments...)
B) One level only (reply to top-level comments)
C) Two levels (reply and one nested level)

[... conversation continues ...]

You: Based on our discussion, I'm creating the specification at:
specs/features/blog-comments.md

[Creates spec with all discussed requirements]

Here's the Purpose and Requirements section:

## Purpose
Enable readers to discuss blog posts through threaded comments,
fostering community engagement and feedback.

## Requirements

### Functional Requirements
- Readers can submit comments on published blog posts
- Comments require: name, email, comment text
- Comments support one level of replies (threading)
- Comments display in chronological order, newest first
- Replies display under parent comment
...

Does this look right so far?

User: Yes

[... continues through all sections ...]

You: Spec created! Let me validate it for soundness...

[Runs sdd:review-spec]

Spec is sound and implementable ✓

Committed to git ✓

Ready to implement the comment system?
```

## Common Pitfalls

**Don't:**
- Create design documents instead of specs
- Include implementation details ("use Redis for caching")
- Make decisions that belong in implementation phase
- Skip exploring alternatives
- Rush to spec creation before understanding the problem

**Do:**
- Focus on requirements and behavior
- Specify WHAT, not HOW
- Explore multiple approaches
- Validate incrementally
- Check against constitution
- Ensure spec is implementable

## Remember

The spec you create here becomes the source of truth. Implementation will flow from it. Code reviews will validate against it. Make it clear, complete, and correct.

**Good specs enable good implementation. Take the time to get it right.**
