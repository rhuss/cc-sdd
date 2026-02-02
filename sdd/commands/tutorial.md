---
name: sdd:tutorial
description: Interactive guide to SDD methodology and team collaboration workflows
---

# SDD Tutorial

## Overview

Interactive guide to Specification-Driven Development. Offers 3 learning paths.

## Context Detection

Before presenting paths, check the project state to customize messaging:

1. Look for `specs/` directory - indicates SDD may already be in use
2. Check for `specs/constitution.md` - indicates project principles exist
3. Check for `.specify/` directory - indicates spec-kit is initialized

Adapt messaging based on findings:
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

Based on user's selection:

1. Read the corresponding content file from `sdd/docs/`:
   - Path A: `tutorial-quickstart.md`
   - Path B: `tutorial-full.md`
   - Path C: `tutorial-team.md`

2. Present the content section by section:
   - Show one major section at a time
   - Pause after each section: "Ready to continue, or any questions?"
   - Be prepared to answer questions before moving on

3. Keep it conversational:
   - Don't dump the entire file at once
   - Engage with the user throughout
   - Offer to skip sections if already familiar

## Next Steps

After completing the tutorial, suggest next actions based on project state:

**No specs exist yet:**
- "Ready to try it? Start with `/sdd:brainstorm` to turn an idea into a spec"
- "Or create a constitution first with `/sdd:constitution` to set standards"

**Specs already exist:**
- "You have existing specs. Try `/sdd:implement` to build from one"
- "Or use `/sdd:review-spec` to validate your specs"

**Team project:**
- "For team projects, remember to create spec PRs for major features"
- "This lets the team align on WHAT before debating HOW"
