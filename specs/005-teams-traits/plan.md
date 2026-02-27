# Implementation Plan: Agent Teams Integration for SDD

**Branch**: `005-teams-traits` | **Date**: 2026-02-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-teams-traits/spec.md`

## Summary

Add two new traits (`teams-vanilla` and `teams-spec`) that leverage Claude Code Agent Teams for parallel task implementation during `/speckit.implement`. Includes trait dependency infrastructure in `sdd-traits.sh`. The implementation consists of: extending the traits script with dependency checking, creating two overlay files (one per trait), creating two new skills (orchestration and spec guardian), and updating the init command to surface the new traits.

## Technical Context

**Language/Version**: Bash (POSIX-compatible) + Markdown + `jq` for JSON parsing
**Primary Dependencies**: `sdd-traits.sh` (existing), Claude Code Agent Teams (experimental, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), `bd` CLI (beads, for teams-spec only)
**Storage**: `.specify/sdd-traits.json` (trait config), `.beads/` (beads database, existing)
**Testing**: Manual verification via `make reinstall` + Claude Code session testing
**Target Platform**: Claude Code CLI plugin (macOS/Linux)
**Project Type**: Plugin (Markdown/Bash, no compiled artifacts)
**Performance Goals**: N/A (plugin is instruction-driven, not performance-critical)
**Constraints**: Overlay files must be under 30 lines each. Skills must be self-contained. No compiled artifacts.
**Scale/Scope**: 2 overlay files, 2 skills, 1 script modification, 1 command update

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Guided Development | PASS | This is significant feature work following the full SDD workflow |
| II. Overlay Delegation | PASS | Both overlays delegate to skills, under 30 lines, sentinel markers |
| III. Trait Composability | PASS (with note) | `teams-vanilla` is independent. `teams-spec` has dependencies but does not modify other traits' overlays. Dependency is at config level, not overlay level. Consider constitution amendment as follow-up. |
| IV. Quality Gates | PASS | `teams-spec` reinforces quality gates (lead-as-spec-guardian) |
| V. Naming Discipline | PASS | `teams-vanilla`, `teams-spec` follow lowercase-hyphenated. Skills use `sdd:` prefix. Overlays in `sdd/overlays/<trait>/` |
| VI. Skill Autonomy | PASS | Two new skills, each single-purpose. `teams-orchestrate` handles coordination. `teams-spec-guardian` handles compliance. No logic mixing. |

**No violations. Plan may proceed.**

## Project Structure

### Documentation (this feature)

```text
specs/005-teams-traits/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
sdd/
├── scripts/
│   └── sdd-traits.sh                              # MODIFY: add dependency map, extend VALID_TRAITS
├── commands/
│   └── init.md                                     # MODIFY: add teams traits to AskUserQuestion
├── overlays/
│   ├── teams-vanilla/
│   │   └── commands/
│   │       └── speckit.implement.append.md          # NEW: vanilla teams overlay
│   └── teams-spec/
│       └── commands/
│           └── speckit.implement.append.md          # NEW: spec guardian overlay
└── skills/
    ├── teams-orchestrate/
    │   └── SKILL.md                                 # NEW: vanilla orchestration skill
    └── teams-spec-guardian/
        └── SKILL.md                                 # NEW: spec guardian skill
