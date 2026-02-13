                          SDD Quick Reference

WORKFLOW

     ┌──────────┐      ┌──────────┐      ┌──────────┐
     │   IDEA   │─────▶│   SPEC   │─────▶│   PLAN   │
     └──────────┘      └──────────┘      └──────────┘
           │                │                   │
           │  /sdd:brainstorm  /speckit.specify    /speckit.plan
           │                │                   │
           │                ▼                   ▼
           │         ┌──────────┐      ┌──────────────┐
           │         │  REVIEW  │      │  REVIEW PLAN │
           │         └──────────┘      └──────────────┘
           │           /sdd:review-spec   /sdd:review-plan
           │                                   │
           │                                   ▼
           │                            ┌──────────┐
           │                            │IMPLEMENT │
           │                            └──────────┘
           │                                   │  /speckit.implement
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


PRIMARY WORKFLOW (spec-kit commands, enhanced by SDD traits)

  /speckit.specify     Create specification (sdd trait adds review gate)
  /speckit.plan        Generate plan + tasks (sdd trait adds spec review
                       before planning, plan review after)
  /speckit.implement   Execute implementation (sdd trait adds pre/post
                       quality gates, beads trait adds task scheduling)

  Enable traits with /sdd:traits to activate quality gates on these commands.


SDD HELPERS

  /sdd:brainstorm     Rough idea → formal spec (interactive dialogue)
  /sdd:review-spec    Check spec quality and completeness
  /sdd:review-plan    Validate plan coverage, task quality, red flags
  /sdd:review-code    Check code compliance against spec
  /sdd:evolve         Reconcile spec/code drift


CONFIGURATION

  /sdd:init           Initialize spec-kit and SDD plugin
  /sdd:traits         Enable/disable discipline overlays (sdd, beads)
  /sdd:constitution   Define project-wide principles and standards
  /sdd:help           This quick reference (use --tutorial for interactive guide)


DECISION GUIDE
┌─────────────────────────┬───────────────────────┬───────────────────────┐
│ You Have                │ You Want              │ Use                   │
├─────────────────────────┼───────────────────────┼───────────────────────┤
│ Vague idea              │ Clear spec            │ /sdd:brainstorm       │
│ Clear requirements      │ Formal spec           │ /speckit.specify      │
│ Validated spec          │ Plan + tasks          │ /speckit.plan         │
│ Complete spec package   │ Working code          │ /speckit.implement    │
│ Draft spec              │ Quality check         │ /sdd:review-spec      │
│ Plan + tasks            │ Validation            │ /sdd:review-plan      │
│ Code changes            │ Compliance check      │ /sdd:review-code      │
│ Spec/code mismatch      │ Realignment           │ /sdd:evolve           │
│ New project             │ Standards             │ /sdd:constitution     │
│ Want quality gates      │ Trait config           │ /sdd:traits           │
└─────────────────────────┴───────────────────────┴───────────────────────┘


KEY PRINCIPLES

  Spec-first: Always spec before code
  WHAT, not HOW: Specs define requirements, not implementation
  Evolution is healthy: Specs change as you learn
  Verify both ways: Tests pass AND code matches spec
  Traits add discipline: Enable sdd/beads traits for quality gates


MIGRATING FROM OLD COMMANDS

  If you previously used /sdd:spec, /sdd:plan, or /sdd:implement,
  these commands have been consolidated:

  /sdd:spec      → /speckit.specify  (with sdd trait for review gate)
  /sdd:plan      → /speckit.plan     (with sdd trait for quality gates)
  /sdd:implement → /speckit.implement (with sdd trait for pre/post gates)

  Run /sdd:traits to enable the sdd trait for quality gates.


Want an interactive tutorial? Run: /sdd:help --tutorial
