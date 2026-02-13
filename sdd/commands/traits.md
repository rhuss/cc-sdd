---
name: sdd:traits
description: Manage SDD trait overlays - enable, disable, or list active traits
---

# SDD Traits Management

Manage which SDD traits are active. Traits inject discipline overlays into spec-kit command and template files.

**Valid traits**: `sdd`, `beads`

## Parse Arguments

Parse `$ARGUMENTS` for the subcommand and optional trait name:

- No arguments or `list` -> **List** active traits
- `enable <trait-name>` -> **Enable** the specified trait
- `disable <trait-name>` -> **Disable** the specified trait

## Subcommand: List (default)

1. Check if `.specify/sdd-traits.json` exists.
2. If it does not exist: report "No traits configured. Run `/sdd:init` to set up traits." and STOP.
3. If it exists: read the file and display each trait's status in a clear format:
   - For each trait in the `traits` object, display `<trait-name>: enabled` or `<trait-name>: disabled`
   - Also display the `applied_at` timestamp

## Subcommand: Enable

1. Validate the trait name is one of: `sdd`, `beads`. If not, report the error and list valid trait names.
2. Read `.specify/sdd-traits.json`. If it does not exist, report "No traits configured. Run `/sdd:init` first." and STOP.
3. Set the specified trait to `true` in the `traits` object.
4. Update `applied_at` to the current ISO 8601 timestamp.
5. Write the updated config back to `.specify/sdd-traits.json` using the Write tool.
6. Run `<plugin-root>/scripts/apply-traits.sh` via Bash tool. The plugin root is derived from this command file's location: this file is at `commands/traits.md`, so the plugin root is `../` relative to this file.
7. Report the result.

## Subcommand: Disable

1. Validate the trait name is one of: `sdd`, `beads`. If not, report the error and list valid trait names.
2. Read `.specify/sdd-traits.json`. If it does not exist, report "No traits configured. Run `/sdd:init` first." and STOP.
3. **Warn the user**: Disabling a trait requires regenerating all spec-kit files, which resets any manual customizations to `.claude/commands/speckit.*.md` and `.specify/templates/*.md` files.
4. Use `AskUserQuestion` to confirm:
   - **Question**: "Disabling a trait will reset all spec-kit files to defaults (losing any manual customizations). Proceed?"
   - **Header**: "Confirm"
   - **Options**:
     - Label: "Yes, disable", Description: "Reset spec-kit files and remove this trait's overlays"
     - Label: "Cancel", Description: "Keep current trait configuration unchanged"
5. If cancelled: report "Trait disable cancelled." and STOP.
6. If confirmed:
   a. Set the specified trait to `false` in the `traits` object.
   b. Update `applied_at` to the current ISO 8601 timestamp.
   c. Write the updated config back to `.specify/sdd-traits.json`.
   d. Run `specify init --here --ai claude --force` to reset spec-kit files to defaults.
   e. Run `<plugin-root>/scripts/apply-traits.sh` to reapply only the remaining enabled traits.
   f. Report which traits are still active.
