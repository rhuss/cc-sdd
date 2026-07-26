# Research: Current Codex Contracts

The current Codex configuration contract supports two distinct mappings needed
here. Named permission profiles use `default_permissions` plus `[permissions.*]`,
and linked-worktree Git metadata needs an explicit writable root when that
profile is bounded. `approval_policy = "on-request"` with
`approvals_reviewer = "auto_review"` preserves that boundary for Autonomous
without routine user prompts.

For YOLO, `sandbox_mode = "danger-full-access"` removes the filesystem and
network sandbox, while `approval_policy = "never"` removes approval prompts.
Keeping the named profile in YOLO would contradict the requested unrestricted
mode and could make unattended workflows fail at its boundary.

Decision: use the bounded named profile only for Autonomous, use native
danger-full-access plus never-approve settings for YOLO, preserve user policy in
Safe, and defer hooks to plugin packaging. Do not carry the old hook installer
or `tomllib` dependency forward. Codex supports explicit `$` mentions for skills.
