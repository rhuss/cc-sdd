# Research: Extract Review into Standalone cc-review Plugin

**Date**: 2026-08-02 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## R-001: Spec-kit Path Dependencies in Deep Review

**Question**: Which spec-kit path references in the deep-review command are mandatory vs optional?

**Findings**: The deep-review command (`speckit.spex-deep-review.run.md`, 1404 lines) references these spec-kit paths:

| Path | Usage | Required? | cc-review Approach |
|------|-------|-----------|-------------------|
| `.specify/scripts/bash/check-prerequisites.sh` | Spec resolution | Optional | Replace with `--spec <path>` flag; skip if absent |
| `.specify/extensions/spex-deep-review/deep-review-config.yml` | External tool config, test command | Optional | Use `~/.cc-review/config.yml` or `.cc-review/config.yml` standalone |
| `.specify/extensions/.registry` | Teams extension check | Optional | Skip parallel dispatch check; use adapter-provided capability flag |
| `.specify/.spex-state` | Ship pipeline state | Optional | Not needed standalone; spec-kit adapter passes pipeline context |
| `.specify/review-hints.md` | Review hints injection | Optional | Use `.cc-review/review-hints.md` or `--hints <path>` flag |
| `specs/<feature>/review-findings.md` | Output location | Required | Use `--output <path>` flag; default to `./review-findings.md` |
| `.specify/extensions/spex-deep-review/scripts/spex-flow-state.sh` | Flow state update | Optional | Not needed standalone; spec-kit adapter handles flow state |

**Decision**: All spec-kit paths are replaceable with flags or local defaults. The core review logic is fully extractable with a config resolution layer that checks (1) CLI flags, (2) `.cc-review/config.yml`, (3) built-in defaults.

**Alternatives considered**: Keeping `.specify/` path resolution in core and having standalone users create a `.specify/` directory. Rejected because it couples standalone UX to spec-kit conventions.

## R-002: Triage Spec-kit Dependencies

**Question**: Which spec-kit references exist in the triage command?

**Findings**: The triage command (`speckit.spex-collab.triage.md`, 926 lines) references:

| Path | Usage | Required? | cc-review Approach |
|------|-------|-----------|-------------------|
| `.specify/.spex-state` | Ship pipeline guard | Optional | Not needed standalone; spec-kit adapter checks before delegating |
| `.specify/extensions/spex-collab/scripts/spex-triage-state.sh` | State management | Required | Move script to `core/scripts/triage-state.sh` |
| `.specify/extensions/spex-collab/scripts/sanitize-gh-json.py` | JSON sanitization | Required | Move script to `core/scripts/sanitize-gh-json.py` |
| `.specify/extensions/spex-collab/collab-config.yml` | Codecov threshold, bot profiles | Optional | Use `.cc-review/config.yml` section |
| `.specify/scripts/bash/check-prerequisites.sh` | Spec-aware assessment | Optional | Use `--spec <path>` flag |
| `.specify/memory/constitution.md` | Principle extraction (Step 14) | Optional | Spec-kit adapter only; standalone skips |
| `brainstorm/idea-inbox.md` | Deferred findings capture (Step 15) | Optional | Use `--idea-inbox <path>` or skip |

**Decision**: Core triage is PR-centric. Spec-kit-specific features (ship guard, constitution principles, brainstorm capture) stay as adapter-only behavior. The spec-kit adapter wraps cc-review triage with these features.

**Alternatives considered**: Keeping constitution extraction in cc-review core. Rejected because it makes cc-review depend on spec-kit concepts.

## R-003: cc-review Detection Mechanism

**Question**: How should cc-spex detect that cc-review is installed?

**Findings**: Three detection approaches evaluated:

| Approach | Mechanism | Pros | Cons |
|----------|-----------|------|------|
| spec-kit registry | `jq '.extensions["cc-review"].enabled' .specify/extensions/.registry` | Consistent with existing pattern | Only works when cc-review is installed as spec-kit extension |
| Filesystem probe | Check for `~/.cc-review/` or `.cc-review/` | Works for all installation methods | Fragile; directory might exist without cc-review being functional |
| Marker file | Check for `.cc-review/.installed` or similar | Explicit signal | Requires cc-review to create the marker |

**Decision**: Use a two-tier detection. First check the spec-kit extension registry (fastest, most reliable for spec-kit users). If not found, check for a `.cc-review/` directory with a `config.yml` file (covers standalone installations). This handles both the spec-kit adapter path and the standalone installation path.

Detection script: `spex/extensions/spex-deep-review/scripts/detect-cc-review.sh` outputs the cc-review core path on stdout if found, exits non-zero if not found.

**Alternatives considered**: Environment variable (`CC_REVIEW_PATH`). Rejected as an unnecessary manual step.

## R-004: Adapter Thinness Contract

**Question**: What is the maximum acceptable complexity for an adapter?

**Findings**: SC-007 requires adapters under 50 lines each. Analyzed what an adapter needs to do:

1. Resolve the cc-review core path (installed location)
2. Parse harness-specific arguments into cc-review flags
3. Invoke the core command with resolved flags
4. Handle harness-specific post-processing (e.g., flow state update for spec-kit)

For Claude Code adapters (SKILL.md files):
- Frontmatter: ~5 lines
- Core path resolution: ~3 lines (check relative path from adapter install location)
- Argument mapping: ~5 lines
- Invocation: ~3 lines
- Total: ~16 lines (well under 50)

