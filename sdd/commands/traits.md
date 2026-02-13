---
name: sdd:traits
description: Manage SDD trait overlays - enable, disable, or list active traits
argument-hint: "[list | enable <sdd|beads> | disable <sdd|beads>]"
---

# SDD Traits Management

Manage which SDD traits are active. Traits inject discipline overlays into spec-kit command and template files.

**Valid traits**: `sdd`, `beads`

### Step 0: Resolve Plugin Root

Extract `PLUGIN_ROOT` from the `<sdd-context>` system reminder
injected by the UserPromptSubmit hook. Use the value from `<plugin-root>`.

If `<sdd-context>` is not present, the hook may not have fired.
Instruct the user to verify the plugin is installed correctly.

---

## Parse Arguments

Parse `$ARGUMENTS` for the subcommand and optional trait name:

- No arguments or `list` -> **List**
- `enable <trait-name>` -> **Enable**
- `disable <trait-name>` -> **Disable**

## Subcommand: List (default)

Run via Bash:

```bash
"$PLUGIN_ROOT/scripts/sdd-traits.sh" list
```

Display the output to the user.

## Subcommand: Enable

Run via Bash:

```bash
"$PLUGIN_ROOT/scripts/sdd-traits.sh" enable <trait-name>
```

Report the result to the user.

## Subcommand: Disable

1. Run `"$PLUGIN_ROOT/scripts/sdd-traits.sh" list` and check if the trait is already disabled. If so, report that and STOP.
2. **Warn the user**: Disabling a trait requires regenerating all spec-kit files, which resets any manual customizations to `.claude/commands/speckit.*.md` and `.specify/templates/*.md` files.
3. Use `AskUserQuestion` to confirm:
   - **Question**: "Disabling a trait will reset all spec-kit files to defaults (losing any manual customizations). Proceed?"
   - **Header**: "Confirm"
   - **Options**:
     - Label: "Yes, disable", Description: "Reset spec-kit files and remove this trait's overlays"
     - Label: "Cancel", Description: "Keep current trait configuration unchanged"
4. If cancelled: report "Trait disable cancelled." and STOP.
5. If confirmed, run these commands sequentially via Bash:
   ```bash
   "$PLUGIN_ROOT/scripts/sdd-traits.sh" disable <trait-name>
   specify init --here --ai claude --force
   "$PLUGIN_ROOT/scripts/sdd-traits.sh" apply
   ```
6. Report which traits are still active.
