# Data-Pipeline Hygiene with spex

When your feature involves data work (ETL, dashboards, corpus builds), spex's constants drift check catches a common failure mode: spec-declared values drifting out of sync with the implementing code. This tutorial also provides a ready-made checklist you can copy into your project for data-pipeline spec quality validation.

## Use Case 1: Declare Constants in Your Spec

When your spec defines thresholds, palettes, or other shared values that both code and documentation depend on, declare them in a `## Constants` section:

```markdown
## Constants

- NULL_THRESHOLD = 5%
- SKEW_LIMIT = 1.0
- CV_THRESHOLD = 30%
- P99_LATENCY = 200ms
```

Two bullet formats are supported: `- NAME = value` and `- NAME: value`. Names must be `UPPER_CASE_WITH_UNDERSCORES`. Values are treated as strings (no numeric parsing), so expressions like `>5%` or `+/-1` are valid.

## Use Case 2: Catch Constants Drift During Code Review

After implementation, the review-code gate automatically checks whether your code matches the spec's declared constants. Run it manually or let the ship pipeline trigger it:

```
/speckit-spex-gates-review-code
```

The gate checks three things:

1. **Value match**: Does the code define `NULL_THRESHOLD` with value `5%`? If the code says `10%`, you get a drift finding.
2. **Consolidation**: Are all constants in a single module? If `NULL_THRESHOLD` is in `config.py` and `SKEW_LIMIT` is in `utils.py`, you get a consolidation finding recommending a single module.
3. **Missing constants**: Is `CV_THRESHOLD` declared in the spec but not found in the code? You get a missing-constant finding.

If the spec has no `## Constants` section, the check is silently skipped (no false positives).

## Use Case 3: Create a Data-Pipeline Checklist for Your Project

spex's `/speckit-checklist` command generates requirement-quality checklists. For data-pipeline work, you can create a project-level checklist preset that encodes your team's hygiene standards. Place it at `.specify/checklists/presets/data-pipeline.md`:

```bash
mkdir -p .specify/checklists/presets
```

Here's a starter preset covering six common hygiene categories. Copy it to `.specify/checklists/presets/data-pipeline.md` and customize for your project:

```markdown
# Data-Pipeline Hygiene Checklist

## Lineage Docstrings

- [ ] CHK001 [Completeness] Are lineage docstrings (source, pipeline, schedule, owner) required for each transform step?
- [ ] CHK002 [Clarity] Does the spec identify the upstream data sources and their refresh cadence?
- [ ] CHK003 [Coverage] Are intermediate transform outputs documented with their lineage chain?

## Row Count Logging

- [ ] CHK004 [Completeness] Are row count logging requirements defined for before and after every transform?
- [ ] CHK005 [Clarity] Does the spec specify what constitutes an acceptable row count change per step?
- [ ] CHK006 [Consistency] Are row count thresholds defined for alerting on unexpected drops or spikes?

## Fan-Out Checks

- [ ] CHK007 [Completeness] Are post-join row count validation requirements specified?
- [ ] CHK008 [Clarity] Does the spec define expected cardinality for each join (1:1, 1:N, N:M)?
- [ ] CHK009 [Gap] Are fan-out guardrails specified to prevent silent row multiplication after joins?

## Schema Assertions

- [ ] CHK010 [Completeness] Are fail-fast schema assertions defined (column exists, dtype matches)?
- [ ] CHK011 [Completeness] Are key column constraints specified (not null, no duplicate keys)?
- [ ] CHK012 [Consistency] Are schema assertion failure behaviors defined (fail-fast vs. warn-and-continue)?

## Output Conventions

- [ ] CHK013 [Clarity] Are output format requirements specified (e.g., Parquet over CSV)?
- [ ] CHK014 [Consistency] Are filename conventions defined (e.g., snake_case, date-prefixed)?
- [ ] CHK015 [Coverage] Are output partitioning or bucketing strategies specified where applicable?

## Visualization Standards

- [ ] CHK016 [Completeness] Are insight-first chart title requirements defined?
- [ ] CHK017 [Completeness] Are KPI flag thresholds specified (e.g., skew beyond +/-1, null >5%, CV >30%)?
- [ ] CHK018 [Gap] Are visualization requirements defined, or does the spec lack visualization coverage?
- [ ] CHK019 [Clarity] Are P95/P99 reporting requirements specified for latency or distribution metrics?
```

Each item follows the "unit tests for English" pattern: they test whether your requirements are complete and clear, not whether your code works.

## Putting It Together

A typical workflow for a data feature:

1. **Specify**: `/speckit-specify` to write the spec
2. **Checklist**: Copy the preset above to `.specify/checklists/presets/data-pipeline.md`, then run `/speckit-checklist data-pipeline` to validate spec coverage
3. **Add constants**: If the spec declares thresholds, add a `## Constants` section
4. **Plan and implement**: The normal spex workflow
5. **Review**: The review-code gate automatically checks constants drift

Or use `/speckit-spex-ship` to run the full pipeline. The constants drift check is built into the review-code stage.
