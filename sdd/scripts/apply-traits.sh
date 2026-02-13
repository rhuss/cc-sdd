#!/bin/bash
# apply-traits.sh - Apply SDD trait overlays to spec-kit files
#
# Reads .specify/sdd-traits.json and appends overlay content from
# sdd/overlays/<trait>/ to the corresponding spec-kit target files.
# Uses sentinel markers (<!-- SDD-TRAIT:<trait-name> -->) for idempotency.
#
# Usage:
#   apply-traits.sh          # Apply all enabled trait overlays
#
# Must be run from the project root (where .specify/ and .claude/ exist).
#
# Exit codes:
#   0 - Success (all overlays applied or already present)
#   1 - Error (invalid config, missing targets)

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TRAITS_CONFIG=".specify/sdd-traits.json"

# --- Validation ---

if [ ! -f "$TRAITS_CONFIG" ]; then
  echo "ERROR: Traits config not found at $TRAITS_CONFIG" >&2
  echo "  Likely cause: Traits have not been configured yet." >&2
  echo "  Remediation: Run /sdd:init to select and configure traits." >&2
  exit 1
fi

if ! jq empty "$TRAITS_CONFIG" 2>/dev/null; then
  echo "ERROR: Invalid JSON in $TRAITS_CONFIG" >&2
  echo "  Likely cause: The file was manually edited with a syntax error." >&2
  echo "  Remediation: Fix the JSON syntax or delete the file and run /sdd:init to reconfigure." >&2
  exit 1
fi

# --- Collect enabled traits ---

enabled_traits=$(jq -r '.traits | to_entries[] | select(.value == true) | .key' "$TRAITS_CONFIG")

if [ -z "$enabled_traits" ]; then
  echo "No traits enabled. Nothing to apply."
  exit 0
fi

# --- Collect all overlays and validate targets first ---

declare -a overlay_files=()
declare -a target_files=()
errors=0

for trait in $enabled_traits; do
  overlay_dir="$PLUGIN_ROOT/overlays/$trait"

  if [ ! -d "$overlay_dir" ]; then
    echo "WARNING: No overlay directory found for trait '$trait' at $overlay_dir" >&2
    continue
  fi

  # Find all .append.md files under this trait's overlay directory
  while IFS= read -r -d '' overlay_file; do
    # Derive the relative path within the overlay dir (e.g., commands/speckit.specify.append.md)
    rel_path="${overlay_file#"$overlay_dir"/}"

    # Determine target type and name
    overlay_subdir=$(dirname "$rel_path")
    overlay_basename=$(basename "$rel_path")
    # Strip .append.md to get the target filename
    target_basename="${overlay_basename%.append.md}.md"

    # Map overlay subdirectory to target directory
    case "$overlay_subdir" in
      commands)
        target_file=".claude/commands/$target_basename"
        ;;
      templates)
        target_file=".specify/templates/$target_basename"
        ;;
      *)
        echo "WARNING: Unknown overlay subdirectory '$overlay_subdir' in $overlay_file, skipping" >&2
        continue
        ;;
    esac

    if [ ! -f "$target_file" ]; then
      echo "ERROR: Target file not found: $target_file" >&2
      echo "  Overlay: $overlay_file" >&2
      echo "  Likely cause: spec-kit is not initialized, or the overlay targets a file that doesn't exist in this spec-kit version." >&2
      echo "  Remediation: Run 'specify init --here --ai claude --force' to initialize spec-kit, then re-run apply-traits.sh." >&2
      errors=$((errors + 1))
      continue
    fi

    overlay_files+=("$overlay_file")
    target_files+=("$target_file")
  done < <(find "$overlay_dir" -name "*.append.md" -print0 2>/dev/null)
done

if [ "$errors" -gt 0 ]; then
  echo "ERROR: $errors target file(s) missing. No overlays applied." >&2
  exit 1
fi

if [ ${#overlay_files[@]} -eq 0 ]; then
  echo "No overlay files found for enabled traits."
  exit 0
fi

# --- Apply overlays (idempotent) ---

applied=0
skipped=0

for i in "${!overlay_files[@]}"; do
  overlay_file="${overlay_files[$i]}"
  target_file="${target_files[$i]}"

  # Extract trait name from overlay path for sentinel check
  # Path format: PLUGIN_ROOT/overlays/<trait>/...
  trait_name=$(echo "$overlay_file" | sed "s|$PLUGIN_ROOT/overlays/||" | cut -d'/' -f1)
  sentinel="<!-- SDD-TRAIT:$trait_name -->"

  if grep -q "$sentinel" "$target_file" 2>/dev/null; then
    skipped=$((skipped + 1))
    continue
  fi

  # Append with newline separator
  printf '\n' >> "$target_file"
  cat "$overlay_file" >> "$target_file"
  applied=$((applied + 1))
done

echo "Traits applied: $applied overlay(s) appended, $skipped already present (skipped)."
exit 0
