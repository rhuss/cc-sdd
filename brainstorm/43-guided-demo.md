# Brainstorm #43: Guided Demo (Smoke Test v4)

**Status**: Ready for spec
**Date**: 2026-07-31
**Supersedes**: Brainstorm #24 (Smoke Test Rethink), Spec #029

## Problem

The current smoke test presents spec acceptance scenarios verbatim to the user for pass/fail judgment. These scenarios are written in implementation terms ("Policy is nil", "ResolveProfiles produces these strings") that no human can validate by looking at a running system. The result is a useless ritual where the user either blindly passes everything or skips the entire smoke test.

Example of what the user sees today:

```
Scenario 1 of 13 (User Story: Profile-Based Sandbox Creation)

Given a manifest with agents: [claude] and no explicit tools
When a workspace is created
Then cc-deck creates providers referencing the "anthropic" and "claude-agent" profiles,
passes them in SandboxSpec.Providers with Policy set to nil

Evidence (automated):
Tests: TestResolveProfiles_SingleAgent (PASS), TestCreate_ProfileBased_NoPolicy (PASS)

Does this scenario pass? (pass / fail / skip)
```

The user cannot meaningfully answer this question. The evidence is test names and internal state, not observable behavior.

## Design

### Rename

The feature is renamed from "smoke test" to "guided demo" in all user-facing output (report titles, console messages, descriptions). The command name stays `speckit-spex-smoke-test` for backward compatibility.

### Input Model

The skill reads from two sources:

1. **Spec functional requirements and acceptance scenarios** (primary, always available). The skill reads all FR-NNN entries and Given/When/Then blocks and translates them into user-observable demo flows.

2. **`## Smoke Test` section** (optional priority hints). If present, these signal which flows the author considers most important and may include environment-specific setup details. They do not replace the synthesis; they focus it.

The spec template changes from "write numbered imperative instructions" to guidance like: "List the 3-5 most important user-observable behaviors you want to verify. Focus on what the user should see, not what the code does internally."

The template includes an example contrasting bad vs. good:
- Bad: "Policy object is nil after workspace creation"
- Good: "Start a workspace, verify the sandbox has internet access"

### Demo Plan Synthesis

The skill builds a demo plan by translating FRs into user-observable flows:

- For each FR/acceptance scenario, determine: "What would a human see if this requirement is working correctly?"
- Each demo flow has: what to show (observable outcome), how to get there (setup steps), what infrastructure is needed, and a verification method (what the human looks at to judge)
- Related FRs are grouped into single flows (e.g., FR-001 profile parsing + FR-003 profile passing = one "start workspace, check internet" flow)
- FRs with no observable effect (purely internal constraints verified by unit tests) are excluded with a note: "Verified by unit tests only, no user-observable behavior"
- Target: 3-7 demo flows

The demo plan is presented to the user before execution so they can adjust priorities or skip flows.

### Environment Triage

After building the demo plan, the skill probes the environment and classifies each flow:

| Tier | Meaning | Example |
|------|---------|---------|
| **Full** | Everything available or startable | Start server, hit endpoint, show response |
| **Partial** | Core action works, end-to-end chain incomplete. Observable proxy available | Show the API request payload and log output |
| **Setup offered** | Infrastructure missing but skill can set it up | "Gateway isn't running. I can start it via docker-compose (~2 min) or help with full env setup (~10 min)" |
| **Manual** | Can't automate, precise human instructions provided | "Requires VPN access. Here's exactly what to run and verify" |

The triage result is shown as a compact readiness table:

```
Guided Demo Readiness:

  1. Start workspace, verify sandbox has internet    [full]
  2. Add per-agent domain filtering                  [setup needed: gateway]
  3. Backward compat with existing manifests         [full]
  4. MCP endpoint import from profiles               [partial: can show request shape]
  5. Compose fallback still works                    [full]

3 flows ready, 1 needs setup, 1 partial.

Options:
  a) Run what's ready now (3 flows)
  b) Set up gateway first, then run all (docker-compose, ~2 min)
  c) Run everything available including partial evidence (4 flows)
  d) Skip guided demo
```

