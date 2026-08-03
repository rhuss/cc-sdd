# Quickstart Validation Guide: cc-review Plugin Extraction

**Date**: 2026-08-02 | **Plan**: [plan.md](plan.md)

## Prerequisites

- Git repository with at least one branch and some changed files
- `gh` CLI installed and authenticated (for PR operations)
- An AI coding agent with subagent support (Claude Code, Codex, or OpenCode)
- Optional: `coderabbit`, `copilot`, or `codex` CLIs for external tool integration

## Scenario 1: Standalone Review (User Story 1)

Validates that cc-review works without spec-kit or cc-spex.

### Setup

```bash
# Clone a test project (or use any git repo)
git clone <test-repo> && cd <test-repo>

# Install cc-review for Claude Code
git clone https://github.com/rhuss/cc-review .cc-review
# OR: copy the Claude Code adapter to your commands directory
```

### Test

```bash
# Create a branch with some changes
git checkout -b test-review
# Make some code changes...
git add -A && git commit -m "test changes"

# Run review
/review
```

### Expected Outcome

- 6 review agents dispatch and complete
- Findings report generated at `./review-findings.md`
- Console shows agent summary table with gate outcome
- No errors about missing `.specify/` directory or spec-kit
- No errors about missing spec files

### Verify

- `review-findings.md` exists and contains the expected structure (see [findings-report-contract.md](contracts/findings-report-contract.md))
- Each agent section shows "completed" status
- Gate outcome is reported (PASS or FAIL)

## Scenario 2: PR Triage (User Story 2)

Validates that triage works for PR comments.

### Setup

```bash
# Use a repo with an open PR that has review comments
# Ensure gh is authenticated
gh auth status
```

### Test

```bash
# Triage the current branch's PR
/triage

# OR triage a specific PR
/triage --pr 42
```

### Expected Outcome

- Bot comments classified and handled (accepted/rejected/deferred)
- Human comments presented interactively
- Fixes committed and pushed (if any accepted)
- Reply comments posted to PR threads
- Summary table showing bot/human comment counts

### Verify

- Check the PR on GitHub: replies should appear on triaged threads
- Resolved threads should be marked as resolved
- `.cc-review/.triage-state.json` contains entries for handled comments

## Scenario 3: cc-spex Integration (User Story 3)

Validates that cc-spex delegates to cc-review when both are installed.

### Setup

```bash
# In a project with cc-spex installed
# Install cc-review as a spec-kit extension
specify extension add path/to/cc-review/adapters/speckit --dev

# Verify installation
jq '.extensions["cc-review"]' .specify/extensions/.registry
```

### Test

```bash
# Run the code review gate (triggers deep-review, which should delegate)
/speckit-spex-gates-review-code
```

### Expected Outcome

- Spec compliance check runs first (Stage 1)
- cc-review detected via registry check
- Delegation message: "cc-review detected, delegating to enhanced review"
- cc-review's full agent dispatch runs (including external tools)
- Findings report written to `specs/<feature>/review-findings.md`
- Flow state updated to show review-code gate passed

### Verify

- `review-findings.md` includes external tool sections (CodeRabbit, etc.)
- Console summary shows external tool status rows
- Flow state file shows `review-code` gate marked

## Scenario 4: cc-spex Fallback (User Story 3, edge case)

Validates that cc-spex's simplified review works when cc-review is NOT installed.

### Setup

```bash
# In a project with cc-spex but WITHOUT cc-review
# Ensure cc-review is not in the extension registry
jq '.extensions["cc-review"]' .specify/extensions/.registry
# Should return null or "not found"
```

### Test

```bash
/speckit-spex-gates-review-code
```

### Expected Outcome

- cc-review detection fails (expected)
- Simplified fallback runs: 6 agents, fix loop, no external tools
- Console summary shows "skipped" for external tool rows
- Gate outcome reported normally

### Verify

- `review-findings.md` does NOT contain external tool sections
- Console summary shows "skipped (cc-review not installed)" for external tools

## Scenario 5: Multi-Harness Installation (User Story 4)

Validates each adapter installation method.

### Claude Code

```bash
# Install as Claude Code plugin
cp -r cc-review/adapters/claude-code/commands/* ~/.claude/commands/
# Verify
/review --help  # Should show cc-review options
```

### spec-kit

```bash
# Install as spec-kit extension
specify extension add cc-review/adapters/speckit --dev
specify extension enable cc-review
# Verify
specify extension list  # Should show cc-review enabled
```

### Codex/OpenCode

```bash
# Append to AGENTS.md
cat cc-review/adapters/agents-md/AGENTS.md >> AGENTS.md
# Verify: ask the agent to "review my code"
```

### Verify for each

- The review command is available and produces findings
- Adapter file is under 50 lines (SC-007)
- No review logic in the adapter itself (FR-013)
