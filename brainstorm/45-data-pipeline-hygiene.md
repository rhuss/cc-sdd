# Brainstorm: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Date:** 2026-08-02
**Status:** active
**Issue:** https://github.com/rhuss/cc-spex/issues/49

## Problem Framing

When a spec covers data work (ETL steps, dashboards, corpus builds), the same quality checks come up every time: schema assertions, row-count logging, fan-out checks after joins, lineage notes. These checks are well-known data-engineering hygiene, but today they have to be remembered and re-typed for each feature. spex already has the machinery (checklists, coverage matrix, drift gates) but lacks the domain-specific content for data pipelines.

A second, related problem: when a spec declares constants that both code and docs depend on (a palette, thresholds, a schema), those constants tend to drift apart over time. The plan should point them at one code module, and the review-code gate should verify the code still matches the spec.

## Approaches Considered

### A: Preset Files in Checklist Skill (original, rejected)

Modify the upstream speckit-checklist skill to load preset files by name.

- Pros: Clean integration, two-level override system (built-in + project)
- Cons: **Requires modifying upstream spec-kit code.** The checklist skill is from spec-kit and we don't control it.

### B: Standalone Extension Command (chosen, short-term)

Create a new spex extension command (`speckit-spex-data-checklist`) that generates data-pipeline-specific checklist items directly. Separate from the upstream checklist skill, self-contained in a spex extension.

- Pros: Self-contained, no upstream dependency. Full control over items. Works today.
- Cons: Duplicates some checklist generation logic. Users need to know about a different command name.

### C: Upstream Preset System (long-term, parallel)

Propose a preset mechanism to spec-kit upstream so that `/speckit-checklist data-pipeline` can load domain-specific preset files natively. Two-level system: built-in presets as defaults, project-level overrides in `.specify/checklists/presets/`.

- Pros: The right long-term architecture. Benefits all spec-kit users, not just spex.
- Cons: Depends on upstream acceptance and timeline.

### Drift Rule Approaches

For the shared-constants drift check, three approaches were considered:

1. **review-code gate enhancement (chosen):** Add a "Spec-Declared Constants" section to the existing review-code gate. When the spec declares constants, the gate checks code defines them in one module and values match.
2. **Separate drift-check command:** New standalone command. Rejected as over-engineered for a single check.
3. **Plan-level enforcement only:** Just planning guidance. Rejected because it doesn't leverage existing gate machinery.

## Decision

**Hybrid B+C:** Ship the extension command as a short-term solution, propose the preset system to spec-kit upstream in parallel. When upstream ships presets, the extension command gets retired.

Specifically:
1. **New spex extension command** (`speckit-spex-data-checklist`) in a spex extension, generating data-pipeline checklist items using the same "unit tests for English" philosophy as the upstream checklist
2. **review-code gate enhancement** for spec-declared constants drift detection (check one-module consolidation, value matching)
3. **Upstream issue/PR** proposing preset system for speckit-checklist (two-level: built-in + project override)

## Key Requirements

### Data-Pipeline Checklist Items

The checklist preset covers these requirement-quality checks:

- **Lineage:** Are lineage docstrings (source / pipeline / schedule / owner) required for each transform?
- **Row counts:** Are row count logging requirements defined for before and after every transform?
- **Fan-out checks:** Are post-join row count validation requirements specified?
- **Schema assertions:** Are fail-fast schema assertions defined (column exists, dtype matches, key columns not null, no duplicate keys)?
- **Output conventions:** Are output format requirements specified (Parquet over CSV, snake_case + date-prefixed filenames)?
- **Viz conventions:** Are insight-first chart title requirements defined? Are KPI flag thresholds specified (skew beyond +/-1, null >5%, CV >30%, P95/P99 reporting)?

### Preset System (two-level)

- Built-in presets ship alongside the checklist skill/command
- Project-level presets in `.specify/checklists/presets/` override built-ins
- Single `data-pipeline` preset covers all items (no split into sub-presets)

### Shared-Constants Drift Rule

- Scope: spec-declared constants only (not proactive duplication detection)
- Location: enhancement to the existing review-code gate
- Check: (a) constants defined in a single code module, (b) values match spec declarations

## Open Questions

- What format should the spec use to declare constants? (e.g., a `## Constants` section, a YAML block, inline annotations)
- Should the extension command live in the existing `spex-gates` extension or a new `spex-data` extension?
- What's the migration path when upstream presets land? (deprecation notice, automatic fallback)
