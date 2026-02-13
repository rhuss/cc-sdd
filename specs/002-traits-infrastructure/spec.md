# Feature Specification: SDD Traits Infrastructure

**Feature Branch**: `002-traits-infrastructure`
**Created**: 2026-02-13
**Status**: Draft
**Input**: User description: "SDD Traits Infrastructure: trait storage, patching mechanism, sdd:traits command, init integration"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time Setup with Trait Selection (Priority: P1)

A new user initializes SDD for the first time and selects which traits (sdd, beads) to enable. The system persists their choices and applies overlays to spec-kit files so that future `/speckit.*` commands include the selected discipline automatically.

**Why this priority**: This is the foundational flow. Without trait selection and overlay application during init, no other trait functionality works.

**Independent Test**: Run `/sdd:init` in a fresh project with spec-kit installed. Verify that `.specify/sdd-traits.json` is created with selected traits, and that overlay content appears in the targeted spec-kit command files.

**Acceptance Scenarios**:

1. **Given** a project with spec-kit initialized and no `.specify/sdd-traits.json`, **When** the user runs `/sdd:init`, **Then** the system prompts which traits to enable (sdd, beads) via `AskUserQuestion`, creates `.specify/sdd-traits.json` with the selections, and runs `apply-traits.sh` to append overlays to spec-kit files.

2. **Given** a project with spec-kit initialized and no `.specify/sdd-traits.json`, **When** the user runs `/sdd:init` and selects only the `sdd` trait, **Then** only sdd-related overlays are appended to spec-kit files, and `.specify/sdd-traits.json` records `{"sdd": true, "beads": false}`.

3. **Given** a project with spec-kit initialized and no `.specify/sdd-traits.json`, **When** the user runs `/sdd:init` and selects both `sdd` and `beads` traits, **Then** both sets of overlays are appended to the appropriate spec-kit files.

---

### User Story 2 - Refresh/Update Reapplies Traits (Priority: P2)

After a `specify init --force` (which overwrites spec-kit templates and commands), the user runs `/sdd:init --refresh` and traits are reapplied from the saved config. Overlay sentinel markers are removed by the spec-kit overwrite, so `apply-traits.sh` re-appends them cleanly.

**Why this priority**: Users will periodically update spec-kit, and traits must survive those updates. Without this, every `specify init --force` would strip discipline overlays permanently.

**Independent Test**: Enable traits, then run `specify init --force` followed by `/sdd:init --refresh`. Verify overlays are present in spec-kit files after the refresh.

**Acceptance Scenarios**:

1. **Given** a project with traits enabled and overlays applied, **When** `specify init --force` is run (which overwrites spec-kit files, removing sentinel markers), and then `/sdd:init --refresh` is run, **Then** `apply-traits.sh` reads `.specify/sdd-traits.json` and reapplies all enabled trait overlays.

2. **Given** a project with `.specify/sdd-traits.json` recording `{"sdd": true, "beads": true}`, **When** `/sdd:init --refresh` is run, **Then** both sdd and beads overlays are appended to their target files, and sentinel markers are present in each.

---

### User Story 3 - Enable/Disable Traits Individually (Priority: P2)

A user enables or disables a specific trait using the `/sdd:traits` command. The trait config is updated and overlays are reapplied (or removed) accordingly.

**Why this priority**: Users need to toggle traits after initial setup, for example enabling beads after installing the beads plugin, or disabling sdd discipline temporarily.

**Independent Test**: Run `/sdd:traits enable beads` in a project with only sdd enabled. Verify `.specify/sdd-traits.json` is updated and beads overlays are applied.

**Acceptance Scenarios**:

1. **Given** a project with `sdd` trait enabled and `beads` trait disabled, **When** the user runs `/sdd:traits enable beads`, **Then** `.specify/sdd-traits.json` is updated to `{"sdd": true, "beads": true}`, and beads overlays are appended to target files.

2. **Given** a project with both traits enabled, **When** the user runs `/sdd:traits disable beads`, **Then** `.specify/sdd-traits.json` is updated to `{"sdd": true, "beads": false}`, and all spec-kit target files are regenerated (stripped of beads sentinels) by running `specify init --force` followed by `apply-traits.sh` (which only applies sdd overlays).

---

### User Story 4 - List Active Traits (Priority: P3)

A user checks which traits are currently active by running `/sdd:traits` or `/sdd:traits list`.

**Why this priority**: Useful for debugging and orientation, but not required for the core patching and init workflows.

**Independent Test**: Run `/sdd:traits list` in a project with traits configured. Verify the output lists each trait and its enabled/disabled status.

**Acceptance Scenarios**:

1. **Given** a project with `.specify/sdd-traits.json` recording `{"sdd": true, "beads": false}`, **When** the user runs `/sdd:traits` (no arguments) or `/sdd:traits list`, **Then** the system displays: `sdd: enabled`, `beads: disabled`.

