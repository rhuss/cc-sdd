# Data Model: Guided Demo (Smoke Test v4)

**Branch**: `049-guided-demo` | **Date**: 2026-08-01

## Entities

### Demo Flow

A synthesized walkthrough step derived from one or more FRs.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Sequential flow number (1-based) |
| title | string | Human-readable description of what to demonstrate |
| observable_outcome | string | What the human should see if the requirement works |
| setup_steps | list[string] | Actions the skill performs before the demo (start server, create data) |
| infrastructure_needs | list[string] | External dependencies (CLI tools, servers, databases, browser) |
| verification_method | string | What the human looks at to judge (curl output, screenshot, file contents) |
| fr_coverage | list[string] | FR-NNN identifiers this flow covers |
| tier | enum | full, partial, setup_offered, manual (set during triage) |
| verify_yourself | list[string] | Commands the human can run to independently verify |

### Tier Classification

| Value | Meaning | Probing result |
|-------|---------|----------------|
| full | All infrastructure available or startable | All `which`/port/connection checks pass |
| partial | Can produce some real system output without full infra | dry-run or log capture available |
| setup_offered | Missing but skill can provision locally | docker-compose file or setup script detected |
| manual | No automation possible | Requires VPN, physical access, or external credentials |

### Readiness Table Entry

Compact display row for the triage table.

| Field | Type | Description |
|-------|------|-------------|
| flow_id | integer | References Demo Flow.id |
| title | string | Short flow title |
| tier | enum | Tier classification |
| detail | string | Tier-specific note (e.g., "can show request shape", "gateway not reachable") |

### SMOKE-TEST.md Report

Persistent record of guided demo results.

| Section | Content |
|---------|---------|
| Header | Feature name, date, demo plan summary |
| Per-flow sections | Tier, setup performed, evidence captured, verdict (pass/fail/skip/manual) |
| Coverage mapping | Table: FR-NNN -> Flow N -> Verdict |
| Internal-only FRs | List of FRs excluded as "verified by unit tests only" |
| Triage summary | What was available, what was missing, what was skipped and why |

### FR Classification

Result of the observability heuristic (FR-020).

| Classification | Keyword signals | Result |
|----------------|----------------|--------|
| Observable | output, display, respond, create, file, log, start, server, CLI, endpoint, UI | Included in demo plan |
| Internal-only | data structure, nil, null, internal, return value, function, constraint, MUST NOT | Excluded, noted as "verified by unit tests only" |
| Ambiguous | No clear signals either way | Defaults to observable |

## Relationships

```
Spec (spec.md)
  └── has many FR-NNN entries
        └── classified as Observable or Internal-only
              └── Observable FRs grouped into Demo Flows (many-to-one)
                    └── each Demo Flow assigned a Tier during triage
                          └── selected flows executed, producing Report entries
```

## State Transitions

### Demo Flow Lifecycle

```
[synthesized] → [triaged: tier assigned] → [selected/skipped by user] → [executed] → [verdict: pass/fail/skip/manual]
                                                                                          ↓ (if fail)
                                                                                    [investigated] → [fix applied] → [retried] (max 2)
```
