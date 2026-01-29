---
name: tutorial
description: Interactive onboarding for SDD methodology - offers learning paths for quick start, full introduction, or team collaboration focus
---

# SDD Tutorial

## Overview

Interactive guide to Specification-Driven Development. Offers 3 learning paths based on your goals.

This skill provides structured onboarding for new users, explaining:
- What SDD is and why it matters
- The workflow phases and when to use each command
- Team collaboration patterns (when to share specs via PR)
- Decision guidance (which command for which situation)

## Context Detection

Before presenting paths, check the project state to customize messaging:

1. **Look for `specs/` directory** - indicates SDD may already be in use
2. **Check for `specs/constitution.md`** - indicates project principles exist
3. **Check for `.specify/` directory** - indicates spec-kit is initialized

Adapt the tutorial messaging based on findings:
- New project: Focus on getting started
- Existing SDD project: Focus on advanced patterns
- Team project: Emphasize collaboration workflows

## Learning Path Selection

Present the user with 3 learning paths using AskUserQuestion:

**Path A: Quick Start (5 min)**
- Core concepts and cheat sheet
- Best for: Experienced developers who want to jump in

**Path B: Full Introduction (15 min)**
- All phases explained with examples
- Best for: New users wanting thorough understanding

**Path C: Team Collaboration (10 min)**
- PR workflows and spec reviews
- Best for: Teams adopting SDD together

## Deliver Content

Based on the user's selection:

1. **Read the corresponding content file:**
   - Path A: Read `sdd/skills/tutorial/quick-start.md`
   - Path B: Read `sdd/skills/tutorial/full-introduction.md`
   - Path C: Read `sdd/skills/tutorial/team-collaboration.md`

2. **Present the content section by section:**
   - Show one major section at a time
   - Pause after each section: "Ready to continue, or any questions?"
   - Be prepared to answer questions before moving on

3. **Keep it conversational:**
   - Don't just dump the entire file
   - Engage with the user throughout
   - Offer to skip sections if they're already familiar

## Next Steps

After completing the tutorial, suggest next actions based on project state:

**No specs exist yet:**
- "Ready to try it? Start with `/sdd:brainstorm` to turn an idea into a spec"
- "Or create a constitution first with `/sdd:constitution` to set project standards"

**Specs already exist:**
- "You have existing specs. Try `/sdd:implement` to build from one"
- "Or use `/sdd:review-spec` to validate your specs"

**Team project:**
- "For team projects, remember to create spec PRs for major features"
- "This lets the team align on WHAT before debating HOW"

## Presentation Guidelines

- Use the content files as your source, but present conversationally
- Don't overwhelm: one concept at a time
- Check understanding before moving to next section
- Be ready to give examples from the user's domain if they share context
- End with clear, actionable next step

## Example Flow

```
You: I'm using sdd:tutorial to introduce you to SDD.

Let me check your project first...
[Checks for specs/, constitution, .specify/]

This looks like a new project, so I'll tailor the tutorial for getting started.

Which learning path would you prefer?
[Presents AskUserQuestion with 3 paths]

User: Quick Start

You: [Reads quick-start.md]
[Presents Core Concepts section]

The core idea is simple: specs come first, code validates against specs.
[Explains briefly]

Ready to see the workflow overview, or any questions so far?

User: Continue

You: [Presents Workflow section]
...

You: That's the quick start! Ready to try it on your project?

The best way to learn is by doing. I suggest starting with:
/sdd:brainstorm - if you have a rough idea for a feature
/sdd:spec - if you have clear requirements already

Which would you like to try?
```
