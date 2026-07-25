# Feature Specification: Workflow-First Spex Setup

**Feature Branch**: `048-workflow-first-setup`  
**Created**: 2026-07-25  
**Status**: Draft  
**Input**: Replace the monolithic Codex-support delivery with a workflow-first setup that persists user intent, remains source-transparent for Claude development, and treats generated harness trees as disposable outputs.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Repeat Setup from Project Configuration (Priority: P1)

A developer records the desired Spex harness, extensions, and security level in project configuration. Any teammate can rerun the Spex setup workflow and receive the same selections without answering the setup questionnaire again.

**Why this priority**: A durable, reviewable declaration makes the Spec-Kit workflow sufficient as the primary installation and refresh mechanism.

**Independent Test**: Add a valid Spex project configuration to a clean repository, run setup without selection overrides, and verify that the declared extensions and security intent are applied and preserved on a second run.

**Acceptance Scenarios**:

1. **Given** a repository containing valid Spex project configuration, **When** setup runs without explicit overrides, **Then** it uses the recorded harness preference, extension selection, and security level.
2. **Given** a configured repository, **When** setup runs repeatedly, **Then** the resulting enabled extensions and requested security remain unchanged and no duplicate configuration is introduced.
3. **Given** explicit setup inputs and existing project configuration, **When** setup runs, **Then** the explicit inputs take precedence and the accepted result becomes the new recorded intent.
4. **Given** setup creates or updates project configuration, **When** a teammate inspects the repository, **Then** that declaration is visible to version control and can be reviewed and shared.

---

### User Story 2 - Bootstrap Configuration Interactively (Priority: P1)

A developer without Spex project configuration runs the setup workflow, chooses from clearly described harness, extension, and security options, and receives both a working installation and a durable configuration for future refreshes.

**Why this priority**: First-time setup must remain approachable while converging onto the same repeatable path used by automated and team-owned setup.

**Independent Test**: Run setup in an unconfigured disposable repository, choose non-default options, and verify that the resulting project configuration reproduces those choices on a non-interactive refresh.

**Acceptance Scenarios**:

1. **Given** no Spex project configuration, **When** interactive setup begins, **Then** it identifies the recommended defaults and describes every additional extension and security choice.
2. **Given** the user accepts or changes the proposed selections, **When** setup completes, **Then** the accepted intent is stored in project configuration before harness-specific settings are generated.
3. **Given** setup cannot apply the requested configuration, **When** it fails, **Then** it reports the failing selection and does not persist a partially accepted configuration.

---

### User Story 3 - Preserve Canonical Source Ownership (Priority: P1)

A Spex contributor edits canonical workflow and extension sources without maintaining generated copies under agent-specific project directories. Repository safeguards detect generated harness trees before they are committed.

**Why this priority**: The workflow-first architecture depends on a single maintained source; accidental generated-tree commits would recreate the duplication it is designed to prevent.

**Independent Test**: Generate Claude and Codex project files in the repository, verify Git ignores them, then stage representative generated paths forcibly and verify the repository quality check rejects them.

**Acceptance Scenarios**:

1. **Given** setup generates project-local Claude, Codex, or shared agent files, **When** Git status is inspected, **Then** generated skill and harness configuration trees are ignored.
2. **Given** a generated harness file is forcibly added, **When** repository quality checks run, **Then** they fail with guidance to edit canonical Spex sources instead.
3. **Given** a deliberately maintained plugin descriptor or repository guidance file, **When** generated-tree safeguards run, **Then** the maintained source remains allowed.

---

### User Story 4 - Develop Claude Directly from Source (Priority: P2)

A Claude plugin maintainer can install and debug the plugin directly from the source tree without first producing a staged cross-harness distribution.

**Why this priority**: Claude's native plugin model is source-transparent, and ordinary development should not acquire a build boundary solely because another harness may require packaging.

**Independent Test**: Install the Claude plugin from a clean source checkout, invoke its setup entry point, and verify that no materialization command or staged distribution is required.

**Acceptance Scenarios**:

1. **Given** a clean Spex source checkout, **When** a maintainer performs the documented Claude development install, **Then** the plugin runs directly from canonical sources.
2. **Given** optional release packaging is unavailable, **When** Claude development tests run, **Then** source installation and workflow setup remain functional.

### Edge Cases

