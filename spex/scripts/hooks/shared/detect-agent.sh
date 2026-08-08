#!/bin/sh
# detect-agent.sh - Agent detection
#
# Identifies the running AI coding agent using a priority order:
#   1. Agent-specific environment variables
#   2. Agent directory presence in cwd
#   3. --ai value from .specify/init-options.json
#
# Usage:
#   agent=$(sh detect-agent.sh [cwd])
#   # agent is "claude", "codex", "opencode", or "claude" (default fallback)
#
# Environment variables checked:
#   CLAUDE_PROJECT_DIR  -> claude
#   CLAUDECODE          -> claude
#   CODEX_SESSION_ID    -> codex
#   (OpenCode sets no single reliable env var; detected via directory)

set -eu

CWD="${1:-.}"

# Priority 1: Environment variables (most reliable)
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] || [ "${CLAUDECODE:-}" = "1" ]; then
  echo "claude"
  exit 0
fi

if [ -n "${CODEX_SESSION_ID:-}" ]; then
  echo "codex"
  exit 0
fi

# Priority 2: Agent directory presence
# Check .claude first: projects often have leftover .opencode/ or .codex/ dirs
# from trying other agents, but the env var check above is the real signal.
if [ -d "$CWD/.claude" ]; then
  echo "claude"
  exit 0
fi

if [ -d "$CWD/.codex" ]; then
  echo "codex"
  exit 0
fi

if [ -d "$CWD/.opencode" ]; then
  echo "opencode"
  exit 0
fi

# Priority 3: --ai value from init-options.json
INIT_OPTIONS="$CWD/.specify/init-options.json"
if [ -f "$INIT_OPTIONS" ] && command -v jq >/dev/null 2>&1; then
  AI_VALUE=$(jq -r '.ai // ""' "$INIT_OPTIONS" 2>/dev/null || echo "")
  case "$AI_VALUE" in
    claude|codex|opencode)
      echo "$AI_VALUE"
      exit 0
      ;;
  esac
fi

# Default fallback: Claude Code
echo "claude"