```

**Structure Decision**: Follows the established SDD plugin layout exactly. Each trait gets its own overlay directory. Each skill gets its own directory with SKILL.md. No new directories at non-standard locations.

## Implementation Phases

### Phase 1: Trait Dependency Infrastructure (User Story 2 - P1)

**Goal**: Extend `sdd-traits.sh` to support trait dependencies, validate on enable/disable, and auto-resolve during init.

**Files modified**:
- `sdd/scripts/sdd-traits.sh`

**Changes**:

1. **Add dependency map** after `VALID_TRAITS` declaration:
   ```bash
   VALID_TRAITS="superpowers beads teams-vanilla teams-spec"

   # Trait dependency map (space-separated lists)
   declare -A TRAIT_DEPS
   TRAIT_DEPS[superpowers]=""
   TRAIT_DEPS[beads]=""
   TRAIT_DEPS[teams-vanilla]=""
   TRAIT_DEPS[teams-spec]="teams-vanilla superpowers beads"
   ```

2. **Add dependency check functions**:
   - `check_deps_for_enable()`: Given a trait, check all its dependencies are enabled in config. Return missing list.
   - `check_dependents_for_disable()`: Given a trait, check no enabled trait depends on it. Return dependent list.

3. **Modify `do_enable()`**: Before enabling, call `check_deps_for_enable()`. If dependencies missing, report and exit 1.

4. **Modify `do_disable()`**: Before disabling, call `check_dependents_for_disable()`. If dependents exist, report and exit 1.

5. **Modify `do_init()`**: During `--enable` processing, auto-resolve `teams-vanilla` if `teams-spec` is in the list. Error if `superpowers` or `beads` are missing when `teams-spec` is requested.

6. **Modify `ensure_config()`**: Add `teams-vanilla` and `teams-spec` keys (both false) to the default config JSON.

**Verification**: Run `sdd-traits.sh enable teams-spec` without deps enabled (should error). Enable all deps first, then enable `teams-spec` (should succeed). Try disabling `teams-vanilla` with `teams-spec` enabled (should error).

### Phase 2: teams-vanilla Overlay and Skill (User Story 1 - P1)

**Goal**: Create the vanilla teams overlay and orchestration skill.

**Files created**:
- `sdd/overlays/teams-vanilla/commands/speckit.implement.append.md`
- `sdd/skills/teams-orchestrate/SKILL.md`

**Overlay content** (under 30 lines):

The overlay will:
1. Include sentinel marker `<!-- SDD-TRAIT:teams-vanilla -->`
2. Check for CC Teams feature flag availability
3. If not available, set it in `.claude/settings.local.json` and inform user
4. If available, delegate to `{Skill: sdd:teams-orchestrate}`

**Skill content** (`sdd:teams-orchestrate`):

The skill will instruct the lead to:
1. Read tasks.md and parse the dependency graph
2. Identify groups of independent tasks (no unresolved dependencies)
3. If 0-1 independent groups: fall back to sequential execution
4. Spawn one teammate per group (max 5), providing spec.md context in spawn prompt
5. Wait for all teammates to complete
6. Proceed to post-implementation steps

Key skill sections:
- Prerequisites (CC Teams enabled check)
- Feature flag auto-enablement logic
- Task graph analysis instructions
- Teammate spawning instructions (with spawn prompt template)
- Completion waiting protocol
- Sequential fallback logic

**Verification**: Enable `teams-vanilla`, run `/speckit.implement` on a project with 4+ independent tasks. Verify teammates are spawned.

### Phase 3: teams-spec Overlay and Skill (User Stories 3, 4 - P2)

**Goal**: Create the spec guardian overlay, skill, and beads bridge.

**Files created**:
- `sdd/overlays/teams-spec/commands/speckit.implement.append.md`
- `sdd/skills/teams-spec-guardian/SKILL.md`

**Overlay content** (under 30 lines):

The overlay will:
1. Include sentinel marker `<!-- SDD-TRAIT:teams-spec -->`
2. Override vanilla behavior: "When this trait is active, the lead acts as spec guardian, NOT as implementer"
3. Delegate to `{Skill: sdd:teams-spec-guardian}`

**Skill content** (`sdd:teams-spec-guardian`):

The skill will instruct the lead to:
1. **Beads bootstrap**: Run `sdd-beads-sync.py` to create beads issues from tasks.md (if not already synced)
2. **Task graph analysis**: Same as vanilla but with worktree spawning
3. **Worktree spawning**: Each teammate gets `isolation: "worktree"` for git worktree isolation
4. **Spec guardian loop**:
   - Lead monitors teammate completion
   - When teammate finishes: run `sdd:review-code` against their changes
   - If review passes: merge worktree into working branch
   - If review fails: send feedback to teammate, request fixes
5. **Final sync**: Run `bd sync` and reverse sync to update tasks.md checkboxes
6. **Precedence**: Explicitly state this skill supersedes `sdd:teams-orchestrate` when both are present

Key skill sections:
- Beads pre-flight and bootstrap
- Worktree teammate spawning (spawn prompt template with spec.md + task assignment)
- Review-merge loop
- Failure handling (teammate crash, merge conflicts)
- Final beads sync protocol

**Verification**: Enable all deps + `teams-spec`. Run `/speckit.implement`. Verify lead doesn't implement, teammates use worktrees, review-code runs on completed work.

### Phase 4: Init Command Update (User Story 5 - P3)

**Goal**: Add teams traits to the `/sdd:init` trait selection prompt.

**Files modified**:
- `sdd/commands/init.md`

**Changes**:

1. Add two new options to the traits AskUserQuestion:
   - `teams-vanilla`: "Parallel implementation via Claude Code Agent Teams (experimental)"
   - `teams-spec`: "Spec guardian + worktree isolation (requires: teams-vanilla, superpowers, beads)"

2. The init command already passes selected traits to `sdd-traits.sh init --enable`. The dependency resolution in Phase 1 handles auto-inclusion of `teams-vanilla` when `teams-spec` is selected.

**Verification**: Run `/sdd:init` on a fresh project. Verify the four traits appear in the selection prompt with correct descriptions.

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CC Teams feature removed/changed | High | Low | Feature flag check with sequential fallback |
| Worktree merge conflicts | Medium | Medium | Lead pauses and reports to user, no auto-resolution |
| Teammate crashes mid-task | Medium | Medium | Lead detects idle teammate, spawns replacement or falls back |
| Token cost surprises | Low | High | Documentation warns about cost. teams trait is opt-in. |
| `declare -A` not available in POSIX sh | Medium | Low | Script uses `#!/bin/bash` (not sh), associative arrays available in bash 4+ |

## Complexity Tracking

> No constitution violations to justify. All principles pass.

| Aspect | Complexity | Notes |
|--------|-----------|-------|
| Dependency infrastructure | Low | Bash associative array + two check functions |
| Overlay files | Low | Under 30 lines each, following established pattern |
| teams-orchestrate skill | Medium | Task graph analysis instructions, spawn prompt template |
| teams-spec-guardian skill | High | Worktree spawning, review loop, beads bridge, merge protocol |
| Init command update | Low | Adding 2 options to existing AskUserQuestion |

## Post-Phase 1 Constitution Re-check

After completing Phase 1 design:

| Principle | Status | Notes |
|-----------|--------|-------|
| II. Overlay Delegation | PASS | Overlay designs confirmed under 30 lines with skill delegation |
| III. Trait Composability | PASS | Dependency map doesn't violate composability; traits don't modify each other's files |
| VI. Skill Autonomy | PASS | `teams-orchestrate` and `teams-spec-guardian` are clearly separated |
