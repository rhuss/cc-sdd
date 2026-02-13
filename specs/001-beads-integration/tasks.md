# Tasks: Beads Integration for SDD Implementation

**Spec:** specs/001-beads-integration/spec.md
**Plan:** specs/001-beads-integration/plan.md
**Created:** 2026-02-13

## Phase 1: Setup

- [X] T001 Read current sdd/skills/implement/SKILL.md and understand full structure before any modifications
- [X] T002 Verify bd CLI is installed and working by running `bd --version` to confirm test environment

## Phase 2: Foundational - Flag Detection and Routing

- [X] T003 Add `--with-beads` flag detection section at the top of SKILL.md, before Phase 1, that parses the ARGUMENTS for the flag and sets a BEADS_MODE variable
- [X] T004 Add conditional routing in Phase 2 that branches between Path A (speckit.implement, unchanged) and Path B (beads-driven loop) based on BEADS_MODE

**Checkpoint:** Running `/sdd:implement` without `--with-beads` must behave identically to current behavior (FR-017).

## Phase 3: User Story 1 - First-Run Implementation with Beads

- [X] T005 Write Phase 1.5.1 section: bd CLI verification with actionable error message, and bd init --quiet if .beads/ does not exist, in sdd/skills/implement/SKILL.md
- [X] T006 Write Phase 1.5.3 section: tasks.md parsing instructions with regex patterns, phase detection, and parse error handling in sdd/skills/implement/SKILL.md
- [X] T007 Write Phase 1.5.4 section: beads issue creation instructions with priority mapping and dependency creation in sdd/skills/implement/SKILL.md
- [X] T008 Write Phase 1.5.5 section: bootstrap summary and DAG verification via `bd dep tree` in sdd/skills/implement/SKILL.md
- [X] T009 Write Phase 2 Path B section: beads-driven execution loop (bd ready, implement, bd close, loop) in sdd/skills/implement/SKILL.md
- [X] T010 Write handling for pre-checked tasks: instructions to create already-closed beads issues for tasks marked `[X]` in sdd/skills/implement/SKILL.md

**Checkpoint:** The SKILL.md should now contain complete instructions for first-run beads implementation flow (FR-001 through FR-009).

## Phase 4: User Story 2 - Multi-Session Resume

- [X] T011 Write Phase 1.5.2 section: resume detection logic (check .beads/, bd list, title matching, 50% threshold) in sdd/skills/implement/SKILL.md
- [X] T012 Write skip-conversion logic: when resume is detected, proceed directly to bd ready loop in sdd/skills/implement/SKILL.md
- [X] T013 Write handling for stale beads issues: instructions when match ratio is low (create alongside, report) in sdd/skills/implement/SKILL.md

**Checkpoint:** The SKILL.md should now handle both first-run and resume scenarios (FR-010, FR-011).

## Phase 5: User Story 4 - Sync-Back to tasks.md

- [X] T014 Write Phase 2.5 section: sync-back logic (bd list, match task IDs, update checkboxes, preserve structure) in sdd/skills/implement/SKILL.md
- [X] T015 Write discovered tasks append logic: detect non-matching issues, append under `## Discovered During Implementation` section in sdd/skills/implement/SKILL.md
- [X] T016 Write sync-back error handling: file write failure fallback (print to stdout) in sdd/skills/implement/SKILL.md
- [X] T028 Write bd sync step at end of Phase 2.5: run `bd sync` after tasks.md update to persist state to JSONL for resume detection in sdd/skills/implement/SKILL.md

**Checkpoint:** After implementation, tasks.md accurately reflects beads state and beads JSONL is synced (FR-013 through FR-015, FR-019).

## Phase 6: User Story 3 - Discovered Work

- [X] T017 Write discovered work instructions in Phase 2 Path B: when to create new beads issues, bd create parameters, dependency linking in sdd/skills/implement/SKILL.md

**Checkpoint:** Agent has clear instructions for tracking discovered work during implementation (FR-012).

## Phase 7: Error Handling and Edge Cases

- [X] T018 Write error handling section: bd CLI not found, bd create failure, bd close failure, bd ready failure, circular dependency detection in sdd/skills/implement/SKILL.md
- [X] T019 Write circular dependency detection and resolution flow: bd list open issues, show dependency chains, ask user in sdd/skills/implement/SKILL.md
- [X] T020 Write tasks.md parse error handling: line-level error reporting with recovery suggestion in sdd/skills/implement/SKILL.md

**Checkpoint:** All edge cases from spec are handled with actionable error messages.

## Phase 8: Polish and Integration

- [X] T021 Update the "When to Use" section to mention `--with-beads` option in sdd/skills/implement/SKILL.md
- [X] T022 Update the Three-Phase Process diagram to show the conditional Path A/B and new phases (1.5, 2.5) in sdd/skills/implement/SKILL.md
- [X] T023 Update the Checklist section to include beads-specific checklist items in sdd/skills/implement/SKILL.md
- [X] T024 Update the Integration section to document beads CLI as an external dependency in sdd/skills/implement/SKILL.md
- [X] T025 Review that the existing Error Handling section references the beads error cases written in T018 (no new content, integration check only) in sdd/skills/implement/SKILL.md
- [X] T026 Review the complete modified SKILL.md for consistency, correct ordering, and no contradictions between Path A and Path B
- [X] T027 Verify the modified SKILL.md against all 17 functional requirements (FR-001 through FR-017) and all 5 success criteria (SC-001 through SC-005)
