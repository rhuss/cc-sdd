# Smoke Test Report

**Feature**: Guided Demo (Smoke Test v4)
**Date**: 2026-08-01
**Spec**: specs/049-guided-demo/spec.md
**Result**: 0 passed, 3 skipped, 0 failed (out of 3)

---

## Scenario 1: Run the guided demo against a spec with observable FRs

> Run the guided demo against a spec with observable FRs (CLI tool or server feature) and verify the synthesis produces human-readable flows with real system evidence, not test names or internal state.

### Evidence

**Setup**: This is a meta-test. The guided demo IS the skill being implemented. It cannot test itself in the same session.
**Execution**: Reviewed the skill file for compliance with the scenario's requirements.
**Output**: The skill file defines FR synthesis (Step 2), keyword heuristic (Step 2a), observable-only evidence (Step 5a, HARD-GATE), and human-readable flow fields (title, observable_outcome, verify_yourself).

### Verdict: SKIP

Cannot run the guided demo skill against itself. Requires a separate session after deployment with a spec containing observable FRs for a running artifact.

**Manual test instructions**:
1. After merging, find a feature with observable FRs (CLI tool or server)
2. Run `/speckit-spex-smoke-test`
3. Verify synthesis produces human-readable flows with real system evidence
4. Check SMOKE-TEST.md includes FR coverage mapping

---

## Scenario 2: Run the guided demo against a spec requiring missing infrastructure

> Run the guided demo against a spec that requires missing infrastructure and verify the triage table offers tiered options including setup.

### Evidence

**Setup**: Same meta-test limitation.
**Execution**: Reviewed the skill file's triage logic (Step 3).
**Output**: The skill defines four-tier classification (full/partial/setup_offered/manual), readiness table (Step 3c), tier-aware interactive options, and complexity estimates for setup flows.

### Verdict: SKIP

Cannot simulate missing infrastructure triage within the same session. Requires a spec with infrastructure dependencies not present.

**Manual test instructions**:
1. Find a spec requiring infrastructure not present (e.g., a gateway, database)
2. Run `/speckit-spex-smoke-test`
3. Verify triage table shows tiers, "setup offered" flows show estimates
4. Verify options adapt to available tiers (no "Run what's ready" when nothing is ready)

---

## Scenario 3: Run the guided demo against a pure library spec

> Run the guided demo against a pure library spec (no observable FRs) and verify it auto-skips cleanly.

### Evidence

**Setup**: Same meta-test limitation.
**Execution**: Reviewed the skill file's auto-skip logic (Step 2b, Step 6).
**Output**: The skill checks `OBSERVABLE_COUNT = 0`, reports "All N requirements are verified by unit tests", writes minimal SMOKE-TEST.md, and exits without error.

### Verdict: SKIP

Cannot test auto-skip without a separate pure-library spec. The logic is straightforward and verifiable from the skill text.

**Manual test instructions**:
1. Create a spec with only internal FRs (data structure shapes, nil checks)
2. Run `/speckit-spex-smoke-test`
3. Verify message "All requirements are verified by unit tests"
4. Verify minimal SMOKE-TEST.md is written with FR classification table
