# Review Summary: Agent Teams Integration for SDD

**Spec:** specs/005-teams-traits/spec.md | **Plan:** specs/005-teams-traits/plan.md
**Generated:** 2026-02-27

---

## Executive Summary

The SDD plugin currently runs implementation tasks one at a time within a single Claude Code session. When a feature has many independent tasks, this sequential approach wastes time that could be spent on parallel work. Claude Code recently shipped Agent Teams, an experimental feature that lets multiple Claude Code sessions coordinate on shared work. Each "teammate" gets its own context window, claims tasks from a shared list, and communicates with the lead session.

This feature introduces two new SDD traits that plug into Agent Teams. The first trait, `teams-vanilla`, adds basic team orchestration to `/speckit.implement`: the lead reads the task list, figures out which tasks can run simultaneously, spawns teammates, and waits for them to finish. The second trait, `teams-spec`, builds on the first with three additions: the lead stops implementing and instead acts as a "spec guardian" that reviews each teammate's completed work against the specification before merging it; each teammate works in an isolated git worktree to prevent file conflicts; and task state bridges to the beads persistence layer so progress survives across sessions.

Because `teams-spec` depends on `teams-vanilla` (for base orchestration), `superpowers` (for review-code), and `beads` (for persistence), this feature also adds dependency checking to the trait infrastructure. Enabling a trait now validates that its dependencies are already active, and disabling a trait checks that nothing else depends on it. This is the first time traits have formal dependencies, and it extends the constitution's composability principle in a controlled way.

The implementation is scoped to 19 tasks across 7 phases, all Markdown and Bash. No compiled artifacts, no new external dependencies beyond the existing `jq` and `bd` CLIs. The MVP (Phases 1-3) delivers parallel implementation with `teams-vanilla` alone.

## PR Contents

| Artifact | Description |
|----------|-------------|
| `spec.md` | Feature specification covering two traits, dependency infrastructure, 5 user stories |
| `plan.md` | Implementation plan with 4 phases, constitution check, risk assessment |
| `tasks.md` | 19 tasks across 7 phases with dependency graph and parallel opportunities |
| `research.md` | Technical decisions: bash 3.2 compatibility, precedence handling, worktree approach |
| `review-summary.md` | This file |
| `checklists/requirements.md` | Spec quality checklist (all items passing) |

## Technical Decisions

### Bash 3.2 Compatibility for Dependency Map
- **Chosen approach:** Case-statement function (`get_trait_deps()`) instead of associative arrays
- **Alternatives considered:**
  - `declare -A` associative arrays: Not available in macOS default bash 3.2. Would break for users without Homebrew bash.
  - JSON file for dependency map: Adds unnecessary file I/O and another artifact to maintain
- **Trade-off:** Slightly more verbose code, but works everywhere without bash version requirements

### Precedence Handling (teams-spec over teams-vanilla)
- **Chosen approach:** The `teams-spec-guardian` skill checks `.specify/sdd-traits.json` at runtime. When both overlays are appended, the spec guardian instructions appear later in the file and take precedence.
- **Alternatives considered:**
  - Conditional overlay application (skip vanilla if spec is enabled): Breaks the "append all enabled" overlay model
  - Single combined skill with mode detection: Violates constitution Principle VI (Skill Autonomy)
- **Trade-off:** Both overlays are always appended even when only spec-guardian runs. Minor overhead.

### Feature Flag Auto-Enablement
- **Chosen approach:** Overlay checks for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` at runtime and sets it in `.claude/settings.local.json` if missing, informing user to restart.
- **Alternatives considered:**
  - Require manual setup: Adds friction, users may not know about the flag
  - Set during `sdd-traits.sh enable`: Wrong layer (trait script manages config, not runtime env)
- **Trade-off:** Requires restart, but only on first use.

## Critical References

| Reference | Why it needs attention |
|-----------|----------------------|
| `spec.md` FR-D01 through FR-D04: Trait Dependency Infrastructure | First time traits have formal dependencies. Extends constitution Principle III (composability). Reviewer should verify the dependency model doesn't create fragility. |
| `spec.md` FR-S09: Precedence of teams-spec over teams-vanilla | Both overlays append to the same file. The precedence mechanism needs reviewer confidence that it works reliably. |
| `spec.md` Edge Cases: Teammate crash, merge conflicts | These failure modes are handled by the lead, not the platform. Reviewer should assess whether the recovery strategies are sufficient. |
| `plan.md` Risk Assessment: `declare -A` portability | The switch from associative arrays to case statements is a research.md decision. Reviewer should confirm this is the right call for the target audience. |

## Reviewer Checklist

### Verify
- [ ] Dependency map in FR-D01 correctly models all relationships (teams-spec depends on teams-vanilla, superpowers, beads)
- [ ] The 30-line overlay limit (constitution Principle II) is achievable for both overlays given their delegation requirements
- [ ] Case-statement dependency lookup is maintainable as more traits are added in the future

### Question
- [ ] Should constitution Principle III be formally amended to acknowledge trait dependencies, or is the current "controlled extension" sufficient?
- [ ] Is the "5 teammate maximum" (FR-V04) the right default? CC Teams docs suggest 3-5, but should this be configurable?
- [ ] Should the feature flag auto-enablement write to `.claude/settings.local.json` or `.claude/settings.json`? Local is less intrusive but may not persist across project clones.

### Watch out for
- [ ] CC Teams is experimental. If the API changes or the feature is removed, both traits will need updating.
- [ ] Token cost can be significant with teams. The spec explicitly makes this opt-in (trait), but users may be surprised by the cost.
- [ ] macOS bash 3.2 compatibility: the existing script already uses some bash 4+ features (verify before committing to case-statement approach).

## Scope Boundaries
- **In scope:** Two traits (teams-vanilla, teams-spec), trait dependency infrastructure, two new skills, init command update
- **Out of scope:** Non-implementation phases, custom teammate models, nested teams, automatic cost optimization
- **Why these boundaries:** Agent Teams adds most value during implementation (many independent tasks). Other SDD phases are inherently sequential. Cost optimization and model selection are user concerns, not plugin concerns.

## Naming & Schema Decisions

| Item | Name | Context |
|------|------|---------|
| Trait 1 | `teams-vanilla` | "Vanilla" indicates basic/unmodified CC Teams usage |
| Trait 2 | `teams-spec` | "Spec" indicates spec-guardian pattern |
| Skill 1 | `sdd:teams-orchestrate` | Vanilla orchestration logic |
| Skill 2 | `sdd:teams-spec-guardian` | Spec guardian logic with review + merge |
| Sentinel 1 | `<!-- SDD-TRAIT:teams-vanilla -->` | Standard sentinel pattern |
| Sentinel 2 | `<!-- SDD-TRAIT:teams-spec -->` | Standard sentinel pattern |
| Dependency function | `get_trait_deps()` | Returns space-separated dep list per trait |

## Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| CC Teams feature removed/changed | High | Feature flag check with sequential fallback |
| Worktree merge conflicts | Medium | Lead pauses and reports to user, no auto-resolution |
| Teammate crashes mid-task | Medium | Lead detects idle state, spawns replacement or falls back |
| Token cost surprises | Low | Opt-in trait with documentation warning |
| macOS bash 3.2 incompatibility | Medium | Case-statement approach avoids associative arrays |

---
*Share this with reviewers. Full context in linked spec and plan.*
