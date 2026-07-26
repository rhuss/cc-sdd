#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SKILL="$ROOT/plugins/cc-spex/skills/cc-spex-init"
MARKETPLACE="$ROOT/.agents/plugins/marketplace.json"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/cc-spex-plugin-test-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin"
cat > "$TMP/bin/specify" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$@" > "$CC_SPEX_CAPTURE"
[ -z "${CC_SPEX_CWD_CAPTURE:-}" ] || pwd -P > "$CC_SPEX_CWD_CAPTURE"
EOF
chmod +x "$TMP/bin/specify"
cat > "$TMP/bin/git" <<'EOF'
#!/usr/bin/env sh
exit 99
EOF
chmod +x "$TMP/bin/git"
CC_SPEX_CAPTURE="$TMP/arguments" PATH="$TMP/bin:$PATH" \
  "$SKILL/scripts/bootstrap.sh" --security yolo --extensions spex-gates >/dev/null
grep -qx 'workflow' "$TMP/arguments"
grep -qx -- '--json' "$TMP/arguments"
grep -qx 'integration=codex' "$TMP/arguments"
grep -qx 'extensions=spex-gates' "$TMP/arguments"
grep -qx 'security=yolo' "$TMP/arguments"
mkdir "$TMP/project"
PROJECT_DIR="$(cd "$TMP/project" && pwd -P)"
(
  cd "$PROJECT_DIR"
  CC_SPEX_CAPTURE="$TMP/project-arguments" \
    CC_SPEX_CWD_CAPTURE="$TMP/project-cwd" \
    SPEX_SOURCE="$ROOT/spex" PATH="$TMP/bin:$PATH" \
    "$SKILL/scripts/bootstrap.sh" >/dev/null
)
grep -qx "$PROJECT_DIR" "$TMP/project-cwd"
grep -q '\$speckit-spex-help' "$SKILL/SKILL.md"
grep -q 'working directory at the project root' "$SKILL/SKILL.md"
grep -q 'Do not.*cd.*skill' "$SKILL/SKILL.md"
test -f "$MARKETPLACE"
jq -e '.name == "cc-spex" and any(.plugins[]; .name == "cc-spex" and .source.path == "./plugins/cc-spex")' \
  "$MARKETPLACE" >/dev/null
test ! -e "$ROOT/.codex-plugin/marketplace.json"
if grep -Eq '`/[^` ]+' "$SKILL/SKILL.md"; then
  echo "FAIL: Codex skill advertises slash invocation" >&2
  exit 1
fi

help="$($SKILL/scripts/bootstrap.sh --help)"
grep -q 'codex (default)' <<<"$help"
grep -q 'recommended (default)' <<<"$help"
grep -q 'safe (default)' <<<"$help"

if "$SKILL/scripts/bootstrap.sh" --unknown >/dev/null 2>&1; then
  echo "FAIL: unknown option was accepted" >&2
  exit 1
fi
if "$SKILL/scripts/bootstrap.sh" --extensions spex-unknown >/dev/null 2>&1; then
  echo "FAIL: unknown extension was accepted" >&2
  exit 1
fi
echo "PASS: cc-spex delegates to workflow with Codex syntax and options"
