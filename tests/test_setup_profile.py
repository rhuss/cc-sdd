#!/usr/bin/env python3
"""Contract tests for the team-owned Spex setup declaration."""

from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "spex/scripts/spex-setup-profile.py"
FIXTURES = ROOT / "tests/fixtures/setup-profile"


class SetupProfileTests(unittest.TestCase):
    def run_tool(self, *args: str, cwd: Path, input_value=None, success=True):
        payload = None if input_value is None else json.dumps(input_value)
        result = subprocess.run(
            ["python3", str(TOOL), *args], cwd=cwd, input=payload,
            capture_output=True, text=True, check=False,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
            return json.loads(result.stdout)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        return result.stderr

    def test_defaults_are_recommended_and_safe(self):
        with tempfile.TemporaryDirectory() as raw:
            resolved = self.run_tool("resolve", "--root", raw, cwd=Path(raw))
        self.assertEqual(resolved["harness"], "auto")
        self.assertEqual(resolved["security"], "safe")
        self.assertEqual(
            resolved["extensions"],
            ["spex", "spex-gates", "spex-worktrees", "spex-deep-review"],
        )

    def test_stored_intent_is_reused_and_explicit_values_win(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            stored = json.loads((FIXTURES / "valid.json").read_text())
            self.run_tool("persist", "--root", raw, cwd=root, input_value=stored)
            reused = self.run_tool("resolve", "--root", raw, cwd=root)
            overridden = self.run_tool(
                "resolve", "--root", raw, "--harness", "claude",
                "--extensions", "spex,spex-collab", "--security", "yolo", cwd=root,
            )
        self.assertEqual(reused, stored)
        self.assertEqual(overridden["harness"], "claude")
        self.assertEqual(overridden["security"], "yolo")
        self.assertEqual(overridden["extensions"], ["spex", "spex-gates", "spex-collab"])

    def test_validation_rejects_unknowns_and_normalizes_dependencies(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            normalized = self.run_tool(
                "resolve", "--root", raw, "--extensions", "spex-teams,spex", cwd=root
            )
            error = self.run_tool(
                "validate", "--root", raw, cwd=root,
                input_value=json.loads((FIXTURES / "invalid.json").read_text()), success=False,
            )
        self.assertEqual(normalized["extensions"], ["spex", "spex-gates", "spex-teams"])
        self.assertIn("harness", error)

    def test_failure_is_byte_identical_and_persistence_is_atomic(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            valid = json.loads((FIXTURES / "valid.json").read_text())
            self.run_tool("persist", "--root", raw, cwd=root, input_value=valid)
            path = root / ".specify/spex.json"
            before = hashlib.sha256(path.read_bytes()).digest()
            self.run_tool(
                "persist", "--root", raw, cwd=root,
                input_value={**valid, "security": "unsafe"}, success=False,
            )
            after = hashlib.sha256(path.read_bytes()).digest()
            temporary = list(path.parent.glob(".spex.*.tmp"))
        self.assertEqual(before, after)
        self.assertEqual(temporary, [])

    def test_legacy_permission_names_migrate(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            safe = self.run_tool(
                "resolve", "--root", raw, "--legacy-permissions", "none", cwd=root
            )
            autonomous = self.run_tool(
                "resolve", "--root", raw, "--legacy-permissions", "standard", cwd=root
            )
        self.assertEqual(safe["security"], "safe")
        self.assertEqual(autonomous["security"], "autonomous")


if __name__ == "__main__":
    unittest.main()
