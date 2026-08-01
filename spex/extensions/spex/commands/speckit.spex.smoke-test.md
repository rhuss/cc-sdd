---
description: "Guided Demo: synthesize user-observable flows from spec FRs, triage infrastructure, present evidence humans can evaluate"
---

# Guided Demo (speckit-spex-smoke-test)

## Overview

Synthesize user-observable demo flows from the spec's functional requirements and acceptance scenarios, triage infrastructure availability, and walk the developer through a guided demo where every piece of evidence is something they can look at and judge. Results are persisted as SMOKE-TEST.md in the spec directory.

The primary input is FR-NNN entries and acceptance scenarios from the spec. If the spec includes an optional `## Smoke Test` section, its entries are used as priority hints (which flows matter most) but never replayed literally. The skill always synthesizes its own flows from the FRs.

If all FRs describe internal behavior with no user-observable effects, the skill auto-skips with a clear message and minimal report.

<HARD-GATE>
## No Simulated Tests

You MUST NOT simulate, fake, or manually reproduce what the system under test would do. Every demo flow must exercise the actual system (run the real command, call the real API, invoke the real skill). If a flow cannot be properly tested in the current session (e.g., requires infrastructure not available, external credentials, or state that cannot be set up), you MUST:

1. Classify it honestly using the tier system (partial, setup offered, or manual)
2. For partial: present honest proxy evidence (dry-run output, request payloads, logs) with a clear disclaimer about what it proves and what it does not
3. For manual: provide concrete step-by-step instructions the user can follow later (exact commands, expected output, what to verify)

A simulated test that manually edits files to mimic system output is worse than no test. It creates false confidence.
</HARD-GATE>

<HARD-GATE>
## Always Interactive

The guided demo is ALWAYS interactive regardless of the pipeline's `--ask` level. The `--ask never` flag CANNOT auto-pass demo flows. The entire purpose of the guided demo is human validation of real system behavior. The triage table and user choices are always shown.
</HARD-GATE>

## Ship Pipeline Guard

If `.specify/.spex-state` exists and its `status` is `running`, this command is part of a ship pipeline. The guided demo is **always interactive** regardless of the `ask` level. However, it should not output a completion summary or ask "Shall I proceed?" after finishing. Complete the walkthrough and return.

```bash
PIPELINE_MODE=false
if [ -f ".specify/.spex-state" ]; then
  STATUS=$(jq -r '.status // empty' .specify/.spex-state 2>/dev/null)
  if [ "$STATUS" = "running" ]; then
    PIPELINE_MODE=true
  fi
fi
```

## Prerequisites

### Spec Resolution

Resolve the feature spec using the standard check-prerequisites script:

```bash
PREREQS=$(.specify/scripts/bash/check-prerequisites.sh --json --paths-only 2>/dev/null)
FEATURE_DIR=$(echo "$PREREQS" | jq -r '.FEATURE_DIR')
SPEC_FILE="$FEATURE_DIR/spec.md"
```

If the spec cannot be resolved, report the error and exit.

## Step 1: Load Spec and Extract Functional Requirements

Read the spec file and extract the primary inputs for demo plan synthesis.

### 1a. Extract FR-NNN Entries

Scan the spec for functional requirement entries. These follow the pattern `- **FR-NNN**:` followed by the requirement text.

```bash
FR_ENTRIES=$(grep -E '^\s*-\s+\*\*FR-[0-9]+\*\*:' "$SPEC_FILE" 2>/dev/null)
FR_COUNT=$(echo "$FR_ENTRIES" | grep -c '.' 2>/dev/null || echo "0")
```

If no FRs are found (`FR_COUNT` = 0):

```
No functional requirements (FR-NNN) found in spec. Cannot synthesize demo flows.
```

Exit without error. If in pipeline mode, return immediately.

### 1b. Extract Acceptance Scenarios

Scan the spec for acceptance scenarios. These appear under `**Acceptance Scenarios**:` headings and follow numbered patterns like `1. **Given**` or `1. **When**`.

