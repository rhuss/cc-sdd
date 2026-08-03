#!/usr/bin/env bash
# detect-cc-review.sh - Detect cc-review installation
# Outputs cc-review core path on stdout if found, exits 1 if not.

set -euo pipefail

# Tier 1: spec-kit extension registry
CC_REVIEW_ENABLED=$(jq -r '.extensions["cc-review"].enabled // false' \
  .specify/extensions/.registry 2>/dev/null || echo "false")
if [ "$CC_REVIEW_ENABLED" = "true" ]; then
  CC_REVIEW_PATH=".specify/extensions/cc-review"
  if [ -f "$CC_REVIEW_PATH/core/commands/review.md" ]; then
    echo "$CC_REVIEW_PATH"
    exit 0
  fi
fi

# Tier 2: project-local or user-level installation
for candidate in ".cc-review" "${HOME}/.cc-review"; do
  if [ -f "$candidate/core/commands/review.md" ]; then
    echo "$candidate"
    exit 0
  fi
done

exit 1
