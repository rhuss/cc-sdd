# Implementation Plan: Extract Review into Standalone cc-review Plugin

**Branch**: `051-extract-cc-review` | **Date**: 2026-08-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/051-extract-cc-review/spec.md`

## Summary

Extract the multi-agent code review (6 review agents + fix loop + external tool integration) and PR comment triage from cc-spex into a standalone `cc-review` plugin (`rhuss/cc-review`). The plugin provides a harness-agnostic core with thin adapters for Claude Code, spec-kit, and Codex/OpenCode. cc-spex retains a simplified deep-review fallback and gains a delegation mechanism to cc-review when present.

## Technical Context

**Language/Version**: Bash (POSIX-compatible), Markdown (skill/command files), Python 3 (JSON sanitization script)

**Primary Dependencies**: `jq`, `yq`, `gh` CLI, `git`; optional: `coderabbit`, `copilot`, `codex` CLIs

**Storage**: File-based state (JSON state files for triage, YAML for config)

**Testing**: `make release` (schema validation + integration test for cc-spex); manual smoke tests for cc-review adapters

**Target Platform**: Any platform with Bash, Git, and an AI coding agent (Claude Code, Codex, OpenCode)

**Project Type**: CLI plugin / AI agent extension (two repositories)

**Performance Goals**: N/A (interactive workflow, no latency targets)

**Constraints**: Adapters must be < 50 lines each (SC-007). No spec-kit dependency for standalone mode. Core review logic must be identical across all adapters.

**Scale/Scope**: ~2300 lines of existing command content to extract and refactor. 2 repositories affected.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Guided Development | PASS | This is a significant cross-cutting feature, following full SDD workflow |
| II. Extension Architecture | PASS | cc-review adapters follow extension conventions; cc-spex retains its extension structure |
| III. Extension Composability | PASS | cc-review is independent; cc-spex detects and delegates without coupling |
| IV. Quality Gates | PASS | Quality gates apply to this feature work; cc-review does not impose its own quality gates on users |
| V. Naming Discipline | PASS | cc-review uses `/review` and `/triage` commands; cc-spex retains `speckit.spex-*` prefixes |
| VI. Skill Autonomy | PASS | Each adapter is a thin wrapper with a single purpose; no logic duplication |
| VII. State as Scripts | PASS | Triage state management already uses external scripts; these move to cc-review |

No violations. All principles satisfied.

## Project Structure

### Documentation (this feature)

```text
specs/051-extract-cc-review/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (two repositories)

```text
# Repository 1: rhuss/cc-review (NEW)
cc-review/
├── README.md                  # Installation guides, usage, adapters
├── LICENSE                    # MIT
├── core/
│   ├── commands/
│   │   ├── review.md          # Main review command (agents + fix loop)
│   │   └── triage.md          # PR comment triage command
│   ├── agents/
│   │   ├── preamble.md        # Common agent preamble
│   │   ├── correctness.md     # Agent 1 prompt
│   │   ├── architecture.md    # Agent 2 prompt
│   │   ├── security.md        # Agent 3 prompt
│   │   ├── production.md      # Agent 4 prompt
│   │   ├── test-quality.md    # Agent 5 prompt
│   │   └── goal-alignment.md  # Agent 6 prompt
│   ├── scripts/
│   │   ├── resolve-config.sh  # Config resolution (CLI > project > user > defaults)
│   │   ├── platform.sh        # Platform detection and API abstraction
│   │   ├── triage-state.sh    # Triage state management
│   │   └── sanitize-gh-json.py # GitHub JSON sanitizer
│   └── schemas/
│       └── finding.schema.json # Finding output schema
├── config/
│   └── config-template.yml    # Default configuration
├── adapters/
│   ├── claude-code/           # Claude Code commands directory adapter
│   │   ├── commands/
│   │   │   ├── review/
│   │   │   │   └── SKILL.md   # Thin wrapper invoking core/commands/review.md
│   │   │   └── triage/
│   │   │       └── SKILL.md   # Thin wrapper invoking core/commands/triage.md
│   │   └── install.sh         # Symlinks core into Claude Code commands
│   ├── speckit/               # spec-kit extension bundle adapter
│   │   ├── extension.yml      # Extension manifest
│   │   ├── commands/
│   │   │   ├── speckit.cc-review.review.md   # Thin wrapper
│   │   │   └── speckit.cc-review.triage.md   # Thin wrapper
│   │   └── install.sh         # `specify extension add` wrapper
│   └── agents-md/             # Codex/OpenCode adapter
│       ├── AGENTS.md          # Review agent instructions fragment
│       └── install.sh         # Append to existing AGENTS.md
└── docs/
    ├── standalone-guide.md    # Quick start without spec-kit
    └── speckit-guide.md       # Integration with cc-spex

# Repository 2: rhuss/cc-spex (EXISTING, changes only)
spex/extensions/
├── spex-deep-review/
│   ├── commands/
│   │   └── speckit.spex-deep-review.run.md  # MODIFIED: simplified fallback + delegation
│   ├── scripts/
│   │   └── detect-cc-review.sh              # NEW: cc-review detection
│   └── config-template.yml                  # UNCHANGED
├── spex-collab/
│   ├── commands/
│   │   └── speckit.spex-collab.triage.md    # REMOVED (moved to cc-review)
│   ├── scripts/
│   │   ├── spex-triage-state.sh             # REMOVED (moved to cc-review)
│   │   └── sanitize-gh-json.py              # REMOVED (moved to cc-review)
│   └── extension.yml                        # MODIFIED: remove triage command
└── spex-gates/
    └── commands/
        └── speckit.spex-gates.review-code.md  # MODIFIED: delegation check
```

**Structure Decision**: Two-repository approach per brainstorm decision. cc-review is the standalone plugin; cc-spex changes are the integration/delegation layer.

## Complexity Tracking

No constitution violations. No complexity justifications needed.
