#!/usr/bin/env python3
"""Hook script for UserPromptSubmit event.
Injects SDD plugin context as system reminder when sdd commands detected.
"""
import json
import sys
from pathlib import Path


def read_hook_input():
    """Read and parse hook input JSON from stdin."""
    try:
        return json.loads(sys.stdin.read())
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(2)


def main():
    hook_input = read_hook_input()

    prompt = hook_input.get('prompt', '')
    session_id = hook_input.get('session_id')
    cwd = Path(hook_input.get('cwd', '.'))

    # Only process SDD commands
    if not prompt.startswith('/sdd:'):
        sys.exit(0)

    # Resolve plugin root from script location:
    # scripts/hooks/context-hook.py -> scripts/hooks -> scripts -> plugin_root
    plugin_root = Path(__file__).parent.parent.parent

    # Resolve script paths
    init_script = plugin_root / 'scripts' / 'sdd-init.sh'
    traits_script = plugin_root / 'scripts' / 'sdd-traits.sh'
    beads_sync_script = plugin_root / 'scripts' / 'sdd-beads-sync.py'

    # Check if SDD traits are configured
    sdd_configured = (cwd / '.specify' / 'sdd-traits.json').exists()

    # Parse init arguments (--refresh, --update)
    init_args = ''
    if prompt.startswith('/sdd:init'):
        parts = prompt.split()
        for part in parts[1:]:
            if part in ('--refresh', '--update', '-r', '-u'):
                init_args = f' {part}'
                break

    context = f"""<sdd-context>
<plugin-root>{plugin_root}</plugin-root>
<project-dir>{cwd}</project-dir>
<session-id>{session_id}</session-id>
<sdd-configured>{str(sdd_configured).lower()}</sdd-configured>
<sdd-init-command>{init_script}{init_args}</sdd-init-command>
<sdd-traits-command>{traits_script}</sdd-traits-command>
<sdd-beads-sync-command>{beads_sync_script}</sdd-beads-sync-command>
</sdd-context>"""

    response = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": context
        }
    }
    print(json.dumps(response))
    sys.exit(0)


if __name__ == "__main__":
    main()
