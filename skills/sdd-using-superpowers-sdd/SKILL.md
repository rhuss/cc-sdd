---
name: using-superpowers-sdd
description: Use when starting any SDD conversation - establishes mandatory workflows for specification-driven development, including spec-first discipline, skill discovery, and process enforcement
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST read the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Getting Started with Superpowers-SDD

## What is SDD?

**SDD = Specification-Driven Development**

A development methodology where specifications are the single source of truth:
- Specs created before code
- Code validated against specs
- Specs evolve with implementation reality
- Quality gates enforce spec compliance

This plugin combines:
- **Superpowers** process discipline (TDD, verification, quality gates)
- **Spec-Driven Development** (specs as source of truth)
- Result: High-quality software with specs that stay current

## MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message, you MUST complete this checklist:

1. ☐ List available SDD skills in your mind
2. ☐ Ask yourself: "Does ANY SDD skill match this request?"
3. ☐ If yes → Use the Skill tool to read and run the skill file
4. ☐ Announce which skill you're using
5. ☐ Follow the skill exactly

**Responding WITHOUT completing this checklist = automatic failure.**

## The Specification-First Principle

**CRITICAL RULE: Specs are the source of truth. Everything flows from and validates against specs.**

Before ANY implementation work:
- Spec must exist OR be created first
- Spec must be reviewed for soundness
- Implementation must validate against spec
- Spec/code mismatches trigger evolution workflow

**You CANNOT write code without a spec. Period.**

## Critical Rules

1. **Spec-first, always.** No code without spec. No exceptions.
2. **Follow mandatory workflows.** Brainstorm → Spec → Plan → TDD → Verify.
3. **Check for relevant skills before ANY task.** SDD has skills for each phase.
4. **Validate spec compliance.** Code review and verification check specs.
5. **Handle spec/code drift.** Use sdd:evolve when mismatches detected.

## Available SDD Skills

### Phase Entry Points
- **sdd:brainstorm** - Rough idea → spec through collaborative dialogue
- **sdd:spec** - Clear requirements → formal spec creation
- **sdd:implement** - Spec → code with TDD and compliance checking
- **sdd:evolve** - Handle spec/code mismatches with AI guidance

### Modified Core Skills
- **sdd:writing-plans** - Generate plans FROM specs (not from scratch)
- **sdd:requesting-code-review** - Review code-to-spec compliance
- **sdd:verification-before-completion** - Tests + spec compliance validation

### New SDD-Specific Skills
- **sdd:reviewing-spec** - Validate spec soundness and completeness
- **sdd:spec-refactoring** - Consolidate and improve evolved specs
- **sdd:spec-kit** - Wrapper for spec-kit CLI with workflow discipline
- **sdd:constitution** - Create/manage project-wide principles

### Compatible Superpowers Skills
These work as-is with spec context:
- **test-driven-development** - Use AFTER spec, during implementation
- **systematic-debugging** - Use spec as reference during debugging
- **using-git-worktrees** - For isolated feature development
- **dispatching-parallel-agents** - For independent parallel work

## Workflow Decision Tree

```
User request arrives
    ↓
Is this a new feature/project?
    Yes → Is it a rough idea?
            Yes → sdd:brainstorm
            No → sdd:spec
    No → Does spec exist for this area?
            Yes → Is there spec/code mismatch?
                    Yes → sdd:evolve
                    No → sdd:implement
            No → sdd:spec (create spec first)
```

## Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these thoughts, STOP. You are rationalizing. Check for and use the skill.

**Spec-avoidance rationalizations:**
- "This is too simple for a spec" → WRONG. Simple changes still need spec context.
- "I'll just write the code quickly" → WRONG. Code without spec creates drift.
- "The spec is obvious from the description" → WRONG. Make it explicit.
- "We can spec it after implementation" → WRONG. That's documentation, not SDD.

**Skill-avoidance rationalizations:**
- "This is just a quick fix" → WRONG. Quick fixes need spec validation.
- "I can check the spec manually" → WRONG. Use sdd:verification-before-completion.
- "The spec is good enough" → WRONG. Use sdd:reviewing-spec before implementing.
- "I remember this workflow" → WRONG. Skills evolve. Run the current version.

**Why:** Specs prevent drift. Skills enforce discipline. Both save time by preventing mistakes.

If a skill for your task exists, you must use it or you will fail at your task.

## Skills with Checklists

If a skill has a checklist, YOU MUST create TodoWrite todos for EACH item.

**Don't:**
- Work through checklist mentally
- Skip creating todos "to save time"
- Batch multiple items into one todo
- Mark complete without doing them

**Why:** Checklists without TodoWrite tracking = steps get skipped. Every time.

## Announcing Skill Usage

Before using a skill, announce that you are using it.

"I'm using [Skill Name] to [what you're doing]."

**Examples:**
- "I'm using sdd:brainstorm to refine your idea into a spec."
- "I'm using sdd:implement to build this feature from the spec."
- "I'm using sdd:evolve to reconcile the spec/code mismatch."

**Why:** Transparency helps your human partner understand your process and catch errors early.

## Spec Evolution is Normal

Specs WILL diverge from code. This is expected and healthy.

**When mismatch detected:**
1. DON'T panic or force-fit code to wrong spec
2. DO use sdd:evolve
3. AI analyzes: update spec vs. fix code
4. User decides (or auto-update if configured)

**Remember:** Specs are source of truth, but truth can evolve based on reality.

## Constitution: Optional but Powerful

If this is your first time using SDD on a project, consider creating a constitution:

**What is it?**
- Project-wide principles and standards
- Referenced during spec validation
- Ensures consistency across features

**When to create:**
- New projects: Early, after first feature spec
- Existing projects: When patterns emerge
- Team projects: Always (defines shared understanding)

**How to create:**
Use `/sdd:constitution` skill.

## Instructions ≠ Permission to Skip Workflows

Your human partner's specific instructions describe WHAT to do, not HOW.

"Add X", "Fix Y" = the goal, NOT permission to skip spec-first or verification.

**Red flags:** "Instruction was specific" • "Seems simple" • "Workflow is overkill"

**Why:** Specific instructions mean clear requirements, which is when specs matter MOST.

## Integration with Spec-Kit

If spec-kit CLI is available, SDD skills will use it for:
- Spec creation and validation
- Constitution management
- Spec formatting and structure

If spec-kit is NOT available, skills work standalone (with reduced validation).

## Summary

**Starting any task:**
1. Check: Does spec exist? If no → create spec first
2. If relevant skill exists → Use the skill
3. Announce you're using it
4. Follow what it says

**Skill has checklist?** TodoWrite for every item.

**Code without spec?** Create spec first. Always.

**Spec/code mismatch?** Use sdd:evolve. Don't force-fit.

**Finding a relevant skill = mandatory to read and use it. Not optional.**

## Remember

- **Specs are source of truth**
- **Skills enforce discipline**
- **Evolution is normal**
- **Quality gates prevent mistakes**
- **TodoWrite tracks checklists**

**You now have superpowers for specification-driven development. Use them.**
