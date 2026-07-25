#!/usr/bin/env python3
"""Regression coverage for quiet Codex PreToolUse ship reminders."""

from __future__ import annotations

import importlib.util
import io
import json
import sys
import unittest
from pathlib import Path
from unittest.mock import patch


REPO_ROOT = Path(__file__).resolve().parents[2]
ADAPTER = REPO_ROOT / "spex/scripts/adapters/codex/pretool-gate.py"


def load_adapter():
    spec = importlib.util.spec_from_file_location("codex_pretool_gate", ADAPTER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class CodexPreToolGateTests(unittest.TestCase):
    def test_advisory_ship_context_is_not_printed(self) -> None:
        adapter = load_adapter()
        root = REPO_ROOT.resolve()
        hook_input = json.dumps(
            {"tool_name": "Bash", "tool_input": {}, "turn_id": "quiet", "cwd": str(root)}
        )
        results = iter(
            [
                "allow",
                "allow",
                'context:<ship-pipeline stage="implement">invoke speckit-implement</ship-pipeline>',
                "allow",
            ]
        )
        resolved = {
            "git_root": root,
            "project_dir": root,
            "state": {"status": "running"},
            "state_file": root / ".specify/.spex-state",
        }
        output = io.StringIO()
        with (
            patch.object(adapter, "resolve_project_context", return_value=resolved),
            patch.object(adapter, "side_effects"),
            patch.object(adapter, "run_shared", side_effect=lambda *_: next(results)),
            patch.object(sys, "stdin", io.StringIO(hook_input)),
            patch.object(sys, "stdout", output),
            self.assertRaises(SystemExit) as exit_result,
        ):
            adapter.main()

        self.assertEqual(exit_result.exception.code, 0)
        self.assertEqual(output.getvalue(), "")


if __name__ == "__main__":
    unittest.main()
