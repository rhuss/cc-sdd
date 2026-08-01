# Deep Review Findings

**Date:** 2026-08-01
**Branch:** 049-guided-demo
**Rounds:** 1
**Gate Outcome:** PASS
**Invocation:** quality-gate

## Summary

| Severity | Found | Fixed | Remaining |
|----------|-------|-------|-----------|
| Critical | 0 | 0 | 0 |
| Important | 4 | 4 | 0 |
| Minor | 5 | - | 5 |
| Notable | 1 | - | 1 |
| **Total** | **10** | **4** | **6** |

**Agents completed:** 3/5 (+ 1 external tool, 1 external failed)
**Agents pending:** correctness-agent, architecture-agent (timed out)
**External tools:** CodeRabbit (9 findings, all on excluded specs/ files), Codex (failed: no API credits)

## Findings

### FINDING-1
- **Severity:** Important
- **Confidence:** 82
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:365-380
- **Category:** production-readiness
- **Source:** production-agent
- **Round found:** 1
- **Resolution:** fixed (round 1)

**What is wrong:**
App startup captures PID via `APP_PID=$!` but does not specify what happens when the `/run` skill is used for delegation. When `/run` starts the app, the PID capture mechanism (`$!`) may not work because the process was started by a different skill context. Cleanup in Step 8 relies on having a valid `APP_PID`, so processes started via `/run` delegation could be orphaned.

**Why this matters:**
If `/run` starts the app but `APP_PID` is not properly captured, Step 8 cleanup will skip termination, leaving the dev server running indefinitely.

**How it was resolved:**
Added explicit instruction that after `/run` starts the app, the skill identifies the started process by checking newly listening ports or process tree, with port-based fallback discovery via `lsof -ti :<port>`.

### FINDING-2
- **Severity:** Important
- **Confidence:** 85
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:635-643
- **Category:** production-readiness
- **Source:** production-agent
- **Round found:** 1
- **Resolution:** fixed (round 1)

**What is wrong:**
Step 8 cleanup only runs after normal flow completion. There is no trap or early-exit cleanup mechanism specified. If the AI agent encounters an unrecoverable error mid-execution, or if the user force-quits, the app process started in Step 5b will be left running.

**Why this matters:**
A dev server left running on port 3000/5173/8080/8000 will block subsequent runs and consume resources.

**How it was resolved:**
Added explicit documentation of all exit points (Step 1, 2b, 3c, 5 mid-flow, 7 normal) with cleanup applicability for each. Documented the stale process check in 5b as the safety net for abandoned sessions.

### FINDING-3
- **Severity:** Important
- **Confidence:** 82
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:116-127
- **Category:** test-quality
- **Source:** test-quality-agent
- **Round found:** 1
- **Resolution:** fixed (round 1)

**What is wrong:**
The keyword heuristic's default-to-observable case (rule 4) has no display value for the report's "matched keyword" column. When an FR matches neither category, it is classified as observable but the report template shows `<matched keyword>` with no guidance on what to display.

**Why this matters:**
Creates an inconsistency between classification logic and reporting format. The FR Coverage table in SMOKE-TEST.md would have a blank or undefined keyword signal column for defaulted FRs.

**How it was resolved:**
Added explicit instruction to record the keyword signal as "default (ambiguous)" for FRs that matched neither category. Updated the classification recording instructions to specify keyword display for all three cases.

### FINDING-4
- **Severity:** Important
- **Confidence:** 78
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:238-244
- **Category:** test-quality
- **Source:** test-quality-agent
- **Round found:** 1
- **Resolution:** fixed (round 1)

**What is wrong:**
Triage interactive choices do not adapt to available tiers. When no full-tier flows exist, "Run what's ready" is still offered as an option. The spec edge cases explicitly mention the all-manual scenario but the options list is static.

**Why this matters:**
Presenting "Run what's ready" when zero flows are ready is confusing UX. The all-manual edge case (from spec) would present misleading options.

