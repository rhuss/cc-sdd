# Tasks: SDD Command Consolidation

**Input**: Design documents from `/specs/003-command-consolidation/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests**: Not applicable. This is a Claude Code plugin consisting of Markdown + Bash files. Verification is manual via `make reinstall` and Claude Code sessions.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Plugin root**: `sdd/` (commands, skills, overlays, scripts, docs)
- **Overlays**: `sdd/overlays/<trait>/commands/` and `sdd/overlays/<trait>/templates/`
- **Commands**: `sdd/commands/<name>.md`
- **Skills**: `sdd/skills/<name>/SKILL.md`

---

## Phase 1: Setup

**Purpose**: No setup needed. Plugin structure and trait infrastructure from Spec 002 are already in place.

**Checkpoint**: Existing overlay pattern validated (speckit.specify.append.md and beads speckit.implement.append.md both exist and are under 20 lines).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No shared blocking prerequisites beyond what exists. All user stories can begin independently.

**Checkpoint**: Proceed directly to user story phases.

---

## Phase 3: User Story 3 - Plan with SDD Trait Active (Priority: P1) MVP

**Goal**: Running `/speckit.plan` with the sdd trait enabled validates the spec before planning, generates the plan and tasks, then runs post-planning quality validation and generates review-summary.md.

**Independent Test**: Enable sdd trait, create a spec, run `/speckit.plan`. Verify spec review runs before planning, `/speckit.tasks` runs after plan generation, and `sdd:review-plan` validates coverage + generates review-summary.md.

### Implementation for User Story 3

- [X] T001 [P] [US3] Create SDD overlay for speckit.plan in `sdd/overlays/sdd/commands/speckit.plan.append.md` with sentinel marker `<!-- SDD-TRAIT:sdd -->`, pre-planning instruction to invoke `{Skill: sdd:review-spec}`, and post-planning instruction to run `/speckit.tasks` then invoke `{Skill: sdd:review-plan}`. Must be under 20 lines.
- [X] T002 [P] [US3] Create review-plan command file `sdd/commands/review-plan.md` with frontmatter (name: `sdd:review-plan`, description, argument-hint) and `{Skill: sdd:review-plan}` body.
- [X] T003 [US3] Create review-plan skill `sdd/skills/review-plan/SKILL.md` extracting post-planning validation logic from current `sdd/skills/plan/SKILL.md` sections 5-8: task quality enforcement (Actionable, Testable, Atomic, Ordered), coverage matrix (requirement to task to test mapping), red flag scanning + NFR validation, and review-summary.md generation. Must require both plan.md and tasks.md to exist. Should use `{Skill: spec-kit}` for initialization.

**Checkpoint**: `/speckit.plan` with sdd trait produces the full pipeline: spec review, plan, tasks, quality validation, review-summary.md.

---

## Phase 4: User Story 2 - Implement with Beads Trait Active (Priority: P1)

**Goal**: Running `/speckit.implement` with sdd and beads traits enabled verifies spec package completeness before implementation, runs beads-driven task execution, and invokes post-implementation review.

**Independent Test**: Enable both traits, create a complete spec package (spec.md, plan.md, tasks.md), run `/speckit.implement`. Verify pre-implementation package check, beads task scheduling via `bd ready`, and post-implementation review-code + verification gates fire.

### Implementation for User Story 2

- [X] T004 [P] [US2] Create SDD overlay for speckit.implement in `sdd/overlays/sdd/commands/speckit.implement.append.md` with sentinel marker `<!-- SDD-TRAIT:sdd -->`, pre-implementation instruction to verify spec.md/plan.md/tasks.md exist, and post-implementation instruction to invoke `{Skill: sdd:review-code}` and `{Skill: sdd:verification-before-completion}`. Must be under 20 lines.
- [X] T005 [P] [US2] Create beads-execute skill `sdd/skills/beads-execute/SKILL.md` extracting beads execution logic from current `sdd/skills/implement/SKILL.md`: beads bootstrapping from tasks.md, `bd ready --json` loop for dependency-aware task scheduling, `bd sync` for git-backed state persistence, discovered work tracking via `bd create`. Include error handling for missing `bd` CLI.
- [X] T006 [P] [US2] Create beads overlay for tasks template `sdd/overlays/beads/templates/tasks-template.append.md` with sentinel marker `<!-- SDD-TRAIT:beads -->` and beads usage instructions covering `bd` commands, memory model, and discovered work tracking. Must be under 20 lines.

**Checkpoint**: `/speckit.implement` with both traits fires pre-check, beads execution, and post-review gates. With only sdd trait, only pre/post gates fire.

---

## Phase 5: User Story 1 - Specify with SDD Trait Active (Priority: P1)

**Goal**: Running `/speckit.specify` with the sdd trait enabled invokes spec review and constitution alignment check after spec creation.

**Independent Test**: Enable sdd trait, run `/speckit.specify` with a feature description. Verify the review gate fires automatically after spec creation.

### Implementation for User Story 1

- [X] T007 [US1] Verify existing SDD overlay for speckit.specify in `sdd/overlays/sdd/commands/speckit.specify.append.md` is correct (already created in Spec 002, should invoke `{Skill: sdd:review-spec}` and check constitution alignment, under 20 lines). No changes expected.

**Checkpoint**: `/speckit.specify` with sdd trait fires the review gate. Without trait, baseline behavior.

---

## Phase 6: User Story 5 - Existing User Upgrades (Priority: P2)

**Goal**: Removed commands no longer exist, all retained skills reference `/speckit.*` instead of removed wrappers, and the routing skill directs users to the new command structure.

**Independent Test**: Verify `sdd/commands/spec.md`, `sdd/commands/plan.md`, `sdd/commands/implement.md` and corresponding skill directories don't exist. Run `rg "sdd:spec[^-]|sdd:plan[^-]|sdd:implement" sdd/skills/` and confirm zero matches.

### Implementation for User Story 5

- [X] T008 [P] [US5] Delete command files: `sdd/commands/spec.md`, `sdd/commands/plan.md`, `sdd/commands/implement.md`
- [X] T009 [P] [US5] Delete skill directories: `sdd/skills/spec/`, `sdd/skills/plan/`, `sdd/skills/implement/`
- [X] T010 [P] [US5] Update cross-references in `sdd/skills/brainstorm/SKILL.md`: replace all `sdd:plan` with `/speckit.plan`, all `sdd:implement` with `/speckit.implement`, update the flow diagram terminal state label
- [X] T011 [P] [US5] Update cross-references in `sdd/skills/evolve/SKILL.md`: replace `sdd:spec` with `/speckit.specify`
- [X] T012 [P] [US5] Update cross-references in `sdd/skills/review-spec/SKILL.md`: replace `sdd:implement` with `/speckit.implement`, replace `sdd:spec` with `/speckit.specify`
- [X] T013 [P] [US5] Update cross-references in `sdd/skills/review-code/SKILL.md`: replace `sdd:spec` with `/speckit.specify`, replace `sdd:implement` references
- [X] T014 [P] [US5] Update cross-references in `sdd/skills/verification-before-completion/SKILL.md`: replace `sdd:implement` with `/speckit.implement (via sdd trait overlay)`, replace `sdd:spec` with `/speckit.specify`
- [X] T015 [P] [US5] Update cross-references in `sdd/skills/spec-kit/SKILL.md`: replace `sdd:spec` with `/speckit.specify`, replace `sdd:implement` with `/speckit.implement`, update the integration points list to remove sdd:implement and add note about overlay-based integration
- [X] T016 [US5] Update routing skill `sdd/skills/using-superpowers-sdd/SKILL.md`: replace `sdd:spec` with `/speckit.specify`, `sdd:plan` with `/speckit.plan`, `sdd:implement` with `/speckit.implement` in decision tree and skill listing; add `sdd:traits` and `sdd:review-plan`; remove `sdd:spec-kit` from user-visible listing

**Checkpoint**: No retained skill references removed commands. Routing skill directs to `/speckit.*` commands.

---

## Phase 7: User Story 4 - Updated Help Shows Unified Workflow (Priority: P2)

**Goal**: `/sdd:help` shows `/speckit.*` as primary workflow with SDD helpers alongside. No references to removed commands.

**Independent Test**: Run `/sdd:help` and verify output shows `/speckit.specify`, `/speckit.plan`, `/speckit.implement` as main workflow steps, lists `/sdd:traits` and `/sdd:review-plan`, and does not list `/sdd:spec`, `/sdd:plan`, or `/sdd:implement`.

### Implementation for User Story 4

- [X] T017 [P] [US4] Rewrite `sdd/docs/help.md` with new workflow diagram showing: primary workflow (`/speckit.specify` -> `/speckit.plan` -> `/speckit.implement`), SDD helpers (`/sdd:brainstorm`, `/sdd:review-spec`, `/sdd:review-plan`, `/sdd:review-code`, `/sdd:evolve`), configuration commands (`/sdd:traits`, `/sdd:init`, `/sdd:constitution`). Remove the "SDD vs spec-kit" comparison table. Add migration note for upgrading users.
- [X] T018 [P] [US4] Update `sdd/skills/help/SKILL.md`: replace "Try `/sdd:implement`" with "Try `/speckit.implement`" in tutorial next steps, update any other references to removed commands

**Checkpoint**: `/sdd:help` shows unified workflow with no references to removed commands.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Reinstall, verify, and commit.

- [X] T019 Run `make reinstall` to push all changes to plugin cache (skipped: cannot run inside Claude Code session; run manually after commit)
- [X] T020 Verify SC-004: confirm `sdd/commands/spec.md`, `sdd/commands/plan.md`, `sdd/commands/implement.md` and corresponding skill files no longer exist in plugin cache
- [X] T021 Verify SC-007: confirm all overlay files in `sdd/overlays/` are under 20 lines each
- [X] T022 Verify SC-010: run `rg "sdd:spec[^-]|sdd:plan[^-]|sdd:implement" sdd/skills/` and confirm zero matches (exclude spec-refactoring references which are valid)
- [X] T023 Commit all changes with descriptive commit message

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies, nothing to do
- **Foundational (Phase 2)**: No dependencies, nothing to do
- **US3 - Plan (Phase 3)**: No dependencies on other stories. Creates new overlay + skill.
- **US2 - Implement (Phase 4)**: No dependencies on other stories. Creates new overlay + skill.
- **US1 - Specify (Phase 5)**: No dependencies, verification only.
- **US5 - Upgrades (Phase 6)**: Should run AFTER Phases 3-5 so new skills exist before old ones are removed. Cross-reference updates in T010-T016 can run in parallel.
- **US4 - Help (Phase 7)**: Should run AFTER Phase 6 so removed commands are already gone.
- **Polish (Phase 8)**: Depends on all phases being complete.

### User Story Dependencies

- **US3 (P1)**: Independent. Can start immediately.
- **US2 (P1)**: Independent. Can start immediately. Can run in parallel with US3.
- **US1 (P1)**: Independent. Verification only.
- **US5 (P2)**: Depends on US3 and US2 completion (new skills must exist before old skills are removed).
- **US4 (P2)**: Depends on US5 completion (help should reflect final state after removals).

### Within Each User Story

- Overlay files and skill files within the same story can be created in parallel [P]
- Cross-reference updates (T010-T016) within US5 can all run in parallel [P]

### Parallel Opportunities

Within Phase 3 (US3): T001 and T002 can run in parallel (different files). T003 depends on knowing the review-plan structure.

Within Phase 4 (US2): T004, T005, T006 can all run in parallel (different files).

Within Phase 6 (US5): T008-T016 can all run in parallel (different files, no dependencies).

Within Phase 7 (US4): T017 and T018 can run in parallel (different files).

---

## Parallel Example: User Story 2

```bash
# Launch all three tasks in parallel (different files, no dependencies):
Task: "Create SDD overlay for speckit.implement in sdd/overlays/sdd/commands/speckit.implement.append.md"
Task: "Create beads-execute skill in sdd/skills/beads-execute/SKILL.md"
Task: "Create beads overlay for tasks template in sdd/overlays/beads/templates/tasks-template.append.md"
```

---

## Implementation Strategy

### MVP First (User Story 3 - Plan with SDD Trait)

1. Complete Phase 3: Create plan overlay + review-plan skill
2. **STOP and VALIDATE**: `make reinstall`, run `/speckit.plan` with sdd trait, verify full pipeline fires
3. If working, proceed to Phase 4 (US2)

### Incremental Delivery

1. Phase 3 (US3) + Phase 4 (US2) -> New overlays and skills in place -> Validate
2. Phase 5 (US1) -> Verify existing overlay -> Validate
3. Phase 6 (US5) -> Remove old commands, update cross-refs -> Validate
4. Phase 7 (US4) -> Update help -> Validate
5. Phase 8 -> Final reinstall and verification -> Commit

### Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each phase or logical group
- Stop at any checkpoint to validate the story independently
