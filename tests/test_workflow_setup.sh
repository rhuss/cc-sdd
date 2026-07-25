#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_REPO="$(mktemp -d "${TMPDIR:-/tmp}/spex-workflow-setup.XXXXXX")"
trap 'rm -rf -- "$TEST_REPO"' EXIT
git -C "$TEST_REPO" init -q

run_setup() {
  (
    cd "$TEST_REPO"
    SPEX_SOURCE="$REPO_ROOT/spex" specify workflow run "$REPO_ROOT/spex/setup.yml" --json "$@"
  )
}

initial="$(run_setup \
  -i integration=claude \
  -i extensions=spex-gates,spex-worktrees \
  -i security=autonomous)"
jq -e '.status == "completed"' <<<"$initial" >/dev/null

profile="$TEST_REPO/.specify/spex.json"
jq -e '
  .schema_version == 1 and .harness == "claude" and
  .security == "autonomous" and
  .extensions == ["spex", "spex-gates", "spex-worktrees"]
' "$profile" >/dev/null
before="$(shasum -a 256 "$profile" | awk '{print $1}')"

refresh="$(run_setup)"
jq -e '.status == "completed"' <<<"$refresh" >/dev/null
after="$(shasum -a 256 "$profile" | awk '{print $1}')"
[[ "$before" == "$after" ]]

if find "$TEST_REPO" -maxdepth 2 -type d -name '*materializ*' | grep -q .; then
  echo "FAIL: workflow setup created a staged distribution" >&2
  exit 1
fi

echo "PASS: workflow setup persists intent and refreshes without materialization"
