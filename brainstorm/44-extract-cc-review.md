# Brainstorm: Extract Review Workflow into Standalone cc-review Plugin

**Date:** 2026-08-02
**Status:** active
**Issue:** https://github.com/rhuss/cc-spex/issues/50

## Problem Framing

The deep-review agents (6 specialized review agents + autonomous fix loop) and PR triage workflow in cc-spex are useful beyond the spec-driven development context. Any developer working with PRs on GitHub/GitLab could benefit from multi-agent code review and automated triage of bot vs human comments, without needing specs, plans, or the full SDD workflow.

Currently, these capabilities are embedded in two cc-spex extensions:
- `spex-deep-review`: 6 review agents, fix loop, external tool integration (CodeRabbit, Copilot, Codex)
- `spex-collab`: triage (PR comment classification and handling), plus spec-centric commands (revise, reconcile, phase-split, phase-manager, reviewers)

The coupling to spec-kit paths and the spex lifecycle makes these inaccessible to users who want code review without spec-driven development. With cc-spex moving toward harness agnosticism (brainstorm #28), a review plugin should also be harness-agnostic from the start.

## Approaches Considered

### A: Spec-kit Extension Bundle
cc-review as a spec-kit bundle installed via `specify enable`. Inherits harness agnosticism from spec-kit (28+ harness adapters). Clean integration with cc-spex via extension registry.

- Pros: Minimal new infrastructure, proven extension model, natural upgrade path
- Cons: Requires spec-kit installation even for users who only want PR reviews. Ties the review plugin to spec-kit's ecosystem, limiting reach (e.g., OpenShell users).

### B: Standalone Plugin with Thin Adapters (Chosen)
cc-review as an independent repo with harness-agnostic core review logic. Thin adapters for each ecosystem: spec-kit extension wrapper for cc-spex integration, Claude Code commands, Codex/OpenShell AGENTS.md fragments.

- Pros: Works without spec-kit. Maximum reach across agent harnesses. Clean separation of concerns. Each harness gets its native installation format.
- Cons: Multiple adapter layers (but they're thin wrappers, not logic). Slightly more complex repo structure. Adapter maintenance (mitigated by keeping adapters logic-free).

### C: Monorepo (cc-review inside cc-spex)
Keep review as a directory within cc-spex, independently installable.

- Pros: Single repo, shared CI/testing
- Cons: Couples release cycles, harder independent discovery, users who want review might not want the whole cc-spex repo

## Decision

**Approach B: Standalone plugin with thin adapters.**

The key insight is that the cons of B (adapter maintenance, complexity) are manageable in practice because adapters are thin wrappers with no logic of their own. The benefit (independence from spec-kit, maximum reach) is significant for adoption, especially for users like OpenShell who want code review without buying into the SDD methodology.

Analysis of current code confirms feasibility: the deep-review command has ~26 spec-kit path references, but most are optional (spec path, review hints, config locations). The core logic (dispatch agents, collect findings, fix loop) is inherently spec-independent. Triage is purely PR-centric with only config path and ship-guard references to spec-kit.

## Key Requirements

### Scope Split
- **Moves to cc-review**: 6 review agents + fix loop, external tool integration (CodeRabbit/Copilot/Codex), PR comment triage (fetch/classify/apply/reply)
- **Stays in cc-spex**: revise (spec cascade), reconcile, phase-split, phase-manager, reviewers (REVIEWERS.md generation), and a simplified built-in deep-review fallback

### Architecture
- **Core**: Harness-agnostic review logic as markdown command files, standalone scripts (Python for JSON sanitization, Bash for state management)
- **Adapters**: Thin wrappers for spec-kit, Claude Code, Codex/OpenShell (and future harnesses)
- **Spec awareness**: Optional input, not a dependency. If a spec is provided (by cc-spex or manually), review agents use it for compliance checking. Otherwise, pure code review.

### Standalone UX
- Entry point: `/review` slash command (or equivalent per harness)
- Works against current branch diff or a specific PR (`/review --pr 42`)
- No spec, no plan, no tasks required

### cc-spex Integration
- cc-spex keeps a simplified deep-review fallback (6 agents, fix loop, no external tools) for standalone use
- When cc-review is detected, `spex-deep-review` delegates to cc-review's enhanced agents
- Spec path and review hints are passed as optional inputs to cc-review

### Repo
- New GitHub repo: `rhuss/cc-review`
- Independent releases, stars, issues
- Own documentation and installation guides per harness

## Open Questions
- Exact adapter structure for each target harness
- Detection mechanism: how cc-spex discovers cc-review presence (registry check, filesystem probe, or environment variable)
- Concrete differences between "simplified" fallback and "full" cc-review agents (which agents are omitted? which features gated?)
- Whether the deep-review trigger hardening issue (95% threshold gap where deep review never fires after findings are fixed) should be addressed in cc-review or cc-spex
- Config file location and format for standalone cc-review without `.specify/` directory
- CI integration story: how would a bot trigger cc-review on every PR?
- Relationship to existing `/review` skill in superpowers (naming collision?)
