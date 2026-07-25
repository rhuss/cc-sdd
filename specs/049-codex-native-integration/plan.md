# Implementation Plan: Native Codex Project Integration

Use a Python standard-library configurator called by `spex/setup.yml`. It
resolves the Git common directory, writes a current Codex named permission
profile into a sentinel-owned `.codex/config.toml` block, and merges concise
Codex guidance into `AGENTS.md`. Safe removes only Spex-owned permission data;
Autonomous uses auto-review; YOLO uses `never`, so out-of-bound actions fail
rather than interrupting the user.

Project hooks are excluded. Codex plugins carry hooks natively, so project hook
installation would duplicate ownership and trust review.
