#!/bin/bash
# sdd-init.sh - Fast spec-kit initialization check and setup
#
# Usage:
#   sdd-init.sh           # Check + initialize if needed
#   sdd-init.sh --refresh # Re-download templates and refresh project
#   sdd-init.sh --update  # Update specify-cli and refresh project
#
# Exit codes:
#   0 - READY (spec-kit fully initialized)
#   1 - Error (check output for details)
#   2 - NEED_INSTALL (specify CLI not found)
#   3 - RESTART_REQUIRED (new slash commands installed, restart Claude Code)

set -euo pipefail

# --- Fast path: single check for everything ---
check_ready() {
  command -v specify &>/dev/null || return 1
  [ -d .specify ] || return 1
  [ -f .specify/templates/spec-template.md ] || return 1
  ls .claude/commands/speckit.* &>/dev/null || return 1
  return 0
}

# --- Fix constitution symlink silently ---
fix_constitution() {
  if [ -f "specs/constitution.md" ] && [ ! -e ".specify/memory/constitution.md" ]; then
    mkdir -p .specify/memory
    ln -s ../../specs/constitution.md .specify/memory/constitution.md
  elif [ -f ".specify/memory/constitution.md" ] && [ ! -L ".specify/memory/constitution.md" ] && [ ! -f "specs/constitution.md" ]; then
    mkdir -p specs
    mv .specify/memory/constitution.md specs/constitution.md
    ln -s ../../specs/constitution.md .specify/memory/constitution.md
  fi
}

# --- Initialize project ---
do_init() {
  if ! command -v specify &>/dev/null; then
    echo "NEED_INSTALL"
    echo ""
    echo "The 'specify' CLI is required but not installed."
    echo ""
    echo "Install with:"
    echo "  uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git"
    echo ""
    echo "IMPORTANT: The CLI command is 'specify' (not 'speckit')."
    echo "           The package is 'specify-cli' (from github.com/github/spec-kit)."
    exit 2
  fi

  # Track whether commands existed before init
  local had_commands=false
  ls .claude/commands/speckit.* &>/dev/null && had_commands=true

  echo "Initializing spec-kit..."
  if ! specify init --here --ai claude --force; then
    echo "ERROR: specify init failed"
    exit 1
  fi

  # Check if NEW commands were installed (didn't exist before)
  if [ "$had_commands" = false ] && ls .claude/commands/speckit.* &>/dev/null; then
    fix_constitution
    echo ""
    echo "RESTART_REQUIRED"
    echo ""
    echo "spec-kit has installed local slash commands in:"
    echo "  .claude/commands/speckit.*"
    echo ""
    echo "To load these new commands, please:"
    echo "1. Save your work"
    echo "2. Close this conversation"
    echo "3. Restart Claude Code"
    echo "4. Return to this project"
    exit 3
  fi

  # Verify after init
  if check_ready; then
    fix_constitution
    echo ""
    echo "READY"
  else
    echo "ERROR: initialization completed but verification failed"
    exit 1
  fi
}

# --- Refresh templates only ---
do_refresh() {
  if ! command -v specify &>/dev/null; then
    echo "ERROR: specify CLI not installed. Run without flags to install, or use --update."
    exit 2
  fi

  echo "Refreshing project templates..."
  if ! specify init --here --ai claude --force; then
    echo "ERROR: specify init failed"
    exit 1
  fi

  fix_constitution

  echo ""
  echo "RESTART_REQUIRED"
  echo "Templates and slash commands refreshed. Please restart Claude Code."
  exit 3
}

# --- Update protocol ---
do_update() {
  echo "Updating specify-cli from GitHub..."
  if ! uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git; then
    echo "ERROR: Failed to update specify-cli"
    echo "Please update manually: uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git"
    exit 1
  fi

  echo ""
  echo "Refreshing project setup..."
  specify init --here --ai claude --force

  echo ""
  specify version

  echo ""
  echo "RESTART_REQUIRED"
  echo "Slash commands refreshed. Please restart Claude Code."
  exit 3
}

# --- Main ---
case "${1:-}" in
  --refresh)
    do_refresh
    ;;
  --update)
    do_update
    ;;
  *)
    # Fast path: already ready?
    if check_ready; then
      fix_constitution
      echo "READY"
      exit 0
    fi
    # Slow path: need initialization
    do_init
    ;;
esac
