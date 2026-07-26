# Implementation Plan: Native Codex Project Integration

Use a Python standard-library configurator called by `spex/setup.yml`. It
resolves the Git common directory for Autonomous, writes a sentinel-owned
`.codex/config.toml` block, and merges concise Codex guidance into `AGENTS.md`.
Safe removes only Spex-owned permission data. Autonomous uses the bounded
`spex-project` profile with on-request auto-review. YOLO uses the unrestricted
`danger-full-access` sandbox with `never`, so filesystem and network operations
run without approval prompts.

Project hooks are excluded. Codex plugins carry hooks natively, so project hook
installation would duplicate ownership and trust review.
