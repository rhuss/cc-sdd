#!/usr/bin/env python3
"""Contract tests for current Codex project setup."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "spex/scripts/configure-codex-project.py"


class CodexProjectTests(unittest.TestCase):
    """Verify prompt-free bounded configuration and ownership behavior."""

    def run_tool(self, root, security="yolo"):
        """Run the configurator and require a successful JSON response."""
        result = subprocess.run(
            ["python3", str(TOOL), "--root", str(root), "--security", security],
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        return json.loads(result.stdout)

    def test_yolo_covers_linked_worktree_git_without_network_or_prompts(self):
        """YOLO writes workspace and shared Git metadata but fails closed beyond them."""
        with tempfile.TemporaryDirectory() as raw:
            repository = Path(raw) / "repository"
            worktree = Path(raw) / "feature"
            subprocess.run(["git", "init", "-q", str(repository)], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.name", "Test"], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.email", "test@example.invalid"], check=True)
            subprocess.run(["git", "-C", str(repository), "commit", "--allow-empty", "-q", "-m", "initial"], check=True)
            subprocess.run(["git", "-C", str(repository), "worktree", "add", "-q", "-b", "feature", str(worktree)], check=True)
            payload = self.run_tool(worktree)
            config = (worktree / ".codex/config.toml").read_text()
            self.assertEqual(payload["security"], "yolo")
            self.assertIn('approval_policy = "never"', config)
            self.assertIn(json.dumps(str((repository / ".git").resolve())) + ' = "write"', config)
            self.assertIn("enabled = false", config)

    def test_refresh_preserves_user_guidance_and_is_idempotent(self):
        """Refresh only owns sentinel blocks and produces stable bytes."""
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "AGENTS.md").write_text("# Team rules\n")
            self.run_tool(root, "autonomous")
            first_config = (root / ".codex/config.toml").read_bytes()
            first_agents = (root / "AGENTS.md").read_bytes()
            self.run_tool(root, "autonomous")
            self.assertEqual(first_config, (root / ".codex/config.toml").read_bytes())
            self.assertEqual(first_agents, (root / "AGENTS.md").read_bytes())
            self.assertTrue((root / "AGENTS.md").read_text().startswith("# Team rules\n"))

    def test_safe_removes_only_managed_permissions(self):
        """Safe mode removes Spex permissions and retains user configuration."""
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            self.run_tool(root)
            path = root / ".codex/config.toml"
            path.write_text(path.read_text() + '\nmodel = "user-choice"\n')
            self.run_tool(root, "safe")
            self.assertEqual(path.read_text(), 'model = "user-choice"\n')

    def test_refuses_user_owned_permission_selector(self):
        """Setup never silently replaces a user's existing Codex policy."""
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            path = root / ".codex/config.toml"
            path.parent.mkdir()
            path.write_text('approval_policy = "on-request"\n')
            result = subprocess.run(
                ["python3", str(TOOL), "--root", str(root), "--security", "yolo"],
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn("refusing to override", result.stdout)
            self.assertEqual(path.read_text(), 'approval_policy = "on-request"\n')


if __name__ == "__main__":
    unittest.main()