- Existing repositories may contain legacy setup inputs but no durable Spex project configuration.
- A configuration may name an unknown extension, omit the mandatory core extension, or contain an unsupported security value.
- Setup may be interrupted after extensions change but before harness configuration is generated.
- A repository may intentionally track a root `AGENTS.md` while ignoring generated `.agents/` contents.
- Existing ignore rules may contain narrower Claude patterns that need migration without discarding user entries.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Spex MUST provide one project-owned declaration of requested harness preference, enabled extensions, and security level.
- **FR-002**: Project configuration MUST distinguish user-requested intent from generated harness configuration and transient workflow state.
- **FR-003**: Setup MUST use project configuration when explicit invocation inputs are absent.
- **FR-004**: Explicit invocation inputs MUST override stored values for that run and MUST update stored intent only after the complete selection is validated.
- **FR-005**: First-time setup MUST present the recommended extension set by default and expose all optional extensions with concise descriptions.
- **FR-006**: First-time setup MUST expose exactly three security choices: Safe, Autonomous, and YOLO, with Safe recommended by default.
- **FR-007**: The project declaration MUST record requested security intent only; detected capabilities and effective harness policy MUST remain owned by the corresponding harness adapter.
- **FR-008**: Setup MUST describe Safe as preserving host policy, Autonomous as reducing prompts for enumerated project operations, and YOLO as requesting the broadest project-local autonomy the active harness can safely express.
- **FR-009**: Setup MUST NOT claim that requested security is effective until the active harness adapter has applied or safely degraded it.
- **FR-010**: Harness-specific fallback confirmation and effective-policy persistence MUST be delivered and tested with the corresponding harness adapter rather than encoded in the shared declaration.
- **FR-011**: Setup MUST validate the complete requested configuration before changing the persisted declaration.
- **FR-012**: Setup MUST reject unknown harnesses, extensions, and security values with actionable diagnostics.
- **FR-013**: Setup MUST remain idempotent and preserve valid selections during refresh.
- **FR-014**: The project-owned Spex declaration MUST be visible to version control and MUST NOT be treated as transient workflow state.
- **FR-015**: Generated `.agents/`, `.codex/`, and project-local `.claude/` trees MUST be excluded from ordinary version control discovery.
- **FR-016**: Repository quality checks MUST reject tracked generated harness artifacts while allowing explicitly maintained distribution descriptors and repository guidance.
- **FR-017**: Canonical workflow, extension, and setup behavior MUST remain owned under the maintained Spex source tree.
- **FR-018**: Claude source development and installation MUST NOT require plugin materialization or a staged distribution.
- **FR-019**: Existing repositories without the new declaration MUST receive deterministic migration behavior that preserves any discoverable valid selections and otherwise uses documented defaults.
- **FR-020**: Setup failure MUST identify whether requested intent was persisted and MUST NOT leave a partially written project declaration.

### Key Entities

- **Spex Project Configuration**: Team-owned requested setup intent, including harness preference, extension selection, security level, and configuration format version.
- **Generated Harness Tree**: Disposable project-local skills, hooks, and settings produced for a specific coding agent.
- **Setup Resolution**: The validated effective selection obtained from defaults, stored intent, and explicit invocation inputs in precedence order.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A configured repository can be refreshed twice with zero additional selection prompts and byte-identical requested configuration.
- **SC-002**: The project-owned configuration appears as an ordinary reviewable repository file while generated harness trees remain absent from ordinary Git status.
- **SC-003**: Clean-repository tests cover default setup, non-default setup, explicit override, invalid configuration, migration, and interrupted persistence without manual file repair.
- **SC-004**: Generated Claude and Codex project trees produce no ordinary Git status entries in every supported setup test.
- **SC-005**: A forced attempt to track a representative generated skill fails the repository quality gate in every tested harness.
- **SC-006**: Claude source installation and its setup smoke test pass without invoking a materialization command.
- **SC-007**: The setup documentation presents one primary workflow-based path and allows a new user to identify defaults and alternatives without consulting plugin internals.

## Assumptions

- The core `spex` extension remains mandatory; init-only operation is separate follow-up work.
- Native Codex hooks, security-policy translation, linked-worktree behavior, and skill presentation belong to the next scoped feature.
- Native plugin marketplace discovery is a separate packaging feature and is not required for successful workflow setup.
- Worktree state transfer, ship recovery, progress presentation, and Teams behavior remain outside this feature.
- OpenCode is not a supported acceptance target for this feature.
