# Tasks: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Feature**: 052-data-pipeline-hygiene
**Generated**: 2026-08-04
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Setup & Registration

- [ ] T001 Read `spex/extensions/spex-gates/extension.yml` and register the new `speckit.spex-gates.data-checklist` command entry pointing to `commands/speckit.spex-gates.data-checklist.md`

## Phase 2: User Story 1 - Data-Pipeline Checklist Command (P1)

**Goal**: Provide a `/speckit-spex-gates-data-checklist` command that generates a domain-specific checklist from a preset file.

**Independent Test**: Run the command on any feature spec and verify a `data-pipeline.md` checklist is generated with at least 15 items across six categories.

**Interfaces**:
- T002 produces: `spex/extensions/spex-gates/presets/data-pipeline.md` (markdown file with checklist items grouped by category, each item prefixed with `- [ ]` and a category tag like `[Completeness]`)
- T003 consumes: the preset file at the path above; the resolved `FEATURE_DIR` and `FEATURE_SPEC` from `check-prerequisites.sh --json --paths-only`

- [ ] T002 [P] [US1] Create the `spex/extensions/spex-gates/presets/` directory and add the built-in preset file `spex/extensions/spex-gates/presets/data-pipeline.md` with checklist items for all six hygiene categories: lineage docstrings, row count logging, fan-out checks, schema assertions, output conventions, and visualization standards. Each item MUST follow the "unit tests for English" pattern with category tags ([Completeness], [Clarity], [Consistency], [Coverage], [Gap]). The preset MUST contain at least 15 items total.
- [ ] T003 [US1] Create command file at `spex/extensions/spex-gates/commands/speckit.spex-gates.data-checklist.md` implementing the checklist generation command. The command MUST: (1) run `check-prerequisites.sh --json --paths-only` to resolve FEATURE_DIR and FEATURE_SPEC (exit with clear error explaining the command must be run from a feature branch if resolution fails), (2) load the built-in preset from `spex/extensions/spex-gates/presets/data-pipeline.md` (exit with error referencing the expected path and suggesting `spex:init` to reinstall extensions if the file is missing), (3) read the spec to contextualize items (gap-detection framing when spec content is missing for a category), (4) create `FEATURE_DIR/checklists/` directory if it does not exist (exit with filesystem error rather than silently failing if creation fails), (5) write checklist to `FEATURE_DIR/checklists/data-pipeline.md`, (6) report output path and item count.

## Phase 3: User Story 2 - Constants Drift Check in Review-Code (P2)

**Goal**: The review-code gate detects when spec-declared constants diverge from code implementations.

**Independent Test**: Write a spec with a `## Constants` section, implement code with mismatched values, run review-code, and verify drift findings are reported.

- [ ] T004 [US2] Read the existing review-code gate at `spex/extensions/spex-gates/commands/speckit.spex-gates.review-code.md`, identify the insertion point (after existing compliance checks, before deep review trigger), and add a "Spec-Declared Constants Check" section. The section MUST: (1) parse the spec for a `## Constants` section, (2) extract constant names and values using the two supported bullet formats (`- NAME = value` and `- NAME: value`), (3) skip silently if no `## Constants` section exists (zero false positives), (4) for each constant, search the codebase for definitions matching the constant name, (5) report findings for: value mismatches (spec value vs code value with file path), constants spread across multiple files (consolidation recommendation), constants declared in spec but not found in code, (6) skip unparseable entries with a warning listing the lines. Constant values (including threshold expressions like ">5%") MUST be compared as strings, not parsed numerically.

## Phase 4: User Story 3 - Project-Level Preset Override (P3)

**Goal**: Allow project-level preset overrides that fully replace built-in presets.

**Independent Test**: Place a custom preset at `.specify/checklists/presets/data-pipeline.md`, run the command, verify custom items appear instead of built-in items.

- [ ] T005 [US3] Update the command in `spex/extensions/spex-gates/commands/speckit.spex-gates.data-checklist.md` to check for a project-level preset at `.specify/checklists/presets/data-pipeline.md` before loading the built-in preset. If the project-level preset exists, use it instead of the built-in preset. Project preset MUST fully replace built-in (no merging or deduplication).

## Phase 5: User Story 4 - Upstream Preset Proposal (P4)

**Goal**: Create an upstream issue proposing a native preset system for speckit-checklist.

**Independent Test**: Verify the draft exists and describes the two-level preset mechanism.

- [ ] T006 [US4] Draft upstream issue content for spec-kit repository proposing a native preset system for `/speckit-checklist`. Content MUST include: (1) problem statement (domain-specific checklist items are re-typed each time), (2) proposed solution (two-level preset system: built-in at `presets/{name}.md` + project override at `.specify/checklists/presets/{name}.md`), (3) preset loading logic (project > built-in, full replacement, no merging), (4) migration path from the spex-gates extension command, (5) reference to this feature as the motivating use case. Save draft to `specs/052-data-pipeline-hygiene/upstream-preset-proposal.md` for user review before submission.

## Phase 6: Polish & Documentation

- [ ] T007 Update `spex/docs/help.md` to add the new `/speckit-spex-gates-data-checklist` command and the constants drift check behavior in review-code
- [ ] T008 Update `README.md` Commands Reference table to include the new command

## Dependencies

```
T001 → T002 (extension registration before preset file)
T002 → T003 (preset file exists before command references it)
T001 → T003 (extension registration before command file)
T003 → T005 (base command before override logic)
T004 (can run in parallel with T002-T003, independent of checklist work)
T006 (independent, documentation only)
T007, T008 (after T003 and T004 complete)
```

## Parallel Execution

- **T002 and T004** can run in parallel (preset file creation and review-code modification are independent)
- **T006** can run in parallel with any other task (documentation only)
- **T007 and T008** can run in parallel (different documentation files)

## Implementation Strategy

**MVP (User Story 1 only)**: T001 → T002 → T003. Delivers the core checklist command with built-in preset.

**Incremental delivery**:
1. MVP: Checklist command (T001-T003)
2. Constants drift check (T004)
3. Project-level override (T005)
4. Upstream proposal + docs (T006-T008)
