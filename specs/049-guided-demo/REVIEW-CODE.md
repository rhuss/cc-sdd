# Code Review: Guided Demo (049-guided-demo)

**Spec:** specs/049-guided-demo/spec.md
**Date:** 2026-08-01
**Reviewer:** Claude (speckit.spex-gates.review-code + spex-deep-review)

## Compliance Summary

**Overall Score: 100%**

- Functional Requirements: 20/20 (100%)
- Error Handling: covered (all edge cases addressed)
- Edge Cases: 6/6 (100%)
- Non-Functional: covered (always-interactive, no-simulation gates)

### Functional Requirements Compliance Matrix

| FR | Requirement Summary | Implementation | Status |
|----|-------------------|----------------|--------|
| FR-001 | Synthesize from FRs, not Smoke Test section | Step 1a + Step 2 | Compliant |
| FR-002 | Smoke Test as priority hints only | Step 1c + Step 2d | Compliant |
| FR-003 | Determine observable outcome per FR | Step 2a + Step 2c (observable_outcome field) | Compliant |
| FR-004 | Group into 3-7 flows | Step 2c (consolidation at >7) | Compliant |
| FR-005 | Exclude internal-only FRs | Step 2a + Step 2b | Compliant |
| FR-006 | Present plan before execution, allow adjust | Step 4 (interactive choices) | Compliant |
| FR-007 | Four-tier classification | Step 3b (full/partial/setup offered/manual) | Compliant |
| FR-008 | Present readiness table with options | Step 3c | Compliant |
| FR-009 | Multiple complexity levels for setup | Step 3c (quick/full setup) | Compliant |
| FR-010 | Honest proxy evidence with disclaimer | Step 5a (partial disclaimer) | Compliant |
| FR-011 | Evidence must be user-observable only | Step 5a + HARD-GATE (no simulation) | Compliant |
| FR-012 | Verdict recommendation with reasoning | Step 5a (PASS/FAIL/SKIP/MANUAL) | Compliant |
| FR-013 | Auto-skip + minimal report | Step 2b + Step 6 | Compliant |
| FR-014 | SMOKE-TEST.md with FR coverage mapping | Step 7 (full report structure) | Compliant |
| FR-015 | "Guided Demo" in user-facing output | Title, report headers, results display | Compliant |
| FR-016 | Template guidance with examples | .specify/templates/spec-template.md | Compliant |
| FR-017 | No simulation/faking | HARD-GATE (lines 15-25) | Compliant |
| FR-018 | Failure handling with max 2 retries | Step 5d (tier-aware retry) | Compliant |
| FR-019 | Always interactive in pipeline | HARD-GATE (lines 27-31) | Compliant |
| FR-020 | Keyword heuristic, default-to-observable | Step 2a (keyword lists + rule 4) | Compliant |

### Extra Features (Not in Spec)

| Feature | Location | Assessment |
|---------|----------|------------|
| App startup auto-detection | Step 5b | Helpful (supports flow execution) |
| App crash detection | Step 5e | Helpful (robustness) |
| Playwright graceful degradation | Step 5c | Helpful (per spec assumptions) |
| Stale process check | Step 5b | Helpful (safety net) |

## Deep Review Report

**Gate:** PASS (after fix round 1)
**Rounds:** 1/3
**Agents:** 5/5 completed

### Review Agents

| Agent | Found | Fixed | Remaining | Status |
|-------|-------|-------|-----------|--------|
| Correctness | 4 | 2 | 2 | completed |
| Architecture & Idioms | 5 | 0 | 5 | completed (4 Minor, 1 Notable) |
| Security | 1 | 0 | 1 | completed (1 Notable) |
| Production Readiness | 4 | 3 | 1 | completed |
| Test Quality | 5 | 2 | 3 | completed |
| CodeRabbit (external) | 0 | 0 | 0 | completed (9 findings on excluded specs/ files) |
| Copilot (external) | 0 | 0 | 0 | skipped (CLI not installed) |
| Codex (external) | 0 | 0 | 0 | failed (no API credits) |
| Test Suite (regression) | 0 | 0 | 0 | skipped (no test command) |
|-------|-------|-------|-----------|--------|
| Total | 19 | 7 | 12 | |

MVP: Architecture & Idioms / Test Quality (5 findings each)

### Key Fixes Applied

1. **PID capture for /run delegation** (production-agent): Added port-based PID discovery fallback when `/run` skill starts the app, preventing orphaned processes.
2. **Cleanup at all exit points** (production-agent): Documented all exit paths and cleanup applicability. Stale process check serves as safety net for abandoned sessions.
3. **Default-to-observable keyword display** (test-quality-agent): Added "default (ambiguous)" as the keyword signal for FRs matching neither category.
4. **Tier-aware triage options** (test-quality-agent): Made interactive options conditional on available tiers. Added "Walk through manual steps" for all-manual scenario.
5. **Stale process confirmation** (production-agent): Added user confirmation before killing processes on dev ports to avoid destroying unrelated work.
6. **Retry limit enforcement** (correctness-agent): Removed "try once more" offer after 2 retries; now enforces hard stop at max 2, matching FR-018.
7. **User-skip report generation** (correctness-agent): Added SMOKE-TEST.md report generation when user selects "Skip guided demo", satisfying SC-004 (report on every run).

### Remaining Findings (10 Minor, 2 Notable)

Minor findings (informational, not blocking):
- Crash detection only at flow boundaries, not mid-flow (production, low impact)
- Smoke Test grep exact-match only (test-quality, hints are optional)
- Stale process port list partially hardcoded (test-quality, mitigated by fix)
- FR-016 template cross-reference (test-quality, downgraded, template IS the implementation)
- FR extraction `grep -c '.'` edge case on empty string (correctness, shell portability)
- Keyword lists embedded inline, harder to find for tuning (architecture)
- Pipeline guard pattern duplicated from finish.md (architecture, 5 lines)
- Redundant MANDATORY heading + HARD-GATE wrapper (architecture)
- App startup auto-detect overlaps with /run skill (architecture, low risk)
- PID capture for /run already addressed in fix (correctness, duplicate of production fix)

Notable observations (informational):
- AI prompt injection via malicious spec content (security, self-attack scenario, very low risk)
- Integration section is a useful pattern worth backporting to other commands (architecture, positive)

### External Tool Analysis

**CodeRabbit**: Ran against committed changes. All 9 findings targeted files under `specs/` and `brainstorm/` (spec artifacts excluded from code review scope). 0 findings on implementation files.

**Codex**: Failed due to depleted OpenAI API credits. No findings produced.

**Copilot**: CLI not installed. Skipped.

## Conclusion

Spec compliance is 100% (20/20 FRs). Deep review across all 5 agents found 6 Important issues (all fixed in round 1): retry limit enforcement (FR-018), user-skip report gap (SC-004), process management for /run delegation, cleanup scoping, triage option UX, and report format consistency. 10 Minor + 2 Notable findings remain as informational items. Gate passes.

Details: specs/049-guided-demo/review-findings.md
