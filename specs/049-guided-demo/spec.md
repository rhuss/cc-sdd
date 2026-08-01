# Feature Specification: Guided Demo (Smoke Test v4)

**Feature Branch**: `049-guided-demo`

**Created**: 2026-08-01

**Status**: Draft

**Input**: Brainstorm #43 (supersedes Brainstorm #24, Spec #029)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guided Demo for a Feature with Running Infrastructure (Priority: P1)

A developer has shipped a feature that produces a runnable artifact (CLI tool, server, UI component). They invoke `/speckit-spex-smoke-test`. Instead of being presented with incomprehensible internal state ("Policy is nil", "ResolveProfiles produces these strings"), the skill reads the spec's functional requirements, synthesizes user-observable demo flows, probes the environment, and walks the developer through a guided demo where every piece of evidence is something they can look at and judge.

**Why this priority**: This is the core value proposition. The current smoke test is unusable because it presents implementation-level evidence that no human can validate. Making evidence observable and actionable is the fundamental fix.

**Independent Test**: Can be tested by running `/speckit-spex-smoke-test` against a spec with functional requirements that produce observable behavior (CLI output, server responses, file contents), and verifying the skill synthesizes demo flows with human-readable evidence.

**Acceptance Scenarios**:

1. **Given** a spec with functional requirements describing observable behavior (e.g., "system MUST respond with HTTP 200"), **When** the developer invokes `/speckit-spex-smoke-test`, **Then** the skill synthesizes 3-7 demo flows from the FRs (not from a literal `## Smoke Test` section), presents a demo plan to the user, and executes each flow showing real system output as evidence.
2. **Given** a spec with both FRs and an optional `## Smoke Test` section, **When** the skill builds the demo plan, **Then** the `## Smoke Test` entries are used as priority hints (which flows matter most) but the demo plan is synthesized from FRs, not literally replayed from the section.
3. **Given** a demo flow that requires a running server, **When** the skill executes that flow, **Then** it starts the server automatically, runs the demo action (curl, CLI command, browser navigation), captures the output, and presents it with a verdict recommendation and "verify yourself" instructions.
4. **Given** a demo flow execution, **When** evidence is presented to the human, **Then** the evidence contains only user-observable artifacts (command output, HTTP responses, file contents, screenshots, log lines) and never internal variable names, test assertion results, or code-level state.

---

### User Story 2 - Environment Triage with Tiered Options (Priority: P1)

A developer has shipped a feature that depends on external infrastructure (gateway, database, cloud service) that may or may not be available in the current session. Before executing any demo flows, the skill probes the environment, classifies each flow into a tier, and presents the developer with options ranging from "run what's available now" to "let me set up the missing infrastructure for you."

**Why this priority**: Equally critical to the core. The current smoke test either skips everything when infrastructure is missing or forces the developer through meaningless scenarios. Tiered triage provides honest, actionable options.

**Independent Test**: Can be tested by running the smoke test against a spec that requires infrastructure not present in the session (e.g., a gateway) and verifying the triage table correctly classifies flows and offers setup options.

**Acceptance Scenarios**:

1. **Given** a demo plan with 5 flows where 3 have all infrastructure available and 2 require a missing gateway, **When** the triage phase runs, **Then** the skill presents a readiness table showing each flow's tier (full/partial/setup offered/manual) and offers options: run what's ready, set up missing infrastructure (with complexity estimate), run partial evidence, or skip.
2. **Given** a flow classified as "setup offered", **When** the user chooses to set up the infrastructure, **Then** the skill offers varying complexity levels (e.g., "docker-compose ~2 min" vs. "full environment ~10 min") and attempts the setup before executing the flow.
3. **Given** a flow classified as "partial", **When** the user chooses to include partial evidence, **Then** the skill presents honest proxy evidence (e.g., dry-run API payload, log output) with a clear disclaimer about what it proves and what it does not.
4. **Given** the triage phase completes, **When** the user selects an option, **Then** only the selected flows are executed and the rest are recorded as skipped with reasons in the report.

---

### User Story 3 - Auto-Skip for Non-Observable Features (Priority: P1)

A developer has shipped a library or internal module with no runnable artifact. All functional requirements are verified by unit tests and produce no user-observable behavior. The guided demo detects this during synthesis and skips cleanly.

