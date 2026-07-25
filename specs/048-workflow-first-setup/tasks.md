# Tasks: Workflow-First Spex Setup

**Input**: Design documents from `/specs/048-workflow-first-setup/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Contract and integration tests are required by SC-002 through SC-005 and are written before implementation.

## Phase 1: Setup

**Purpose**: Establish the configuration contract and focused test entry points.

- [x] T001 Add valid and invalid Spex project configuration fixtures under `tests/fixtures/setup-profile/`
- [x] T002 [P] Add `test-setup-profile` and `test-generated-trees` targets to `Makefile`
- [x] T003 [P] Add the project configuration schema validation case to `tests/test_setup_profile.py`

---

## Phase 2: Foundational Profile Contract

**Purpose**: Define the read-only resolution and failure-atomic persistence behavior used by all setup stories.

- [x] T004 Add failing tests for defaults, stored intent, explicit precedence, normalization, dependency closure, requested-security vocabulary, and invalid values in `tests/test_setup_profile.py`
- [x] T005 Add failing tests for atomic persistence, byte-identical failure behavior, and legacy-input migration in `tests/test_setup_profile.py`
- [x] T006 Implement validation, resolution, dependency closure, and JSON output in `spex/scripts/spex-setup-profile.py`
- [x] T007 Implement same-directory atomic persistence and migration in `spex/scripts/spex-setup-profile.py`

**Checkpoint**: The profile utility independently satisfies the configuration contract without invoking a workflow or harness adapter.

---

## Phase 3: User Story 1 - Repeat Setup from Project Configuration (Priority: P1) 🎯 MVP

**Goal**: A committed project declaration drives repeatable, non-interactive refresh.

**Independent Test**: Run setup twice in a disposable repository and verify the second run reuses a byte-identical declaration without selection prompts.

- [x] T008 [US1] Add a failing configured-refresh journey to `tests/test_workflow_setup.sh`
- [x] T009 [US1] Resolve empty workflow inputs from `.specify/spex.json` before harness detection and extension selection in `spex/setup.yml`
- [x] T010 [US1] Persist the validated normalized request once after selection and before harness-specific generation in `spex/setup.yml`

**Checkpoint**: Stored non-default intent survives a prompt-free refresh.

---

## Phase 4: User Story 2 - Bootstrap Configuration Interactively (Priority: P1)

**Goal**: First setup presents all choices and converges onto the same durable declaration.

**Independent Test**: Supply simulated prompt responses in a clean repository and verify a subsequent non-interactive refresh reproduces them.

- [x] T011 [US2] Add failing first-run default, non-default, and rejected-selection journeys to `tests/test_workflow_setup.sh`
- [x] T012 [US2] Update extension selection to expose recommended and optional choices and emit a normalized selection from `spex/setup.yml`
- [x] T013 [US2] Add requested Safe, Autonomous, and YOLO selection with Safe recommended in `spex/setup.yml`
- [x] T014 [US2] Ensure failed validation leaves `.specify/spex.json` absent or byte-identical in `spex/setup.yml`

**Checkpoint**: Interactive and scripted setup produce the same declaration and refresh behavior.

---

## Phase 5: User Story 3 - Preserve Canonical Source Ownership (Priority: P1)

**Goal**: Generated harness trees remain disposable and cannot silently become maintained copies.

**Independent Test**: Verify ignore behavior in a temporary repository and verify a force-tracked generated skill fails the guard.

- [x] T015 [US3] Add failing ignore and force-tracked generated-tree cases to `tests/test_generated_trees.sh`
- [x] T016 [US3] Extend repository and generated setup ignore rules for `.agents/`, `.codex/`, `.claude/`, and the `.specify/spex.json` exception in `.gitignore` and `spex/setup.yml`
- [x] T017 [US3] Implement the maintained-source allowlist and tracked-generated-tree rejection in `tests/test_generated_trees.sh`
- [x] T018 [US3] Run the generated-tree guard in `.github/workflows/test.yml`

**Checkpoint**: Generated trees are ignored by default, force-tracked copies fail CI, and maintained descriptors remain allowed.

---

## Phase 6: User Story 4 - Develop Claude Directly from Source (Priority: P2)

**Goal**: Claude development stays source-transparent and independent of optional packaging.

**Independent Test**: The existing local Claude install journey passes without invoking any materialization target.

- [x] T019 [US4] Add an assertion to `tests/test_workflow_setup.sh` that the Claude setup journey uses canonical source paths and creates no staged distribution
- [x] T020 [US4] Document the direct Claude development path and workflow-first user path in `README.md`

**Checkpoint**: Claude source installation remains the documented and tested development workflow.

---

## Phase 7: Polish and Verification

- [x] T021 [P] Document `.specify/spex.json`, precedence, defaults, and migration in `README.md`
- [x] T022 [P] Validate `specs/048-workflow-first-setup/contracts/spex-project-config.schema.json` against its metaschema
- [x] T023 Run `make test-setup-profile`, `make test-generated-trees`, the workflow setup journey, and the existing Claude marketplace installation test
- [x] T024 Run `git diff --check` and verify the PR contains no Codex hook, plugin packaging, state/recovery, progress, Teams, or OpenCode production changes

---

## Dependencies and Execution Order

- Phase 1 precedes the profile contract.
- Phase 2 blocks both setup user stories.
- User Story 1 is the minimum viable increment and precedes the interactive bootstrap integration.
- User Story 3 is independent after Phase 1 and may be implemented alongside User Stories 1 and 2.
- User Story 4 depends only on the final setup path and can be validated after User Story 1.
- Polish and verification follow all selected stories.

## Parallel Opportunities

- T002 and T003 touch independent build and test files.
- T015–T018 can proceed independently from workflow integration after test targets exist.
- T020–T022 are independent documentation and contract checks after behavior stabilizes.

## Implementation Strategy

Deliver the profile utility and non-interactive configured refresh first. Add interactive convergence second, generated-tree enforcement in parallel, and finish with source-transparency validation. Do not import unrelated feature-047 subsystems to satisfy this feature.
