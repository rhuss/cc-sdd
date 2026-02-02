---
name: sdd:help
description: Quick reference for all SDD commands
---

Display the following content exactly as written, then offer to answer questions:

---

```
                          SDD Quick Reference

WORKFLOW

     ┌──────────┐      ┌──────────┐      ┌──────────┐
     │   IDEA   │─────▶│   SPEC   │─────▶│  REVIEW  │
     └──────────┘      └──────────┘      └──────────┘
           │                                   │
           │  /sdd:brainstorm                  │  /sdd:review-spec
           │  /sdd:spec                        │
           │                                   ▼
           │                            ┌──────────┐
           │                            │IMPLEMENT │
           │                            └──────────┘
           │                                   │  /sdd:implement
           │                                   ▼
           │                            ┌──────────┐
           │                            │  VERIFY  │
           │                            └──────────┘
           │                                   │  /sdd:review-code
           │                                   ▼
           │                            ╔══════════╗
           │                            ║ COMPLETE ║
           │                            ╚══════════╝
           │                                   ▲
           │                            ┌──────┴─────┐
           │                            │   EVOLVE   │ /sdd:evolve
           │                            └────────────┘
           │                                   ▲
           └───────────────────────────────────┘
                       (when drift detected)


COMMANDS

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

DECISION GUIDE
┌─────────────────────────┬───────────────────────┬───────────────────────┐
│ You Have                │ You Want              │ Use                   │
├─────────────────────────┼───────────────────────┼───────────────────────┤
│ Vague idea              │ Clear spec            │ /sdd:brainstorm       │
│ Clear requirements      │ Formal spec           │ /sdd:spec             │
│ Validated spec          │ Working code          │ /sdd:implement        │
│ Draft spec              │ Quality check         │ /sdd:review-spec      │
│ Code changes            │ Compliance check      │ /sdd:review-code      │
│ Spec/code mismatch      │ Realignment           │ /sdd:evolve           │
│ New project             │ Standards             │ /sdd:constitution     │
└─────────────────────────┴───────────────────────┴───────────────────────┘

```
KEY PRINCIPLES

  • Spec-first: Always spec before code
  • WHAT, not HOW: Specs define requirements, not implementation
  • Evolution is healthy: Specs change as you learn
  • Verify both ways: Tests pass AND code matches spec


TEAM WORKFLOW

  For team projects, use two PRs per feature:

  1. Spec PR - Get alignment on WHAT before coding
  2. Code PR - Review implementation against approved spec

  Requires: GitHub MCP server (preferred) or gh CLI tool
```

---

After displaying, ask: "Any questions about the SDD workflow? I can explain any command in detail."
