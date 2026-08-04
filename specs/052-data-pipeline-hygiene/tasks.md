# Tasks: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Feature**: 052-data-pipeline-hygiene
**Generated**: 2026-08-04
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Setup

- [ ] T001 Create preset directory at `spex/extensions/spex-gates/presets/`

## Phase 2: Foundational

- [ ] T002 Read `spex/extensions/spex-gates/extension.yml` and register the new `speckit.spex-gates.data-checklist` command entry

## Phase 3: User Story 1 - Data-Pipeline Checklist Command (P1)

**Goal**: Provide a `/speckit-spex-gates-data-checklist` command that generates a domain-specific checklist from a preset file.

**Independent Test**: Run the command on any feature spec and verify a `data-pipeline.md` checklist is generated with at least 15 items across six categories.

- [ ] T003 [P] [US1] Create built-in preset file at `spex/extensions/spex-gates/presets/data-pipeline.md` with checklist items for all six hygiene categories: lineage docstrings, row count logging, fan-out checks, schema assertions, output conventions, and visualization standards. Each item MUST follow the "unit tests for English" pattern with category tags ([Completeness], [Clarity], [Consistency], [Coverage], [Gap]).
- [ ] T004 [US1] Create command file at `spex/extensions/spex-gates/commands/speckit.spex-gates.data-checklist.md` implementing the checklist generation command. The command MUST: (1) run `check-prerequisites.sh --json --paths-only` to resolve FEATURE_DIR and FEATURE_SPEC, (2) check for project-level preset at `.specify/checklists/presets/data-pipeline.md`, (3) fall back to built-in preset at `spex/extensions/spex-gates/presets/data-pipeline.md`, (4) read the spec to contextualize items (gap-detection framing when spec content is missing for a category), (5) write checklist to `FEATURE_DIR/checklists/data-pipeline.md`, (6) report output path and item count.

## Phase 4: User Story 2 - Constants Drift Check in Review-Code (P2)

**Goal**: The review-code gate detects when spec-declared constants diverge from code implementations.

**Independent Test**: Write a spec with a `## Constants` section, implement code with mismatched values, run review-code, and verify drift findings are reported.

- [ ] T005 [US2] Read the existing review-code gate at `spex/extensions/spex-gates/commands/speckit.spex-gates.review-code.md` and identify the insertion point for the constants drift check section (after existing compliance checks, before deep review trigger)
- [ ] T006 [US2] Add a "Spec-Declared Constants Check" section to `spex/extensions/spex-gates/commands/speckit.spex-gates.review-code.md`. The section MUST: (1) parse the spec for a `## Constants` section, (2) extract constant names and values using the two supported bullet formats (`- NAME = value` and `- NAME: value`), (3) skip silently if no `## Constants` section exists, (4) for each constant, search the codebase for definitions matching the constant name, (5) report findings for: value mismatches (spec value vs code value with file path), constants spread across multiple files (consolidation recommendation), constants declared in spec but not found in code, (6) skip unparseable entries with a warning listing the lines

## Phase 5: User Story 3 - Project-Level Preset Override (P3)

**Goal**: Allow project-level preset overrides that fully replace built-in presets.

**Independent Test**: Place a custom preset at `.specify/checklists/presets/data-pipeline.md`, run the command, verify custom items appear.

- [ ] T007 [US3] Update the command in `spex/extensions/spex-gates/commands/speckit.spex-gates.data-checklist.md` to check for project-level preset at `.specify/checklists/presets/data-pipeline.md` before falling back to built-in. Project preset MUST fully replace built-in (no merging). Add error handling for missing built-in preset.

## Phase 6: User Story 4 - Upstream Preset Proposal (P4)

**Goal**: Create an upstream issue proposing a native preset system for speckit-checklist.

**Independent Test**: Verify the issue exists and describes the two-level preset mechanism.

- [ ] T008 [US4] Draft upstream issue content for spec-kit repository proposing a native preset system for `/speckit-checklist`. Content MUST include: (1) problem statement (domain-specific checklist items are re-typed each time), (2) proposed solution (two-level preset system: built-in at `presets/{name}.md` + project override at `.specify/checklists/presets/{name}.md`), (3) preset loading logic (project > built-in, full replacement, no merging), (4) migration path from the spex-gates extension command, (5) reference to this feature as the motivating use case. Save draft to `specs/052-data-pipeline-hygiene/upstream-preset-proposal.md` for user review before submission.

## Phase 7: Polish & Documentation

- [ ] T009 Update `spex/docs/help.md` to add the new `/speckit-spex-gates-data-checklist` command and the constants drift check behavior in review-code
- [ ] T010 Update `README.md` Commands Reference table to include the new command

## Dependencies

```
T001 → T003 (preset dir must exist before preset file)
T002 → T004 (extension registration before command file)
T003 → T004 (preset file exists before command references it)
T005 → T006 (read existing gate before modifying it)
T004 → T007 (base command before override logic)
T006 (independent, can run in parallel with T003-T004)
T008 (independent, documentation only)
T009, T010 (after T004 and T006 complete)
```

## Parallel Execution

- **T003 and T005** can run in parallel (preset file and reading review-code are independent)
- **T008** can run in parallel with any other task (documentation only)
- **T009 and T010** can run in parallel (different documentation files)

## Implementation Strategy

**MVP (User Story 1 only)**: T001 → T002 → T003 → T004. Delivers the core checklist command with built-in preset.

**Incremental delivery**:
1. MVP: Checklist command (T001-T004)
2. Constants drift check (T005-T006)
3. Project-level override (T007)
4. Upstream proposal + docs (T008-T010)
