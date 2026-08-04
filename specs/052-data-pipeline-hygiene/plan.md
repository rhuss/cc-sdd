# Implementation Plan: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Branch**: `052-data-pipeline-hygiene` | **Date**: 2026-08-04 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/052-data-pipeline-hygiene/spec.md`

## Summary

Add a `/speckit-spex-gates-data-checklist` command to the `spex-gates` extension that generates data-pipeline-specific checklist items from a preset file, and enhance the `review-code` gate with a spec-declared constants drift check. The checklist uses a two-level preset system (built-in default, project override). The drift check parses `## Constants` sections in specs and verifies code consolidation and value matching.

## Technical Context

**Language/Version**: Bash (POSIX-compatible), Markdown

**Primary Dependencies**: `jq`, `yq`, `specify` CLI (spec-kit), `grep`/`awk` for constants parsing

**Storage**: Filesystem (markdown files)

**Testing**: Manual validation via sample specs with known constants; checklist output inspection

**Target Platform**: Any platform running Claude Code with spec-kit

**Project Type**: CLI plugin (spex extension commands)

**Performance Goals**: N/A (interactive command, runs once per spec)

**Constraints**: No modification to upstream speckit-checklist skill; POSIX-compatible shell

**Scale/Scope**: Single extension enhancement (2 new files, 2 modified files)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Guided Development | PASS | Following full SDD workflow |
| II. Extension Architecture | PASS | Command lives in spex-gates, follows `speckit.{ext-id}.{command}` naming |
| III. Extension Composability | PASS | Additive enhancement, no cross-extension modifications |
| IV. Quality Gates | PASS | Drift check adds to existing review-code gate, does not replace |

## Project Structure

### Documentation (this feature)

```text
specs/052-data-pipeline-hygiene/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root)

```text
spex/extensions/spex-gates/
├── commands/
│   ├── speckit.spex-gates.data-checklist.md    # NEW: checklist command
│   └── speckit.spex-gates.review-code.md       # MODIFIED: add constants drift section
├── presets/
│   └── data-pipeline.md                         # NEW: built-in preset
└── extension.yml                                # MODIFIED: register new command
```