**Why this priority**: Equally critical. Library features should never force the developer through a meaningless walkthrough.

**Independent Test**: Can be tested by running the smoke test against a spec where all FRs describe internal behavior (data structure constraints, function return values) with no observable artifacts.

**Acceptance Scenarios**:

1. **Given** a spec where all FRs describe internal behavior with no user-observable effects, **When** the developer invokes `/speckit-spex-smoke-test`, **Then** the skill reports "All requirements are verified by unit tests. No user-observable flows to demo." and exits without error.
2. **Given** the ship pipeline reaches the guided demo stage for a non-observable feature, **When** the pipeline evaluates the stage, **Then** it skips the demo, reports the skip, and proceeds.

---

### User Story 4 - Demo Plan Synthesis from Functional Requirements (Priority: P2)

The skill reads the spec's FR-NNN entries and acceptance scenarios and translates them into user-observable demo flows. Related FRs are grouped, internal-only FRs are excluded, and the result is a coherent walkthrough of 3-7 flows.

**Why this priority**: The synthesis logic is the engine that powers Stories 1-3. It requires careful design but builds on the core interaction model.

**Independent Test**: Can be tested by feeding the skill a spec with 10+ FRs (mix of observable and internal) and verifying the synthesis produces 3-7 grouped flows with correct FR coverage mapping.

**Acceptance Scenarios**:

1. **Given** a spec with 10 FRs where 3 are purely internal (data structure shapes, nil checks) and 7 produce observable effects, **When** the skill synthesizes a demo plan, **Then** the plan contains 3-7 flows covering the 7 observable FRs, the 3 internal FRs are listed as "verified by unit tests only", and related FRs are grouped into single flows.
2. **Given** a spec with a `## Smoke Test` section listing 3 priority behaviors, **When** the skill synthesizes the demo plan, **Then** the listed behaviors appear first in the plan (priority ordering) and any additional observable FRs are included after them.
3. **Given** the synthesized demo plan, **When** it is presented to the user, **Then** each flow shows: a human-readable title, the observable outcome to verify, the setup steps needed, and the FRs it covers.

---

### User Story 5 - Persistent Report with Coverage Mapping (Priority: P2)

After the guided demo completes, a SMOKE-TEST.md report is written to the spec directory. The report captures not just verdicts but tier information, evidence, and a coverage section mapping FRs to demo flows.

**Why this priority**: The report enables audit trails and review. It builds on the core demo execution.

**Independent Test**: Can be tested by running a guided demo to completion and verifying the report structure includes tier information, FR coverage mapping, and triage summary.

**Acceptance Scenarios**:

1. **Given** a completed guided demo with 5 flows (3 passed, 1 partial, 1 skipped), **When** the report is generated, **Then** SMOKE-TEST.md includes per-flow sections with tier, setup, evidence, and verdict, plus a coverage section showing which FRs mapped to which flows.
2. **Given** a demo where 2 FRs were excluded as "unit-test-only", **When** the report is generated, **Then** the coverage section lists those FRs with the note "verified by unit tests only, no user-observable behavior."

---

### User Story 6 - Spec Template Guidance for Observable Scenarios (Priority: P3)

The spec template's optional `## Smoke Test` section is updated with guidance that steers authors toward user-observable behaviors rather than implementation details.

**Why this priority**: Template changes are small but prevent the root cause of bad scenarios from recurring.

**Independent Test**: Can be tested by running `/speckit-specify` for a feature and verifying the generated spec includes updated guidance with good/bad examples.

**Acceptance Scenarios**:

1. **Given** a feature description for a runnable artifact, **When** `/speckit-specify` generates the spec, **Then** the `## Smoke Test` section includes guidance: "List the 3-5 most important user-observable behaviors you want to verify. Focus on what the user should see, not what the code does internally." with contrasting examples (bad: "Policy object is nil", good: "Start a workspace, verify the sandbox has internet access").

---

### Edge Cases

