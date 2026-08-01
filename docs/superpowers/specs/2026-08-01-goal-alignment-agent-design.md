# Goal Alignment Agent for Deep Review

Add a 6th review agent to the deep review extension that checks whether a PR's
changes match its declared goals, and flags undeclared changes by tier (Breaking,
Substantive, Minor).

## Problem

The existing 5 deep review agents evaluate implementation quality (correctness,
architecture, security, production readiness, test quality) but never ask: "does
this PR actually do what it says it does?" Undeclared changes, especially
breaking ones like API surface changes or version bumps, slip through because no
agent checks goal alignment.

## Goal Sources

The agent receives pre-parsed declared goals from three sources, in priority
order:

1. **Spec requirements** (`specs/<branch>/spec.md`): FR-NNN items are
   authoritative when present. Already available via existing spec-awareness
   logic. Optional: many PRs (especially in non-spex projects or for small
   fixes) have no spec. The agent works without one.
2. **PR body**: Extracted from `gh pr view --json body`. Bullets, numbered
   lists, or sections like "Goals", "Changes", "What this PR does".
3. **Linked issues**: From `Fixes #N` / `Closes #N` patterns in the PR body.
   Issue title + body fetched via `gh issue view`.

When a spec exists and conflicts with the PR body, the spec wins and the
conflict is noted. When no spec exists, the PR body and linked issues are
the sole goal sources.

Goal extraction happens in the orchestrator (Step 2), not inside the agent. The
agent receives a structured `DECLARED_GOALS` block:

```
## Declared Goals

### From spec (authoritative):
- FR-001: Support CONNECT tunneling with typed error handling
- FR-002: Emit OCSF events for all connection lifecycle stages

### From PR description:
- Add policy binding enforcement to all proxy paths

### From linked issues:
- #142: Policy binding should cover WebSocket upgrades
```

## Analysis: Two-Pass Approach

### Pass 1: Goal Delivery Check

For each declared goal, verify whether the diff delivers it:

- **DELIVERED**: The diff contains code implementing this goal.
- **PARTIAL**: Some aspects implemented, others missing. Cite what is missing.
- **NOT DELIVERED**: No evidence in the diff. Produces an `Important` finding.

### Pass 2: Undeclared Change Detection

Walk the diff file-by-file. For each substantive change (not whitespace,
formatting, or import reordering), check whether it maps to a declared goal.
Changes that do not map are classified:

| Tier | Criteria | Severity | Examples |
|------|----------|----------|----------|
| Breaking | Changes API surface, renames public symbols, alters serialization format, bumps protocol versions, changes default behavior | Critical | Version hash algorithm change, renamed public function |
| Substantive | Adds new logic, new validation, new error paths, bug fixes unrelated to goals | Important | Security hardening, pre-existing bug fix |
| Minor | Cleanup, typo fixes, comment updates, internal renames, import sorting | Notable | Whitespace, doc fixes |

The agent does NOT judge whether undeclared changes are good or bad. Agents 1-5
cover quality. This agent only flags that changes exist outside declared goals.

## Finding Output

Goal alignment findings use the existing finding schema with category
`goal-alignment`.

### Goal not delivered:

```json
{
  "id": "FINDING-N",
  "severity": "Important",
  "confidence": 85,
  "file": "n/a",
  "line_start": 0,
  "line_end": 0,
  "category": "goal-alignment",
  "description": "FR-003 (WebSocket upgrade policy binding) not implemented",
  "rationale": "Spec requires policy binding on WebSocket upgrades but no changes touch the WebSocket handler",
  "fix": "Implement policy binding check in the WebSocket upgrade path",
  "source_agent": "goal-alignment"
}
```

### Undeclared change:

```json
{
  "id": "FINDING-N",
  "severity": "Critical",
  "confidence": 90,
  "file": "grpc/policy.rs",
  "line_start": 42,
  "line_end": 55,
  "category": "goal-alignment",
  "description": "Undeclared breaking change: revision hash algorithm v1 to v3",
  "rationale": "hash_policy_revision now uses resource_version instead of updated_at_ms. Existing caches see a forced revision change on upgrade. Not mentioned in PR description or linked issues.",
  "fix": "Add this change to the PR description. Consider whether a migration path is needed.",
  "source_agent": "goal-alignment"
}
```

### Summary Table

Appended to the console output (Step 9) and `review-findings.md`:

```
## Goal Alignment

| # | Goal | Status | Source |
|---|------|--------|--------|
| 1 | Policy binding on CONNECT | DELIVERED | FR-001 |
| 2 | OCSF event emission | DELIVERED | FR-002 |
| 3 | WebSocket upgrade binding | NOT DELIVERED | FR-003 |

### Undeclared Changes
| Tier | File | Description |
|------|------|-------------|
| Breaking | grpc/policy.rs | Revision hash v1->v3 |
| Substantive | l7/rest.rs | Authority validation hardening |
| Minor | proxy.rs | Fragment rejection |
```

## Integration into Deep Review Orchestration

Changes to `speckit.spex-deep-review.run.md`:

### Step 2: Fetch PR metadata

After existing file detection, add:

```bash
PR_BODY=$(gh pr view --json body -q '.body' 2>/dev/null || echo "")
PR_ISSUES=$(echo "$PR_BODY" | grep -oE '(Fixes|Closes|Resolves)\s+#[0-9]+' | grep -oE '[0-9]+' || echo "")
```

For each linked issue, fetch its title and body. Build the `DECLARED_GOALS`
block from spec (if available) + PR body + issue descriptions.

If no PR exists (running on a local branch without a PR), skip goal extraction
and disable the goal alignment agent. Report in the summary: "Goal alignment:
skipped (no PR found)".

### Step 3: Dispatch Agent 6

Dispatch the goal alignment agent alongside agents 1-5 using the same
parallel/sequential mechanism. The agent receives the common preamble, the
goal-specific prompt with its checklist, `DECLARED_GOALS`, changed files, and
the spec.

Agent count in output updates from "5 agents" to "6 agents".

### Step 5: Merge

`goal-alignment` is a new category in the merge/dedup step. Goal findings do
not dedup against findings from other agents since they answer a different
question.

### Step 9: Console summary

The summary includes the goal alignment table after the per-agent findings
table. The agent appears in the agent table as "Goal Alignment" with its
finding counts.

### Gate logic

Breaking (Critical) and Substantive (Important) undeclared changes block the
gate, consistent with how all other Critical/Important findings are handled.
Minor (Notable) is informational and does not block.

## Agent Prompt Structure

The goal alignment agent prompt follows the same structure as agents 1-5:

1. Common preamble (anti-sycophancy, confidence scoring, isolation rules)
2. Role statement: "You are the Goal Alignment reviewer."
3. `DECLARED_GOALS` block
4. Two-pass analysis instructions (goal delivery, then undeclared changes)
5. Tier classification criteria table
6. Output format instructions (same JSON finding schema)
7. Changed files and spec

## No-Goals Fallback

When no goals can be extracted (empty PR body, no linked issues, no spec), the
agent skips Pass 1 entirely and only runs Pass 2 (undeclared change detection
against an empty goal set, meaning every change is "undeclared"). To avoid
noise, in this mode it only reports Breaking tier changes and skips Substantive
and Minor.

Report in the summary: "Goal alignment: partial (no declared goals found, only
breaking change detection active)".
