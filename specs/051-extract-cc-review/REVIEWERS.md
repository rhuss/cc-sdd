# Review Guide: Extract Review into Standalone cc-review Plugin

**Generated**: 2026-08-02 | **Spec**: [spec.md](spec.md)

## Why This Change

The deep-review agents (6 specialized code review perspectives + autonomous fix loop) and PR comment triage workflow are embedded inside cc-spex, coupled to spec-kit paths and the SDD lifecycle. This means any developer who wants multi-agent code review or automated PR triage must install spec-kit and cc-spex, even if they don't use specification-driven development. The review capabilities are useful on their own, and locking them behind the SDD workflow limits adoption across different AI coding agents (Codex, OpenCode, and others beyond Claude Code).

## What Changes

A new standalone plugin `cc-review` (`rhuss/cc-review`) is created with the core review agents, triage workflow, and fix loop. cc-spex is refactored to detect cc-review and delegate to it when present, or fall back to a simplified built-in review (same 6 agents, no external tool integration) when cc-review is absent. The triage command moves out of `spex-collab` entirely. Three thin adapters (Claude Code, spec-kit, Codex/OpenCode) provide native installation formats for each harness. This is a breaking change for cc-spex users who relied on triage via `spex-collab`, but the upgrade path is installing cc-review, which provides the same triage plus enhancements.

## How It Works

cc-review uses a core + adapters architecture. The `core/` directory contains the harness-agnostic review command (agent dispatch, finding merge, fix loop), triage command (PR comment fetching, bot classification, fix application), agent prompts (6 markdown files), and helper scripts (config resolution, platform detection, JSON sanitization, triage state management). The `adapters/` directory contains thin wrappers (< 50 lines each) that translate each harness's native command format into cc-review core invocations.

Config resolution follows: CLI flags > project `.cc-review/config.yml` > user `~/.cc-review/config.yml` > built-in defaults. Spec awareness is optional: when a `--spec` flag provides a spec path, agents include spec compliance checking. Without it, they do pure code review.

On the cc-spex side, a detection script checks two tiers: (1) spec-kit extension registry for `cc-review`, (2) filesystem probe for `.cc-review/config.yml`. When found, `spex-deep-review` delegates with `--spec`, `--hints`, and `--output` flags. When not found, it runs the simplified fallback (identical agents, no external tools).

## When It Applies

**Applies when**:
- A developer wants multi-agent code review without spec-kit or cc-spex
- A developer wants automated PR comment triage (bot classification + fix application)
- An existing cc-spex user wants enhanced review with external tool integration (CodeRabbit, Copilot, Codex)
- A user of Codex, OpenCode, or other non-Claude-Code agents wants code review

**Does not apply when**:
- CI/CD bot integration (running cc-review in CI pipelines is out of scope for initial release)
- Platforms beyond GitHub and GitLab (e.g., Bitbucket, Azure DevOps)
- Custom review agent creation (the 6 agents are fixed; user-defined agents are future work)

## Key Decisions

1. **Standalone plugin with thin adapters** over spec-kit extension bundle. Users get code review without installing spec-kit. The adapters are thin wrappers (< 50 lines), minimizing maintenance overhead. Alternative: spec-kit-only distribution was rejected because it limits reach.

2. **Two-tier detection mechanism** (registry then filesystem) over environment variables. Automatic detection avoids manual configuration. Registry check handles spec-kit users, filesystem probe handles standalone installations. Alternative: `CC_REVIEW_PATH` environment variable was rejected as an unnecessary manual step.

3. **Config in `.cc-review/` directory** over `.specify/` paths for standalone mode. Following conventions from tools like CodeRabbit (`.coderabbit.yaml`) and ESLint (`.eslintrc`). The spec-kit adapter maps spec-kit config locations to cc-review's resolution chain.

4. **Platform abstraction via shell functions** in `core/scripts/platform.sh` over separate command files per platform. GitHub is fully implemented; GitLab has stub implementations. Alternative: separate triage command files per platform was rejected because it would duplicate the entire triage flow.

5. **Simplified fallback in cc-spex** retains identical agent prompts and fix loop, only removing external tool integration. This ensures existing cc-spex users get the same review quality without cc-review installed.

## Areas Needing Attention

- **Triage migration path**: Users who have triage state from `spex-collab` will need to understand that triage now comes from cc-review. The state file location changes from `.specify/` to `.cc-review/`.
- **Command name collision**: `/review` conflicts with the existing superpowers `review` skill. The decision is that cc-review takes precedence when installed, but this may surprise users who expect the superpowers PR-viewing behavior.
- **Adapter thinness enforcement**: The 50-line limit (SC-007) is a design constraint, not a test. Reviewers should verify each adapter contains no review logic.
- **GitLab support depth**: FR-008 requires GitHub + GitLab, but the plan implements full GitHub with GitLab stubs. The stubs use `glab` CLI but are marked experimental.
- **Two-repo coordination**: Tasks span `rhuss/cc-review` and `rhuss/cc-spex`. Implementation order matters: cc-review core must be stable before cc-spex delegation changes land.

## Open Questions

- Whether the deep-review trigger hardening issue (95% threshold gap where deep review never fires after findings are fixed) should be addressed in cc-review or cc-spex
- Exact precedence behavior when both cc-review's `/review` and superpowers' `/review` are installed in the same Claude Code session
- Whether cc-review should provide its own `make release` or similar validation tooling, or rely on manual smoke tests

## Review Checklist

- [ ] Key decisions are justified
- [ ] Breaking changes are documented with migration guidance
- [ ] Scope matches the stated boundaries
- [ ] Success criteria are achievable
- [ ] No unstated assumptions
- [ ] Adapter files are under 50 lines each (SC-007)
- [ ] cc-review core has zero spec-kit path dependencies
- [ ] Delegation contract is clearly defined between cc-spex and cc-review
- [ ] Triage removal from spex-collab leaves other commands intact
- [ ] GitLab stubs are marked as experimental
