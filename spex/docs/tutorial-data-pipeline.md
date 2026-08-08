# Data-Pipeline Hygiene with spex

When your feature involves data work (ETL, dashboards, corpus builds), spex provides two tools to catch quality gaps early: a domain-specific checklist and a constants drift check.

## Use Case 1: Validate a Data Spec with the Hygiene Checklist

You're writing a spec for a new ETL pipeline that ingests customer data, joins it with transaction records, and produces a daily report. Before planning, run the data-pipeline checklist to verify your spec covers the hygiene basics.

```
/speckit-spex-gates-data-checklist
```

This generates a checklist at `FEATURE_DIR/checklists/data-pipeline.md` with 19 requirement-quality questions across six categories:

- **Lineage Docstrings**: Are sources, schedules, and owners documented?
- **Row Count Logging**: Are before/after counts required for each transform?
- **Fan-Out Checks**: Are post-join cardinality validations specified?
- **Schema Assertions**: Are column existence, dtype, and key constraints defined?
- **Output Conventions**: Are format (Parquet vs CSV) and naming conventions specified?
- **Visualization Standards**: Are insight-first titles and KPI thresholds defined?

Each item follows the "unit tests for English" pattern. They test whether your *requirements* are complete, not whether your *code* works:

```markdown
- [ ] CHK007 [Completeness] Are post-join row count validation requirements specified?
- [ ] CHK010 [Completeness] Are fail-fast schema assertions defined (column exists, dtype matches)?
- [ ] CHK016 [Completeness] Are insight-first chart title requirements defined?
```

Walk through the checklist and mark items. Any unchecked item is a gap in your spec that could cause problems during implementation.

## Use Case 2: Customize the Checklist for Your Project

The built-in preset covers general data-pipeline hygiene. If your project has additional conventions (e.g., specific data retention policies, regional residency requirements), create a project-level override:

```bash
mkdir -p .specify/checklists/presets
```

Create `.specify/checklists/presets/data-pipeline.md` with your custom items. The project preset **fully replaces** the built-in (no merging), so copy items you want to keep from the built-in at `spex/extensions/spex-gates/presets/data-pipeline.md` and add your own.

## Use Case 3: Declare Constants in Your Spec

When your spec defines thresholds, palettes, or other shared values that both code and documentation depend on, declare them in a `## Constants` section:

```markdown
## Constants

- NULL_THRESHOLD = 5%
- SKEW_LIMIT = 1.0
- CV_THRESHOLD = 30%
- P99_LATENCY = 200ms
```

Two bullet formats are supported: `- NAME = value` and `- NAME: value`. Names must be `UPPER_CASE_WITH_UNDERSCORES`. Values are treated as strings (no numeric parsing), so expressions like `>5%` or `+/-1` are valid.

## Use Case 4: Catch Constants Drift During Code Review

After implementation, the review-code gate automatically checks whether your code matches the spec's declared constants. Run it manually or let the ship pipeline trigger it:

```
/speckit-spex-gates-review-code
```

The gate checks three things:

1. **Value match**: Does the code define `NULL_THRESHOLD` with value `5%`? If the code says `10%`, you get a drift finding.
2. **Consolidation**: Are all constants in a single module? If `NULL_THRESHOLD` is in `config.py` and `SKEW_LIMIT` is in `utils.py`, you get a consolidation finding recommending a single module.
3. **Missing constants**: Is `CV_THRESHOLD` declared in the spec but not found in the code? You get a missing-constant finding.

If the spec has no `## Constants` section, the check is silently skipped (no false positives).

## Putting It Together

A typical workflow for a data feature:

1. **Brainstorm**: `/speckit-spex-brainstorm` to explore the idea
2. **Specify**: `/speckit-specify` to write the spec
3. **Checklist**: `/speckit-spex-gates-data-checklist` to validate the spec covers data hygiene
4. **Add constants**: If the spec declares thresholds, add a `## Constants` section
5. **Plan and implement**: The normal spex workflow
6. **Review**: The review-code gate automatically checks constants drift

Or use `/speckit-spex-ship` to run the full pipeline autonomously. The constants drift check is built into the review-code stage.