Read the full content of each user story's acceptance scenarios to supplement FR understanding. These provide concrete examples of observable behavior that inform flow construction.

### 1c. Check for `## Smoke Test` Section (Priority Hints)

Check for an optional `## Smoke Test` section:

```bash
HAS_SMOKE_TEST=$(grep -c '^## Smoke Test' "$SPEC_FILE" 2>/dev/null || echo 0)
```

If the section exists, extract its numbered list items as **priority hints**. These hints influence the ordering of synthesized flows (hint-matching flows appear first) but do NOT replace the FR-based synthesis. The skill never replays `## Smoke Test` entries literally.

If the section does not exist, synthesis proceeds normally without priority ordering.

### 1d. Report Extraction Results

```
Guided Demo: Loaded N functional requirements from spec.
<if hints> Found M priority hints from ## Smoke Test section.
```

## Step 2: Demo Plan Synthesis

Translate FRs into user-observable demo flows using a keyword-based observability heuristic.

### 2a. FR Classification (Observable vs Internal-Only)

For each FR, determine whether it produces user-observable behavior using keyword matching:

**Observable keywords** (FR describes something a human can see or verify):
`output`, `display`, `respond`, `create`, `file`, `log`, `start`, `server`, `CLI`, `endpoint`, `UI`, `HTTP`, `API`, `print`, `write`, `generate`, `return` (when describing API responses), `screenshot`, `browser`, `page`, `render`

**Internal-only keywords** (FR describes implementation constraints):
`data structure`, `nil`, `null`, `internal`, `return value`, `function`, `constraint`, `MUST NOT`, `private`, `encapsulat`, `abstract`, `interface` (when describing code interfaces, not UI), `type`, `schema` (when describing internal data shapes)

**Classification rules:**
1. Scan the FR text (case-insensitive) for observable keywords and internal-only keywords
2. If observable keywords are found and no internal-only keywords dominate the FR's meaning, classify as **observable**
3. If only internal-only keywords are found, classify as **internal-only**
4. If the FR matches neither category clearly, **default to observable** (more inclusive, so ambiguous requirements are demonstrated rather than silently excluded). Record the keyword signal as "default (ambiguous)" in the report's classification column.

Record each FR's classification for the coverage mapping in the report. For each FR, record the matched keyword (e.g., "output", "data structure") or "default (ambiguous)" if no keyword matched.

### 2b. Auto-Skip Gate

After classification, check if ANY FRs are observable:

```
OBSERVABLE_COUNT = count of FRs classified as observable
INTERNAL_COUNT = count of FRs classified as internal-only
```

**If zero observable FRs** (`OBSERVABLE_COUNT` = 0):

Report to the user:
```
All N requirements are verified by unit tests. No user-observable flows to demo.

Internal-only FRs:
  - FR-001: <text> (keyword: data structure)
  - FR-002: <text> (keyword: MUST NOT)
  ...
```

Write a minimal SMOKE-TEST.md report (see Step 6 for the auto-skip report format) and exit without error. If in pipeline mode, return immediately so the pipeline can proceed.

**If observable FRs exist**, proceed to flow synthesis.

### 2c. Flow Grouping and Synthesis

Group related observable FRs into demo flows. The target is 3-7 flows total.

**Grouping strategy:**
1. Read each observable FR's text and its related acceptance scenarios
2. Group FRs that describe different aspects of the same user-facing feature (e.g., "server starts" and "server responds to requests" belong in one flow)
3. Keep FRs that describe independent features in separate flows

For each group, synthesize a demo flow with these fields:
- **id**: Sequential number (1-based)
- **title**: Human-readable description of what to demonstrate (e.g., "Start the CLI tool and verify help output")
- **observable_outcome**: What the human should see if the requirement works (e.g., "HTTP 200 response with JSON body containing 'status: ok'")
- **setup_steps**: Actions the skill performs before the demo (e.g., "Start the server on port 8080", "Create test data file")
- **infrastructure_needs**: External dependencies needed (e.g., "docker", "node", "curl", "browser")
- **verification_method**: What the human looks at to judge (e.g., "curl output", "file contents", "screenshot")
- **fr_coverage**: List of FR-NNN identifiers this flow covers
- **verify_yourself**: Commands the human can run to independently verify

