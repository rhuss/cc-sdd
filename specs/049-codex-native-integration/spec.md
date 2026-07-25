# Feature Specification: Native Codex Project Integration

## Goal

Make workflow-first Spex setup feel native in Codex without requiring a plugin
or materialization. Preserve user files, use `$skill` syntax, and make trusted
worktree Git operations prompt-free when YOLO is explicitly selected.

## Requirements

- **FR-001**: Merge a sentinel-owned block into `AGENTS.md`.
- **FR-002**: Show `$...`, never `/...`, for Codex Spex skill invocation.
- **FR-003**: Safe MUST leave user permission policy unchanged.
- **FR-004**: Autonomous MUST use automatic review within bounded permissions.
- **FR-005**: YOLO MUST be prompt-free for workspace, temp, and Git metadata.
- **FR-006**: YOLO MUST keep command network disabled and fail closed beyond bounds.
- **FR-007**: Support linked worktrees and Python 3.9 without third-party TOML.
- **FR-008**: Refresh MUST be byte-idempotent and preserve user content.
- **FR-009**: This slice MUST NOT install hooks or package a plugin.

## Success Criteria

- A linked worktree includes its Git common directory in its writable boundary.
- Repeating setup changes neither generated config nor guidance bytes.
- Existing workflow, generated-tree, and Claude manifest tests remain green.
