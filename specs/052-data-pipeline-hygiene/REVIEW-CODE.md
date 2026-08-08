# Code Review: Data-Pipeline Hygiene Checklist + Shared-Constants Drift Rule

**Spec:** specs/052-data-pipeline-hygiene/spec.md
**Date:** 2026-08-04
**Reviewer:** Claude (speckit.spex-gates.review-code)

## Compliance Summary

**Overall Score: 96%**

- Functional Requirements: 11/12 (92%)
- Error Handling: 4/4 (100%)
- Edge Cases: 4/4 (100%)
- Documentation: 3/3 (100%)

## Detailed Review

### Functional Requirements

#### FR-001: `/speckit-spex-gates-data-checklist` command
**Implementation:** `spex/extensions/spex-gates/commands/speckit.spex-gates.data-checklist.md`
**Status:** Compliant
**Notes:** Full command file with 6-step generation process, registered in extension.yml

#### FR-002: "Unit tests for English" philosophy
**Implementation:** `spex/extensions/spex-gates/presets/data-pipeline.md` + command Step 3
**Status:** Compliant
**Notes:** All 19 preset items are requirement-quality questions with category tags

#### FR-003: Six hygiene categories
**Implementation:** `spex/extensions/spex-gates/presets/data-pipeline.md`
**Status:** Compliant
**Notes:** All six sections present: Lineage Docstrings, Row Count Logging, Fan-Out Checks, Schema Assertions, Output Conventions, Visualization Standards

#### FR-004: Project-level preset override
**Implementation:** `speckit.spex-gates.data-checklist.md` Step 2
**Status:** Compliant
**Notes:** Checks `.specify/checklists/presets/data-pipeline.md` first, falls back to built-in. Explicit "no merging" policy.

#### FR-005: Built-in preset at `spex/extensions/spex-gates/presets/data-pipeline.md`
**Implementation:** `spex/extensions/spex-gates/presets/data-pipeline.md`
**Status:** Compliant
**Notes:** 19 items with CHK001-CHK019 traceability markers across 6 categories

#### FR-006: Constants check activates on `## Constants` section
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b
**Status:** Compliant
**Notes:** "This check activates ONLY when the spec contains a `## Constants` section"

#### FR-007: Verify constants in single code module
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b, point 3
**Status:** Compliant
**Notes:** Consolidation check tracks files per constant, reports multi-file findings

#### FR-008: Verify constant values match spec
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b, point 2
**Status:** Compliant
**Notes:** Trimmed string comparison with DRIFT reporting format

#### FR-009: Report findings with file paths, spec/code values
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b
**Status:** Compliant
**Notes:** DRIFT format includes `${SPEC_VALUE}`, `${CODE_VALUE}`, `${FILE_PATH}:${LINE}` plus compliance table

#### FR-010: Skip silently when no `## Constants` section
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b
**Status:** Compliant
**Notes:** Explicit guard: "skip this entire step silently (zero false positives, per FR-010)"

#### FR-011: Auto-detect spec via `check-prerequisites.sh`
**Implementation:** `speckit.spex-gates.data-checklist.md` Step 1
**Status:** Compliant
**Notes:** Uses `check-prerequisites.sh --json --paths-only`, parses FEATURE_DIR and FEATURE_SPEC

#### FR-012: Upstream issue on spec-kit proposing preset system
**Implementation:** N/A
**Status:** MISSING
**Notes:** No issue found on github/spec-kit for preset/checklist system. The spec's Assumptions section notes this "does not block shipping the extension command." This is an external deliverable (documentation work), not code.

### Error Handling

#### EH-001: check-prerequisites.sh failure
**Implementation:** `speckit.spex-gates.data-checklist.md` Step 1
**Status:** Compliant
**Notes:** "ERROR: Could not resolve feature directory. This command must be run from a feature branch with a matching spec directory."

#### EH-002: Built-in preset missing
**Implementation:** `speckit.spex-gates.data-checklist.md` Step 2
**Status:** Compliant
**Notes:** Error references expected path and suggests `/spex:init` to reinstall

#### EH-003: Output directory creation failure
**Implementation:** `speckit.spex-gates.data-checklist.md` Step 4
**Status:** Compliant
**Notes:** "ERROR: Could not create directory ... Check filesystem permissions."

#### EH-004: Unparseable Constants entries
**Implementation:** `speckit.spex-gates.review-code.md` Step 7b Rules
**Status:** Compliant
**Notes:** "Lines that do not match either supported format MUST be skipped with a warning listing the unparseable lines"

### Edge Cases

#### EC-001: No data-pipeline content in spec
**Status:** Compliant
**Notes:** Command Step 3 scans for category terms; unmatched categories use gap-detection framing