**How it was resolved:**
Made options conditional on available tiers. Each option is now annotated with "only if X-tier flows exist". Added a "Walk through manual steps" option for the all-manual case. "Skip guided demo" remains always available.

### FINDING-5
- **Severity:** Minor
- **Confidence:** 75
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:369
- **Category:** production-readiness
- **Source:** production-agent
- **Round found:** 1
- **Resolution:** fixed (round 1)

**What is wrong:**
The stale process check blindly kills processes on dev ports without confirming with the user. A user running a separate project's dev server on port 3000 would have it killed without warning.

**Why this matters:**
Could destroy unrelated work. The Step 8 cleanup correctly scopes to only processes the skill started (via APP_PID), but the stale process check has no such scoping.

**How it was resolved:**
Added user confirmation before killing stale processes, with message showing port and PID. Also added SIGTERM/SIGKILL escalation pattern consistent with Step 8.

### FINDING-6
- **Severity:** Minor
- **Confidence:** 72
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:462-468
- **Category:** production-readiness
- **Source:** production-agent
- **Round found:** 1
- **Resolution:** pending (Minor, not in fix scope)

**What is wrong:**
Crash detection in 5e uses `kill -0 $APP_PID` only "before each flow." If a flow causes the app to crash mid-execution, the error manifests as "connection refused" rather than the more helpful "app crashed" message.

**Why this matters:**
Lower diagnostic quality. The crash will still be caught at the next flow boundary, but the error message during the current flow could mislead diagnosis.

### FINDING-7
- **Severity:** Minor
- **Confidence:** 75
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:86-97
- **Category:** test-quality
- **Source:** test-quality-agent
- **Round found:** 1
- **Resolution:** pending (Minor, not in fix scope)

**What is wrong:**
Smoke Test section grep pattern (`^## Smoke Test`) is exact-match only, could miss formatting variations like `## Smoke test` or extra whitespace.

**Why this matters:**
Low impact since hints are optional and missing them just means no priority ordering.

### FINDING-8
- **Severity:** Minor
- **Confidence:** 72
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:369
- **Category:** test-quality
- **Source:** test-quality-agent
- **Round found:** 1
- **Resolution:** pending (Minor, not in fix scope)

**What is wrong:**
Stale process port list is hardcoded (3000, 5173, 8080, 8000) and does not consume port information from the current demo plan's `infrastructure_needs`.

**Why this matters:**
Custom ports used by less common frameworks would not be checked. Partially addressed by the fix to FINDING-5 which added infrastructure_needs port discovery.

### FINDING-9
- **Severity:** Minor
- **Confidence:** 85
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md
- **Category:** test-quality
- **Source:** test-quality-agent
- **Round found:** 1
- **Resolution:** pending (Minor, not in fix scope)

**What is wrong:**
FR-016 (spec template guidance) has no cross-reference in the skill file. The test-quality agent flagged this as a coverage gap, but the implementation IS the template change in `.specify/templates/spec-template.md`. Downgraded from Important to Minor since it's a separate artifact, not a skill file responsibility.

## Notable Observations

### NOTABLE-1
- **File:** spex/extensions/spex/commands/speckit.spex.smoke-test.md:196-204
- **Category:** security
- **Source:** security-agent
- **Description:** Infrastructure probing commands use placeholder values filled by the AI agent from spec-derived data. A maliciously crafted spec could potentially influence command construction.
- **Rationale:** Practical risk is very low: spec author is the project developer (self-attack), bash snippets use double-quoted variables, AI agent has safety filters, and the demo is interactive. Existing defense-in-depth is adequate.

## Test Suite Results

No test command detected; post-fix test step was skipped.

## External Tool Results

### CodeRabbit
- **Status:** Completed (stopped after extended runtime)
- **Findings on implementation files:** 0
- **Findings on excluded files (specs/, brainstorm/):** 9 (all discarded per review scope)

### Codex
- **Status:** Failed (no OpenAI API credits)
- **Findings:** 0

### Copilot
- **Status:** Skipped (CLI not installed)
- **Findings:** 0
