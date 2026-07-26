#!/usr/bin/env python3
"""Atomically configure Spex guidance and permissions for a Codex project."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


CONFIG_BEGIN = "# >>> spex managed Codex permissions >>>"
CONFIG_END = "# <<< spex managed Codex permissions <<<"
GUIDANCE_BEGIN = "<!-- >>> spex managed Codex guidance >>>"
GUIDANCE_END = "<!-- <<< spex managed Codex guidance <<< -->"


class ConfigurationError(Exception):
    """Refuse an unsafe or ambiguous project configuration change."""


def absolute_root(raw):
    """Return an existing absolute project directory."""
    root = Path(raw)
    if not root.is_absolute() or not root.is_dir():
        raise argparse.ArgumentTypeError("--root must be an existing absolute directory")
    return root.resolve()


def git_common_dir(root):
    """Resolve the shared Git metadata directory, including linked worktrees."""
    result = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--path-format=absolute", "--git-common-dir"],
        capture_output=True,
        text=True,
        timeout=5,
        check=False,
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise ConfigurationError(result.stderr.strip() or "YOLO requires a Git repository")
    path = Path(result.stdout.strip())
    if not path.is_absolute():
        path = root / path
    return path.resolve(strict=True)


def replace_block(existing, begin, end, replacement):
    """Replace one managed block while preserving all user-owned content."""
    if existing.count(begin) != existing.count(end) or existing.count(begin) > 1:
        raise ConfigurationError("malformed Spex-managed block")
    if begin not in existing:
        if not existing:
            return replacement.rstrip() + "\n"
        separator = "\n" if existing.endswith("\n") else "\n\n"
        return existing + separator + replacement.rstrip() + "\n"
    if existing.index(begin) > existing.index(end):
        raise ConfigurationError("malformed Spex-managed block")
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.DOTALL)
    updated, count = pattern.subn(replacement.rstrip(), existing)
    if count != 1:
        raise ConfigurationError("could not isolate Spex-managed block")
    return updated


def remove_block(existing, begin, end):
    """Remove one managed block while preserving user-owned content."""
    if existing.count(begin) != existing.count(end) or existing.count(begin) > 1:
        raise ConfigurationError("malformed Spex-managed block")
    if begin not in existing:
        return existing
    pattern = re.compile(r"(?:^|\n)" + re.escape(begin) + r".*?" + re.escape(end) + r"(?:\n|$)", re.DOTALL)
    updated, count = pattern.subn("\n", existing)
    if count != 1:
        raise ConfigurationError("could not isolate Spex-managed block")
    return updated.lstrip("\n")


def merge_permissions(existing, block):
    """Prepend managed root keys or refresh their existing owned block."""
    if CONFIG_BEGIN in existing:
        return replace_block(existing, CONFIG_BEGIN, CONFIG_END, block)
    root_region = existing.split("\n[", 1)[0]
    conflicts = []
    for key in ("sandbox_mode", "default_permissions", "approval_policy", "approvals_reviewer"):
        key_pattern = r'(?:' + re.escape(key) + r'|"' + re.escape(key) + r'"|\'' + re.escape(key) + r"\')"
        if re.search(r"^\s*" + key_pattern + r"\s*=", root_region, re.MULTILINE):
            conflicts.append(key)
    permissions = r'''(?:permissions|"permissions"|'permissions')'''
    profile = r'''(?:spex-project|"spex-project"|'spex-project')'''
    if re.search(
        r"^\s*\[\s*" + permissions + r"\s*\.\s*" + profile + r"(?:\s*\.|\s*\])",
        existing,
        re.MULTILINE,
    ):
        conflicts.append("permissions.spex-project")
    if conflicts:
        raise ConfigurationError(
            "refusing to override user-owned Codex settings: " + ", ".join(conflicts)
        )
    return block.rstrip() + "\n" + ("\n" + existing if existing else "")


def permission_block(root, security):
    """Render current Codex permission-profile configuration."""
    if security == "safe":
        return ""
    if security == "yolo":
        return "\n".join(
            [
                CONFIG_BEGIN,
                '# Generated from .specify/spex.json; edit that declaration, not this block.',
                'sandbox_mode = "danger-full-access"',
                'approval_policy = "never"',
                CONFIG_END,
            ]
        )
    common = json.dumps(str(git_common_dir(root)))
    return "\n".join(
        [
            CONFIG_BEGIN,
            '# Generated from .specify/spex.json; edit that declaration, not this block.',
            'default_permissions = "spex-project"',
            'approval_policy = "on-request"',
            'approvals_reviewer = "auto_review"',
            "",
            '[permissions.spex-project.filesystem]',
            '":minimal" = "read"',
            '":tmpdir" = "write"',
            '":slash_tmp" = "write"',
            '":workspace_roots" = { "." = "write" }',
            common + ' = "write"',
            "",
            "[permissions.spex-project.network]",
            "enabled = false",
            CONFIG_END,
        ]
    )


def atomic_write(path, content):
    """Replace a file atomically without changing its existing mode."""
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
    descriptor, temporary = tempfile.mkstemp(dir=path.parent, prefix=".spex.")
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def configure(args):
    """Apply the selected security mapping and managed Codex guidance."""
    config_path = args.root / ".codex" / "config.toml"
    agents_path = args.root / "AGENTS.md"
    template_path = Path(__file__).resolve().parent.parent / "templates" / "agents-md" / "codex.md"
    config = config_path.read_text(encoding="utf-8") if config_path.exists() else ""
    guidance = agents_path.read_text(encoding="utf-8") if agents_path.exists() else ""
    block = permission_block(args.root, args.security)
    updated_config = (
        merge_permissions(config, block)
        if block
        else remove_block(config, CONFIG_BEGIN, CONFIG_END)
    )
    template = template_path.read_text(encoding="utf-8")
    updated_guidance = replace_block(guidance, GUIDANCE_BEGIN, GUIDANCE_END, template)
    changes = []
    if updated_config != config:
        changes.append((config_path, updated_config))
    if updated_guidance != guidance:
        changes.append((agents_path, updated_guidance))
    for path, content in changes:
        atomic_write(path, content)
    return {
        "status": "configured",
        "security": args.security,
        "permissions": {
            "safe": "unchanged",
            "autonomous": "spex-project",
            "yolo": "danger-full-access",
        }[args.security],
        "config_changed": updated_config != config,
        "guidance_changed": updated_guidance != guidance,
    }


def main():
    """Run the Codex project configurator."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=absolute_root)
    parser.add_argument("--security", required=True, choices=("safe", "autonomous", "yolo"))
    args = parser.parse_args()
    try:
        payload = configure(args)
    except (ConfigurationError, OSError, subprocess.SubprocessError) as error:
        payload = {"status": "refused", "error": str(error), "config_changed": False}
        json.dump(payload, sys.stdout, sort_keys=True)
        sys.stdout.write("\n")
        return 1
    json.dump(payload, sys.stdout, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
