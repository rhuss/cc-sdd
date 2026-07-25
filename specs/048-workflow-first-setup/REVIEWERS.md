# Review Guide: Workflow-First Spex Setup

## Purpose

This PR replaces only the setup/configuration slice of the abandoned monolithic Codex-support delivery. It does not introduce the Codex adapter, plugin packaging, workflow-state recovery, progress, Teams, or production OpenCode work.

## Focused cross-harness review

Please verify:

1. The Spec-Kit workflow remains the primary installation and refresh path.
2. `.specify/spex.json` contains requested team-owned intent only; it does not accumulate detected capabilities, effective policy, timestamps, or workflow state.
3. Configuration behavior is implemented by one focused utility rather than a generic adapter or materialization framework.
4. Generated `.agents/`, `.codex/`, and `.claude/skills/` trees cannot become maintained duplicate sources.
5. Existing explicit repository configuration such as `.claude/settings.json` remains permitted.
6. Claude installation and debugging continue directly from canonical repository sources without staging.
7. No deferred feature-047 subsystem was imported to make this PR work.

## Evidence

- `make test-setup-profile`
- `make test-workflow-setup`
- `make test-generated-trees`
- `make validate`
- `make sync-scripts-check`
- `make test-install` — 39 assertions
- JSON Schema metaschema and valid-fixture checks

## Deferred deliberately

- Native Codex hooks and project policy translation
- Thin Codex marketplace discovery plugin
- Worktree/state authority
- Ship recovery and progress
- Teams/subagent execution
- Production OpenCode support
