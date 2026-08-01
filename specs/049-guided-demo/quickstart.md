# Quickstart Validation: Guided Demo (Smoke Test v4)

**Branch**: `049-guided-demo` | **Date**: 2026-08-01

## Prerequisites

- Claude Code CLI with spex plugin installed
- A project with a feature spec containing FR-NNN entries
- `jq` and `yq` installed

## Validation Scenarios

### 1. Basic Guided Demo (Observable Feature)

**Setup**: Use any existing spec with observable FRs (e.g., a CLI tool or server feature).

**Run**:
```bash
/speckit-spex-smoke-test
```

**Expected**:
1. The skill reads FRs from the spec (not a `## Smoke Test` section)
2. A demo plan with 3-7 flows is presented
3. A readiness/triage table shows each flow's tier
4. User selects which flows to run
5. Each flow shows real system output as evidence (not test names or internal state)
6. A SMOKE-TEST.md report is written to the spec directory

**Verify**: Open `SMOKE-TEST.md` and confirm it has per-flow sections with tier, evidence, and FR coverage mapping.

### 2. Auto-Skip (Library Feature)

**Setup**: Use a spec where all FRs describe internal behavior (data structures, constraints, function return values) with no observable artifacts.

**Run**:
```bash
/speckit-spex-smoke-test
```

**Expected**: The skill reports "All requirements are verified by unit tests. No user-observable flows to demo." and exits without error. A minimal SMOKE-TEST.md is still written recording the skip reason.

### 3. Triage with Missing Infrastructure

**Setup**: Use a spec that requires external infrastructure not present in the current session (e.g., a database server, gateway, or cloud API).

**Run**:
```bash
/speckit-spex-smoke-test
```

**Expected**:
1. Flows requiring the missing infrastructure are classified as "setup offered" or "partial"
2. The readiness table shows the tier for each flow
3. Options are presented: run what's ready, set up infrastructure (with complexity estimate), include partial evidence, or skip
4. Partial-tier flows show honest proxy evidence with a disclaimer

### 4. Ship Pipeline Integration

**Setup**: Run the full ship pipeline on a feature with observable FRs.

**Run**:
```bash
/speckit-spex-ship brainstorm/NN-feature.md
```

**Expected**: At the finish stage, the guided demo runs interactively (regardless of `--ask` level), presents the triage table, and allows the user to select flows. No "shall I proceed?" after completion.

### 5. Spec Template Guidance

**Setup**: Create a new feature spec.

**Run**:
```bash
/speckit-specify "A new CLI tool that does X"
```

**Expected**: The generated spec includes an optional `## Smoke Test` section with guidance about writing user-observable behaviors (not implementation details) and contrasting good/bad examples.
