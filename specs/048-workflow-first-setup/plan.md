# Implementation Plan: Workflow-First Spex Setup

**Branch**: `048-workflow-first-setup` | **Date**: 2026-07-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/048-workflow-first-setup/spec.md`

## Summary

Make the existing Spec-Kit setup workflow the authoritative installation path by adding a small, project-owned `.specify/spex.json` declaration. A Python standard-library profile utility validates, resolves, and atomically persists requested intent; workflow prompts collect first-run choices and feed the same resolver used by non-interactive refresh. Repository ignore rules and a focused CI check keep generated `.agents/`, `.codex/`, and `.claude/` trees disposable while explicitly allowing the team-owned declaration. Claude's existing source install remains unchanged and requires no staged distribution.

## Technical Context

**Language/Version**: Python 3.9+ standard library, POSIX shell, Spec-Kit workflow YAML  
**Primary Dependencies**: `specify` CLI, `git`, `jq`; no new parser dependency  
**Storage**: Project-owned JSON declaration plus existing generated project files  
**Testing**: Python unit tests and shell integration tests in temporary Git repositories  
**Target Platform**: macOS and Linux environments supported by Spec-Kit  
**Project Type**: CLI workflow and extension bundle  
**Performance Goals**: Configuration validation and persistence complete in under one second; repeat setup introduces no extra prompts  
**Constraints**: Preserve current Claude installation; do not port Codex adapter, plugin packaging, state/recovery, progress, Teams, or OpenCode production support  
**Scale/Scope**: One declaration schema, one profile utility, one setup workflow integration, one generated-tree guard

## Constitution Check

*GATE: Passed before research and re-checked after design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Guided Development | PASS | New scoped feature package replaces the monolithic delivery plan. |
| II. Extension Architecture | PASS | Setup continues installing native Spec-Kit extensions. |
| III. Extension Composability | PASS | Selection and dependency closure remain centralized in setup. |
| IV. Quality Gates | PASS | Unit and end-to-end setup tests are required before completion. |
| V. Naming Discipline | PASS | Existing `specify` and `speckit-*` conventions are retained. |
| VI. Skill Autonomy | PASS | Configuration logic lives in a script rather than an oversized init skill. |
| VII. State as Scripts | PASS | Validation and persistence are implemented by a dedicated utility. |
| No compiled artifacts | PASS | Python standard library and existing shell dependencies only. |
| Source-transparent Claude development | PASS | The existing source plugin path remains the development path. |

Post-design re-check: PASS. The design introduces one data declaration and one focused utility; it does not introduce a generic adapter, materializer, or new package dependency.

## Project Structure

### Documentation (this feature)

```text
specs/048-workflow-first-setup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── spex-project-config.schema.json
└── tasks.md
```

### Source Code (repository root)

```text
spex/
├── setup.yml                         # Resolve prompts/config and persist accepted intent
└── scripts/
    └── spex-setup-profile.py         # Validate, resolve, and atomically persist configuration

tests/
├── test_setup_profile.py             # Profile contract and failure-atomicity tests
├── test_workflow_setup.sh            # Disposable-repository setup journey
└── test_generated_trees.sh           # Ignore and tracked-output guard

.github/workflows/test.yml            # Run generated-tree guard
.gitignore                            # Ignore generated harness trees; allow spex.json
Makefile                              # Focused test targets
README.md                             # Workflow-first setup and configuration reference
```

**Structure Decision**: Extend the existing workflow and script layout. Configuration behavior is not placed in a skill, plugin manifest, generic adapter descriptor, or new build system.

## Implementation Approach

1. Add contract-first tests for configuration validation, precedence, dependency closure, migration, and atomic persistence.
2. Implement a focused profile utility with `resolve` and `persist` operations. `resolve` is read-only and emits normalized JSON; `persist` validates again and atomically replaces the declaration.
3. Change workflow input defaults to empty sentinels so stored intent can win when no override is supplied. Preserve the existing interactive extension prompt and add equivalent security selection, then persist once after all selections normalize.
4. Update setup ignore generation to ignore `.agents/`, `.codex/`, and `.claude/` while explicitly allowing `.specify/spex.json`.
5. Add a tracked-generated-tree guard with a narrow maintained-source allowlist and run it in CI.
6. Document the primary workflow command, declaration format, precedence, defaults, and source-transparent Claude development path.

## Complexity Tracking

No constitution violations require justification.
