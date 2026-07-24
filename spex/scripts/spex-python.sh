#!/bin/sh
# Resolve a Python interpreter with the stdlib modules required by Spex setup.

set -eu

for candidate in python3 python3.14 python3.13 python3.12 python3.11 python py; do
  command -v "$candidate" >/dev/null 2>&1 || continue
  if "$candidate" -c 'import json, tomllib' >/dev/null 2>&1; then
    resolved=$(command -v "$candidate")
    printf '%s' "$resolved"
    exit 0
  fi
done

echo "ERROR: Spex setup requires Python 3.11+ with the tomllib module." >&2
echo "Install Python 3.11 or newer and ensure it is available on PATH." >&2
exit 1
