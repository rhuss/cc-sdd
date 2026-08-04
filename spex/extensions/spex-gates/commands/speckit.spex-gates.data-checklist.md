---
description: "Generate a data-pipeline-specific checklist from a preset file"
---

# Data-Pipeline Hygiene Checklist

## Ship Pipeline Guard

If `.specify/.spex-state` exists and its `status` is `running`, this command is part of an autonomous pipeline. Complete the checklist generation autonomously and return immediately. Do NOT output a completion summary, do NOT ask "Shall I proceed?", do NOT suggest next steps.

## Overview

Generate a domain-specific checklist that validates whether a spec adequately covers data-pipeline hygiene requirements. The checklist follows the "unit tests for English" philosophy: items test requirement quality, not implementation behavior.

## Step 1: Resolve Feature Directory

Run `check-prerequisites.sh` to resolve the feature directory and spec path:

```bash
PREREQS=$(.specify/scripts/bash/check-prerequisites.sh --json --paths-only 2>/dev/null)
```

If this fails, exit with a clear error:

```
ERROR: Could not resolve feature directory.
This command must be run from a feature branch with a matching spec directory.
```

Parse the JSON output to extract `FEATURE_DIR` and `FEATURE_SPEC`:

```bash
FEATURE_DIR=$(echo "$PREREQS" | jq -r '.FEATURE_DIR')
FEATURE_SPEC=$(echo "$PREREQS" | jq -r '.FEATURE_SPEC // empty')
```

If `FEATURE_SPEC` is empty, look for `spec.md` in the feature directory:

```bash
FEATURE_SPEC="${FEATURE_DIR}/spec.md"
```

## Step 2: Locate Preset File

Determine the preset file to use. Check for a project-level override first, then fall back to the built-in preset.

```bash
PROJECT_PRESET=".specify/checklists/presets/data-pipeline.md"
BUILTIN_PRESET=".specify/extensions/spex-gates/presets/data-pipeline.md"
```

**Resolution order** (project-level fully replaces built-in, no merging):

1. If `$PROJECT_PRESET` exists, use it as the preset source
2. Otherwise, use `$BUILTIN_PRESET`

If neither file exists, exit with an error:

```
ERROR: Built-in preset not found at .specify/extensions/spex-gates/presets/data-pipeline.md
Run /spex:init to reinstall extensions.
```

## Step 3: Read Spec Content for Contextualization

Read the spec file to identify which data-pipeline topics are covered:

```bash
cat "$FEATURE_SPEC"
```

Scan the spec content for mentions of each hygiene category:

- **Lineage**: Look for terms like "lineage", "source", "upstream", "provenance", "pipeline owner"
- **Row counts**: Look for terms like "row count", "record count", "cardinality", "volume"
- **Fan-out**: Look for terms like "join", "fan-out", "cartesian", "multiplication", "merge"
- **Schema**: Look for terms like "schema", "dtype", "column", "type assertion", "validation"
- **Output conventions**: Look for terms like "output", "format", "parquet", "csv", "filename", "partition"
- **Visualization**: Look for terms like "chart", "dashboard", "visualization", "plot", "KPI", "metric"

For each category:
- If the spec mentions the topic: leave checklist items as-is (requirement-quality validation)
- If the spec does NOT mention the topic: frame items as gap-detection questions (the checklist item text already uses gap-detection phrasing like "Are X defined?" which naturally surfaces gaps)

## Step 4: Create Output Directory

Create the checklists directory within the feature directory:

```bash
mkdir -p "${FEATURE_DIR}/checklists"
```

If directory creation fails, exit with a filesystem error:

```
ERROR: Could not create directory ${FEATURE_DIR}/checklists/
Check filesystem permissions.
```

## Step 5: Generate Checklist

Copy the preset content to the output file at `${FEATURE_DIR}/checklists/data-pipeline.md`.

Add a header section that references the source spec:

```markdown
# Data-Pipeline Hygiene Checklist

**Feature**: [spec.md](../spec.md)
**Generated**: YYYY-MM-DD
**Preset**: {built-in | project-level}
```

Then include all checklist items from the preset file, preserving the category sections and item formatting.

Write the complete checklist to:

```bash
OUTPUT="${FEATURE_DIR}/checklists/data-pipeline.md"
```

## Step 6: Report Results

Count the total checklist items generated:

```bash
ITEM_COUNT=$(grep -c '^\- \[ \]' "$OUTPUT")
```

Report the output:

```
Data-pipeline hygiene checklist generated:
  Output: ${OUTPUT}
  Items:  ${ITEM_COUNT}
  Preset: {built-in | project-level}
```