The user picks, and execution begins.

### Evidence Presentation

For each flow, the skill performs setup, executes the demo action, and presents evidence that a human can actually evaluate:

**Full-tier example:**

```
Flow 1: Start workspace, verify sandbox has internet

I ran: cc-deck workspace create --manifest test-manifest.yaml
Output:
  Workspace "test-ws" created
  Sandbox running at 10.0.1.42
  Providers: anthropic, claude-agent, github, gitlab

Then I ran: cc-deck exec test-ws -- curl -s https://google.com
Output:
  <HTML><HEAD>... (200 OK)

Expected: Sandbox has unrestricted internet (no policy filtering).
Actual: curl to google.com succeeded from inside the sandbox.

Verdict recommendation: PASS
Why: Sandbox has internet access, confirming profiles applied without restrictive policy.

To verify yourself:
  1. Run: cc-deck workspace list
  2. Run: cc-deck exec test-ws -- curl -I https://google.com
  3. Look for: HTTP 200 response

Pass this flow? (pass / fail / skip)
```

**Partial-tier example:**

```
Flow 4: MCP endpoint import from profiles (partial evidence)

I can't reach the gateway, so I'm showing the request that would be sent.

I ran: cc-deck workspace create --manifest test-manifest.yaml --dry-run
Output:
  POST /api/v1/sandboxes
  {
    "providers": ["anthropic", "claude-agent"],
    "policy": null,
    "mcp_endpoints": [...]
  }

What to look for: "policy" is null (not an empty object), providers list
matches the manifest's agent declarations.

This does NOT prove the gateway would handle it correctly, only that the
client sends the right request.

Pass this flow? (pass / fail / skip)
```

Key principle: every piece of evidence must be something the user can look at and form an opinion about. No internal variable names, no test assertion results, no code-level state.

### Failure Handling

Unchanged from the current implementation: on failure, offer to investigate, suggest a fix, allow retry (max 2). The investigation now has context about the tier (full-tier failure = investigate the real system; partial-tier failure = the proxy evidence is wrong).

### Report

SMOKE-TEST.md is written to the spec directory with:
- Header: feature name, date, demo plan summary
- Per-flow sections: tier, setup performed, evidence captured, verdict
- Coverage section: which FRs mapped to which flows, which FRs are unit-test-only
- Triage summary: what was available, what was missing, what was skipped and why

### Auto-Skip

If the spec has no FRs that produce observable behavior (pure library, no CLI, no server, no UI), the skill detects this during synthesis and skips: "All requirements are verified by unit tests. No user-observable flows to demo."

### Pipeline Integration

The guided demo remains always-interactive in the ship pipeline. Triage table is still shown, user picks the tier. Pipeline-specific: no "shall I proceed?" after completion, just the results report and return.

## Changes from Current Implementation

| Aspect | Current (029) | New (043) |
|--------|--------------|-----------|
| Input | `## Smoke Test` section only | FRs + acceptance scenarios (primary), `## Smoke Test` as hints |
| Scenarios | Literally replayed from spec | Synthesized into observable demo flows |
| Evidence | Test names, internal state | Running system output, curl responses, screenshots, logs |
| Infrastructure gaps | Skip with manual instructions | Triage with tiered options (full/partial/setup/manual) |
| Setup offer | None | "Want me to start the gateway? docker-compose ~2 min" |
| User-facing name | Smoke Test | Guided Demo |
| Spec template | "Write numbered instructions" | "List observable behaviors, not code internals" |

## What Stays the Same

- No-simulation hard gate (never fake evidence)
- Always interactive (never auto-pass)
- Single-session execution (no subagents for the demo itself)
- SMOKE-TEST.md report in spec directory
- Ship pipeline integration (Stage 8)
- Failure investigation and retry loop
- App startup via /run skill or auto-detection
- Playwright MCP for browser scenarios with graceful degradation
- Command name: `speckit-spex-smoke-test`

## Open Questions

None. Design validated through interactive brainstorming.
