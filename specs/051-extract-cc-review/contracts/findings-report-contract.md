# Findings Report Contract

**Date**: 2026-08-02

## Output Format: review-findings.md

The review command produces a `review-findings.md` file with this structure:

```markdown
# Review Findings

**Date:** YYYY-MM-DD
**Branch:** branch-name
**Rounds:** N
**Gate Outcome:** PASS|FAIL
**Invocation:** standalone|speckit|manual

## Summary

| Severity | Found | Fixed | Remaining |
|----------|-------|-------|-----------|
| Critical | N | N | N |
| Important | N | N | N |
| Minor | N | - | N |
| Notable | N | - | N |
| **Total** | **N** | **N** | **N** |

**Agents completed:** N/6 (+ N external tools)
**Agents failed:** [list if any]

## Findings

### FINDING-N
- **Severity:** Critical|Important|Minor|Notable
- **Confidence:** 0-100
- **File:** path/to/file:start-end
- **Category:** <category>
- **Source:** <agent-name> (also reported by: <others>)
- **Round found:** N
- **Resolution:** fixed (round N)|pending|unresolved (after N rounds)|informational (Notable)

**What is wrong:**
[Description]

**Why this matters:**
[Rationale]

**How it was resolved:**
[Resolution or what needs to happen]

## Notable Observations
[Simplified format for Notable findings, if any]

## Goal Alignment
[Goal delivery table + undeclared changes, if goal agent ran]

## Test Suite Results
[Per-round test results, if tests ran]

## Remaining Findings
[Unresolved Critical/Important findings, if gate failed]
```

## Console Summary Contract

The review command outputs a console summary:

```
Review completed.

Gate: PASS|FAIL (after fix round N)

Review Agents:

| Agent                   | Found | Fixed | Remaining | Status    |
|-------------------------|-------|-------|-----------|-----------|
| Correctness             |     N |     N |         N | completed |
| Architecture & Idioms   |     N |     N |         N | completed |
| Security                |     N |     N |         N | completed |
| Production Readiness    |     N |     N |         N | completed |
| Test Quality            |     N |     N |         N | completed |
| Goal Alignment          |     N |     N |         N | completed/skipped |
| CodeRabbit (external)   |     N |     N |         N | completed/skipped/failed |
| Copilot (external)      |     N |     N |         N | completed/skipped/failed |
| Codex (external)        |     N |     N |         N | completed/skipped/failed |
| Test Suite (regression) |     N |     N |         N | passed/failed/skipped |
|-------------------------|-------|-------|-----------|-----------|
| Total                   |     N |     N |         N |           |

MVP: <agent name> (<N> findings)

Key fixes applied:
  1. <description> (<agent>)
  ...

Details: review-findings.md
```

## Agent Output Contract

Each review agent MUST return findings in this format:

```markdown
## Findings

### FINDING-1
- **Severity**: Critical|Important|Minor|Notable
- **Confidence**: 0-100
- **File**: relative/path/to/file
- **Lines**: start-end
- **Category**: [agent's category]
- **Description**: [what is wrong]
- **Rationale**: [why it matters]
- **Fix**: [concrete fix suggestion]

## Self-Verification
- [ ] Each finding has file:line evidence
- [ ] No invented findings
- [ ] No duplicates
- [ ] Honest confidence scores
- [ ] Re-read code if zero findings
- [ ] Every finding has a concrete fix
```

## Triage Summary Contract

```
## Triage Summary for PR #N

**Bot comments** (by author):
| Bot | Accepted | Rejected | Deferred | Skipped | Already Handled |
|-----|----------|----------|----------|---------|-----------------|

**Bot totals**: Accepted N, Rejected N, Deferred N, Skipped N, Already handled N

**Human comments**: Approved N, Edited N, Skipped N, Pending N

**Coverage** (from Codecov, if detected):
| File | Patch % | Missing | Overlaps with bot findings |
|------|---------|---------|---------------------------|

**Commit**: <SHA>
**CI status**: passing|failing|pending|not checked
**Open bot comments remaining**: N
```
