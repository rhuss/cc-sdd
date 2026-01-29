# SDD Quick Reference

## Commands at a Glance

```
SPECIFICATION
  /sdd:brainstorm     Rough idea → formal spec (interactive dialogue)
  /sdd:spec           Clear requirements → spec (direct creation)
  /sdd:constitution   Define project-wide principles and standards

VALIDATION
  /sdd:review-spec    Check spec quality and completeness
  /sdd:review-code    Check code compliance against spec

IMPLEMENTATION
  /sdd:implement      Build code from spec using TDD

EVOLUTION
  /sdd:evolve         Reconcile spec/code drift

LEARNING
  /sdd:tutorial       Interactive SDD introduction
  /sdd:help           This quick reference
```

## Decision Guide

| You Have | You Want | Use |
|----------|----------|-----|
| Vague idea | Clear spec | `/sdd:brainstorm` |
| Clear requirements | Formal spec | `/sdd:spec` |
| Validated spec | Working code | `/sdd:implement` |
| Draft spec | Quality check | `/sdd:review-spec` |
| Code changes | Compliance check | `/sdd:review-code` |
| Spec/code mismatch | Realignment | `/sdd:evolve` |
| New project | Standards | `/sdd:constitution` |

## Core Workflow

```
1. SPEC      Idea → Spec (brainstorm or spec)
2. REVIEW    Validate spec (review-spec)
3. SPEC PR   Create PR for spec review (team alignment)
4. IMPLEMENT Build from spec (implement)
5. VERIFY    Check compliance (review-code)
6. CODE PR   Create PR for implementation
7. EVOLVE    Fix drift when needed (evolve)
```

## Team PR Workflow

For team projects, use two PRs per feature:

1. **Spec PR** - After spec creation, before implementation
   - Team reviews and aligns on WHAT before debating HOW
   - Catches requirement issues early

2. **Code PR** - After implementation passes verification
   - Implementation review with spec as reference
   - Reviewers can check code-to-spec compliance

**Requires:** GitHub MCP server (preferred) or `gh` CLI tool

## Key Principles

- **Spec-first**: Always spec before code
- **WHAT, not HOW**: Specs define requirements, not implementation
- **Evolution is healthy**: Specs change as you learn
- **Verify both ways**: Tests pass AND code matches spec
