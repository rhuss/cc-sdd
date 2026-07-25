---
name: cc-spex-init
description: Install or refresh Spex specification-driven workflows in the current project. Use when a Codex user asks to initialize Spex, configure Spex extensions or security, or update an existing Spex project through the cc-spex plugin.
---

# Initialize Spex

Run the bundled `scripts/bootstrap.sh` from this skill directory. Pass through
any arguments supplied after `$cc-spex-init`.

With no arguments, use these non-interactive defaults:

- harness: `codex`
- extensions: `recommended` (`spex-gates,spex-worktrees,spex-deep-review`)
- security: `safe`

Supported overrides:

```text
--integration codex|claude|opencode|auto
--extensions recommended|all|interactive|NAME,NAME
--security safe|autonomous|yolo|interactive
```

Before running a non-default selection, summarize all three selected values in
one line. Do not conduct a survey or ask about options the user already supplied.
After success, report the effective command prefix as `$`, remind the user to
start a new Codex session so generated skills are discovered, and suggest
`$speckit-spex-help`. Do not suggest slash-prefixed Spex commands or claim that
`$speckit-spex-ship` is necessarily the next workflow step.
