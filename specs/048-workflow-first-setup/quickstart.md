# Quickstart: Validate Workflow-First Setup

## Prerequisites

- `specify` CLI supported by the repository
- `git`, `jq`, and Python 3.9 or newer

## 1. Validate profile behavior

```bash
python3 -m unittest tests/test_setup_profile.py
```

Expected: defaults, stored values, explicit overrides, dependency closure, invalid inputs, migration, and atomic replacement pass.

## 2. Validate first setup

In a disposable Git repository, run the local setup workflow with explicit non-default selections:

```bash
specify workflow run spex/setup.yml \
  -i integration=claude \
  -i extensions=spex-gates,spex-worktrees \
  -i security=autonomous
```

Expected: `.specify/spex.json` records the accepted request and the installed extension set matches it.

## 3. Validate refresh

Run the workflow again without selection inputs.

Expected: no selection prompt, stored intent is reused, and `.specify/spex.json` is byte-identical.

## 4. Validate generated-tree discipline

```bash
make test-generated-trees
```

Expected: generated harness paths are ignored, `.specify/spex.json` is visible to Git, and a force-tracked generated skill fixture is rejected.

## 5. Validate Claude source transparency

Run the existing local Claude marketplace installation test without invoking a materialization target.

Expected: installation and setup pass directly from repository sources.
