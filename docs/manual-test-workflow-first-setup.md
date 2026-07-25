# Manual Test: Workflow-First Setup

Use these checkpoints to verify the workflow-first setup introduced by PR #42.
Run them from a disposable Git repository.

## Prepare the test repository

```bash
TEST_ROOT=$(mktemp -d)
mkdir "$TEST_ROOT/project"
git -C "$TEST_ROOT/project" init -q
cd "$TEST_ROOT/project"

export SPEX_SOURCE="/Users/rhuss/Development/context-engineering/cc-spex/spex"
export SETUP="$SPEX_SOURCE/setup.yml"
```

## Checkpoint 1: Initial setup

```bash
specify workflow run "$SETUP" --json \
  -i integration=claude \
  -i extensions=spex-gates,spex-worktrees \
  -i security=autonomous

cat .specify/spex.json
```

Expected results:

- The workflow reports `completed`.
- `.specify/spex.json` exists.
- The configuration selects the Claude harness.
- Security is `autonomous`.
- Extensions include `spex`, `spex-gates`, and `spex-worktrees`.

## Checkpoint 2: Prompt-free refresh

```bash
before=$(shasum -a 256 .specify/spex.json)
specify workflow run "$SETUP" --json
after=$(shasum -a 256 .specify/spex.json)

test "$before" = "$after" && echo "PASS: byte-identical refresh"
```

Expected results:

- Setup asks no configuration questions.
- The workflow reports `completed`.
- The final command prints `PASS: byte-identical refresh`.

## Checkpoint 3: Compatibility and ignore rules

```bash
specify workflow run "$SETUP" --json -i permissions=standard

jq -e '.security == "autonomous"' .specify/spex.json
git check-ignore --no-index .agents/skills/example/SKILL.md
git check-ignore --no-index .codex/config.toml
git check-ignore --no-index .specify/spex.json \
  && echo "FAIL: config ignored" \
  || echo "PASS: config trackable"
```

Expected results:

- The deprecated `permissions=standard` input maps to `security=autonomous`.
- Generated `.agents/` and `.codex/` paths are ignored.
- `.specify/spex.json` remains trackable.
- The final command prints `PASS: config trackable`.

## Record the results

- [ ] Checkpoint 1 passed
- [ ] Checkpoint 2 passed
- [ ] Checkpoint 3 passed

Notes:

```text

```

## Clean up

After recording the results:

```bash
cd /tmp
rm -rf "$TEST_ROOT"
unset TEST_ROOT SPEX_SOURCE SETUP
```
