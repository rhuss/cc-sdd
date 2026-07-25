#!/usr/bin/env python3
"""Regression coverage for prompt-free Git operations in bounded YOLO worktrees."""

from __future__ import annotations

import json
import subprocess
import tempfile
import tomllib
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
CONFIGURE = REPO_ROOT / "spex/scripts/adapters/codex/configure-project.py"


class CodexYoloConfigurationTests(unittest.TestCase):
    def run_command(self, *args: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        return result

    def test_yolo_is_prompt_free_and_allows_linked_worktree_git_metadata(self) -> None:
        with tempfile.TemporaryDirectory(prefix="spex-codex-config-") as temporary:
            root = Path(temporary)
            repository = root / "repository"
            worktree = root / "feature"
            self.run_command("git", "init", "-q", str(repository))
            self.run_command("git", "-C", str(repository), "config", "user.name", "Spex Test")
            self.run_command(
                "git", "-C", str(repository), "config", "user.email", "spex@example.invalid"
            )
            self.run_command(
                "git", "-C", str(repository), "commit", "--allow-empty", "-q", "-m", "initial"
            )
            self.run_command(
                "git", "-C", str(repository), "worktree", "add", "-q", "-b", "feature", str(worktree)
            )

            capabilities = json.dumps(
                {
                    "codex_available": True,
                    "project_config": True,
                    "workspace_write": True,
                    "on_request_approval": True,
                }
            )
            result = self.run_command(
                "python3",
                str(CONFIGURE),
                "configure",
                "--root",
                str(worktree),
                "--security",
                "yolo",
                "--capabilities-json",
                capabilities,
            )
            payload = json.loads(result.stdout)
            self.assertEqual(payload["effective_security"], "yolo")

            config = tomllib.loads((worktree / ".codex/config.toml").read_text())
            self.assertEqual(config["approval_policy"], "on-request")
            self.assertEqual(config["sandbox_mode"], "workspace-write")
            workspace = config["sandbox_workspace_write"]
            self.assertFalse(workspace["network_access"])
            expected_common_dir = (repository / ".git").resolve()
            self.assertEqual(workspace["writable_roots"], [str(expected_common_dir)])


if __name__ == "__main__":
    unittest.main()
