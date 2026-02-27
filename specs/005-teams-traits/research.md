# Research: Agent Teams Integration for SDD

**Date**: 2026-02-27
**Feature**: 005-teams-traits

## Claude Code Agent Teams Integration Patterns

### Decision: Overlay + Skill Architecture

**Rationale**: Follows the established SDD trait pattern. Overlays inject minimal instructions into `/speckit.implement`, skills contain the orchestration logic. This keeps overlays auditable (< 30 lines) and skills self-contained.

**Alternatives considered**:
- Hook-based approach (using `TaskCompleted` and `TeammateIdle` hooks): Rejected because hooks are shell scripts, not skill instructions. The lead needs natural language guidance to act as coordinator/guardian, which fits the skill pattern better.
- Direct inline in overlay: Rejected by constitution Principle II (Overlay Delegation). Would exceed 30-line limit.

### Decision: Feature Flag Auto-Enablement

**Rationale**: CC Teams requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Rather than requiring users to set this manually, the overlay will check for it and set it in `.claude/settings.local.json` if missing. This requires a restart but removes a manual step.

**Alternatives considered**:
- Require users to set it manually: More transparent but adds friction. Users may not know about the flag.
- Set it during `sdd-traits.sh enable teams-vanilla`: Would work but the settings.local.json modification is more naturally done by the overlay/skill at runtime.

### Decision: Bash Associative Array for Dependency Map

**Rationale**: `sdd-traits.sh` already uses `#!/bin/bash` (not POSIX sh). Bash associative arrays (`declare -A`) are available in bash 4+ (macOS ships bash 3.2 by default, but Homebrew bash is 5+). Since the plugin targets developers who likely have modern bash, this is acceptable.

**Alternatives considered**:
- Function-based lookup (`deps_for_trait()` with case statements): More portable but harder to maintain as traits grow.
- JSON file for dependency map: Adds file I/O overhead and another artifact to manage.

**Risk note**: macOS default bash is 3.2 (no associative arrays). Mitigation: use a function-based fallback or document the bash 4+ requirement. The existing `sdd-traits.sh` already uses `declare -a` (indexed arrays) and `read -ra` which work in bash 3.2, but `declare -A` does not. **Recommendation**: Use function-based lookup instead of associative arrays for macOS compatibility.

### Decision: Function-Based Dependency Lookup (Revised)

**Rationale**: After researching macOS bash compatibility, use case-statement functions instead of associative arrays. This works with bash 3.2 (macOS default) and is equally readable.

```bash
get_trait_deps() {
  case "$1" in
    teams-spec) echo "teams-vanilla superpowers beads" ;;
    *) echo "" ;;
  esac
}
```

**Alternatives considered**:
- Associative arrays: Not portable to macOS default bash 3.2.

### Decision: Spec Guardian Precedence via Skill Detection

**Rationale**: When both `teams-vanilla` and `teams-spec` overlays are appended to `speckit.implement`, the `teams-spec` skill will check if `teams-spec` trait is enabled (by reading `.specify/sdd-traits.json`). If enabled, it takes over. The vanilla skill is still invoked but its instructions are superseded by the spec guardian instructions later in the file.

**Alternatives considered**:
- Conditional overlay (only append teams-vanilla if teams-spec is not enabled): Would require modifying the overlay application logic, breaking the current "append all enabled" model.
- Single combined skill that checks which mode to use: Violates Principle VI (Skill Autonomy), mixes two concerns.

### Decision: Worktree via CC Teams Native Mechanism

**Rationale**: Claude Code's `Task` tool supports `isolation: "worktree"` for subagents, but CC Teams teammates are different from subagents. CC Teams uses the `EnterWorktree` tool for worktree management. The skill will instruct the lead to request worktree mode when spawning teammates.

**Alternatives considered**:
- Manual worktree creation via `git worktree add`: More control but adds complexity. CC Teams native worktree support handles cleanup.
- No worktrees (file ownership model): Simpler but risk of file conflicts. Spec explicitly chose worktrees.

## No Outstanding Clarifications

All technical context items are resolved. No NEEDS CLARIFICATION markers remain.
