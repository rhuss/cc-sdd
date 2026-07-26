#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_REPO="$(mktemp -d "${TMPDIR:-/tmp}/spex-workflow-setup.XXXXXX")"
LEGACY_REPO="$(mktemp -d "${TMPDIR:-/tmp}/spex-workflow-legacy.XXXXXX")"
CODEX_REPO="$(mktemp -d "${TMPDIR:-/tmp}/spex-workflow-codex.XXXXXX")"
DOWNLOADED_REPO="$(mktemp -d "${TMPDIR:-/tmp}/spex-workflow-downloaded.XXXXXX")"
DOWNLOADED_SOURCE="$(mktemp -d "${TMPDIR:-/tmp}/cc-spex-downloaded.XXXXXX")"
trap 'rm -rf -- "$TEST_REPO" "$LEGACY_REPO" "$CODEX_REPO" "$DOWNLOADED_REPO" "$DOWNLOADED_SOURCE"' EXIT
git -C "$TEST_REPO" init -q
git -C "$LEGACY_REPO" init -q
git -C "$CODEX_REPO" init -q
git -C "$DOWNLOADED_REPO" init -q

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

legacy="$({
  cd "$LEGACY_REPO"
  SPEX_SOURCE="$REPO_ROOT/spex" specify workflow run "$REPO_ROOT/spex/setup.yml" --json \
    -i integration=claude -i extensions=recommended -i permissions=standard
})"
jq -e '.status == "completed"' <<<"$legacy" >/dev/null
jq -e '.security == "autonomous"' "$LEGACY_REPO/.specify/spex.json" >/dev/null

mkdir -p "$CODEX_REPO/.codex"
printf '%s\n' 'approval_policy = "on-request"' > "$CODEX_REPO/.codex/config.toml"
codex_refusal="$({
  cd "$CODEX_REPO"
  SPEX_SOURCE="$REPO_ROOT/spex" specify workflow run "$REPO_ROOT/spex/setup.yml" --json \
    -i integration=codex -i extensions=recommended -i security=yolo
} || true)"
jq -e '.status == "failed" and .current_step_id == "codex-project"' \
  <<<"$codex_refusal" >/dev/null

cp -R "$REPO_ROOT/spex" "$DOWNLOADED_SOURCE/spex"
downloaded="$({
  cd "$DOWNLOADED_REPO"
  SPEX_SOURCE="$DOWNLOADED_SOURCE/spex" \
    specify workflow run "$DOWNLOADED_SOURCE/spex/setup.yml" --json \
      -i integration=codex -i extensions=recommended -i security=safe
})"
jq -e '.status == "completed"' <<<"$downloaded" >/dev/null
test -f "$DOWNLOADED_REPO/.specify/extensions/spex/extension.yml"

if find "$TEST_REPO" "$CODEX_REPO" "$DOWNLOADED_REPO" -maxdepth 2 -type d -name '*materializ*' | grep -q .; then
  echo "FAIL: workflow setup created a staged distribution" >&2
  exit 1
fi

echo "PASS: workflow setup persists intent, migrates legacy permissions, propagates Codex refusal, and refreshes without materialization"
