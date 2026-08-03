# Feature Specification: Extract Review into Standalone cc-review Plugin

**Feature Branch**: `051-extract-cc-review`

**Created**: 2026-08-02

**Status**: Draft

**Input**: Extract deep-review agents and PR triage workflow into a new standalone plugin `cc-review` (`rhuss/cc-review`), with harness-agnostic core and thin adapters for each ecosystem.

**Brainstorm**: `brainstorm/44-extract-cc-review.md` | **Issue**: [#50](https://github.com/rhuss/cc-spex/issues/50)

## User Scenarios & Testing

### User Story 1 - Standalone PR Review (Priority: P1)

A developer using any AI coding agent (Claude Code, Codex, OpenCode, or others) wants to run a multi-agent code review on their current branch or a specific PR. They install cc-review in their harness's native format and invoke `/review`. The system dispatches specialized review agents, collects findings, classifies them by severity, and presents a structured report. No spec-kit, no cc-spex, no spec files required.

**Why this priority**: This is the core value proposition. If standalone review doesn't work without dependencies, the extraction has failed.

**Independent Test**: Install cc-review into a fresh Claude Code project (no cc-spex, no spec-kit). Run `/review` on a branch with an open PR. Verify that review agents run, findings are reported with severity classification, and no errors about missing spec-kit or .specify/ directory occur.

**Acceptance Scenarios**:

1. **Given** a project with cc-review installed (no cc-spex), **When** user invokes `/review`, **Then** the system reviews the current branch diff, dispatches specialized review agents, and presents a findings report with severity classification.
2. **Given** a project with cc-review installed, **When** user invokes `/review --pr 42`, **Then** the system reviews the specified PR's changes.
3. **Given** a project with no spec files, **When** review agents run, **Then** spec compliance checks are skipped gracefully (no errors, no warnings about missing specs).

---

### User Story 2 - PR Comment Triage (Priority: P1)

A developer receives review comments on their PR from both automated tools (CodeRabbit, Copilot, dependabot) and human reviewers. They invoke `/triage` (or `/review --triage`) to automatically classify comments, apply valid bot suggestions, reject invalid ones with explanations, and present human comments for interactive review.

**Why this priority**: Triage is a distinct, high-value workflow that's immediately useful without the review agents. Many PRs accumulate dozens of bot comments that are tedious to process manually.

**Independent Test**: Create a PR with mixed bot and human review comments. Run triage. Verify bot comments are classified and handled (applied/rejected with replies), human comments are presented interactively, and no spec-kit infrastructure is required.

**Acceptance Scenarios**:

1. **Given** a PR with bot review comments, **When** user invokes triage, **Then** bot comments are assessed, valid suggestions are applied, invalid ones are rejected with reply comments.
2. **Given** a PR with human review comments, **When** user invokes triage after bot processing, **Then** human comments are presented one by one for the user to approve, modify, or skip.
3. **Given** a PR on a GitLab repository, **When** user invokes triage, **Then** the system uses GitLab API equivalents (not just GitHub).

---

### User Story 3 - cc-spex Enhanced Review (Priority: P2)

A cc-spex user has cc-review installed alongside cc-spex. When the SDD workflow triggers a code review (via the `after_implement` hook or `/speckit-spex-gates-review-code`), the system detects cc-review and delegates to its enhanced review agents instead of running cc-spex's simplified built-in review. The spec path and review hints are passed as optional context, enabling spec compliance checking alongside the code review.

**Why this priority**: This is the upgrade path for existing cc-spex users. It must work seamlessly, but it depends on Story 1 being solid first.

**Independent Test**: In a project with both cc-spex and cc-review installed, trigger the code review gate after implementation. Verify that cc-review's enhanced agents run (with external tool integration), spec compliance is checked (since a spec exists), and findings include spec-aware analysis.

**Acceptance Scenarios**:

1. **Given** a project with both cc-spex and cc-review installed, **When** the code review gate fires, **Then** cc-spex detects cc-review and delegates to it instead of running its own simplified review.
2. **Given** cc-review receives a spec path as optional input, **When** review agents run, **Then** spec compliance checking is included in the review.
3. **Given** cc-review is NOT installed, **When** the code review gate fires, **Then** cc-spex runs its own simplified deep-review (6 agents, fix loop, no external tools) as before.

---

### User Story 4 - Multi-Harness Installation (Priority: P2)

A user wants to install cc-review in their specific AI agent environment. The repository provides native installation formats for each supported harness: Claude Code plugin directory, spec-kit extension bundle, Codex/OpenCode AGENTS.md fragments. Each installation method provides the same core review capabilities through the harness's native command interface.

**Why this priority**: Reach across harnesses is a key differentiator from keeping review inside cc-spex. Without multi-harness support, the extraction loses its primary motivation.

**Independent Test**: Install cc-review using each supported method (Claude Code commands directory, spec-kit extension, Codex AGENTS.md). In each case, verify the review command is available and functional.

**Acceptance Scenarios**:

1. **Given** a Claude Code user, **When** they install cc-review as a plugin, **Then** `/review` and `/triage` commands are available and functional.
2. **Given** a spec-kit user, **When** they run `specify enable cc-review`, **Then** the review extension is available and integrates with spec-kit hooks.
3. **Given** a Codex/OpenCode user, **When** they include the cc-review AGENTS.md fragment, **Then** the review capability is available through the agent's native interface.

---

### User Story 5 - Autonomous Fix Loop (Priority: P3)

After the review agents report Critical or Important findings, the system enters an autonomous fix loop: it attempts to fix each finding, runs tests to verify the fix, and re-reviews. The loop runs up to a configurable number of rounds (default 3). Findings that survive the fix loop are reported as unresolved.

**Why this priority**: The fix loop is a power feature that builds on top of the review agents. It's valuable but not essential for the initial release.

**Independent Test**: Run a review that produces Critical findings. Verify the fix loop activates, attempts fixes, runs tests, and either resolves findings or reports them as unresolved after max rounds.

**Acceptance Scenarios**:

1. **Given** review findings with Critical severity, **When** fix loop is enabled, **Then** the system attempts to fix each finding and runs tests to verify.
2. **Given** a fix that introduces test failures, **When** the fix loop detects the regression, **Then** the fix is reverted and the finding is reported as unresolved.
3. **Given** the fix loop reaches the maximum round count, **When** findings remain unresolved, **Then** remaining findings are reported with "unresolved after N rounds" status.

---

### Edge Cases

- What happens when `gh` CLI is not authenticated? The system reports a clear error and skips PR-specific operations (triage, PR comment fetching), but still allows local diff review.
- What happens when the PR has no review comments? Triage reports "no review comments found" and exits cleanly.
- What happens when cc-review is installed but the project has no git repository? Review falls back to analyzing staged or provided files, or reports that git is required.
- What happens when both cc-review and cc-spex's built-in review are present? cc-spex always defers to cc-review. There is no "double review" scenario.
- What happens when external tools (CodeRabbit, Copilot) are not configured? Those review channels are skipped. Core review agents always run.

## Requirements

### Functional Requirements

- **FR-001**: cc-review MUST operate as a standalone tool without requiring spec-kit, cc-spex, or any spec artifacts.
- **FR-002**: cc-review MUST provide a primary entry point command (`/review` or equivalent) that works in each supported harness.
- **FR-003**: cc-review MUST dispatch multiple specialized review agents that analyze code from distinct perspectives (correctness, architecture, security, production readiness, test quality, goal alignment).
- **FR-004**: cc-review MUST merge and deduplicate findings from all review agents into a single findings report with severity classification (Critical, Important, Minor, Notable).
- **FR-005**: cc-review MUST provide a triage workflow that fetches PR review comments, classifies them as bot vs human, and handles each category appropriately.
- **FR-006**: cc-review MUST accept an optional spec path input; when provided, agents include spec compliance checking in their review.
- **FR-007**: cc-review MUST accept an optional review hints input; when provided, agents focus on the hinted areas.
- **FR-008**: cc-review MUST support GitHub for PR operations (fetching comments, posting replies). GitLab support SHOULD be scaffolded (platform detection, function stubs) with basic experimental implementations using `glab` CLI; full GitLab parity is deferred to a follow-up release.
- **FR-009**: cc-review MUST provide an autonomous fix loop that attempts to resolve Critical and Important findings, with configurable round limits.
- **FR-010**: The repository MUST include thin adapters for at least three harnesses: Claude Code, spec-kit, and one Codex/OpenCode variant.
- **FR-011**: cc-spex MUST retain a simplified built-in deep-review fallback that works without cc-review installed. "Simplified" means: same 6 review agent perspectives, same fix loop, but without external tool integration (CodeRabbit, Copilot, Codex channels) and without triage capability.
- **FR-012**: cc-spex MUST detect cc-review presence and delegate to it when available, passing spec path and review hints as optional inputs.
- **FR-013**: Each adapter MUST contain no review logic of its own; adapters are thin wrappers that load and invoke core review commands.
- **FR-014**: cc-review MUST use its own configuration file location (not `.specify/` paths) when running standalone; when running via the spec-kit adapter, it MAY read spec-kit paths.
- **FR-015**: cc-review MUST support external tool integration (CodeRabbit, Copilot, Codex) as optional, configurable review channels.

### Key Entities

- **Review Agent**: A specialized review perspective (correctness, architecture, security, production readiness, test quality, goal alignment) that analyzes code and produces findings.
- **Finding**: A specific issue discovered by a review agent, with severity (Critical, Important, Minor, Notable), location (file, line), description, and suggested fix.
- **Findings Report**: The merged, deduplicated collection of all findings from all agents for a review session.
- **Triage Session**: A workflow that processes PR review comments, classifying and handling bot comments autonomously and presenting human comments interactively.
- **Adapter**: A thin, logic-free wrapper that makes cc-review's core commands available in a specific harness's native format.
- **Fix Loop**: An autonomous cycle that attempts to resolve findings, runs tests, and re-reviews until findings are resolved or the round limit is reached.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A user can install cc-review and run a review on a PR within 5 minutes, without installing spec-kit or cc-spex.
- **SC-002**: cc-review produces review findings for at least 5 distinct review perspectives in a single invocation.
- **SC-003**: Triage correctly classifies bot vs human comments with at least 95% accuracy across GitHub PRs.
- **SC-004**: cc-spex users who install cc-review experience the same or better review quality compared to the current built-in deep-review, with zero additional configuration.
- **SC-005**: cc-review works across at least 3 different AI agent harnesses using native installation methods.
- **SC-006**: The fix loop resolves at least 60% of Critical findings autonomously when tests are available.
- **SC-007**: Adapter files for each harness total fewer than 50 lines of content each (measuring wrapper thinness).

## Implementation Scope

This feature spans two repositories:
- **`rhuss/cc-review`** (new): Core review agents, triage workflow, fix loop, adapters, configuration, documentation.
- **`rhuss/cc-spex`** (existing): Refactor `spex-deep-review` to detect and delegate to cc-review, simplify the built-in fallback, remove triage from `spex-collab`.

The plan phase MUST clearly separate work items by target repository.

## Assumptions

- Users have `git` installed and are working in a git repository.
- For PR operations (triage, PR-specific review), users have `gh` (GitHub) or `glab` (GitLab) CLI installed and authenticated.
- External tools (CodeRabbit, Copilot, Codex) are optional and independently configured by the user in their CI/CD or agent environment.
- The existing cc-spex deep-review agent prompts are reusable as-is for the core review logic, with spec-kit path references replaced by optional inputs.
- cc-review's config file lives in a location conventional for each harness (e.g., `.cc-review/config.yml` for standalone, `.specify/extensions/cc-review/` for spec-kit).
- The `/review` command name is available. If it collides with an existing skill (e.g., superpowers' `/review`), the cc-review command takes precedence when installed, or uses a disambiguated name.
