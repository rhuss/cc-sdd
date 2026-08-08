# Quickstart: Data-Pipeline Hygiene Checklist + Constants Drift

## Prerequisites

- spec-kit initialized (`.specify/` directory exists)
- `spex-gates` extension enabled: `specify extension enable spex-gates`
- A feature branch with a spec containing data-pipeline content

## Validation Scenario 1: Generate Data-Pipeline Checklist

1. Create or switch to a feature branch with a spec:
   ```bash
   git checkout <feature-branch>
   ```

2. Run the data-pipeline checklist command:
   ```
   /speckit-spex-gates-data-checklist
   ```

3. Expected outcome:
   - A file at `FEATURE_DIR/checklists/data-pipeline.md` is created
   - Contains at least 15 checklist items across six categories:
     - Lineage docstrings
     - Row count logging
     - Fan-out checks
     - Schema assertions
     - Output conventions
     - Visualization standards
   - All items follow the "unit tests for English" pattern (questions about requirement quality)

## Validation Scenario 2: Project-Level Preset Override

1. Create a project-level preset:
   ```bash
   mkdir -p .specify/checklists/presets
   ```
   Place a custom `data-pipeline.md` in that directory with modified items.

2. Run the command again:
   ```
   /speckit-spex-gates-data-checklist
   ```

3. Expected outcome:
   - The generated checklist uses the project-level preset items, not the built-in ones
   - No merging occurs; the project preset fully replaces the built-in

## Validation Scenario 3: Constants Drift Detection

1. Add a `## Constants` section to the spec:
   ```markdown
   ## Constants
   - NULL_THRESHOLD = 5%
   - SKEW_LIMIT = 1.0
   ```

2. In the implementation code, define these constants but with one mismatched value.

3. Run the review-code gate:
   ```
   /speckit-spex-gates-review-code
   ```

4. Expected outcome:
   - The gate reports a drift finding for the mismatched constant
   - Finding includes: constant name, spec value, code value, and file path
   - Non-mismatched constants pass silently

## Validation Scenario 4: No Constants Section (Silent Skip)

1. Use a spec without a `## Constants` section.

2. Run the review-code gate:
   ```
   /speckit-spex-gates-review-code
   ```

3. Expected outcome:
   - No constants-related findings
   - No warnings or errors about missing constants
   - Existing review-code behavior unchanged
