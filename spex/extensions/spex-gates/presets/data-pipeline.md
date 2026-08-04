# Data-Pipeline Hygiene Checklist

**Preset**: data-pipeline
**Version**: 1.0.0
**Categories**: Lineage, Row Counts, Fan-Out, Schema, Output Conventions, Visualization

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
