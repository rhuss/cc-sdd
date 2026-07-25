#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
python3 -m unittest "$SCRIPT_DIR/test_codex_project_config.py"
python3 -m unittest "$SCRIPT_DIR/test_codex_pretool_gate.py"
