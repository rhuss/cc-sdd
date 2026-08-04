# Feature Specification: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Feature Branch**: `052-data-pipeline-hygiene`

**Created**: 2026-08-04

**Status**: Draft

**Input**: Brainstorm #45: data-pipeline hygiene checklist preset and shared-constants drift rule

## Purpose

When a spec covers data work (ETL steps, dashboards, corpus builds), the same quality checks recur every time: schema assertions, row-count logging, fan-out checks after joins, lineage notes. Today these must be remembered and re-typed for each feature, which is error-prone and inconsistent. This feature adds a domain-specific checklist command that validates whether a spec adequately covers data-pipeline hygiene requirements, plus a drift rule that ensures spec-declared constants stay in sync with the implementing code.

## Clarifications

### Session 2026-08-04

- Q: What format should the `## Constants` section use for declaring constants? → A: Simple markdown bullet patterns: `- NAME = value` and `- NAME: value`. Both formats are supported. No complex expression parsing.
- Q: Which extension should host the `/speckit-spex-gates-data-checklist` command? → A: `spex-gates`. It already owns review-code (where the drift check goes), keeping related functionality together.
- Q: How does the command resolve the spec file path? → A: Auto-detect from feature directory via `check-prerequisites.sh`, consistent with all other speckit commands.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Data-Pipeline Checklist (Priority: P1)

A spec author writing a feature that involves data work (ETL steps, dashboards, corpus builds) invokes `/speckit-spex-gates-data-checklist` to generate a domain-specific checklist. The checklist validates whether the spec adequately covers data-pipeline hygiene requirements: lineage documentation, row count logging, fan-out checks, schema assertions, output conventions, and visualization standards.

**Why this priority**: This is the core value proposition. Without the checklist command, users must remember data-pipeline quality checks manually every time, which is error-prone and inconsistent.

**Independent Test**: Can be fully tested by creating a sample spec with data-pipeline content, running the command, and verifying the generated checklist contains all expected requirement-quality items.

**Acceptance Scenarios**:

1. **Given** a spec with data-pipeline content exists in the feature directory, **When** the user runs `/speckit-spex-gates-data-checklist`, **Then** a checklist file is generated at `FEATURE_DIR/checklists/data-pipeline.md` containing requirement-quality items for all six hygiene categories.
2. **Given** a spec that mentions only ETL transforms without visualization, **When** the user runs the command, **Then** the checklist still includes all categories but viz-related items are framed as gap-detection questions ("Are visualization requirements defined?").
3. **Given** a project-level preset override exists at `.specify/checklists/presets/data-pipeline.md`, **When** the user runs the command, **Then** the project-level preset is used instead of the built-in preset.

---

### User Story 2 - Detect Shared-Constants Drift in Code Review (Priority: P2)

During the review-code gate, the reviewer checks whether constants declared in the spec (thresholds, palettes, schemas) are consolidated in a single code module and whether their values match the spec declarations.

**Why this priority**: Constants drifting between spec and code is the failure mode that bites every data project. The checklist catches the requirement-writing side; the drift rule catches the implementation side.

**Independent Test**: Can be tested by writing a spec that declares constants in a `## Constants` section, implementing code where those constants are defined, and running the review-code gate to verify it flags mismatches.

**Acceptance Scenarios**:

1. **Given** a spec with a `## Constants` section declaring `NULL_THRESHOLD = 5%` and `SKEW_LIMIT = 1.0`, **When** the review-code gate runs, **Then** it verifies the code defines these constants in a single module with matching values.
2. **Given** a spec declares `NULL_THRESHOLD = 5%` but the code defines `NULL_THRESHOLD = 10%`, **When** the review-code gate runs, **Then** it reports a drift finding identifying the spec value, code value, and file location.
3. **Given** a spec declares constants but the code spreads them across three different files, **When** the review-code gate runs, **Then** it reports a consolidation finding recommending a single-module pattern.
4. **Given** a spec with no `## Constants` section, **When** the review-code gate runs, **Then** the constants drift check is skipped silently (no false positives).

---

### User Story 3 - Project-Level Preset Override (Priority: P3)

A project maintainer customizes the data-pipeline checklist by placing a modified preset file at `.specify/checklists/presets/data-pipeline.md`. The command uses this override instead of the built-in preset, allowing teams to add project-specific items or remove irrelevant ones.

**Why this priority**: Different projects have different data conventions. The override mechanism makes the feature adaptable without forking.

**Independent Test**: Can be tested by placing a custom preset with additional items, running the command, and verifying the custom items appear in the generated checklist.

**Acceptance Scenarios**:

1. **Given** a project-level preset exists at `.specify/checklists/presets/data-pipeline.md` with additional items, **When** the user runs the command, **Then** the generated checklist uses the project preset, not the built-in.
2. **Given** no project-level preset exists, **When** the user runs the command, **Then** the built-in preset is used as the default.

---

### User Story 4 - Upstream Preset Proposal (Priority: P4)

An upstream issue is created on the spec-kit repository proposing a native preset system for `/speckit-checklist`. This documents the desired architecture (two-level: built-in + project override) so the extension command can be retired when upstream support lands.

