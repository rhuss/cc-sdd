# Implementation Plan: Guided Demo (Smoke Test v4)

**Branch**: `049-guided-demo` | **Date**: 2026-08-01 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/049-guided-demo/spec.md`

## Summary

Redesign the smoke test skill (`speckit.spex.smoke-test`) from a literal scenario replay into a guided demo that synthesizes user-observable flows from the spec's functional requirements, triages infrastructure availability, and presents evidence a human can actually evaluate. The command name stays the same; user-facing output says "Guided Demo."

## Technical Context

**Language/Version**: Bash (POSIX-compatible), Markdown (skill definition)

**Primary Dependencies**: `jq`, `yq`, spec-kit CLI (`specify`), Playwright MCP (optional)

**Storage**: N/A (markdown files only)

**Testing**: Manual validation via the skill itself (self-referential: the guided demo tests features including itself)

**Target Platform**: Claude Code CLI (macOS/Linux)

**Project Type**: Skill/command definition (Markdown-based instruction files)

**Performance Goals**: Demo plan synthesis < 30 seconds, triage < 10 seconds

**Constraints**: Single-session execution (no subagents for the demo itself), always-interactive

**Scale/Scope**: Single skill file (~400 lines), spec template update (~10 lines), documentation updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Spec-Guided Development**: PASS. This feature follows SDD (brainstorm #43, spec #049).
- **II. Extension Architecture**: PASS. The skill is a command in the core `spex` extension, following the existing `speckit.spex.*` naming pattern.

No violations. No complexity tracking needed.

## Project Structure

### Documentation (this feature)

```text
specs/049-guided-demo/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
spex/
└── extensions/
    └── spex/
        ├── commands/
        │   └── speckit.spex.smoke-test.md    # PRIMARY: rewrite this file
        └── docs/
            └── help.md                        # Update references

.specify/
└── templates/
    └── spec-template.md                       # Add ## Smoke Test section with guidance
```

**Files to modify:**

| File | Change |
|------|--------|
| `spex/extensions/spex/commands/speckit.spex.smoke-test.md` | Complete rewrite (core deliverable) |
| `.specify/templates/spec-template.md` | Add optional `## Smoke Test` section with observable-behavior guidance |
| `spex/extensions/spex/docs/help.md` | Update smoke test description to "Guided Demo" |
| `README.md` | Update smoke test references in workflow/commands |

**Files that reference smoke test but need NO changes** (they call the command by name, which stays the same):

| File | Why no change needed |
|------|---------------------|
| `spex/extensions/spex/commands/speckit.spex.finish.md` | Calls `/speckit-spex-smoke-test` by name, still works |
| `spex/extensions/spex/commands/speckit.spex.ship.md` | References smoke test stage, still works |
| `spex/extensions/spex/extension.yml` | Registers `speckit.spex.smoke-test` command, still works |
| `spex/extensions/spex-gates/commands/speckit.spex-gates.verify.md` | References smoke test, still works |
| `spex/extensions/spex-deep-review/commands/speckit.spex-deep-review.run.md` | References smoke test in next-steps, still works |

## Approach

### Core Skill Rewrite

The entire `speckit.spex.smoke-test.md` command file is rewritten. The new structure has 6 phases:

1. **Spec Loading & FR Extraction**: Read the spec, extract FR-NNN entries and acceptance scenarios
2. **Demo Plan Synthesis**: Translate FRs into user-observable flows using the keyword heuristic (FR-020), group related FRs, exclude internal-only FRs
3. **Environment Triage**: Probe infrastructure, classify flows into tiers, present readiness table
4. **User Selection**: Present options (run ready, set up infra, include partial, skip)
5. **Flow Execution**: For each selected flow, perform setup, run demo, capture evidence, present with verdict recommendation
6. **Report Generation**: Write SMOKE-TEST.md with tiers, evidence, verdicts, and FR coverage mapping

### Key Design Decisions

- **Synthesis over replay**: The skill never literally replays `## Smoke Test` scenarios. It always synthesizes from FRs. The `## Smoke Test` section is used for priority ordering only.
- **Tier model**: Four tiers (full/partial/setup offered/manual) replace the binary "can test / can't test" model.
- **Evidence standard**: Every piece of evidence must be user-observable (command output, HTTP responses, file contents, screenshots, logs). Never internal state or test assertion results.
- **Observable default**: When a FR is ambiguous (neither clearly observable nor clearly internal), default to observable (FR-020 clarification).