#### EC-002: Project preset fully replaces built-in
**Status:** Compliant
**Notes:** Step 2 explicit: "project-level fully replaces built-in, no merging"

#### EC-003: Inconsistent Constants formatting
**Status:** Compliant
**Notes:** Regex handles both `- NAME = value` and `- NAME: value` patterns

#### EC-004: Range/threshold expressions as constant values
**Status:** Compliant
**Notes:** "Values are compared as strings, not parsed numerically. Threshold expressions like `>5%` or `+/-1` are valid values"

### Documentation Updates

#### README.md
**Status:** Compliant
**Notes:** Added data-checklist to spex-gates description and commands table; added constants drift mention to review-code description

#### help.md
**Status:** Compliant
**Notes:** Added data-checklist command entry under spex-gates extension; added constants drift check note to review-code entry

#### extension.yml
**Status:** Compliant
**Notes:** Registered `speckit.spex-gates.data-checklist` command with file reference and description

### Extra Features (Not in Spec)

No extra features were identified. All implemented functionality maps directly to spec requirements.

## Code Quality Notes

- The preset file uses a clean, consistent format with traceability markers (CHK001-CHK019) and category tags
- The command follows the same step-by-step pattern as other spex-gates commands
- The constants drift check is well-integrated into the existing review-code flow at Step 7b, between report generation and deep review
- The `awk`/`sed`/`grep` parsing approach for Constants is appropriate for the documented simple formats

## Recommendations

### Post-Ship Action Items
- [ ] FR-012: Create upstream issue on github/spec-kit proposing native preset system for `/speckit-checklist`

### Spec Evolution Candidates
- None identified

### Optional Improvements
- None identified

## Deep Review Report

### Review Agents Summary

| Agent | Findings | Critical | Important | Minor | Fixed |
|-------|----------|----------|-----------|-------|-------|
| Correctness | 1 | 1 | 0 | 0 | 1 |
| Architecture | 3 | 0 | 1 | 2 | 3 |
| Security | 0 | 0 | 0 | 0 | 0 |
| Production | 3 | 0 | 0 | 3 | 0 |
| Test Quality | 3 | 0 | 2 | 1 | 2 |

### External Tools

| Tool | Findings | In-Scope | Fixed |
|------|----------|----------|-------|
| CodeRabbit | 4 | 4 | 4 |
| Codex | 1 | 1 | 1 |

### Critical/Important Findings (all fixed in `d80ca91`)

1. **CRITICAL (Correctness + CodeRabbit + Codex)**: awk range pattern `/^## Constants$/,/^## /` self-terminates because `## Constants` matches both start and end of the range. Constants parsing produced only the heading line, discarding all declarations.
   - **Fix**: Changed to `awk '/^## Constants$/{found=1; next} /^## /{found=0} found{print}'`

2. **IMPORTANT (CodeRabbit)**: Consolidation check was per-constant instead of cross-constant.
   - **Fix**: Changed to collect union of all defining files across all constants, report single finding if >1 file.

3. **IMPORTANT (CodeRabbit)**: grep filter silently dropped unparseable lines with no warning.
   - **Fix**: Added second awk+grep pass that warns about non-matching, non-empty lines.

4. **IMPORTANT (Architecture)**: Compliance score calculated in Step 6 before Step 7b constants check, stale score in Step 8 threshold.
   - **Fix**: Added explicit recalculation instruction after Step 7b.

5. **IMPORTANT (Test Quality)**: `test_marketplace_install.sh` missing data-checklist command and presets directory.
   - **Fix**: Added both entries to `EXPECTED_EXT_COMMANDS`.

### Minor Findings (accepted or deferred)

1. **Minor (Architecture)**: Missing Ship Pipeline Guard. **Fixed**: Added standard guard boilerplate.
2. **Minor (Architecture)**: Extension description stale. **Fixed**: Updated to include domain checklists.
3. **Minor (Production)**: Per-line sed spawning O(n). **Accepted**: Constants sections naturally bounded.
4. **Minor (Production)**: awk boundary lines passed to grep. **Accepted**: Defense-in-depth, grep handles correctly.
5. **Minor (Production)**: `cat "$FEATURE_SPEC"` loads full spec. **Accepted**: Files bounded by human authoring.
6. **Minor (Test Quality)**: US1-S2 passes trivially. **Deferred**: Spec can clarify in future iteration.

### Security Review

Zero findings. All variable interpolation constrained: NAME regex `[A-Z_]+` only, VALUE never in shell commands.

## Conclusion

Implementation is 96% compliant with the specification. The single non-compliant item (FR-012) is an external deliverable (upstream issue creation) that the spec explicitly notes does not block shipping. All code deliverables, error handling, edge cases, and documentation are fully compliant. All critical and important deep review findings have been fixed.