2. **Given** a project with no `.specify/sdd-traits.json`, **When** the user runs `/sdd:traits list`, **Then** the system reports that no traits are configured and suggests running `/sdd:init`.

---

### Edge Cases

- What happens when `apply-traits.sh` is run on a file that already has the sentinel marker? The overlay is skipped (idempotent application).
- What happens when a user enables a trait for which no overlay files exist in the plugin? The trait is recorded in config but no file modifications occur. A warning is displayed.
- What happens when `.specify/sdd-traits.json` is manually edited with invalid JSON? `apply-traits.sh` reports a parse error and exits non-zero without modifying any files.
- What happens when spec-kit files targeted by overlays do not exist (e.g., spec-kit not initialized)? `apply-traits.sh` reports that target files are missing and exits non-zero.
- What happens when disabling a trait? Since overlays are append-only, disabling requires a full refresh: `specify init --force` to get clean files, then `apply-traits.sh` to reapply only enabled traits.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store trait configuration in `.specify/sdd-traits.json` with a versioned schema containing trait names mapped to boolean enabled/disabled status.
- **FR-002**: System MUST provide an `apply-traits.sh` script at `sdd/scripts/apply-traits.sh` that reads `.specify/sdd-traits.json` and appends overlay content to spec-kit target files for each enabled trait.
- **FR-003**: System MUST use sentinel markers (`<!-- SDD-TRAIT:<trait-name> -->`) to prevent duplicate overlay application. If the sentinel is already present in a target file, the overlay for that trait is skipped.
- **FR-004**: System MUST ship overlay files at `sdd/overlays/<trait>/commands/<target>.append.md` and `sdd/overlays/<trait>/templates/<target>.append.md` within the plugin directory structure.
- **FR-005**: Each overlay file MUST be minimal (under 20 lines of content) and delegate heavy logic to existing SDD skills via `{Skill: sdd:<skill-name>}` references rather than inlining discipline content.
- **FR-006**: The `sdd-init.sh` script MUST call `apply-traits.sh` after every `specify init` operation (both fresh init and `--refresh`/`--update`).
- **FR-007**: On first run without an existing `.specify/sdd-traits.json`, `/sdd:init` MUST prompt the user to select which traits to enable using `AskUserQuestion`.
- **FR-008**: System MUST provide a `/sdd:traits` command with subcommands: `enable <trait>`, `disable <trait>`, and `list` (default when no arguments provided).
- **FR-009**: Disabling a trait MUST trigger a full file refresh (`specify init --force` followed by `apply-traits.sh`) to cleanly remove the disabled trait's overlay content.
- **FR-010**: The `.specify/sdd-traits.json` file MUST survive `specify init --force` (spec-kit only overwrites `templates/`, `commands/`, and `scripts/` directories, not arbitrary files in `.specify/`).
- **FR-011**: The `apply-traits.sh` script MUST validate that `.specify/sdd-traits.json` contains valid JSON and that target files exist before attempting modifications, reporting errors to stderr and exiting non-zero on failure.
- **FR-012**: The traits config schema MUST include a `version` field (integer, starting at 1), `traits` object, and `applied_at` timestamp (ISO 8601).

### Key Entities

- **Trait Config** (`.specify/sdd-traits.json`): Persisted trait selections. Contains version, trait map (name to boolean), and last-applied timestamp. Located inside `.specify/` to survive alongside spec-kit without being overwritten.
- **Overlay File** (`sdd/overlays/<trait>/<type>/<target>.append.md`): Small markdown fragment shipped with the SDD plugin. Appended to the corresponding spec-kit file when the trait is enabled. Contains a sentinel marker and skill delegation references.
- **Sentinel Marker** (`<!-- SDD-TRAIT:<name> -->`): HTML comment placed at the start of each overlay block. Used by `apply-traits.sh` to detect whether an overlay has already been applied (idempotency check).
- **Target File**: A spec-kit command file (`.claude/commands/speckit.*.md`) or template file (`.specify/templates/*.md`) that receives overlay content.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After running `/sdd:init` with trait selection, all spec-kit command files targeted by enabled traits contain the corresponding overlay content with sentinel markers.
- **SC-002**: Running `apply-traits.sh` twice in succession produces identical file content (idempotent; second run is a no-op).
- **SC-003**: After `specify init --force` followed by `apply-traits.sh`, all previously enabled trait overlays are present in spec-kit files (survives update cycle).
- **SC-004**: Each overlay file in `sdd/overlays/` is under 20 lines and contains at least one `{Skill: sdd:*}` delegation reference.
- **SC-005**: The `/sdd:traits list` command accurately reflects the current state of `.specify/sdd-traits.json`.
- **SC-006**: Enabling a trait adds its overlays without affecting other traits' overlays. Disabling a trait removes only its overlays while preserving other traits' overlays.
