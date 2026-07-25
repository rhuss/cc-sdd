#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

tracked_generated() {
  git -C "$1" ls-files | awk '
    /^\.agents\// || /^\.codex\// || /^\.claude\/skills\// { print }
  '
}

for generated in \
  .agents/skills/example/SKILL.md \
  .codex/hooks.json \
  .claude/skills/example/SKILL.md; do
  if ! git -C "$REPO_ROOT" check-ignore -q "$generated"; then
    echo "FAIL: generated path is not ignored: $generated" >&2
    exit 1
  fi
done

if git -C "$REPO_ROOT" check-ignore -q .specify/spex.json; then
  echo "FAIL: team-owned .specify/spex.json is ignored" >&2
  exit 1
fi

tracked="$(tracked_generated "$REPO_ROOT")"
if [[ -n "$tracked" ]]; then
  echo "FAIL: generated harness artifacts are tracked:" >&2
  printf '%s\n' "$tracked" >&2
  echo "Edit canonical sources under spex/ instead." >&2
  exit 1
fi

fixture="$(mktemp -d "${TMPDIR:-/tmp}/spex-generated-guard.XXXXXX")"
trap 'rm -rf -- "$fixture"' EXIT
git -C "$fixture" init -q
cp "$REPO_ROOT/.gitignore" "$fixture/.gitignore"
mkdir -p "$fixture/.agents/skills/generated"
printf '%s\n' generated > "$fixture/.agents/skills/generated/SKILL.md"
git -C "$fixture" add -f .agents/skills/generated/SKILL.md
if [[ -z "$(tracked_generated "$fixture")" ]]; then
  echo "FAIL: guard fixture did not detect a force-tracked generated skill" >&2
  exit 1
fi

echo "PASS: generated harness trees are ignored and tracked copies are rejected"
