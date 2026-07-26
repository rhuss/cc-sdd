# Review Guide: Native Codex Project Integration

Review this stacked PR against `048-workflow-first-setup`.

- Confirm Autonomous uses the bounded `spex-project` profile with on-request
  auto-review, including linked-worktree Git metadata and disabled network.
- Confirm YOLO uses `danger-full-access` with approvals set to `never`, including
  unrestricted network access.
- Confirm user `AGENTS.md` and `.codex/config.toml` content is preserved.
- Confirm examples use `$`, and Claude behavior is unchanged.
- Reject hooks, packaging, materialization, state/recovery, or Teams work.
