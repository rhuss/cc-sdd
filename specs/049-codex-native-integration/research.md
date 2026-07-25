# Research: Current Codex Contracts

The current official Codex manual establishes that named permission profiles use
`default_permissions` plus `[permissions.*]`; worktree Git metadata can need an
explicit writable root; `approval_policy = "never"` removes prompts; plugins can
bundle hooks; and Codex supports explicit `$` mentions for skills.

Decision: use current permission profiles and defer hooks to plugin packaging.
Do not carry the old hook installer or `tomllib` dependency forward.
