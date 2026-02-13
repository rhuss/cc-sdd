---
name: init
description: Run the sdd-init.sh script. Do not check for CLI tools or explore the filesystem.
---

# SDD Init

**Note:** The init workflow is defined in `sdd/commands/init.md` directly (not via skill reference) for higher compliance. This skill file exists as documentation only.

The init command:
1. Runs `sdd-init.sh` (path from `<sdd-init-command>` in hook context)
2. Asks user about trait selection and permissions
3. Runs `sdd-traits.sh init` and `sdd-traits.sh permissions`
4. Reports status and restart requirements

See `sdd/commands/init.md` for the authoritative implementation.