**Why this priority**: Long-term sustainability. The extension command is a short-term solution; the proper fix belongs upstream.

**Independent Test**: Can be verified by checking that the upstream issue exists, describes the two-level preset mechanism, and references this feature as the motivating use case.

**Acceptance Scenarios**:

1. **Given** the feature is implemented, **When** the upstream issue is reviewed, **Then** it clearly describes the preset loading mechanism, the two-level override system, and a migration path from the extension command.

---

### Edge Cases

- What happens when the spec has no data-pipeline-related content? The checklist MUST still generate, with all items framed as gap-detection questions.
- What happens when both a built-in and project-level preset exist with conflicting items? The project-level preset completely replaces the built-in (not merged).
- What happens when the `## Constants` section uses inconsistent formatting? The parser MUST handle the documented variations (`- NAME = value`, `- NAME: value`, bullet lists with key-value pairs).
- What happens when a constant value in the spec is a range or threshold expression (e.g., ">5%")? The drift check MUST compare the expression as a string, not attempt numeric parsing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a `/speckit-spex-gates-data-checklist` command that generates a data-pipeline-specific checklist from a preset file.
- **FR-002**: The command MUST generate checklist items following the "unit tests for English" philosophy (testing requirement quality, not implementation behavior).
- **FR-003**: The checklist MUST cover six hygiene categories: lineage docstrings, row count logging, fan-out checks, schema assertions, output conventions, and visualization standards.
- **FR-004**: The command MUST check for a project-level preset at `.specify/checklists/presets/data-pipeline.md` and use it if present, falling back to the built-in preset otherwise.
- **FR-005**: The built-in preset MUST be a markdown file at `spex/extensions/spex-gates/presets/data-pipeline.md`, containing pre-written checklist items with traceability markers.
- **FR-006**: The review-code gate MUST include a "Spec-Declared Constants" check that activates when the spec contains a `## Constants` section.
- **FR-007**: The constants drift check MUST verify that spec-declared constants are defined in a single code module.
- **FR-008**: The constants drift check MUST verify that constant values in code match the values declared in the spec.
- **FR-009**: The constants drift check MUST report findings with specific file paths, spec values, and code values when mismatches are detected.
- **FR-010**: The constants drift check MUST skip silently when no `## Constants` section exists in the spec.
- **FR-011**: The command MUST auto-detect the spec file path from the feature directory using `check-prerequisites.sh`, consistent with all other speckit commands.
- **FR-012**: An upstream issue MUST be created on the spec-kit repository proposing a native preset system for `/speckit-checklist`.

### Key Entities

- **Preset**: A markdown file containing pre-written checklist items for a specific domain. Has a name (e.g., "data-pipeline"), a level (built-in or project), and a list of checklist items grouped by category.
- **Checklist Item**: A requirement-quality question following the "unit tests for English" pattern, with a category tag (e.g., [Completeness], [Clarity]) and optional traceability reference.
- **Spec-Declared Constant**: A named value declared in the spec's `## Constants` section using simple markdown bullet patterns (`- NAME = value` or `- NAME: value`). Consists of a name, a value, and optionally a description. Used as the source of truth for drift detection.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/speckit-spex-gates-data-checklist` on any spec produces a checklist file within the feature directory containing at least 15 requirement-quality items across all six hygiene categories.
- **SC-002**: The generated checklist items all follow the "unit tests for English" pattern (questions about requirement quality, not implementation verification).
- **SC-003**: When a spec declares constants and the code has mismatched values, the review-code gate detects and reports 100% of mismatches.
- **SC-004**: When a spec has no `## Constants` section, the drift check produces zero false positives.
- **SC-005**: Project-level presets fully override built-in presets when present, with no item merging or duplication.

## Error Handling

- If `check-prerequisites.sh` fails to resolve a feature directory, the command MUST exit with a clear error message explaining that it must be run from a feature branch with a matching spec directory.
- If the built-in preset file is missing (not installed), the command MUST exit with an error referencing the expected path and suggesting `spex:init` to reinstall extensions.
- If the generated checklist output directory (`FEATURE_DIR/checklists/`) cannot be created, the command MUST exit with a file-system error rather than silently failing.
- If the `## Constants` section contains entries that do not match any supported format, those entries MUST be skipped with a warning listing the unparseable lines.

## Out of Scope

- Proactive constant discovery (scanning code for magic numbers not declared in the spec).
- Complex expression evaluation in constant values (arithmetic, variable references).
- Merging built-in and project-level presets; project presets are full replacements.
- Modifying the upstream `speckit-checklist` skill; the upstream preset proposal is a separate issue.
- Automatic remediation of drift findings (the gate reports, humans fix).

## Assumptions

- The data-pipeline checklist command lives in the `spex-gates` extension, alongside the review-code gate it complements.
- The `## Constants` section format in specs follows a simple key-value pattern that can be parsed with basic text processing (no complex expression evaluation needed).
- The upstream preset proposal is documentation work only and does not block shipping the extension command.
- The review-code gate enhancement is additive (new check section) and does not modify existing review-code behavior.
- The built-in preset content is based on the specific items listed in brainstorm #45 and GitHub issue #49.