**If more than 7 flows are synthesized**, consolidate by merging the most closely related flows until the count is 7 or fewer.

### 2d. Priority Ordering from Smoke Test Hints

If `## Smoke Test` hints were extracted in Step 1c, reorder the synthesized flows:

1. For each hint, find the flow whose title or FR coverage best matches the hint's description
2. Move matching flows to the front of the list (preserving their relative order among matches)
3. Non-matching flows follow in their original synthesis order

Report the demo plan summary:
```
Synthesized N demo flows covering M observable FRs.
K FRs classified as internal-only (verified by unit tests).
```

## Step 3: Environment Triage

Before executing any flows, probe the environment and classify each flow into a tier.

### 3a. Infrastructure Probing

For each demo flow, check its `infrastructure_needs` list sequentially:

**Probe methods:**
- **CLI tools**: `which <tool>` or `command -v <tool>`
- **Running services/ports**: `lsof -i :<port>` or `nc -z localhost <port>`
- **Docker/containers**: `which docker` or `which podman`, then check for required images/compose files
- **Database connections**: Attempt connection ping
- **Browser/Playwright**: Check if Playwright MCP tools are available in the session
- **Files/directories**: `[ -f <path> ]` or `[ -d <path> ]`

Use sequential probing with early exit: if any required infrastructure is missing, classify the flow immediately based on the first failure.

### 3b. Tier Classification

Classify each flow into one of four tiers:

| Tier | Condition | User sees |
|------|-----------|-----------|
| **full** | All infrastructure available or startable by the skill | Flow runs with full evidence |
| **partial** | Some real output available without full infrastructure (dry-run, log capture, request shape) | Proxy evidence with disclaimer |
| **setup_offered** | Infrastructure missing but the skill can provision it locally (docker-compose file, setup script detected) | Setup offer with complexity estimate |
| **manual** | No automation possible (requires VPN, physical access, external credentials) | Step-by-step instructions for later |

### 3c. Readiness Table and User Selection

Present a readiness table showing each flow's tier:

```
## Guided Demo: Readiness

| # | Flow | Tier | Detail |
|---|------|------|--------|
| 1 | Start server and verify health endpoint | full | Server startable via `make run` |
| 2 | Submit form and verify response | full | All dependencies available |
| 3 | Process webhook from gateway | setup_offered | Gateway not running (docker-compose available, ~2 min) |
| 4 | Verify dashboard renders correctly | partial | Can show request/response shape, browser not available |
| 5 | Authenticate via SSO provider | manual | Requires VPN access to identity provider |

Summary: 2 full, 1 setup offered, 1 partial, 1 manual
```

Present options using {harness:interactive-choice}:

**Question**: "How would you like to proceed with the guided demo?"

Present only options relevant to the available tiers. Omit options that have no applicable flows:

**Options** (include only if the corresponding tier exists in the readiness table):
- **"Run what's ready"** (only if full-tier flows exist): Execute full-tier flows only, skip the rest
- **"Set up missing infrastructure"** (only if setup_offered-tier flows exist): Attempt setup for "setup offered" flows before running (show per-flow complexity estimates: quick ~2 min, full ~10 min)
- **"Include partial evidence"** (only if partial-tier flows exist): Run full-tier flows plus partial-tier flows with proxy evidence and disclaimers
- **"Run everything possible"** (only if multiple tiers exist): Set up infrastructure + include partial evidence (maximum coverage)
- **"Walk through manual steps"** (only if ALL flows are manual-tier): Present manual instructions for all flows and collect verdicts
- **"Skip guided demo"** (always available): Skip entirely (record all flows as skipped in report)

For "setup offered" flows, offer complexity levels:
- **Quick setup** (docker-compose, local script): estimated time
- **Full setup** (multi-service, environment config): estimated time

