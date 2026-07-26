#!/usr/bin/env sh
set -eu

integration=codex
extensions=recommended
security=safe

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [OPTIONS]

Options and defaults:
  --integration VALUE  codex (default), claude, opencode, auto
  --extensions VALUE   recommended (default), all, interactive, or NAME,NAME
  --security VALUE     safe (default), autonomous, yolo, interactive
  -h, --help           show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --integration|--extensions|--security)
      [ "$#" -ge 2 ] || { echo "ERROR: $1 requires a value" >&2; exit 2; }
      option=$1
      value=$2
      shift 2
      case "$option" in
        --integration) integration=$value ;;
        --extensions) extensions=$value ;;
        --security) security=$value ;;
      esac
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$integration" in codex|claude|opencode|auto) ;; *) echo "ERROR: invalid integration" >&2; exit 2 ;; esac
case "$security" in safe|autonomous|yolo|interactive) ;; *) echo "ERROR: invalid security" >&2; exit 2 ;; esac
case "$extensions" in
  recommended|all|interactive) ;;
  *)
    old_ifs=$IFS
    IFS=,
    set -- $extensions
    IFS=$old_ifs
    [ "$#" -gt 0 ] || { echo "ERROR: invalid extensions" >&2; exit 2; }
    for extension in "$@"; do
      case "$extension" in
        spex|spex-gates|spex-worktrees|spex-deep-review|spex-teams|spex-collab|spex-detach) ;;
        *) echo "ERROR: invalid extension: $extension" >&2; exit 2 ;;
      esac
    done
    ;;
esac

command -v specify >/dev/null 2>&1 || {
  echo "ERROR: specify CLI is required." >&2
  echo "Install it from https://github.com/github/spec-kit and retry." >&2
  exit 1
}
command -v git >/dev/null 2>&1 || { echo "ERROR: git is required." >&2; exit 1; }

temporary=""
cleanup() {
  [ -z "$temporary" ] || rm -rf "$temporary"
}
trap cleanup EXIT HUP INT TERM

if [ -n "${SPEX_SOURCE:-}" ]; then
  [ -f "$SPEX_SOURCE/setup.yml" ] && [ -d "$SPEX_SOURCE/extensions/spex" ] || {
    echo "ERROR: SPEX_SOURCE does not contain a Spex source tree: $SPEX_SOURCE" >&2
    exit 1
  }
  source_dir=$(cd "$SPEX_SOURCE" && pwd -P)
elif [ -f "spex/setup.yml" ] && [ -d "spex/extensions/spex" ]; then
  source_dir=$(cd spex && pwd -P)
else
  temporary=$(mktemp -d "${TMPDIR:-/tmp}/cc-spex-init-XXXXXX")
  git clone --depth 1 https://github.com/rhuss/cc-spex.git "$temporary/repository" >&2
  source_dir="$temporary/repository/spex"
fi

echo "Initializing Spex: integration=$integration extensions=$extensions security=$security" >&2
SPEX_SOURCE="$source_dir" specify workflow run "$source_dir/setup.yml" \
  --json \
  -i "integration=$integration" \
  -i "extensions=$extensions" \
  -i "security=$security"
