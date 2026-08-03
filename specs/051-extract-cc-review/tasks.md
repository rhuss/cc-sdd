# Tasks: Extract Review into Standalone cc-review Plugin

**Input**: Design documents from `/specs/051-extract-cc-review/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story. This feature spans two repositories: `rhuss/cc-review` (new) and `rhuss/cc-spex` (existing). Each task notes its target repository.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- **Repo markers**: `[cc-review]` for the new repo, `[cc-spex]` for changes to the existing repo

## Global Constraints

These constraints apply to ALL tasks implicitly:

- **Adapter size**: Every adapter file MUST be < 50 lines of content (SC-007)
- **Standalone independence**: cc-review core MUST NOT depend on spec-kit, `.specify/` paths, or cc-spex. All spec-kit references MUST be behind optional flags or adapter-only code.
- **Config resolution order**: CLI flags > project `.cc-review/config.yml` > user `~/.cc-review/config.yml` > built-in defaults
- **Platform**: GitHub is the primary platform. GitLab support is scaffolded (detection, function stubs) but not implemented in initial delivery.

---

## Phase 1: Setup (cc-review Repository)

**Purpose**: Create the cc-review repository structure and initialize the project

- [X] T001 [cc-review] Create repository `rhuss/cc-review` with MIT license and base README.md
- [X] T002 [cc-review] Create directory structure: `core/commands/`, `core/agents/`, `core/scripts/`, `core/schemas/`, `config/`, `adapters/claude-code/`, `adapters/speckit/`, `adapters/agents-md/`, `docs/`
- [X] T003 [P] [cc-review] Create `config/config-template.yml` with default configuration per data-model.md Configuration entity (external_tools, test_command, triage section, max_fix_rounds, output_dir)
- [X] T004 [P] [cc-review] Create `core/schemas/finding.schema.json` defining the Finding entity schema per data-model.md

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Shared infrastructure that all user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 [cc-review] Create config resolution script `core/scripts/resolve-config.sh` implementing the resolution order: CLI flags > project `.cc-review/config.yml` > user `~/.cc-review/config.yml` > built-in defaults (per research.md R-006). **Interfaces**: Source this script to get shell functions. `resolve_config <key> [default]` returns the resolved value on stdout. `resolve_config_file` returns the path to the resolved config file (or empty if none found). Exit 0 on success.
- [X] T006 [P] [cc-review] Create platform detection script `core/scripts/platform.sh` with functions that check git remote URL for github.com vs gitlab.com (per research.md R-007). **Interfaces**: Source this script. `detect_platform` prints `github` or `gitlab` on stdout, exits 1 if unrecognized. `fetch_pr_threads <pr_number>` outputs paginated JSON threads on stdout (GitHub implemented, GitLab returns error "not implemented"). `post_reply <pr_number> <comment_id> <body>` posts a reply comment. `resolve_thread <thread_id>` resolves a review thread. `check_ci <pr_number>` outputs CI status. GitHub implementations complete; GitLab stubs print "GitLab support not yet implemented" to stderr and exit 1.
- [X] T007 [P] [cc-review] Copy and adapt `sanitize-gh-json.py` from cc-spex `spex/extensions/spex-collab/scripts/sanitize-gh-json.py` to `core/scripts/sanitize-gh-json.py`, removing any spec-kit path references. **Interfaces**: Reads JSON from stdin, writes sanitized JSON to stdout. Strips control characters U+0000-U+001F from string values.
- [X] T008 [P] [cc-review] Create common agent preamble file `core/agents/preamble.md` by extracting the Common Preamble section (items 1-11) from the existing `speckit.spex-deep-review.run.md` command, replacing all `.specify/` path references with cc-review equivalents (`.cc-review/review-hints.md`). **Interfaces**: This file is included verbatim in every agent prompt. It contains the anti-sycophancy rules, confidence scoring thresholds, finding output schema, and optional review hints injection point.

**Checkpoint**: Core infrastructure ready, user story implementation can begin

---

## Phase 3: User Story 1 - Standalone PR Review (Priority: P1) MVP

**Goal**: A developer can install cc-review and run a multi-agent code review on their branch without spec-kit, cc-spex, or any spec files.

**Independent Test**: Install cc-review into a fresh project (no cc-spex). Run `/review` on a branch with changes. Verify 6 agents run, findings are reported, and no spec-kit errors occur.

### Implementation for User Story 1

- [X] T009 [P] [US1] [cc-review] Extract Agent 1 (Correctness) prompt to `core/agents/correctness.md` from existing deep-review command lines 946-1046
- [X] T010 [P] [US1] [cc-review] Extract Agent 2 (Architecture & Idioms) prompt to `core/agents/architecture.md` from existing deep-review command lines 1048-1096
- [X] T011 [P] [US1] [cc-review] Extract Agent 3 (Security) prompt to `core/agents/security.md` from existing deep-review command lines 1098-1142
- [X] T012 [P] [US1] [cc-review] Extract Agent 4 (Production Readiness) prompt to `core/agents/production.md` from existing deep-review command lines 1144-1199
- [X] T013 [P] [US1] [cc-review] Extract Agent 5 (Test Quality) prompt to `core/agents/test-quality.md` from existing deep-review command lines 1201-1271
- [X] T014 [P] [US1] [cc-review] Extract Agent 6 (Goal Alignment) prompt to `core/agents/goal-alignment.md` from existing deep-review command lines 1273-1340
- [X] T015 [US1] [cc-review] Create core review command `core/commands/review.md` with: frontmatter (name, description, argument-hint for `--pr <number>`, `--spec`, `--hints`, `--output`, `--no-fix`, `--no-external`, `--parallel`, `--sequential`), prerequisites section (config resolution via `core/scripts/resolve-config.sh`, review hints detection at `.cc-review/review-hints.md`), and Step 1 (changed file detection: when `--pr` is provided, use `gh pr diff <number>` to get the PR's changed files against its base branch; otherwise use `git diff --name-only` against main branch; exclude `specs/` and `brainstorm/` directories in both cases)
- [X] T015b [US1] [cc-review] Add agent dispatch to `core/commands/review.md`: Step 3 dispatching 6 review agents sequentially (read each agent's prompt from `core/agents/*.md`, prepend preamble from `core/agents/preamble.md`, include changed file contents and optional spec/hints). For each agent, collect findings in the Finding schema format. Include PR metadata fetching for Goal Alignment agent (skip if no PR found).
- [X] T015c [US1] [cc-review] Add finding merge, gate check, and output to `core/commands/review.md`: Step 5 (merge findings from all agents, deduplicate by file+line+category, keep higher severity/confidence, goal-alignment findings exempt from dedup), Step 6 (gate check: Critical + Important = 0 for PASS), Step 8 (write `review-findings.md` at `--output` path using the format from findings-report-contract.md)
- [X] T016 [US1] [cc-review] Add console summary output to `core/commands/review.md` implementing the agent table, MVP designation, and key fixes section per the findings-report-contract.md Console Summary Contract

**Checkpoint**: Standalone review works. 6 agents dispatch, findings merge, gate reports PASS/FAIL, `review-findings.md` written.

---

## Phase 4: User Story 2 - PR Comment Triage (Priority: P1)

**Goal**: A developer can invoke triage to automatically classify PR review comments, apply valid bot suggestions, reject invalid ones, and interactively review human comments.

**Independent Test**: Create a PR with mixed bot and human review comments. Run `/triage`. Verify bot comments are classified and handled, human comments are presented interactively, and no spec-kit infrastructure is required.

### Implementation for User Story 2

- [X] T017 [P] [US2] [cc-review] Copy and adapt triage state script from cc-spex `spex/extensions/spex-collab/scripts/spex-triage-state.sh` to `core/scripts/triage-state.sh`, changing the default state file location from `.specify/` to `.cc-review/.triage-state.json`
- [X] T018 [US2] [cc-review] Create core triage command `core/commands/triage.md` with: frontmatter (name, description, argument-hint for `--pr`, `--spec`, `--no-coverage-fix`, `--idea-inbox`), PR context resolution (Step 1: resolve PR number from `--pr` flag or current branch via `gh pr view`, extract owner/repo from git remote), state initialization (Step 2: call `core/scripts/triage-state.sh init <pr_num>`), and review thread fetching (Step 3a-3b: paginated GraphQL query through `core/scripts/sanitize-gh-json.py`, verify complete fetch)
- [X] T018b [US2] [cc-review] Add bot processing to `core/commands/triage.md`: CodeRabbit rate-limit detection with local fallback (Step 3c), issue comment and status bot parsing with Codecov deep parse (Step 3d), thread partitioning into bot vs human by author type (Step 4), bot profile matching with 3 built-in profiles and config overrides from `core/scripts/resolve-config.sh` (Step 5-5b), bot discovery log (Step 5b)
- [X] T018c [US2] [cc-review] Add bot fix application to `core/commands/triage.md`: assess each bot suggestion against actual code (Step 6a-6f: read context, evaluate validity with code-first approach, apply/skip/defer fixes, detect conflicts and deleted files), batch commit and push (Step 7), CI status check with 1 fix attempt (Step 7b), comment ID re-fetch after push for bots that re-post (Step 7c)
- [X] T018d [US2] [cc-review] Add reply posting and human review to `core/commands/triage.md`: post acceptance/rejection/deferral/fix-failure replies with `<!-- spex-triage -->` signature (Step 8), resolve handled threads per bot profile rules (Step 9-9b), re-evaluation for loop mode (Step 10), spec-aware assessment when `--spec` provided (Step 11), human comment interactive review with approve/edit/skip options (Step 12)
- [X] T018e [US2] [cc-review] Add coverage and summary to `core/commands/triage.md`: coverage cross-reference with Codecov data and bot findings (Step 12b), coverage remediation when threshold exceeded or CI failing (Step 12c), idea inbox capture when `--idea-inbox` provided, and summary output with bot table, human counts, coverage section, commit SHA, CI status (Step 13)

**Checkpoint**: Triage works standalone. Bot comments processed, fixes applied, replies posted, human comments presented interactively.

---

## Phase 5: User Story 3 - cc-spex Enhanced Review (Priority: P2)

**Goal**: cc-spex detects cc-review and delegates to it, or runs its own simplified fallback when cc-review is absent.

**Independent Test**: In a project with both cc-spex and cc-review, trigger the code review gate. Verify cc-review's enhanced agents run with external tools. Then remove cc-review and verify the simplified fallback runs.

### Implementation for User Story 3

- [X] T019 [US3] [cc-spex] Create detection script `spex/extensions/spex-deep-review/scripts/detect-cc-review.sh` implementing two-tier detection per delegation-contract.md: (1) spec-kit extension registry check (`.extensions["cc-review"].enabled == true`, derive path from `.specify/extensions/cc-review`), (2) filesystem probe for `core/commands/review.md` in `.cc-review/` and `~/.cc-review/` (detect by core files, not config, since standalone installs may use built-in defaults)
- [X] T020 [US3] [cc-spex] Refactor `spex/extensions/spex-deep-review/commands/speckit.spex-deep-review.run.md` to add cc-review delegation: at the start of Step 3 (before agent dispatch), call `detect-cc-review.sh`; if found, delegate to cc-review with `--spec`, `--hints`, `--output` flags and return the gate outcome; if not found, run the existing simplified fallback (skip Steps 2 and 4 for external tools per research.md R-005)
- [X] T021 [US3] [cc-spex] Remove triage command from spex-collab: delete `spex/extensions/spex-collab/commands/speckit.spex-collab.triage.md`, remove the command entry from `spex/extensions/spex-collab/extension.yml`, and remove the triage-related scripts (`spex-triage-state.sh`, `sanitize-gh-json.py`) from `spex/extensions/spex-collab/scripts/`
- [X] T022 [US3] [cc-spex] Update `spex/extensions/spex-gates/commands/speckit.spex-gates.review-code.md` to document that when cc-review is detected by spex-deep-review, the enhanced review (with external tools) runs instead of the simplified fallback
- [X] T023 [US3] [cc-spex] Run `make sync-scripts` to propagate script changes to installed extension directories, then verify with `make release` that schema validation and integration tests pass

**Checkpoint**: cc-spex delegates to cc-review when present, runs simplified fallback when absent. Triage removed from spex-collab.

---

## Phase 6: User Story 4 - Multi-Harness Installation (Priority: P2)

**Goal**: cc-review provides native installation formats for Claude Code, spec-kit, and Codex/OpenCode.

**Independent Test**: Install cc-review using each method. Verify the review command is available and functional in each harness.

### Implementation for User Story 4

- [X] T024 [P] [US4] [cc-review] Create Claude Code adapter: `adapters/claude-code/commands/review/SKILL.md` (thin wrapper, < 50 lines) that locates cc-review core and invokes `core/commands/review.md` with translated arguments
- [X] T025 [P] [US4] [cc-review] Create Claude Code triage adapter: `adapters/claude-code/commands/triage/SKILL.md` (thin wrapper, < 50 lines) that invokes `core/commands/triage.md`
- [X] T026 [P] [US4] [cc-review] Create Claude Code install script: `adapters/claude-code/install.sh` that symlinks or copies the adapter commands into the user's Claude Code commands directory
- [X] T027 [P] [US4] [cc-review] Create spec-kit extension manifest: `adapters/speckit/extension.yml` defining `cc-review` extension with commands `speckit.cc-review.review` and `speckit.cc-review.triage`, with hooks for `after_implement` (optional review) and triage integration
- [X] T028 [P] [US4] [cc-review] Create spec-kit review wrapper: `adapters/speckit/commands/speckit.cc-review.review.md` (thin wrapper, < 50 lines) that adds ship pipeline guard, spec resolution via `check-prerequisites.sh`, flow state updates, and delegates to `core/commands/review.md`
- [X] T029 [P] [US4] [cc-review] Create spec-kit triage wrapper: `adapters/speckit/commands/speckit.cc-review.triage.md` (thin wrapper, < 50 lines) that adds ship pipeline guard, spec-aware assessment, constitution principle extraction (Step 14), idea inbox capture (Step 15), and delegates to `core/commands/triage.md`
- [X] T030 [P] [US4] [cc-review] Create spec-kit install script: `adapters/speckit/install.sh` wrapping `specify extension add <path> --dev`
- [X] T031 [P] [US4] [cc-review] Create Codex/OpenCode adapter: `adapters/agents-md/AGENTS.md` fragment describing the review capability, agent dispatch pattern, and invocation instructions for the AGENTS.md format
- [X] T032 [P] [US4] [cc-review] Create Codex/OpenCode install script: `adapters/agents-md/install.sh` that appends the AGENTS.md fragment to an existing AGENTS.md or creates one

**Checkpoint**: All three harness adapters install and invoke cc-review core. Each adapter < 50 lines (SC-007).

---

## Phase 7: User Story 5 - Autonomous Fix Loop (Priority: P3)

**Goal**: After review agents report Critical or Important findings, the system enters an autonomous fix loop with configurable round limits.

**Independent Test**: Run a review that produces Critical findings. Verify the fix loop activates, attempts fixes, runs tests, and resolves or reports findings.

### Implementation for User Story 5

- [X] T033 [US5] [cc-review] Add fix loop to `core/commands/review.md` implementing: test command auto-detection (Makefile, go.mod, package.json, pyproject.toml), fix application in reverse line order, test suite execution with timeout, test failure conversion to Critical findings, re-review on modified files only, maximum round limit from config (`max_fix_rounds`, default 3). This corresponds to Steps 2 (test detection) and 7 (fix loop) from the existing deep-review command.
- [X] T034 [US5] [cc-review] Add external tool integration to `core/commands/review.md` implementing: CodeRabbit CLI detection and invocation with `--agent --files` flags, Copilot CLI invocation, Codex CLI invocation, error handling (timeout/crash does not block review), finding parsing from each tool's output per existing Step 4. All tools gated on config settings.
- [X] T035 [US5] [cc-review] Add post-fix spec compliance check to `core/commands/review.md` implementing Step 7b: detect code removal after fix loop, verify each spec FR is still implemented, add Critical findings for dropped requirements, re-run fix loop if rounds remain

**Checkpoint**: Fix loop runs up to 3 rounds, resolves findings autonomously, runs tests, and reports unresolved findings.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, validation, and cleanup

- [X] T035b [P] [cc-review] Add GitLab stub implementations to `core/scripts/platform.sh` for FR-008: `fetch_pr_threads` calls `glab api` for MR discussions, `post_reply` posts to MR discussion notes, `resolve_thread` resolves MR thread, `check_ci` queries pipeline status. Each stub prints "GitLab support: basic implementation" and uses `glab` CLI. Mark as experimental in documentation.
- [X] T036 [P] [cc-review] Write `README.md` with: project overview, installation guides for each harness (Claude Code, spec-kit, Codex/OpenCode), usage examples, configuration reference, adapter architecture explanation
- [X] T037 [P] [cc-review] Write `docs/standalone-guide.md` with quick start for users without spec-kit
- [X] T038 [P] [cc-review] Write `docs/speckit-guide.md` with integration guide for cc-spex users
- [X] T039 [P] [cc-spex] Update `README.md` to document cc-review delegation: add section explaining the relationship, when simplified fallback runs, how to install cc-review for enhanced review
- [X] T040 [P] [cc-spex] Update `spex/docs/help.md` to reflect triage removal from spex-collab and cc-review delegation in spex-deep-review
- [X] T041 [cc-review] Run quickstart.md validation scenarios 1-5 to verify all user stories work end-to-end
- [X] T042 [cc-spex] Run `make release` to validate schema and integration tests pass after all cc-spex changes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies, can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion
- **US1 Standalone Review (Phase 3)**: Depends on Phase 2 (uses preamble, config, platform scripts)
- **US2 PR Comment Triage (Phase 4)**: Depends on Phase 2 (uses sanitizer, config, platform scripts). Independent of US1.
- **US3 cc-spex Integration (Phase 5)**: Depends on Phase 3 (cc-review core must exist for delegation). Can start after US1 MVP.
- **US4 Multi-Harness (Phase 6)**: Depends on Phase 3 and Phase 4 (adapters wrap core commands). Can start in parallel with US3.
- **US5 Fix Loop (Phase 7)**: Depends on Phase 3 (extends the review command). Can start in parallel with US3/US4.
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

```
Phase 1 (Setup) → Phase 2 (Foundation)
                     ↓
              ┌──────┴──────┐
              ↓             ↓
         Phase 3 (US1)  Phase 4 (US2)
              ↓             ↓
       ┌──────┼─────────────┘
       ↓      ↓
  Phase 5  Phase 6 (US4)
   (US3)      ↓
       ↓   Phase 7 (US5)
       ↓      ↓
       └──────┘
          ↓
     Phase 8 (Polish)
```

- **US1 (P1)** and **US2 (P1)**: Independent, can run in parallel after Foundation
- **US3 (P2)**: Requires US1 core to exist (for delegation target)
- **US4 (P2)**: Requires US1 and US2 core commands to exist (adapters wrap them)
- **US5 (P3)**: Requires US1 core review command (extends it with fix loop and external tools)

### Within Each User Story

- Foundation infrastructure before story-specific tasks
- Agent prompts (T009-T014) can all run in parallel
- Core review command parts: T015 (setup + file detection) → T015b (agent dispatch) → T015c (merge + gate + output) → T016 (console summary)
- Core triage command parts: T018 (setup + fetch) → T018b (bot classification) → T018c (fix application) → T018d (replies + human review) → T018e (coverage + summary)
- Adapter tasks (T024-T032) can all run in parallel

### Parallel Opportunities

- T003, T004: Config and schema in parallel
- T005, T006, T007, T008: All foundation tasks in parallel
- T009-T014: All 6 agent prompt extractions in parallel
- T017 and T018 can start in parallel (state script + command setup)
- T024-T032: All adapter tasks in parallel
- T035b, T036-T040: GitLab stubs and all documentation tasks in parallel

---

## Parallel Example: User Story 1

```
# All agent prompts can be extracted simultaneously:
Task T009: "Extract Correctness agent to core/agents/correctness.md"
Task T010: "Extract Architecture agent to core/agents/architecture.md"
Task T011: "Extract Security agent to core/agents/security.md"
Task T012: "Extract Production agent to core/agents/production.md"
Task T013: "Extract Test Quality agent to core/agents/test-quality.md"
Task T014: "Extract Goal Alignment agent to core/agents/goal-alignment.md"

# Then the core command in sequence (each part depends on previous):
Task T015:  "Review command setup + file detection"
Task T015b: "Agent dispatch"
Task T015c: "Finding merge + gate check + output"
Task T016:  "Console summary output"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup (create repo, directories)
2. Complete Phase 2: Foundation (config, platform, sanitizer, preamble)
3. Complete Phase 3: US1 - Standalone Review (6 agents, merge, gate, output)
4. **STOP and VALIDATE**: Run `/review` in a fresh project without spec-kit
5. Complete Phase 4: US2 - PR Comment Triage (fetch, classify, apply, reply)
6. **STOP and VALIDATE**: Run `/triage` on a PR with bot + human comments

### Incremental Delivery

1. MVP (US1 + US2) delivers standalone review and triage
2. Add US3 (cc-spex integration) so existing users get the upgrade path
3. Add US4 (multi-harness) so non-Claude Code users can install
4. Add US5 (fix loop + external tools) for the power user experience
5. Each story adds value without breaking previous stories

### Cross-Repository Coordination

- cc-review (Phases 1-4, 6-7) is developed first in its own repo
- cc-spex changes (Phase 5) are applied after cc-review core is stable
- cc-spex documentation (Phase 8) updates after both repos are complete
- cc-spex `make release` validates no regressions from the refactoring

---

## Notes

- [P] tasks = different files, no dependencies
- [US*] label maps task to specific user story for traceability
- [cc-review] / [cc-spex] marks which repository the task targets
- Adapter tasks must stay under 50 lines (SC-007)
- Agent prompt extraction preserves content verbatim, only changing path references
- Triage removal from spex-collab leaves the other 5 commands (reviewers, phase-split, phase-manager, revise, reconcile) intact