If setup is attempted and fails, reclassify the flow from "setup offered" to "manual" with concrete instructions for later.

Record the user's selection. Only selected flows proceed to Step 4.

**If the user selects "Skip guided demo"**: Write a minimal SMOKE-TEST.md report recording all flows as skipped with the reason "user-skipped" before exiting. This ensures SC-004 ("every run produces a report regardless of outcome") is satisfied. The report follows the same structure as Step 6 (auto-skip) but with:
- **Result**: User-skipped
- Each flow listed with verdict SKIP and reason "Skipped by user choice"
- FR Coverage section showing all observable FRs mapped to their synthesized flows with verdict "SKIP"

Then display the results report (Step 8 format with all flows showing SKIP) and exit.

## Step 4: Demo Plan Presentation

Present the selected flows to the user before execution, allowing adjustment.

```
## Demo Plan

The following flows will be executed in order:

1. **Start server and verify health endpoint** (full)
   Covers: FR-001, FR-003
   Observable outcome: HTTP 200 response with status field

2. **Submit form and verify response** (full)
   Covers: FR-005, FR-006
   Observable outcome: Confirmation page displays with submitted data

3. **Process webhook from gateway** (setup_offered, after docker-compose setup)
   Covers: FR-008
   Observable outcome: Log entry showing processed webhook payload

Excluded (internal-only, verified by unit tests):
  - FR-002: Data validation constraint
  - FR-007: Return value format
```

{harness:interactive-choice}:

**Question**: "Proceed with this demo plan?"
**Options**:
- **"Run in this order"**: Execute flows as listed
- **"Reorder flows"**: Let user specify a different execution order
- **"Skip specific flows"**: Let user deselect individual flows
- **"Adjust and run"**: Reorder and/or skip, then execute

After any adjustments, proceed to Step 5.

## Step 5: Flow Execution

Execute each selected flow, collecting user-observable evidence and presenting verdicts.

### 5a. Flow Execution Loop

For each selected flow (in order):

1. **Announce the flow**:
   ```
   ## Flow N of TOTAL: <flow title>

   Covers: <FR-NNN list>
   Tier: <tier>
   Observable outcome: <what the human should see>
   ```

2. **Perform setup**: Execute the flow's `setup_steps` (start server, create data, navigate URL). For partial-tier flows, set up whatever proxy evidence is possible.

3. **Execute the demo action**: Run the actual system action and capture evidence. Evidence MUST be user-observable artifacts only:
   - Command output (stdout/stderr)
   - HTTP responses (status code, headers, body)
   - File contents (created or modified files)
   - Screenshots (if browser interaction via Playwright MCP)
   - Log lines (from running services)

   **Never present as evidence**: internal variable names, test assertion results, code-level state, memory addresses, struct dumps, or test framework output.

4. **Present evidence and verdict recommendation**:

   ```
   ### Evidence

   **Setup**: <what the skill did to prepare>
   **Execution**: <commands run, URLs navigated, actions taken>
   **Output**:
   ```
   <captured output, HTTP response, file contents, or screenshot description>
   ```

   **Expected** (from spec): <quote the specific FR text or acceptance scenario>
   **Actual**: <what actually happened, with concrete details>

   ### Recommendation: PASS | FAIL | SKIP | MANUAL

   **Why**: <1-2 sentences explaining the match/mismatch between expected and actual>

   **Verify yourself**:
   1. <concrete command to run>
   2. <what to look for in the output>
   ```

   For **partial-tier flows**, add a disclaimer:
   ```
   **Partial evidence disclaimer**: This flow ran without full infrastructure.
   The evidence shows <what it proves> but cannot verify <what it cannot prove>.
   ```

   The recommendation MUST be specific and evidence-based:
   - **PASS**: state exactly which expected conditions were met and how
   - **FAIL**: state exactly what differs between expected and actual
   - **SKIP**: state exactly why it cannot be tested
   - **MANUAL**: state why automation cannot cover this and provide numbered step-by-step instructions

   **Never present a bare "pass/fail/skip?" without your recommendation and reasoning.**

