# Implementation Plan: SDD Traits Infrastructure

**Branch**: `002-traits-infrastructure` | **Date**: 2026-02-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-traits-infrastructure/spec.md`

## Summary

Add a trait system to the SDD plugin that lets users select which discipline overlays (sdd, beads) to inject into spec-kit command and template files. The implementation creates: (1) `apply-traits.sh` script that reads a JSON config and appends overlay files to spec-kit targets with idempotent sentinel markers, (2) modifications to `sdd-init.sh` to call `apply-traits.sh` after every `specify init`, (3) trait selection prompting in the init SKILL.md, (4) a new `/sdd:traits` command for enable/disable/list, and (5) placeholder overlay directory structure with example overlays.

## Technical Context

**Language/Version**: Bash (POSIX-compatible, uses `jq` for JSON), Markdown for commands/skills
**Primary Dependencies**: `jq` (JSON parsing), `specify` CLI (spec-kit), `grep` (sentinel detection)
**Storage**: `.specify/sdd-traits.json` (JSON file, git-tracked)
**Testing**: Manual verification via shell script execution and file content inspection
**Target Platform**: macOS/Linux (Claude Code environments)
**Project Type**: Claude Code plugin (commands, skills, scripts)
**Constraints**: Overlay files must be under 20 lines of markdown source (excluding sentinel). `apply-traits.sh` must be idempotent. Must survive `specify init --force` cycles.

## Constitution Check

No constitution exists. Skipped.

## Project Structure

### Documentation (this feature)

```text
specs/002-traits-infrastructure/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 (not needed - no unknowns)
├── data-model.md        # Phase 1 (not applicable - no data model)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (plugin root: `sdd/`)

```text
sdd/
├── scripts/
│   ├── sdd-init.sh          # MODIFY: add apply-traits.sh call after specify init
│   └── apply-traits.sh      # NEW: reads config, appends overlays to targets
├── commands/
│   └── traits.md            # NEW: /sdd:traits command (enable|disable|list)
├── skills/
│   └── init/
│       └── SKILL.md         # MODIFY: add trait selection prompting (AskUserQuestion)
└── overlays/                # NEW: overlay directory structure
    ├── sdd/
    │   └── commands/
    │       └── speckit.specify.append.md   # placeholder (content in Spec B)
    └── beads/
        └── commands/
            └── speckit.implement.append.md # placeholder (content in Spec B)
```

**Structure Decision**: This is a Claude Code plugin. All source lives under `sdd/` (plugin root). No `src/` or `tests/` directories. The overlay directory (`sdd/overlays/`) is a new top-level directory within the plugin.

## Implementation Approach

### Component 1: `apply-traits.sh` (FR-002, FR-003, FR-011, FR-013)

The core patching script. Reads `.specify/sdd-traits.json`, iterates enabled traits, finds overlay files in the plugin's `overlays/` directory, and appends each overlay to its target file if the sentinel is not already present.

**Key design decisions:**

- **Working directory assumption**: The script assumes it is invoked from the project root directory (where `.specify/` and `.claude/` exist). All target paths are resolved relative to `pwd`. `sdd-init.sh` already runs from the project root, so this is satisfied naturally.
- **Plugin root detection**: The script lives at `sdd/scripts/apply-traits.sh`. It derives the plugin root as `$(dirname "$0")/..` to find `sdd/overlays/`.
- **Target mapping (FR-013)**: `overlays/<trait>/commands/<name>.append.md` maps to `.claude/commands/<name>.md`. `overlays/<trait>/templates/<name>.append.md` maps to `.specify/templates/<name>.md`. The script strips `.append` from the filename and maps the `commands/` or `templates/` subdirectory to the correct project-root-relative path.
- **Sentinel check (FR-003)**: Before appending, `grep -q "<!-- SDD-TRAIT:<trait-name> -->"` on the target file. If found, skip. This makes the operation idempotent.
- **Validation (FR-011)**: Before any modifications, validate: (a) `.specify/sdd-traits.json` exists and parses as valid JSON via `jq`, (b) each target file exists. On failure, report each problem with a diagnostic (likely cause) and suggested remediation command, then exit non-zero without modifying any files.
- **Append operation**: `cat overlay.append.md >> target.md` with a newline separator. The overlay file itself starts with the sentinel marker.

