# Feature Specification: Agent Teams Integration for SDD

**Feature Branch**: `005-teams-traits`
**Created**: 2026-02-27
**Status**: Draft
**Input**: User description: "Two new traits (teams-vanilla and teams-spec) that leverage Claude Code Agent Teams for parallel task implementation. teams-vanilla provides pure CC Teams orchestration via CLAUDE.md guidance. teams-spec adds spec guardian lead pattern with git worktree isolation, beads bridge, and sdd:review-code integration. Includes trait dependency infrastructure."

## Purpose

The SDD plugin currently executes implementation tasks sequentially within a single Claude Code session. For features with many independent tasks, this leaves significant parallelism on the table. Claude Code Agent Teams enables multiple teammates to implement tasks simultaneously, each in their own context window.

This spec introduces two new traits and the dependency infrastructure to support them:

- **`teams-vanilla`**: Injects guidance into `/speckit.implement` so the lead can orchestrate a team of teammates for parallel task execution. Relies on CC Teams native capabilities with no custom tooling beyond the overlay and a skill.
- **`teams-spec`**: Extends `teams-vanilla` with SDD-specific coordination. The lead acts as a spec compliance guardian (does not implement tasks itself), teammates work in git worktrees for isolation, and task state bridges between beads and CC Teams.
- **Trait dependency model**: `teams-spec` requires `teams-vanilla`, `superpowers`, and `beads`. The traits infrastructure gains dependency checking on enable/disable operations.

## Dependencies & Assumptions

- **Claude Code Agent Teams**: Experimental feature, requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. If the feature is removed or significantly changed in a future CC release, these traits will need updating.
- **Existing trait infrastructure** (spec 002): The overlay application system, sentinel markers, and `sdd-traits.sh` script are assumed functional and stable.
- **`superpowers` and `beads` traits**: Must be working correctly for `teams-spec` to function. `teams-vanilla` has no trait dependencies.
- **Git worktrees**: Required for `teams-spec` teammate isolation. The project must be in a git repository (already an SDD requirement).
- **`jq`**: Required by `sdd-traits.sh` for JSON parsing (already an existing dependency).

## Out of Scope

- **Non-implementation phases**: Teams integration applies only to `/speckit.implement`. Brainstorming, planning, and task generation remain single-session activities.
- **Custom teammate models**: The trait does not allow configuring per-teammate model selection (e.g., Sonnet for some, Opus for others). Users can request this via natural language to the lead.
- **Nested teams**: CC Teams does not support teammates spawning their own teams. This spec does not attempt to work around that limitation.
- **Automatic cost optimization**: The trait does not attempt to minimize token usage by dynamically adjusting team size. Users control team size via task structure.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Parallel Implementation with teams-vanilla (Priority: P1)

A user enables the `teams-vanilla` trait, runs `/speckit.implement` on a feature with 8 independent tasks, and watches multiple teammates execute tasks simultaneously. The lead coordinates task assignment and waits for all teammates to finish before reporting completion.

**Why this priority**: This is the foundational flow. Without basic team orchestration, the `teams-spec` trait has nothing to build on. It also delivers the primary value proposition (parallelism) with minimal complexity.

**Independent Test**: Enable `teams-vanilla` trait on a project with a spec that has 5+ independent tasks in tasks.md. Run `/speckit.implement`. Verify that multiple teammates are spawned, each claims different tasks, and all tasks complete.

**Acceptance Scenarios**:

1. **Given** a project with `teams-vanilla` enabled and `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set, and a tasks.md with 6 tasks (4 independent, 2 blocked), **When** the user runs `/speckit.implement`, **Then** the lead spawns up to 4 teammates (one per independent task group), each teammate claims and implements tasks from the shared task list, and the lead waits for all teammates to complete before proceeding to post-implementation steps.

2. **Given** a project with `teams-vanilla` enabled but `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` not set, **When** the user runs `/speckit.implement`, **Then** the trait overlay detects the missing feature flag, enables it in `.claude/settings.local.json`, and informs the user that a restart is needed for teams to activate.

3. **Given** a project with `teams-vanilla` enabled and only 2 tasks (both independent), **When** the user runs `/speckit.implement`, **Then** the lead spawns 2 teammates (not more than the number of tasks) and each implements one task.

4. **Given** a project with `teams-vanilla` enabled and tasks that have a linear dependency chain (task 2 depends on task 1, task 3 depends on task 2), **When** the user runs `/speckit.implement`, **Then** the lead falls back to sequential execution since no parallelism is possible, or spawns a single teammate for the chain.

---

### User Story 2 - Trait Dependency Enforcement (Priority: P1)

A user tries to enable `teams-spec` without its dependencies being met. The system prevents this and tells them exactly what they need to enable first.

**Why this priority**: Dependency enforcement is critical infrastructure. Without it, `teams-spec` would silently fail when `superpowers` or `beads` are missing.

**Independent Test**: Attempt to enable `teams-spec` with various combinations of missing dependencies. Verify each combination produces the correct error message.

**Acceptance Scenarios**:

1. **Given** a project with only `superpowers` enabled, **When** the user runs `sdd-traits.sh enable teams-spec`, **Then** the script reports that `teams-spec` requires `teams-vanilla` and `beads`, and exits without modifying config.

2. **Given** a project with `teams-vanilla`, `superpowers`, and `beads` all enabled, **When** the user runs `sdd-traits.sh enable teams-spec`, **Then** the trait is enabled and overlays are applied.

3. **Given** a project with `teams-spec` and `teams-vanilla` both enabled, **When** the user runs `sdd-traits.sh disable teams-vanilla`, **Then** the script reports that `teams-spec` depends on `teams-vanilla` and refuses to disable it.

4. **Given** a user running `sdd-traits.sh init --enable teams-spec,superpowers,beads` (without explicitly including `teams-vanilla`), **When** the script processes the enable list, **Then** it auto-includes `teams-vanilla` (since `teams-spec` depends on it) and warns the user about the auto-inclusion.

---

### User Story 3 - Spec Guardian Implementation with teams-spec (Priority: P2)

A user enables the `teams-spec` trait (with all dependencies met) and runs `/speckit.implement`. The lead acts purely as a spec compliance guardian: it spawns teammates in git worktrees, reviews their completed work against spec.md, and only merges compliant changes.

**Why this priority**: This is the advanced workflow that delivers the full SDD value proposition. It depends on User Story 1 (teams-vanilla) and User Story 2 (dependency infrastructure) being functional.

**Independent Test**: Enable `teams-spec` (and all dependencies). Run `/speckit.implement` on a feature spec. Verify the lead does not implement tasks itself, teammates work in worktrees, and the lead runs spec compliance review on completed work before merging.

**Acceptance Scenarios**:

1. **Given** a project with `teams-spec` enabled and a tasks.md with 4 independent tasks, **When** the user runs `/speckit.implement`, **Then** the lead spawns 4 teammates each in a separate git worktree, the lead does not implement any tasks itself, and the lead reviews each teammate's work against spec.md using `sdd:review-code` before merging.

2. **Given** a teammate that completes a task with code that deviates from spec.md, **When** the lead runs spec compliance review, **Then** the lead sends feedback to the teammate listing specific violations and asks them to fix the issues. The lead does not merge non-compliant work.

3. **Given** all teammates have completed their tasks and passed spec review, **When** the lead finishes merging all worktree changes, **Then** the lead syncs final state back to beads via `bd sync` and updates tasks.md checkboxes via reverse sync.

---

### User Story 4 - Beads Bridge in teams-spec (Priority: P2)

A user with `teams-spec` enabled runs `/speckit.implement`. Before spawning teammates, the lead bootstraps beads issues from tasks.md. After all tasks complete, the lead syncs results back to beads for cross-session persistence.

**Why this priority**: The beads bridge preserves the SDD memory model across sessions. Without it, task completion state would be lost if the session ends during implementation.

**Independent Test**: Enable `teams-spec`. Run `/speckit.implement`. Verify beads issues are created from tasks.md before team spawn. After completion, verify `bd list` reflects all completed tasks and tasks.md checkboxes are updated.

**Acceptance Scenarios**:

1. **Given** a tasks.md with 5 tasks and no corresponding beads issues, **When** `/speckit.implement` starts with `teams-spec` enabled, **Then** the lead runs `sdd-beads-sync.py` to create beads issues from tasks.md before spawning any teammates.

2. **Given** beads issues already exist for all tasks, **When** `/speckit.implement` starts, **Then** the lead skips the bootstrap step and proceeds directly to teammate spawning.

3. **Given** all tasks are complete and merged, **When** the lead runs the final sync, **Then** `bd sync` persists all state changes and `bd list` shows all issues as closed with completion reasons.

---

### User Story 5 - Trait Selection During Init (Priority: P3)

A user runs `/sdd:init` for the first time and sees the two new team traits in the trait selection prompt, with clear descriptions indicating their dependencies and experimental status.

**Why this priority**: Important for discoverability but not blocking for users who know how to enable traits via `sdd-traits.sh` directly.

**Independent Test**: Run `/sdd:init` on a fresh project. Verify the trait selection includes `teams-vanilla` and `teams-spec` with dependency information.

**Acceptance Scenarios**:

1. **Given** a fresh project with no `.specify/sdd-traits.json`, **When** the user runs `/sdd:init`, **Then** the AskUserQuestion prompt includes `teams-vanilla` with description "Parallel implementation via Claude Code Agent Teams (experimental)" and `teams-spec` with description "Spec guardian + worktree isolation (requires: teams-vanilla, superpowers, beads)".

2. **Given** a user who selects `teams-spec` during init without selecting its dependencies, **When** the init processes selections, **Then** it auto-enables `teams-vanilla` (direct dependency) and warns that `superpowers` and `beads` must also be selected. If they are not selected, `teams-spec` is not enabled and the user is informed why.

---

### Edge Cases

- What happens when a teammate crashes mid-task? The lead detects the idle/stopped teammate, logs the failure, and either spawns a replacement teammate or falls back to implementing that task itself.
- What happens when two teammates try to claim the same task? CC Teams uses file locking for task claims, preventing race conditions. This is handled by the platform.
- What happens when a worktree merge has conflicts? The lead reports the conflict to the user and pauses. It does not attempt automatic conflict resolution.
- What happens when `bd` is not installed but `teams-spec` is enabled? The beads pre-flight check (from the existing beads trait overlay) catches this and stops before teammate spawning.
- What happens when only 1 task exists in tasks.md? The lead skips team creation and executes the single task directly (no overhead for trivial cases).
- What happens when CC Teams feature flag is removed in a future Claude Code release? The overlay checks for the flag and falls back to sequential implementation. No crash, just degraded mode.

## Requirements *(mandatory)*

### Functional Requirements

**Trait Dependency Infrastructure**

- **FR-D01**: `sdd-traits.sh` MUST maintain a dependency map declaring that `teams-vanilla` has no dependencies and `teams-spec` depends on `teams-vanilla`, `superpowers`, and `beads`.
- **FR-D02**: When enabling a trait, `sdd-traits.sh` MUST verify all dependencies are already enabled. If any dependency is missing, it MUST report which dependencies are needed and exit non-zero without modifying config.
- **FR-D03**: When disabling a trait, `sdd-traits.sh` MUST verify no other enabled trait depends on it. If a dependent trait exists, it MUST report the dependency and exit non-zero.
- **FR-D04**: `sdd-traits.sh init --enable` MUST resolve direct dependencies during batch enable. If `teams-spec` is listed but `teams-vanilla` is not, it MUST auto-include `teams-vanilla` and warn the user. If non-auto-resolvable dependencies (`superpowers`, `beads`) are missing from the enable list, it MUST error.
- **FR-D05**: `VALID_TRAITS` in `sdd-traits.sh` MUST be extended to include `teams-vanilla` and `teams-spec`.
- **FR-D06**: The `/sdd:init` AskUserQuestion prompt MUST include the two new traits with descriptions that indicate their dependencies and experimental status.

**teams-vanilla Trait**

- **FR-V01**: The trait MUST add an overlay to `speckit.implement` that instructs the lead to orchestrate implementation via Claude Code Agent Teams.
- **FR-V02**: If the Agent Teams feature flag is not active, the overlay MUST detect this and either set it in `.claude/settings.local.json` (informing the user a restart is needed) or fall back to sequential implementation.
- **FR-V03**: The overlay MUST instruct the lead to read tasks.md, analyze the dependency graph, and identify groups of tasks that can execute in parallel.
- **FR-V04**: The lead MUST spawn one teammate per independent task group, with a maximum of 5 teammates. If there are more than 5 independent groups, the lead MUST batch them.
- **FR-V05**: Each teammate's spawn prompt MUST include the spec.md content for project context.
- **FR-V06**: The overlay MUST instruct the lead to wait for all teammates to complete before proceeding to post-implementation quality gates.
- **FR-V07**: When only 1 task exists or no parallelism is possible (linear dependency chain), the lead MUST skip team creation and execute sequentially.
- **FR-V08**: The overlay file MUST follow existing conventions: sentinel marker `<!-- SDD-TRAIT:teams-vanilla -->`, under 30 lines, and delegation to `{Skill: sdd:teams-orchestrate}`.

**teams-spec Trait**

- **FR-S01**: The trait MUST add an overlay to `speckit.implement` that changes the lead's role from "implementer + coordinator" to "spec guardian". The lead MUST NOT implement tasks itself when this trait is active.
- **FR-S02**: The lead MUST spawn each teammate in a dedicated git worktree for file isolation.
- **FR-S03**: Before spawning teammates, the lead MUST bootstrap beads issues from tasks.md using `sdd-beads-sync.py` if issues are not already synced.
- **FR-S04**: When a teammate completes a task, the lead MUST run `sdd:review-code` against the teammate's changes, checking compliance with spec.md.
- **FR-S05**: If spec compliance review fails, the lead MUST send feedback to the teammate listing specific violations and request fixes. The lead MUST NOT merge non-compliant work.
- **FR-S06**: When a teammate's work passes review, the lead MUST merge the worktree changes into the working branch.
- **FR-S07**: After all tasks complete, the lead MUST sync final state back to beads via `bd sync` and update tasks.md checkboxes via reverse sync.
- **FR-S08**: The overlay file MUST use sentinel marker `<!-- SDD-TRAIT:teams-spec -->` and delegate to `{Skill: sdd:teams-spec-guardian}`.
- **FR-S09**: When both `teams-vanilla` and `teams-spec` overlays are present on the same implement command file, the `teams-spec` behavior MUST take precedence (spec guardian supersedes vanilla coordinator).

**New Skills**

- **FR-SK01**: A new skill `sdd:teams-orchestrate` MUST be created at `sdd/skills/teams-orchestrate/SKILL.md` containing the vanilla team orchestration logic: task graph analysis, teammate spawning, completion waiting, and fallback to sequential execution.
- **FR-SK02**: A new skill `sdd:teams-spec-guardian` MUST be created at `sdd/skills/teams-spec-guardian/SKILL.md` containing the spec guardian logic: worktree spawning, `sdd:review-code` integration, merge protocol, and beads bridge.

### Key Entities

- **Trait Dependency Map**: A lookup structure in `sdd-traits.sh` that maps each trait to its list of required traits. Used during enable/disable validation.
- **teams-vanilla overlay**: Markdown fragment appended to `speckit.implement` command file. Contains team orchestration instructions and delegates to `sdd:teams-orchestrate`.
- **teams-spec overlay**: Markdown fragment appended to `speckit.implement` command file. Contains spec guardian instructions and delegates to `sdd:teams-spec-guardian`.
- **Task Dependency Graph**: The dependency relationships between tasks in tasks.md, analyzed by the lead to determine which tasks can run in parallel and which must wait.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A feature with 6 independent tasks completes implementation in less time with `teams-vanilla` enabled than without (wall-clock improvement, not token efficiency).
- **SC-002**: Enabling `teams-spec` without all dependencies (`teams-vanilla`, `superpowers`, `beads`) produces a clear error naming each missing dependency.
- **SC-003**: Disabling a trait that another enabled trait depends on produces a clear error naming the dependent trait.
- **SC-004**: With `teams-spec` enabled, the lead does not implement any tasks itself (zero code changes from the lead session, only review and merge actions).
- **SC-005**: With `teams-spec` enabled, each teammate operates in its own git worktree, and no two teammates modify files in the same worktree.
- **SC-006**: With `teams-spec` enabled, tasks.md and beads issues reflect completed state after implementation finishes (all checkboxes checked, all beads issues closed).
- **SC-007**: Both overlay files are under 30 lines each and contain their respective sentinel markers.
- **SC-008**: When CC Teams feature flag is not set and `teams-vanilla` is enabled, the system either auto-enables it or falls back gracefully without crashing.