5. **Ask for verdict**: {harness:interactive-choice} with your recommendation as the first option:
   - **Pass**: Flow works as expected
   - **Fail**: Flow does not match expected behavior
   - **Skip**: Cannot verify right now, will test later
   - **Run manually**: Cannot automate; detailed manual steps provided above

6. **Record the verdict** with any notes the reviewer provides.

### 5b. App Startup

If a flow requires a running app and no app is currently running:

**Stale process check**: Before starting a new app, check if a previous instance is still running on common dev ports (3000, 5173, 8080, 8000) or on any ports specified in the current demo plan's `infrastructure_needs`. If a process is found, confirm with the user before killing it (the process may be unrelated to the guided demo):

```
Found a process on port NNNN (PID XXXX). This may be from a previous demo run or unrelated work.
Kill it to start fresh? (yes / no)
```

If confirmed, use SIGTERM with a 5-second timeout, then SIGKILL if needed (same escalation as Step 8).

**Check for /run skill**: Check if the `/run` skill is available in the current session. If available, delegate to it. After `/run` starts the app, identify the started process (by checking newly listening ports or process tree) and capture its PID as `APP_PID` for cleanup in Step 8. If `/run` does not expose a PID, fall back to port-based process discovery:

```bash
# Find PID by the port the app is listening on
lsof -ti :<port> 2>/dev/null
```

**Auto-detect project type** (if `/run` is not available):
1. **Makefile** with `run` or `serve` target: `make run` or `make serve`
2. **package.json** with `start` script: `npm start`
3. **go.mod**: `go run .`
4. **Python** with `manage.py`, `app.py`, or `main.py`: appropriate python command
5. **Cargo.toml**: `cargo run`

If the app starts successfully, keep it running for subsequent flows. Immediately capture the process ID (`APP_PID=$!` for direct background commands, or via port-based discovery for delegated startup) for cleanup in Step 8.

If the app **cannot be started**:
```
Cannot auto-detect how to start this project.
Please start the app manually and confirm when ready.
```
Wait for user confirmation before continuing.

### 5c. Browser Interaction (Playwright MCP)

When a flow requires browser interaction:

**If Playwright MCP is available**: Use it to navigate URLs, interact with the page (clicks, form fills, navigation), and take screenshots. Present screenshots as evidence.

**If Playwright MCP is NOT available** (graceful degradation): Provide step-by-step manual instructions instead:

```
### Browser Interaction Required (Playwright unavailable)

This flow requires browser interaction. Please perform these steps manually:

1. Open <URL> in your browser
2. <action to perform>
3. <what to look for>

After performing these steps, provide your verdict below.
```

### 5d. Failure Handling and Retry

When a flow verdict is **fail**:

1. **Offer to investigate** with tier-aware context:

   For **full-tier flows**:
   ```
   Flow failed. The system is fully available, so this indicates a real issue.
   Would you like me to investigate the cause?
   (yes / no / skip to next flow)
   ```

   For **partial-tier flows**:
   ```
   Flow failed with partial evidence. This could indicate a real issue or a limitation
   of the proxy evidence (missing infrastructure may affect behavior).
   Would you like me to investigate? (yes / no / skip to next flow)
   ```

   For **setup_offered flows** (after setup):
   ```
   Flow failed after infrastructure setup. The setup may be incomplete or the issue
   may be in the feature itself.
   Would you like me to investigate? (yes / no / skip to next flow)
   ```

2. **If yes**: Analyze the evidence, compare expected vs actual behavior, examine relevant source code, logs, or configuration. Suggest possible causes and fixes.

3. **Offer to fix**: If the cause is identified, offer to make the fix:
   ```
   I identified the issue: <description>

   Suggested fix: <what to change>

   Would you like me to apply this fix? (yes / no)
   ```