**Exit codes**: 0 = success, 1 = error (invalid JSON, missing files), with errors to stderr.

### Component 2: `sdd-init.sh` modifications (FR-006)

After every `specify init` call (in `do_init`, `do_refresh`, `do_update`), call `apply-traits.sh` if `.specify/sdd-traits.json` exists. This re-applies overlays that were wiped by `specify init --force`.

**Key design decisions:**

- Only call `apply-traits.sh` if the traits config file exists. On first-ever init, the config won't exist yet (the init SKILL.md handles trait selection).
- Call `apply-traits.sh` silently (suppress stdout) on the fast path (`check_ready`). On the slow path, let output flow so the user sees what's being applied.
- Do not change exit codes. If `apply-traits.sh` fails, log a warning but don't block the init (spec-kit is still usable without traits).

### Component 3: Init SKILL.md modifications (FR-007, FR-014)

Add trait selection logic to the init skill. After `sdd-init.sh` reports READY:

- If `.specify/sdd-traits.json` does not exist: prompt user via `AskUserQuestion` to select traits (sdd, beads). Create the config file with selections. Call `apply-traits.sh`.
- If `.specify/sdd-traits.json` exists: display current settings. Ask if user wants to keep or reconfigure. If reconfigure, prompt for new selections and reapply.

**Key design decisions:**

- The trait selection uses `AskUserQuestion` with multiSelect, offering "sdd" and "beads" as options.
- The SKILL.md writes `.specify/sdd-traits.json` directly (using a Write tool call), since it runs in the Claude Code agent context, not in bash.
- After writing the config, it invokes `apply-traits.sh` via Bash tool.

### Component 4: `/sdd:traits` command (FR-008, FR-009)

New command file at `sdd/commands/traits.md` that delegates to trait management logic:

- **`list` (default)**: Read `.specify/sdd-traits.json` and display trait status. If no config exists, suggest `/sdd:init`.
- **`enable <trait>`**: Update config to set trait to true, then run `apply-traits.sh` (idempotent, will add the new trait's overlays).
- **`disable <trait>`**: Warn about destructive side effect (spec-kit files will be reset). If confirmed: update config, run `specify init --force`, then run `apply-traits.sh` to reapply remaining traits only.

**Key design decisions:**

- The command is a skill-delegating command file (like other sdd commands). It parses `$ARGUMENTS` for subcommand and trait name.
- Disable is the only destructive operation and requires `AskUserQuestion` confirmation.
- Enable is additive (just appends new overlays) and does not need confirmation.

### Component 5: Overlay directory structure (FR-004, FR-005)

Create the `sdd/overlays/` directory with placeholder overlay files. These placeholders demonstrate the format and are replaced with real content in Spec B (003-command-consolidation).

**Directory layout:**
```
sdd/overlays/
├── sdd/
│   └── commands/
│       └── speckit.specify.append.md
└── beads/
    └── commands/
        └── speckit.implement.append.md
```

Each placeholder contains: sentinel marker, a brief comment noting it's a placeholder, and a `{Skill:}` reference to demonstrate the delegation pattern.

## Error Handling

| Error | Detection | Response |
|-------|-----------|----------|
| `.specify/sdd-traits.json` missing | `[ ! -f ... ]` in apply-traits.sh | Exit 1, stderr message |
| Invalid JSON in traits config | `jq` parse failure | Exit 1, stderr message, no files modified |
| Target file missing | `[ ! -f ... ]` before append | Exit 1, report each missing file with likely cause and remediation suggestion (e.g., "Run `specify init` first"), no files modified |
| Overlay directory missing | `[ ! -d ... ]` | Warn, no overlays applied for that trait |
| Config lost after `specify init` | Check in apply-traits.sh | Exit 1, report assumption violation |
| Unknown trait name in `/sdd:traits` | Check against known list | Report error, list valid trait names |

## Complexity Tracking

No constitution violations to justify. Implementation is straightforward: one bash script, modifications to two existing files, one new command file, and placeholder overlay files.
