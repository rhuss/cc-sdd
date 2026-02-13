# Feature Specification: Beads Integration for SDD Implementation

**Feature Branch**: `001-beads-integration`
**Created**: 2026-02-13
**Status**: Draft
**Input**: Brainstorm session on integrating beads as runtime execution engine and memory layer for multi-session implementation

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Run Implementation with Beads (Priority: P1)

A developer has a complete spec package (spec.md, plan.md, tasks.md) and runs `/sdd:implement --with-beads` for the first time on this spec. The skill converts tasks.md into beads issues with proper dependencies, then executes implementation using beads as the task orchestration engine instead of speckit.implement.

**Why this priority**: This is the core functionality. Without task conversion and beads-driven execution, none of the other stories deliver value.

**Independent Test**: Can be tested by creating a sample spec package with 3-5 tasks across two phases, running `/sdd:implement --with-beads`, and verifying that beads issues are created with correct dependencies and tasks execute in dependency order via `bd ready`.

**Acceptance Scenarios**:

1. **Given** a spec directory with spec.md, plan.md, and tasks.md containing phased tasks, **When** user runs `/sdd:implement --with-beads`, **Then** each task in tasks.md is created as a beads issue with task ID preserved in the title, phase dependencies are mapped to beads blocking relationships, and `[P]` markers result in non-blocking sibling issues within the same phase.

2. **Given** beads issues have been created from tasks.md, **When** the implementation loop begins, **Then** the skill calls `bd ready --json` to get the next unblocked task, implements it using the same TDD approach as speckit.implement, and calls `bd close <id>` on completion before moving to the next ready task.

3. **Given** all beads issues are closed (no more ready tasks), **When** the implementation loop ends, **Then** the skill syncs back to tasks.md by marking all completed tasks as `[X]` and proceeds to the post-implementation quality gates (review-code, verification).

4. **Given** tasks.md contains tasks already marked `[X]`, **When** the skill converts tasks to beads issues, **Then** completed tasks are created with status `closed` so they don't appear in `bd ready` results.

---

### User Story 2 - Multi-Session Resume (Priority: P2)

A developer started implementation with beads in a previous Claude Code session. They return in a new session and run `/sdd:implement --with-beads` again. The skill detects existing beads issues and resumes from where the previous session left off, without re-converting tasks.md.

**Why this priority**: This is the primary motivating use case for beads integration. Without resume capability, beads adds overhead with no benefit over the existing checkbox approach.

**Independent Test**: Can be tested by creating beads issues manually (simulating a partial first run), closing some of them, then running `/sdd:implement --with-beads` and verifying it skips conversion and picks up from the first `bd ready` result.

**Acceptance Scenarios**:

1. **Given** a spec directory where `.beads/` exists and contains issues matching task IDs from tasks.md, **When** user runs `/sdd:implement --with-beads`, **Then** the skill skips the tasks-to-beads conversion step and proceeds directly to the implementation loop with `bd ready --json`.

2. **Given** a resumed session where 3 of 8 beads issues are already closed, **When** the implementation loop runs, **Then** `bd ready` returns only unblocked tasks from the remaining 5, and the skill implements them in dependency order.

3. **Given** a resumed session completes all remaining tasks, **When** sync-back runs, **Then** tasks.md is updated to mark all completed tasks as `[X]`, including those completed in the previous session.

---

### User Story 3 - Discovered Work During Implementation (Priority: P3)

During implementation, the developer (or the agent) discovers additional work needed, such as a bug, a missing helper function, or an unforeseen integration requirement. The skill creates new beads issues for discovered work, tracks them alongside planned tasks, and includes them in the final sync-back to tasks.md.

**Why this priority**: Discovered work tracking is a key differentiator of beads over plain checkboxes. However, the core implementation loop (P1) and resume (P2) must work first.

**Independent Test**: Can be tested by running implementation with beads, manually injecting a `bd create` call mid-execution, and verifying the new issue appears in `bd ready` (respecting dependencies) and is appended to tasks.md during sync-back.

**Acceptance Scenarios**:

1. **Given** the implementation loop is running and the agent identifies new work needed (e.g., a missing utility function), **When** the agent creates a new beads issue via `bd create`, **Then** the issue is tracked in beads with appropriate type and priority, and optionally linked as a dependency to the current task.

2. **Given** discovered work exists as beads issues that have no corresponding entry in tasks.md, **When** sync-back runs at the end of implementation, **Then** discovered tasks are appended to tasks.md under a `## Discovered During Implementation` section with their completion status.

3. **Given** a discovered task blocks the current task, **When** `bd dep add` is called to create the blocking relationship, **Then** `bd ready` correctly reflects the dependency and the blocked task does not appear as ready until the blocker is closed.

---

### User Story 4 - Beads Sync-Back to tasks.md (Priority: P4)

After implementation completes (all tasks done or session ends), the skill synchronizes beads state back to tasks.md so the file remains an accurate, human-readable record of implementation progress.

**Why this priority**: Sync-back is essential for the workflow but is a supporting operation that only matters after the core stories work.

**Independent Test**: Can be tested by creating beads issues with known states, running the sync-back logic in isolation, and verifying tasks.md is correctly updated.

**Acceptance Scenarios**:

1. **Given** beads has 10 issues, 8 closed and 2 open, **When** sync-back executes, **Then** tasks.md has exactly 8 tasks marked `[X]` and 2 tasks still marked `[ ]`, matching the beads state.