4. **Offer to retry**: After a fix is applied:
   ```
   Fix applied. Would you like to retry this flow? (yes / no)
   ```
   - If yes: re-execute the flow from scratch, collect fresh evidence, and ask for verdict again
   - Record both the initial failure and the retry result
   - Maximum 2 retries per flow. After 2 unsuccessful retries, move on:
     ```
     This flow has failed twice after fixes. Moving to the next flow.
     ```

5. **Move on**: If the user declines investigation, fix, or retry, proceed to the next flow.

### 5e. App Crash Detection

Before each flow, verify the app process is still running (if one was started):

```bash
kill -0 $APP_PID 2>/dev/null || echo "APP_CRASHED"
```

If the process is no longer running:

1. Report: "The app appears to have crashed. This may affect remaining flows."
2. Show any available crash output or error logs
3. Offer to restart the app before continuing

## Step 6: Auto-Skip Report

This section handles the case where Step 2b determined that all FRs are internal-only (zero observable flows). Write a minimal SMOKE-TEST.md and display the results.

### Minimal Report

Write to `$FEATURE_DIR/SMOKE-TEST.md`:

```markdown
# Guided Demo Report

**Feature**: <feature name from spec title>
**Date**: <YYYY-MM-DD>
**Spec**: <relative path to spec.md>
**Result**: Auto-skipped (no user-observable flows)

---

## Summary

All functional requirements describe internal behavior verified by unit tests.
No user-observable demo flows could be synthesized.

## FR Classification

| FR | Classification | Keyword Signal |
|----|---------------|----------------|
| FR-001 | internal-only | <matched keyword> |
| FR-002 | internal-only | <matched keyword> |
| ... | ... | ... |
```

### Auto-Skip Results Display

```
═══════════════════════════════════════════════════════
GUIDED DEMO RESULTS
═══════════════════════════════════════════════════════

Feature: <feature name>
Date: <YYYY-MM-DD>
Status: AUTO-SKIPPED

All N requirements are verified by unit tests.
No user-observable flows to demo.

Report: <path to SMOKE-TEST.md>

═══════════════════════════════════════════════════════
```

Exit without error. If in pipeline mode, return immediately.

## Step 7: Report Generation

After all flows are reviewed, generate `SMOKE-TEST.md` in the spec directory.

### Report Structure

```markdown
# Guided Demo Report

**Feature**: <feature name from spec title>
**Date**: <YYYY-MM-DD>
**Spec**: <relative path to spec.md>
**Result**: N passed, M skipped, K failed, J manual (out of TOTAL)

---

## Triage Summary

| Tier | Count | Detail |
|------|-------|--------|
| full | N | All infrastructure available |
| partial | M | Proxy evidence with disclaimers |
| setup_offered | K | Infrastructure provisioned during demo |
| manual | J | Manual verification instructions provided |

User selection: <what the user chose in Step 3c>

---

## Flow 1: <flow title>

**Tier**: <tier>
**Covers**: <FR-NNN list>

### Setup
<what the skill did to prepare>

### Evidence
**Execution**: <commands run, URLs navigated>
**Output**:
```
<captured output, HTTP response, or file contents>
```

### Verdict: PASS | FAIL | SKIP | MANUAL

<reviewer notes if any>

**Verify yourself**:
1. <command to run>
2. <what to look for>

---

## Flow 2: <flow title>

...

---

## FR Coverage

| FR | Flow | Verdict | Classification |
|----|------|---------|----------------|
| FR-001 | Flow 1 | PASS | observable |
| FR-002 | - | - | internal-only (verified by unit tests) |
| FR-003 | Flow 1 | PASS | observable |
| FR-004 | Flow 2 | FAIL | observable |
| FR-005 | - | - | internal-only (verified by unit tests) |
| ... | ... | ... | ... |

## Internal-Only FRs

The following FRs describe internal behavior with no user-observable effects.
They are verified by unit tests only:

- **FR-002**: <FR text> (keyword: <matched keyword>)
- **FR-005**: <FR text> (keyword: <matched keyword>)
```

### Retry Documentation

If a flow failed and was debugged/retried, include both results:

