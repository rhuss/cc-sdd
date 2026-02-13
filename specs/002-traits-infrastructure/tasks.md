# Tasks: SDD Traits Infrastructure

**Input**: Design documents from `/specs/002-traits-infrastructure/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests**: No test tasks generated (not requested in spec). Verification is manual via script execution and file content inspection.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Create the overlay directory structure and placeholder files

- [ ] T001 Create overlay directory structure at `sdd/overlays/sdd/commands/` and `sdd/overlays/beads/commands/`
- [ ] T002 [P] Create placeholder overlay file `sdd/overlays/sdd/commands/speckit.specify.append.md` with sentinel marker `<!-- SDD-TRAIT:sdd -->`, a placeholder comment noting content comes from Spec B, and a `{Skill: sdd:review-spec}` delegation reference
- [ ] T003 [P] Create placeholder overlay file `sdd/overlays/beads/commands/speckit.implement.append.md` with sentinel marker `<!-- SDD-TRAIT:beads -->`, a placeholder comment noting content comes from Spec B, and a `{Skill: sdd:beads-execute}` delegation reference

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create `apply-traits.sh`, the core patching script that all user stories depend on

- [ ] T004 Create `sdd/scripts/apply-traits.sh` with the following behavior: (a) derive plugin root from script location via `$(dirname "$0")/..`, (b) validate `.specify/sdd-traits.json` exists and contains valid JSON using `jq`, (c) for each enabled trait, find overlay files in `sdd/overlays/<trait>/`, (d) for each overlay, derive target path per FR-013 mapping (`commands/<name>.append.md` -> `.claude/commands/<name>.md`, `templates/<name>.append.md` -> `.specify/templates/<name>.md`), (e) check sentinel marker `<!-- SDD-TRAIT:<trait> -->` in target file via `grep -q`, (f) if sentinel not found, append overlay content to target file with newline separator, (g) if sentinel found, skip (idempotent), (h) exit 0 on success, exit 1 on validation errors with messages to stderr
- [ ] T005 Make `sdd/scripts/apply-traits.sh` executable with `chmod +x`

**Checkpoint**: `apply-traits.sh` works standalone. Can manually create `.specify/sdd-traits.json` and run the script to verify overlays are appended with sentinels, and that running twice produces identical output.

---

## Phase 3: User Story 1 - First-Time Setup with Trait Selection (Priority: P1)

**Goal**: When a user runs `/sdd:init` for the first time, they select traits and overlays are applied automatically.

**Independent Test**: Run `/sdd:init` in a fresh project with spec-kit installed. Verify `.specify/sdd-traits.json` is created and overlay content appears in targeted spec-kit files.

### Implementation for User Story 1

- [ ] T006 [US1] Modify `sdd/skills/init/SKILL.md` to add trait selection after the script reports READY. Add a new section "## Trait Configuration" that instructs: (1) check if `.specify/sdd-traits.json` exists, (2) if not, use `AskUserQuestion` with multiSelect to ask which traits to enable (options: "sdd" with description "SDD quality gates on speckit commands", "beads" with description "Beads memory integration for task execution"), (3) write `.specify/sdd-traits.json` with schema `{"version": 1, "traits": {"sdd": <bool>, "beads": <bool>}, "applied_at": "<ISO8601>"}` using the Write tool, (4) invoke `apply-traits.sh` via Bash tool using the plugin root path
- [ ] T007 [US1] Modify `sdd/skills/init/SKILL.md` to handle re-init (FR-014): if `.specify/sdd-traits.json` already exists, read it, display current trait settings to the user, and use `AskUserQuestion` to ask whether to keep current settings or reconfigure. If reconfigure, prompt for new selections and rewrite the config, then invoke `apply-traits.sh`
- [ ] T008 [US1] Modify `sdd/scripts/sdd-init.sh` to call `apply-traits.sh` after `specify init` in `do_init` function: after the `check_ready` verification succeeds, add a conditional block that checks `[ -f .specify/sdd-traits.json ]` and if true, runs `"$(dirname "$0")/apply-traits.sh"` with a warning on failure but without blocking the init (non-fatal)

**Checkpoint**: Running `/sdd:init` in a fresh project prompts for trait selection, creates `.specify/sdd-traits.json`, and appends overlay content to spec-kit files. Running `/sdd:init` again shows current settings and offers to reconfigure.

---

## Phase 4: User Story 2 - Refresh/Update Reapplies Traits (Priority: P2)

**Goal**: After `specify init --force` wipes spec-kit files, `/sdd:init --refresh` reapplies trait overlays from saved config.

**Independent Test**: Enable traits, run `specify init --force`, then `/sdd:init --refresh`. Verify overlays are present in spec-kit files after refresh.

### Implementation for User Story 2

- [ ] T009 [US2] Modify `sdd/scripts/sdd-init.sh` `do_refresh` function: after `specify init --here --ai claude --force` and `fix_constitution`, add conditional `apply-traits.sh` call (same pattern as T008)
- [ ] T010 [US2] Modify `sdd/scripts/sdd-init.sh` `do_update` function: after `specify init --here --ai claude --force`, add conditional `apply-traits.sh` call (same pattern as T008)
- [ ] T011 [US2] Modify `sdd/scripts/sdd-init.sh` `check_ready` fast path: after `fix_constitution` and before `echo "READY"`, add conditional `apply-traits.sh` call (silent, suppress stdout) to ensure overlays are always applied on the fast path if config exists

**Checkpoint**: After `specify init --force` + `/sdd:init --refresh`, all previously enabled trait overlays are present in spec-kit files with sentinel markers.

---

## Phase 5: User Story 3 - Enable/Disable Traits Individually (Priority: P2)

**Goal**: Users can toggle individual traits with `/sdd:traits enable|disable <trait>`.

**Independent Test**: Run `/sdd:traits enable beads` with only sdd enabled. Verify config updated and beads overlays applied.

### Implementation for User Story 3

- [ ] T012 [US3] Create `sdd/commands/traits.md` command file with frontmatter (`name: sdd:traits`, `description: Manage SDD trait overlays - enable, disable, or list active traits`). The command body parses `$ARGUMENTS` for subcommand: (a) no args or "list" -> read and display `.specify/sdd-traits.json` status, or report no config and suggest `/sdd:init`, (b) "enable <trait>" -> validate trait name against known list [sdd, beads], read current config, set trait to true, write updated config with new `applied_at`, invoke `apply-traits.sh`, (c) "disable <trait>" -> warn about destructive side effect via `AskUserQuestion`, if confirmed: update config setting trait to false, run `specify init --here --ai claude --force`, then invoke `apply-traits.sh` to reapply only remaining enabled traits

**Checkpoint**: `/sdd:traits enable beads` adds beads overlays. `/sdd:traits disable beads` warns, confirms, resets files, and reapplies only sdd overlays.

---

## Phase 6: User Story 4 - List Active Traits (Priority: P3)

**Goal**: Users can check which traits are active with `/sdd:traits` or `/sdd:traits list`.

**Independent Test**: Run `/sdd:traits list` with traits configured. Verify output lists each trait and its status.

### Implementation for User Story 4

- [ ] T013 [US4] Verify the list functionality in `sdd/commands/traits.md` (created in T012) handles both cases: (a) config exists, displays formatted output like "sdd: enabled, beads: disabled", (b) no config exists, displays "No traits configured. Run /sdd:init to set up traits."

**Checkpoint**: `/sdd:traits list` accurately reflects `.specify/sdd-traits.json` state.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Verification and documentation

- [ ] T014 Verify idempotency: run `apply-traits.sh` twice and confirm file contents are identical (SC-002)
- [ ] T015 Verify update survival: enable traits, run `specify init --force`, run `apply-traits.sh`, confirm overlays present (SC-003)
- [ ] T016 Verify error handling: test with invalid JSON in `.specify/sdd-traits.json`, missing target files, and missing config file. Confirm appropriate error messages to stderr and non-zero exit codes
- [ ] T017 [P] Add `Bash(*/scripts/apply-traits.sh*)` to suggested auto-approval commands in init SKILL.md documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies, can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (overlay files must exist for testing)
- **User Story 1 (Phase 3)**: Depends on Phase 2 (`apply-traits.sh` must work)
- **User Story 2 (Phase 4)**: Depends on Phase 3 (init flow must work to create config)
- **User Story 3 (Phase 5)**: Depends on Phase 2 (`apply-traits.sh` must work). Can run in parallel with Phase 3.
- **User Story 4 (Phase 6)**: Depends on Phase 5 (list is part of traits command created in T012)
- **Polish (Phase 7)**: Depends on all user stories being complete

### Within Each User Story

- T006 before T007 (init flow before re-init flow)
- T008, T009, T010, T011 can be done in any order (independent `sdd-init.sh` modifications)
- T012 before T013 (create command before verifying list behavior)

### Parallel Opportunities

- T002 and T003 can run in parallel (independent overlay files)
- T009, T010, T011 can run in parallel (independent functions in sdd-init.sh)
- T014, T015, T016, T017 can run in parallel (independent verification tasks)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (overlay directory + placeholders)
2. Complete Phase 2: Foundational (`apply-traits.sh`)
3. Complete Phase 3: User Story 1 (init flow with trait selection)
4. **STOP and VALIDATE**: Test trait selection and overlay application independently
5. This delivers: users can select traits during init and overlays are applied

### Incremental Delivery

1. Setup + Foundational -> `apply-traits.sh` works standalone
2. Add User Story 1 -> Init prompts for traits, applies overlays (MVP)
3. Add User Story 2 -> Traits survive spec-kit updates
4. Add User Story 3 -> Individual trait enable/disable
5. Add User Story 4 -> List active traits
6. Each story adds value without breaking previous stories

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Overlay content is intentionally placeholder; real content comes from Spec B (003-command-consolidation)
