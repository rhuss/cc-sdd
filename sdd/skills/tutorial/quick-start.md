# Quick Start Guide

## What is SDD?

**Specification-Driven Development** = Specs are your single source of truth.

Traditional development: Code first, document later (if ever). Docs drift. Intent gets lost.

SDD: Spec first, code validates against spec. Specs evolve with reality. Intent is preserved.

**The core loop:**
```
Idea → Spec → Code → Verify → (Drift? → Evolve)
```

## The Three Phases

### 1. Specification Phase

**Turn ideas into specs before writing code.**

| Starting Point | Command | What Happens |
|----------------|---------|--------------|
| Rough idea | `/sdd:brainstorm` | Collaborative dialogue refines idea into formal spec |
| Clear requirements | `/sdd:spec` | Create spec directly using spec-kit |

**Output:** A specification file in `specs/features/[name]/spec.md`

### 2. Implementation Phase

**Build from specs with TDD and compliance checking.**

| Command | What Happens |
|---------|--------------|
| `/sdd:implement` | Generates plan from spec, uses TDD, validates compliance |

**Output:** Working code that matches the spec

### 3. Evolution Phase

**When code and spec diverge (it happens), reconcile them.**

| Situation | Command | What Happens |
|-----------|---------|--------------|
| Spec/code mismatch | `/sdd:evolve` | AI analyzes, recommends update spec vs fix code |

**Output:** Restored alignment between spec and code

## Command Decision Table

Use this to pick the right command:

| You Have | You Want | Use |
|----------|----------|-----|
| Vague idea | Clear spec | `/sdd:brainstorm` |
| Clear requirements | Formal spec | `/sdd:spec` |
| Validated spec | Working code | `/sdd:implement` |
| Spec + code mismatch | Alignment | `/sdd:evolve` |
| Draft spec | Validation | `/sdd:review-spec` |
| Code changes | Compliance check | `/sdd:review-code` |
| New project | Standards | `/sdd:constitution` |

## Quick Reference Card

```
SPEC CREATION
  /sdd:brainstorm    Rough idea → spec (interactive)
  /sdd:spec          Clear reqs → spec (direct)
  /sdd:constitution  Project-wide principles

VALIDATION
  /sdd:review-spec   Check spec quality
  /sdd:review-code   Check code-to-spec compliance

IMPLEMENTATION
  /sdd:implement     Spec → code with TDD

EVOLUTION
  /sdd:evolve        Fix spec/code drift
```

## Key Principles

1. **Spec-first, always** - No code without spec. Period.
2. **WHAT, not HOW** - Specs define requirements, not implementation details
3. **Evolution is normal** - Specs change as you learn. That's healthy.
4. **Quality gates** - Verification checks both tests AND spec compliance

## Common Mistakes to Avoid

**Don't:**
- Skip specs for "simple" features (they still need spec context)
- Put implementation details in specs (that's for code)
- Ignore drift warnings (use `/sdd:evolve`)
- Write code then spec afterward (that's documentation, not SDD)

**Do:**
- Start every feature with a spec
- Keep specs focused on WHAT and WHY
- Use `/sdd:evolve` when reality differs from plan
- Review specs before implementing

## Try It Now

Best way to learn: try it on a real feature.

1. Think of a feature you want to build
2. Run `/sdd:brainstorm` to turn it into a spec
3. Run `/sdd:implement` to build it
4. See how the workflow feels

That's it. Specs first, code validates, evolve when needed.