```markdown
### Verdict: PASS (after retry)

**Initial result**: FAIL
**Issue**: <description of the failure>
**Fix applied**: <what was changed>
**Retry result**: PASS

<any additional notes>
```

### Write the File

Write the report to `$FEATURE_DIR/SMOKE-TEST.md`. If a previous report exists, overwrite it (each run is a fresh validation).

Announce:
```
Guided demo report written to <relative path to SMOKE-TEST.md>.
```

## Step 8: Cleanup

**IMPORTANT: App cleanup applies at ANY exit point, not just after successful completion.** If an app was started in Step 5b, cleanup MUST be attempted regardless of how the skill exits. This includes:
- Step 1: No FRs found (exit before app start, no cleanup needed)
- Step 2b: Auto-skip (exit before app start, no cleanup needed)
- Step 3c: User selects "Skip guided demo" (exit before app start, no cleanup needed)
- Step 5: Mid-flow exit (user aborts, unrecoverable error): cleanup needed if app was started
- Step 7: Normal completion: cleanup needed if app was started

The stale process check in Step 5b serves as a safety net for sessions that terminated without cleanup (e.g., user force-quit, context loss).

### Stop the App Process

If the guided demo started the app process (tracked in Step 5b):

1. Attempt graceful shutdown with SIGTERM
2. Wait up to 5 seconds for the process to exit
3. If still running after 5 seconds, send SIGKILL
4. Report cleanup status:
   - "App process stopped gracefully."
   - "App process force-killed after timeout."
   - "App process had already exited."

If the guided demo did NOT start the app (user started it manually), do NOT attempt to stop it.

### Results Report (MANDATORY)

<HARD-GATE>
You MUST output the full results report to the console on EVERY exit path, including pipeline mode. A guided demo that runs without showing its results to a human is worthless. The human must read what was tested and what passed.
</HARD-GATE>

After cleanup, ALWAYS display the full results report. This is not optional. This applies in both manual and pipeline mode.

```
═══════════════════════════════════════════════════════
GUIDED DEMO RESULTS
═══════════════════════════════════════════════════════

Feature: <feature name>
Date: <YYYY-MM-DD>
Status: <COMPLETE | INCOMPLETE (exited early)>

Triage: N full, M partial, K setup, J manual

Flows:

  1. <verdict emoji> <flow title> [<tier>]
     Covers: <FR-NNN list>
     <evidence summary - what was done and observed>

  2. <verdict emoji> <flow title> [<tier>]
     Covers: <FR-NNN list>
     <evidence summary>

  ...

Internal-only (unit tests): FR-002, FR-005, ...

Summary: N passed, M skipped, K failed, J manual (out of TOTAL flows)
FR coverage: X of Y observable FRs demonstrated
Full report: <path to SMOKE-TEST.md>

═══════════════════════════════════════════════════════
```

**Verdict emojis:**
- Pass: checkmark
- Fail: cross mark
- Skip: skip arrow
- Manual: hand pointing right

**For each flow in the report, include:**
- The flow title and tier
- The FR coverage (which FRs this flow covers)
- The verdict (PASS / FAIL / SKIP / MANUAL)
- A one-line evidence summary (what was done and observed)
- For FAIL: expected vs. actual outcome (one line each)
- For SKIP: the skip reason and a one-line manual test instruction
- For MANUAL: numbered step-by-step instructions
- For retried flows: note "(after retry)" next to the verdict

**In pipeline mode**: Still suppress "Shall I proceed?" and next-step suggestions. But NEVER suppress the results report. The report is the whole point.

## Integration

**This command is invoked by:**
- Users directly via `/speckit-spex-smoke-test`
- The ship pipeline (Stage 8) via `/speckit-spex-ship`
- The finish command via `/speckit-spex-finish`

**This command invokes:**
- `.specify/scripts/bash/check-prerequisites.sh` (spec resolution)
- Optionally: `/run` skill (app startup delegation)
- Optionally: Playwright MCP tools (browser interaction)
