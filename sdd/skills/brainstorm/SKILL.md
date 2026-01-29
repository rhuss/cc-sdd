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

2. **Create spec file:**
   - Location: `specs/features/[feature-name]/spec.md`
   - Use spec-kit CLI if available: `speckit specify`
   - Otherwise: Create markdown directly

3. **IMPORTANT: Capture implementation insights separately**

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

4. **Spec structure** (use this template):

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

4. **Validate against constitution** (if exists):
   - Read `specs/constitution.md`
   - Check spec aligns with project principles
   - Note any violations and address them

5. **Present spec in sections:**
   - Show 200-300 words at a time
   - Ask: "Does this look right so far?"
   - Be ready to revise based on feedback

### After spec creation

**Validate the spec:**
- Use `sdd:review-spec` to check soundness
- Ensure spec is implementable
- Confirm no ambiguities remain

**Offer next steps:**
- "Spec created and validated. Ready to implement?"
- If yes → Use `sdd:implement`
- If no → Offer to refine spec or pause

**Commit the spec:**
```bash
git add specs/features/[feature-name].md
git commit -m "Add spec for [feature name]

[Brief description of what the feature does]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
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
