# Feature Specification: Thin cc-spex Plugin

## Goal

Make Spex discoverable in Codex as `cc-spex` without moving setup logic into packaging.

## Requirements

- **FR-001**: Marketplace and manifest MUST name the plugin `cc-spex`.
- **FR-002**: Expose `$cc-spex-init` as the explicit setup entry.
- **FR-003**: Initialization MUST delegate to canonical `spex/setup.yml`.
- **FR-004**: Defaults MUST be Codex, recommended extensions, and Safe.
- **FR-005**: Help MUST list every override and its default.
- **FR-006**: Installation MUST NOT claim to initialize automatically.
- **FR-007**: Do not duplicate skills, adapters, state, recovery, or Teams.

## Success Criteria

- Codex plugin and skill validators pass.
- A fake `specify` observes the expected workflow inputs.
- The init skill advertises no `/...` Spex invocation.
