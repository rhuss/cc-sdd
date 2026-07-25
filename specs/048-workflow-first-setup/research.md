# Research: Workflow-First Spex Setup

## Project configuration format

**Decision**: Store requested project intent in `.specify/spex.json`.

**Rationale**: `jq` is already a setup dependency, JSON has an unambiguous standard parser, and Python 3.9 can read and write it without additional modules. This avoids adding `yq`, PyYAML, or a partial YAML implementation.

**Plan deviation**: Early discussion used `.specify/spex.yml` as an illustrative
name. The implementation deliberately standardizes on JSON for the portability
reason above; this is a conscious contract choice rather than an oversight.

**Alternatives considered**: YAML requires another parser; TOML is not readable through Python's standard library on macOS Python 3.9; `.specify/init-options.json` is owned by Spec-Kit.

## Ownership and persistence

**Decision**: Treat `.specify/spex.json` as user/team-owned intent and keep generated/effective state outside it. Persist only after the whole request validates, using same-directory temporary-file replacement.

**Rationale**: A declaration must remain stable across harness refreshes and must not falsely claim that a requested security level was applied. Atomic replacement prevents partial configuration after interruption.

**Alternatives considered**: Mixing requested and effective values causes unrelated churn; incremental writes can leave misleading partial intent.

## Input precedence

**Decision**: Resolve values in this order: explicit workflow input, stored project intent, recommended default. Empty workflow inputs mean “not explicitly supplied.”

**Rationale**: Concrete workflow defaults otherwise overwrite stored non-default choices on every refresh.

**Alternatives considered**: Environment variables are invisible and session-scoped; fixed workflow defaults cannot distinguish omission from override.

## Interactive setup

**Decision**: Keep interaction in workflow prompt steps. Normalize their result through the same profile utility used by scripted setup, then persist once.

**Rationale**: Profile code remains independent of agent UI and plugin installation.

**Alternatives considered**: A plugin init skill would make the plugin mandatory; an interactive Python utility would duplicate harness UI behavior.

## Generated-tree discipline

**Decision**: Ignore `.agents/`, `.codex/`, and project-local `.claude/` trees, explicitly unignore `.specify/spex.json`, and add a tracked-file guard with a narrow allowlist for maintained repository sources.

**Rationale**: Ignore rules prevent ordinary accidents; a tracked-file check catches force-added or previously tracked generated files.

**Alternatives considered**: Ignore rules alone are bypassable; rejecting all agent-named paths would reject legitimate maintained descriptors and `AGENTS.md`.

## Native plugin lifecycle

**Decision**: Defer native plugin discovery to a separate feature. A future thin plugin may expose an explicit init skill, but installation will not execute the Specify workflow implicitly.

**Rationale**: The current Codex contract has no supported post-install command lifecycle. Silent setup would also expand installation authority unexpectedly.

**Alternatives considered**: Unsupported install hooks and retaining the complete feature-047 materializer were rejected.