- What happens when the spec has FRs but none produce observable behavior? The skill auto-skips with a clear message (User Story 3).
- What happens when infrastructure setup fails? The flow is reclassified from "setup offered" to "manual" with concrete instructions for later.
- What happens when all flows are classified as "manual"? The skill presents the manual instructions and asks the user to walk through them, recording verdicts.
- What happens when the `## Smoke Test` section contains implementation-level scenarios? They are used as priority hints but the skill synthesizes its own observable flows from FRs, so the bad scenarios are never presented verbatim.
- What happens when the demo plan synthesis produces more than 7 flows? The skill consolidates by merging related flows until the count is 7 or fewer.
- What happens when a flow fails and is retried? Both the initial failure and retry result are recorded in the report (unchanged from current behavior).

## Out of Scope

- **Automated acceptance testing**: The guided demo is human-in-the-loop validation, not an automated test suite. It does not replace unit or integration tests.
- **Subagent architecture**: All demo execution happens in the current session (unchanged from 029).
- **CI/CD integration**: The guided demo is a developer-facing interactive walkthrough, not a CI pipeline step.
- **Infrastructure provisioning beyond the session**: The "setup offered" tier covers local infrastructure (docker-compose, local servers). It does not provision cloud resources or remote environments.

## Clarifications

### Session 2026-07-31

- Q: Should the skill use `## Smoke Test` as its primary input or as hints? A: Hints only. The primary input is FRs and acceptance scenarios from the spec. The `## Smoke Test` section provides priority signals.
- Q: What should happen when infrastructure is missing? A: Triage with tiered options (full/partial/setup offered/manual). Offer to set up infrastructure with varying complexity levels.
- Q: Should evidence include test names or internal state? A: Never. Evidence must be user-observable: command output, HTTP responses, file contents, screenshots, log lines.
- Q: Should the feature be renamed? A: "Guided Demo" in user-facing output (report titles, console messages). Command name stays `speckit-spex-smoke-test` for backward compatibility.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST synthesize demo flows from the spec's FR-NNN entries and acceptance scenarios, not from a literal `## Smoke Test` section.
- **FR-002**: The skill MUST use the optional `## Smoke Test` section as priority hints only, not as literal scenarios to replay.
- **FR-003**: For each FR/acceptance scenario, the skill MUST determine "What would a human see if this requirement is working correctly?" and construct an observable demo flow.
- **FR-004**: The skill MUST group related FRs into single demo flows (target: 3-7 flows total).
- **FR-005**: The skill MUST exclude FRs with no user-observable effect and note them as "verified by unit tests only."
- **FR-006**: The skill MUST present the synthesized demo plan to the user before execution, allowing them to reorder flows, skip individual flows, or adjust which flows to include.
- **FR-007**: Before executing any flows, the skill MUST probe the environment and classify each flow into a tier: full, partial, setup offered, or manual.
- **FR-008**: The skill MUST present a readiness table showing each flow's tier and offer options: run what's ready, set up infrastructure (with complexity estimates), run partial evidence, or skip.
- **FR-009**: For "setup offered" flows, the skill MUST offer multiple complexity levels (e.g., docker-compose quick setup vs. full environment setup) and attempt the setup if the user chooses.
- **FR-010**: For "partial" flows, the skill MUST present honest proxy evidence (dry-run output, request payloads, log output) with a clear disclaimer about what it proves and what it does not.
- **FR-011**: All evidence presented to the user MUST be user-observable artifacts (command output, HTTP responses, file contents, screenshots, log lines). The skill MUST NOT present internal variable names, test assertion results, or code-level state as evidence.
- **FR-012**: For each flow, the skill MUST present a verdict recommendation (PASS/FAIL/SKIP/MANUAL) with reasoning, plus "verify yourself" instructions.
- **FR-013**: The skill MUST auto-skip when all FRs describe internal behavior with no user-observable effects, reporting "All requirements are verified by unit tests. No user-observable flows to demo." In the auto-skip case, the skill MUST still produce a minimal SMOKE-TEST.md report recording the skip reason and listing the FRs classified as internal-only.
- **FR-014**: The skill MUST produce a SMOKE-TEST.md report in the spec directory with per-flow sections (tier, setup, evidence, verdict) and a coverage section mapping FRs to flows.
- **FR-015**: The skill MUST use "Guided Demo" in all user-facing output (report title, console messages) while keeping the command name `speckit-spex-smoke-test`.
- **FR-016**: The spec template's `## Smoke Test` section MUST be updated with guidance steering authors toward user-observable behaviors, including contrasting good/bad examples.
- **FR-017**: The skill MUST NOT simulate, fake, or manually reproduce expected output. Every demo flow must exercise the real system or be honestly skipped/proxied.
- **FR-018**: When a flow fails, the skill MUST offer to investigate, suggest a fix, and allow retry (max 2 retries per flow, unchanged from current behavior).
- **FR-019**: The skill MUST remain always-interactive in the ship pipeline. The triage table and user choice are always shown regardless of the pipeline's `ask` level. The `--ask never` flag cannot auto-pass demo flows.
- **FR-020**: The skill MUST determine FR observability using a keyword-based heuristic: FRs mentioning user-facing actions (output, display, respond, create file, log, start server) are observable; FRs describing internal constraints (data structure shapes, nil/null checks, function return values) are internal-only. When an FR matches neither category, it MUST default to observable (more inclusive) so that ambiguous requirements are demonstrated rather than silently excluded.

