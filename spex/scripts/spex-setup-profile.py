#!/usr/bin/env python3
"""Resolve and atomically persist the team-owned Spex setup declaration."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import sys
import tempfile
from typing import Any


PROFILE = Path(".specify/spex.json")
HARNESSES = {"auto", "claude", "codex", "opencode"}
EXTENSIONS = {
    "spex", "spex-gates", "spex-worktrees", "spex-deep-review",
    "spex-teams", "spex-collab", "spex-detach",
}
DEPENDENCIES = {
    "spex-deep-review": {"spex-gates"},
    "spex-teams": {"spex-gates"},
    "spex-collab": {"spex-gates"},
}
SECURITY = {"safe", "autonomous", "yolo"}
DEFAULT = {
    "schema_version": 1,
    "harness": "auto",
    "extensions": ["spex", "spex-gates", "spex-worktrees", "spex-deep-review"],
    "security": "safe",
}
LEGACY_SECURITY = {"none": "safe", "standard": "autonomous", "yolo": "yolo"}
FIELDS = set(DEFAULT)


class ProfileError(Exception):
    """Report invalid or inaccessible setup profile data."""

    pass


def fail(message: str) -> None:
    """Raise a setup-profile validation error."""

    raise ProfileError(message)


def root_path(raw: str) -> Path:
    """Return a validated absolute project root."""

    root = Path(raw)
    if not root.is_absolute() or not root.is_dir():
        fail("--root must be an existing absolute directory")
    return root.resolve()


def normalize_extensions(value: Any) -> list[str]:
    """Validate extensions, add dependencies, and return canonical order."""

    if not isinstance(value, list) or not value:
        fail("extensions must be a nonempty array")
    if any(not isinstance(item, str) or item not in EXTENSIONS for item in value):
        fail("extensions contains an unknown extension")
    enabled = set(value)
    if "spex" not in enabled:
        fail("extensions must include spex")
    for extension, required in DEPENDENCIES.items():
        if extension in enabled:
            enabled.update(required)
    order = [*DEFAULT["extensions"], "spex-teams", "spex-collab", "spex-detach"]
    return [extension for extension in order if extension in enabled]


def validate(value: Any) -> dict[str, Any]:
    """Validate and canonicalize a complete setup declaration."""

    if not isinstance(value, dict):
        fail("configuration must be a JSON object")
    missing = FIELDS - set(value)
    extra = set(value) - FIELDS
    if missing:
        fail(f"configuration is missing: {', '.join(sorted(missing))}")
    if extra:
        fail(f"configuration contains unknown fields: {', '.join(sorted(extra))}")
    if value["schema_version"] != 1:
        fail("schema_version must be 1")
    if value["harness"] not in HARNESSES:
        fail("harness must be auto, claude, codex, or opencode")
    if value["security"] not in SECURITY:
        fail("security must be safe, autonomous, or yolo")
    return {
        "schema_version": 1,
        "harness": value["harness"],
        "extensions": normalize_extensions(value["extensions"]),
        "security": value["security"],
    }


def read_json(stream) -> dict[str, Any]:
    """Read a JSON object from a text stream with a stable error message."""

    try:
        return json.load(stream)
    except json.JSONDecodeError as error:
        fail(f"invalid JSON: {error.msg}")


def load(root: Path) -> dict[str, Any] | None:
    """Load a stored declaration, or return None when it is absent."""

    path = root / PROFILE
    if not path.exists():
        return None
    try:
        with path.open(encoding="utf-8") as stream:
            return validate(read_json(stream))
    except OSError as error:
        fail(f"cannot read {path}: {error}")


def emit(value: dict[str, Any]) -> None:
    """Write a canonical declaration to standard output."""

    json.dump(value, sys.stdout, indent=2)
    sys.stdout.write("\n")


def parse_extension_argument(raw: str) -> list[str]:
    """Parse a comma-separated workflow extension input."""

    return [item.strip() for item in raw.split(",") if item.strip()]


def resolve(args: argparse.Namespace) -> None:
    """Resolve explicit inputs over stored values and defaults."""

    root = root_path(args.root)
    stored = load(root) or DEFAULT
    security = args.security
    if not security and args.legacy_permissions:
        security = LEGACY_SECURITY[args.legacy_permissions]
    candidate = {
        "schema_version": 1,
        "harness": args.harness or stored["harness"],
        "extensions": (
            ["spex", *parse_extension_argument(args.extensions)]
            if args.extensions else stored["extensions"]
        ),
        "security": security or stored["security"],
    }
    emit(validate(candidate))


def persist(args: argparse.Namespace) -> None:
    """Atomically persist a validated declaration below the project root."""

    root = root_path(args.root)
    value = validate(read_json(sys.stdin))
    destination = root / PROFILE
    destination.parent.mkdir(parents=True, exist_ok=True)
    descriptor, raw_temporary = tempfile.mkstemp(
        dir=destination.parent, prefix=".spex.", suffix=".tmp"
    )
    temporary = Path(raw_temporary)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(value, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, destination)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise
    emit(value)


def validate_command(args: argparse.Namespace) -> None:
    """Validate a declaration received on standard input."""

    root_path(args.root)
    emit(validate(read_json(sys.stdin)))


def parser() -> argparse.ArgumentParser:
    """Build the command-line parser."""

    result = argparse.ArgumentParser(description=__doc__)
    commands = result.add_subparsers(required=True)
    resolve_parser = commands.add_parser("resolve")
    resolve_parser.add_argument("--root", required=True)
    resolve_parser.add_argument("--harness", choices=sorted(HARNESSES), default="")
    resolve_parser.add_argument("--extensions", default="")
    resolve_parser.add_argument("--security", choices=sorted(SECURITY), default="")
    resolve_parser.add_argument(
        "--legacy-permissions", choices=sorted(LEGACY_SECURITY), default=""
    )
    resolve_parser.set_defaults(handler=resolve)
    persist_parser = commands.add_parser("persist")
    persist_parser.add_argument("--root", required=True)
    persist_parser.set_defaults(handler=persist)
    validate_parser = commands.add_parser("validate")
    validate_parser.add_argument("--root", required=True)
    validate_parser.set_defaults(handler=validate_command)
    return result


def main() -> int:
    """Run the requested setup-profile operation."""

    args = parser().parse_args()
    args.handler(args)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ProfileError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1) from error