For spec-kit adapter:
- Extension manifest: separate file, not counted
- Command wrapper: ~20 lines (adds spec resolution, flow state, ship guard)
- Total: ~20 lines (well under 50)

**Decision**: Adapters are wrappers that: (1) locate cc-review core, (2) translate harness arguments to cc-review flags, (3) invoke the core command. No review logic in adapters.

## R-005: Simplified Fallback vs Full cc-review

**Question**: What exactly does the cc-spex "simplified built-in deep-review fallback" contain when cc-review is NOT installed?

**Findings**: Per FR-011 and the brainstorm, the simplified fallback retains:
- Same 6 review agent perspectives (identical prompts)
- Same fix loop (up to 3 rounds)
- Same finding schema and deduplication
- Same gate logic (Critical + Important = 0 for PASS)
- Same `review-findings.md` output format

The fallback removes:
- External tool integration (CodeRabbit, Copilot, Codex) - Steps 2 and 4 of the current command
- PR-level triage capability (no triage command)
- Goal alignment agent (skipped when no PR context is available, since it requires PR body and issue metadata to assess goal delivery)

This means the simplified fallback is roughly the current deep-review command minus ~200 lines of external tool code and triage delegation.

**Decision**: Create the simplified fallback by conditionally skipping Steps 2 (external tool detection) and 4 (external tool dispatch) when cc-review is not detected. The agent prompts, fix loop, and output format remain identical.

**Alternatives considered**: Removing the fallback entirely and requiring cc-review for any review. Rejected because it would break existing cc-spex users who upgrade.

## R-006: Config File Strategy

**Question**: Where does cc-review store its configuration when running standalone?

**Findings**: Convention survey across tools:

| Tool | Config Location |
|------|----------------|
| CodeRabbit | `.coderabbit.yaml` in project root |
| ESLint | `.eslintrc.*` in project root |
| Prettier | `.prettierrc` in project root |

**Decision**: cc-review uses `.cc-review/config.yml` in the project root for project-specific config, with `~/.cc-review/config.yml` as a user-level fallback. Config schema matches the existing `deep-review-config.yml` plus triage-specific keys (bot profiles, codecov thresholds).

Config resolution order: CLI flags > project `.cc-review/config.yml` > user `~/.cc-review/config.yml` > built-in defaults.

When running via the spec-kit adapter, the adapter maps `.specify/extensions/cc-review/config.yml` to cc-review's config resolution.

## R-007: Platform Support (GitHub vs GitLab)

**Question**: How should cc-review support both GitHub and GitLab for PR operations?

**Findings**: Current implementation is GitHub-only (`gh` CLI, GitHub GraphQL API). FR-008 requires GitLab support.

The triage command uses:
- `gh api graphql` for fetching review threads (GitHub-specific)
- `gh pr view` for PR metadata
- `gh pr checks` for CI status
- `gh api repos/...` for issue comments

GitLab equivalents:
- `glab api` for REST API (GitLab doesn't have a public GraphQL equivalent for MR threads)
- `glab mr view` for MR metadata
- GitLab CI API for pipeline status

**Decision**: Implement a platform abstraction layer as shell functions in `core/scripts/platform.sh`. Functions: `detect_platform()` (checks remote URL), `fetch_pr_threads()`, `fetch_pr_metadata()`, `post_reply()`, `resolve_thread()`, `check_ci()`. GitHub implementation first (port existing code). GitLab implementation as a follow-up PR (can be a separate task within this feature).

**Alternatives considered**: Separate command files for each platform. Rejected because it would duplicate the entire triage flow.

## R-008: Command Name Collision

**Question**: The `/review` command name collides with the existing superpowers `review` skill. How to resolve?

**Findings**: The existing superpowers `review` skill reviews GitHub PRs using `gh pr view`. cc-review's `/review` does multi-agent code review. These are complementary but different.

Options:
1. cc-review takes `/review`, superpowers keeps its existing name
2. cc-review uses `/code-review` to avoid collision
3. cc-review uses `/review` and superpowers renames to `/pr-review`

**Decision**: cc-review uses `/review` as its primary command. The existing superpowers `review` skill is a PR reading/viewing tool (reads PR content, checks, comments), while cc-review's `/review` is a code analysis tool (dispatches agents, produces findings). When cc-review is installed, it takes precedence for `/review`. The superpowers skill can be invoked explicitly as `/superpowers:review` if needed.

Per the spec assumption: "The `/review` command name is available. If it collides with an existing skill, the cc-review command takes precedence when installed."

## R-009: Harness Abstraction Tokens

**Question**: The deep-review command uses `{harness:...}` tokens (e.g., `{harness:codex-review-tool}`, `{harness:parallel-dispatch}`). How should cc-review handle these?

**Findings**: These tokens are spec-kit's harness abstraction mechanism. They allow the same command file to work across different AI agent harnesses by conditionally including/excluding content.

In cc-review standalone (without spec-kit):
- Codex-specific blocks: Include by default in Codex adapter, exclude in Claude Code adapter
- Parallel dispatch: Each adapter provides the native parallel mechanism or falls back to sequential
- Subagent mechanism: Each adapter specifies how to spawn review sub-agents

**Decision**: cc-review core commands use plain markdown without harness tokens. Each adapter is responsible for providing the harness-specific invocation mechanism. The core command accepts a `--parallel` flag and a `--subagent-type` flag that adapters set based on their harness capabilities.

This is simpler than spec-kit's token-based approach and avoids a dependency on spec-kit's harness adapter registry.
