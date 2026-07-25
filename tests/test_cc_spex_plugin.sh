#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SKILL="$ROOT/plugins/cc-spex/skills/cc-spex-init"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/cc-spex-plugin-test-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin"
cat > "$TMP/bin/specify" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$@" > "$CC_SPEX_CAPTURE"
EOF
chmod +x "$TMP/bin/specify"
CC_SPEX_CAPTURE="$TMP/arguments" PATH="$TMP/bin:$PATH" \
  "$SKILL/scripts/bootstrap.sh" --security yolo --extensions spex-gates >/dev/null
grep -qx 'workflow' "$TMP/arguments"
grep -qx 'integration=codex' "$TMP/arguments"
grep -qx 'extensions=spex-gates' "$TMP/arguments"
grep -qx 'security=yolo' "$TMP/arguments"
grep -q '\$speckit-spex-help' "$SKILL/SKILL.md"
if grep -Eq '`/[^` ]+' "$SKILL/SKILL.md"; then
  echo "FAIL: Codex skill advertises slash invocation" >&2
  exit 1
fi
echo "PASS: cc-spex delegates to workflow with Codex syntax and options"