### Key Entities

- **Demo Flow**: A synthesized walkthrough step derived from one or more FRs. Contains: title (human-readable), observable outcome, setup steps, infrastructure requirements, verification method, and FR coverage list.
- **Tier Classification**: One of four levels describing infrastructure readiness for a demo flow. Full = everything available. Partial = skill can produce some real system output (dry-run, request payload, logs) without full infrastructure. Setup offered = infrastructure missing but skill knows how to provision it locally. Manual = no automation possible (requires VPN, physical access, or external credentials the skill cannot obtain).
- **Readiness Table**: A compact display of all demo flows with their tier classifications, presented before execution so the user can choose which flows to run.
- **SMOKE-TEST.md Report**: Persistent record of guided demo results, including tier information, evidence, verdicts, and FR coverage mapping.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every piece of evidence shown to the user during a guided demo is something they can independently verify by looking at system output, not by reading test code or internal state.
- **SC-002**: The guided demo completes in under 5 minutes for a 3-5 flow plan (excluding infrastructure setup and fix/retry time).
- **SC-003**: Features with no user-observable FRs skip the guided demo in under 2 seconds with zero human interaction.
- **SC-004**: Every guided demo run produces a SMOKE-TEST.md report with FR coverage mapping, regardless of outcome.
- **SC-005**: When infrastructure is missing, the triage table presents actionable options (setup with complexity estimate, partial evidence, or skip) rather than blanket "skip all" or meaningless scenarios.

## Smoke Test

1. Run the guided demo against a spec with observable FRs (CLI tool or server feature) and verify the synthesis produces human-readable flows with real system evidence, not test names or internal state.
2. Run the guided demo against a spec that requires missing infrastructure and verify the triage table offers tiered options including setup.
3. Run the guided demo against a pure library spec (no observable FRs) and verify it auto-skips cleanly.

## Clarifications

### Session 2026-08-01

- Q: How should the skill determine if an FR produces "observable" vs "internal-only" behavior? → A: Keyword-based heuristic. FRs mentioning user-facing actions (output, display, respond, create file, log, start server) are observable. FRs describing internal constraints (data structure shapes, nil/null checks, function return values) are internal-only.
- Q: When is a flow "partial" vs "manual"? → A: Partial = the skill can produce some real system output (dry-run mode, request payload capture, log output) without the full infrastructure. Manual = no automation is possible (requires VPN, physical access, external credentials the skill cannot obtain).
- Q: Does `--ask never` in the ship pipeline auto-pass demo flows? → A: No. The guided demo is always interactive regardless of `--ask` level. The entire purpose is human validation.

## Assumptions

- The spec contains FR-NNN entries with enough semantic content for the skill to determine observability (most specs generated by `/speckit-specify` meet this criterion).
- Playwright MCP is available in most developer environments but graceful degradation to manual instructions is acceptable when absent.
- The `/run` skill or project auto-detection provides the primary mechanism for starting apps. Projects that require non-standard setup may need custom instructions in the `## Smoke Test` section.
- Infrastructure setup ("setup offered" tier) covers local tooling only (docker-compose, local servers, local databases). Cloud provisioning is out of scope.
- The existing no-simulation hard gate carries forward as a core principle.
