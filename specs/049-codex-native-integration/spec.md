# Feature Specification: Native Codex Project Integration

## Goal

Make workflow-first Spex setup feel native in Codex without requiring a plugin
or materialization. Preserve user files, use `$skill` syntax, keep Autonomous
bounded, and make YOLO reliably prompt-free and unrestricted when explicitly
selected.

## Requirements

- **FR-001**: Merge a sentinel-owned block into `AGENTS.md`.
- **FR-002**: Show `$...`, never `/...`, for Codex Spex skill invocation.
- **FR-003**: Safe MUST leave user permission policy unchanged.
- **FR-004**: Autonomous MUST set `approval_policy = "on-request"` and
  `approvals_reviewer = "auto_review"` within bounded `spex-project` permissions.
- **FR-005**: YOLO MUST set `sandbox_mode = "danger-full-access"` and
  `approval_policy = "never"` so filesystem and network access are unrestricted
  and prompt-free.
- **FR-006**: Safe MUST preserve existing user policy without adding a sandbox,
  approval policy, or permission profile.
- **FR-007**: Support linked worktrees and Python 3.9 without third-party TOML.
- **FR-008**: Refresh MUST be byte-idempotent and preserve user content.
- **FR-009**: This slice MUST NOT install hooks or package a plugin.

## Success Criteria

- Autonomous in a linked worktree includes its Git common directory in its
  writable boundary and keeps command network access disabled.
- YOLO works without a Git repository and permits network access without prompts.
- Repeating setup changes neither generated config nor guidance bytes.
- Existing workflow, generated-tree, and Claude manifest tests remain green.