2. **Given** beads has 3 discovered issues not in the original tasks.md, **When** sync-back executes, **Then** tasks.md has a new `## Discovered During Implementation` section with 3 entries, each formatted as `- [X] DISCOVERED: <title>` or `- [ ] DISCOVERED: <title>` based on their beads status.

3. **Given** sync-back completes successfully, **When** the user views tasks.md, **Then** the original task ordering and phase structure are preserved, only checkbox states are changed, and discovered tasks are appended at the end.

---

### Edge Cases

- What happens when beads CLI (`bd`) is not installed? The skill MUST fail with a clear error message suggesting installation, and MUST NOT fall back to speckit.implement silently.
- What happens when tasks.md has a format the parser cannot handle (e.g., missing task IDs, non-standard format)? The skill reports the parsing error with the specific line that failed and suggests running `/speckit.tasks` to regenerate.
- What happens when `bd ready` returns empty but there are still open (non-closed) beads issues? This indicates a circular dependency. The skill reports the blocked issues and their dependency chains and asks the user how to proceed.
- What happens when the user runs `/sdd:implement` without `--with-beads`? The existing speckit.implement flow runs unchanged. No beads interaction occurs.
- What happens when `.beads/` exists but contains issues from a different spec? The skill matches beads issue titles against task IDs from the current tasks.md. If no matches are found, it treats this as a first run and converts tasks.md to new beads issues.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `sdd:implement` skill MUST accept an optional `--with-beads` flag that switches Phase 2 from speckit.implement to beads-driven execution.
- **FR-002**: When `--with-beads` is specified, the skill MUST verify that the `bd` CLI is available by running `which bd` or `bd --version`. If not found, the skill MUST stop with an error message.
- **FR-003**: The skill MUST parse tasks.md to extract task ID, description, phase membership, `[P]` parallel marker, user story label, and checkbox state.
- **FR-004**: The skill MUST create one beads issue per task using `bd create "<TaskID> <Description>" -t task --json`, preserving the task ID in the issue title for traceability.
- **FR-005**: The skill MUST map phase dependencies to beads blocking relationships using the "last sequential task as phase gate" pattern: Phase N+1 tasks are blocked by the last sequential (non-`[P]`) task in Phase N. If Phase N ends with parallel tasks, all trailing parallel tasks block Phase N+1.
- **FR-006**: Within a phase, sequential tasks (no `[P]` marker) MUST have blocking dependencies on their predecessor. Parallel tasks (`[P]`) within the same phase MUST NOT block each other.
- **FR-007**: Tasks already marked `[X]` in tasks.md MUST be created as closed beads issues to maintain accurate dependency state.
- **FR-008**: The implementation loop MUST use `bd ready --json` to determine the next task to implement, MUST NOT hardcode task ordering.
- **FR-009**: After implementing a task, the skill MUST close the beads issue with `bd close <id> --reason "completed"`.
- **FR-010**: The skill MUST auto-detect existing beads issues on subsequent runs by checking if `.beads/` exists and contains issues whose titles match task IDs from the current tasks.md.
- **FR-011**: When existing beads issues are detected (resume scenario), the skill MUST skip tasks-to-beads conversion and proceed directly to the `bd ready` implementation loop.
- **FR-012**: During implementation, the skill MUST create new beads issues for discovered work using `bd create` with appropriate dependencies.
- **FR-018**: The skill MUST run `bd init --quiet` before creating beads issues if the `.beads/` directory does not exist. This initializes beads' local database and JSONL storage.
- **FR-019**: The skill MUST run `bd sync` after the sync-back phase to persist all beads state to the git-tracked JSONL file, enabling resume detection in subsequent sessions.
- **FR-013**: At the end of implementation (all tasks done or user stops), the skill MUST sync beads state back to tasks.md by updating checkbox states and appending discovered tasks.
- **FR-014**: Discovered tasks MUST be appended to tasks.md under a `## Discovered During Implementation` section.
- **FR-015**: The sync-back MUST preserve the original task ordering and phase structure in tasks.md. Only checkbox states change for existing tasks.
- **FR-016**: Phase 1 (pre-implementation) and Phase 3 (post-implementation) MUST remain unchanged from the current sdd:implement behavior.
- **FR-017**: When `--with-beads` is NOT specified, sdd:implement MUST behave identically to its current implementation (invoke speckit.implement).

### Key Entities

- **Beads Issue**: A task tracked in beads' SQLite/JSONL store. Maps 1:1 to a task in tasks.md. Identified by beads' hash ID, with the tasks.md task ID (e.g., T001) preserved in the issue title.
- **Task**: An entry in tasks.md with format `- [ ] T001 [P] [US1] Description with file path`. Parsed into structured data for beads conversion.
- **Phase**: A grouping of tasks in tasks.md (Setup, Foundational, User Story N, Polish). Maps to dependency chains in beads.
- **Dependency**: A blocking relationship between beads issues. Derived from phase ordering and sequential task ordering within phases.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/sdd:implement --with-beads` on a spec with 10+ tasks across 3+ phases creates beads issues with correct blocking dependencies, verified by `bd dep tree` showing the expected DAG structure.
- **SC-002**: A multi-session implementation scenario (stop after 3 tasks, resume in new session) completes all tasks without re-creating beads issues, verified by beads issue count remaining constant across sessions.
- **SC-003**: After full implementation, tasks.md checkbox states match beads issue states with 100% accuracy.
- **SC-004**: Running `/sdd:implement` without `--with-beads` produces identical behavior to the current implementation (no regression).
- **SC-005**: When `bd` is not installed, the skill fails within the first 5 seconds with a clear, actionable error message.
