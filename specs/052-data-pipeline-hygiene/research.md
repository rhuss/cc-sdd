# Research: Data-Pipeline Hygiene Checklist + Constants Drift

## Existing Command Pattern in spex-gates

**Decision**: Follow the same pattern as `speckit.spex-gates.review-code.md` for the new data-checklist command.

**Rationale**: All spex-gates commands are markdown files in `commands/` that follow the `speckit.{ext-id}.{command}` naming convention. The new command follows this exactly as `speckit.spex-gates.data-checklist.md`.

**Alternatives considered**: Creating a new extension (`spex-data`) was rejected because it adds overhead for a single command, and the checklist complements the review-code gate which already lives in spex-gates.

## Preset File Format

**Decision**: Use the same markdown checklist format as `speckit-checklist` output (CHK-numbered items with category tags), stored in `spex/extensions/spex-gates/presets/data-pipeline.md`.

**Rationale**: Consistency with the existing checklist output format means the preset is also a valid checklist. The command reads the preset and copies it to the feature directory, optionally adapting items based on the spec content.

**Alternatives considered**: YAML-based presets were rejected because they add a parsing dependency and diverge from the markdown-native approach used throughout spex.

## Constants Parsing Approach

**Decision**: Use `awk`/`grep` to extract constants from the `## Constants` section. Support two bullet formats: `- NAME = value` and `- NAME: value`. Parse until the next `##` heading or EOF.

**Rationale**: Simple text processing covers the documented formats without requiring a markdown AST parser. The section boundary detection (next `##` heading) is reliable for well-formed specs.

**Alternatives considered**: Using a markdown parser (e.g., Python `mistune`) was rejected because it adds a runtime dependency for a task that `awk` handles reliably.

## Drift Check Integration Point

**Decision**: Add a new section to the review-code gate command file (`speckit.spex-gates.review-code.md`) titled "Spec-Declared Constants Check". This section runs after the existing compliance checks and before the deep review trigger.

**Rationale**: The review-code gate already has a modular structure with numbered sections. Adding a new section is additive and does not change existing behavior. The constants check is logically part of spec compliance.

**Alternatives considered**: A separate `before_review_code` hook was rejected because it would split the review-code logic across two files and add hook-dispatch overhead for a check that is conceptually part of spec compliance.

## Project-Level Override Resolution

**Decision**: Check `.specify/checklists/presets/data-pipeline.md` first. If it exists, use it as the complete preset (no merging with built-in). If not, fall back to the built-in at `spex/extensions/spex-gates/presets/data-pipeline.md`.

**Rationale**: Full replacement is simpler than merging and gives projects complete control. Teams that want the built-in items plus custom ones can copy the built-in preset to the project directory and add their items.

**Alternatives considered**: A merge strategy (project items appended to built-in items) was rejected because it introduces ordering ambiguity and makes it impossible to remove a built-in item.
