# Guided Demo Report

**Feature**: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule
**Date**: 2026-08-08
**Spec**: spec.md
**Result**: 4 passed, 0 skipped, 0 failed, 0 manual (out of 4)

---

## Triage Summary

| Tier | Count | Detail |
|------|-------|--------|
| full | 4 | All infrastructure available |

User selection: Run what's ready

---

## Flow 1: Run data-checklist command and verify output

**Tier**: full
**Covers**: FR-001, FR-003, FR-005, FR-011

### Setup
Installed preset to `.specify/extensions/spex-gates/presets/` (fixed missing installation step). Ran the command logic against the current spec.

### Evidence
**Execution**: Read preset, generated checklist at `specs/052-data-pipeline-hygiene/checklists/data-pipeline.md`
**Output**: 19 checklist items across all 6 categories (Lineage: 3, Row Counts: 3, Fan-Out: 3, Schema: 3, Output: 3, Viz: 4)

### Verdict: PASS

19 items generated, all 6 categories present, all follow "Are X defined/specified?" pattern. Exceeds the SC-001 minimum of 15 items.

**Note**: Discovered that `presets/` directory is not copied during `specify extension add`. The preset file must be manually installed to `.specify/extensions/spex-gates/presets/`.

**Verify yourself**:
1. Check `specs/052-data-pipeline-hygiene/checklists/data-pipeline.md` exists
2. Count items: `grep -c '^\- \[ \]' specs/052-data-pipeline-hygiene/checklists/data-pipeline.md` (should be >= 15)

---

## Flow 2: Verify project-level preset override

**Tier**: full
**Covers**: FR-004

### Setup
Created a custom project-level preset at `.specify/checklists/presets/data-pipeline.md` with 3 project-specific items (CUSTOM001-003).

### Evidence
**Execution**: Ran preset resolution logic. Project preset selected over built-in.
**Output**: 3 items (custom only). Built-in 19 items completely replaced, not merged.

### Verdict: PASS

Project-level override works correctly. Full replacement confirmed (3 items, not 22 merged).

**Verify yourself**:
1. Create `.specify/checklists/presets/data-pipeline.md` with custom items
2. Run the command and verify only custom items appear

---

## Flow 3: Verify built-in preset content quality

**Tier**: full
**Covers**: FR-002, FR-005

### Setup
Read the built-in preset at `spex/extensions/spex-gates/presets/data-pipeline.md`.

### Evidence
**Execution**: Ran 5 content quality checks against all 19 items.
**Output**:
- 19/19 items use requirement-quality question pattern ("Are/Does/Is")
- 19/19 items have category tags ([Completeness/Clarity/Consistency/Coverage/Gap])
- 19/19 items have CHK identifiers (CHK001-CHK019)
- 0 items use prohibited implementation-testing language
- 6 category sections matching spec requirements

### Verdict: PASS

All items pass every content quality check. Zero violations.

**Verify yourself**:
1. Read `spex/extensions/spex-gates/presets/data-pipeline.md`
2. Verify all items start with "Are", "Does", or "Is"
3. Verify no items use "Verify", "Test", "Confirm", "Check"

---

## Flow 4: Verify upstream preset proposal draft

**Tier**: full
**Covers**: FR-012

### Setup
Checked draft file at `specs/052-data-pipeline-hygiene/upstream-preset-proposal.md`.

### Evidence
**Execution**: Verified presence of all 5 required content sections.
**Output**: All sections present: Problem Statement, Proposed Solution, Project-Level Override, Migration Path, Motivating Use Case.

### Verdict: PASS

Draft is complete with all required content.

**Verify yourself**:
1. Read `specs/052-data-pipeline-hygiene/upstream-preset-proposal.md`
2. Verify sections: Problem Statement, Proposed Solution, Migration Path, Motivating Use Case

---

## FR Coverage

| FR | Flow | Verdict | Classification |
|----|------|---------|----------------|
| FR-001 | Flow 1 | PASS | observable |
| FR-002 | Flow 3 | PASS | observable |
| FR-003 | Flow 1 | PASS | observable |
| FR-004 | Flow 2 | PASS | observable |
| FR-005 | Flow 1, 3 | PASS | observable |
| FR-006 | - | - | internal-only (verified by unit tests) |
| FR-007 | - | - | internal-only (verified by unit tests) |
| FR-008 | - | - | internal-only (verified by unit tests) |
| FR-009 | - | - | internal-only (verified by unit tests) |
| FR-010 | - | - | internal-only (verified by unit tests) |
| FR-011 | Flow 1 | PASS | observable |
| FR-012 | Flow 4 | PASS | observable |

## Internal-Only FRs

The following FRs describe internal behavior within the review-code gate. They are verified by the gate's own execution, not by standalone commands:

- **FR-006**: Constants check activation (keyword: "check that activates")
- **FR-007**: Single-module verification logic (keyword: "verify", "defined")
- **FR-008**: Value matching logic (keyword: "verify", "values match")
- **FR-009**: Finding report format (keyword: "report findings")
- **FR-010**: Silent skip behavior (keyword: "skip silently")
