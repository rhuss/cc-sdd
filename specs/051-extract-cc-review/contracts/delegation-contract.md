# Delegation Contract: cc-spex to cc-review

**Date**: 2026-08-02

## Detection Protocol

cc-spex's `spex-deep-review` extension checks for cc-review before running its own review logic.

### Detection Script: `detect-cc-review.sh`

```bash
#!/usr/bin/env bash
# Outputs cc-review core path on stdout if found, exits 1 if not.

# Tier 1: spec-kit extension registry (check enabled flag)
CC_REVIEW_ENABLED=$(jq -r '.extensions["cc-review"].enabled // false' \
  .specify/extensions/.registry 2>/dev/null)
if [ "$CC_REVIEW_ENABLED" = "true" ]; then
  CC_REVIEW_PATH=".specify/extensions/cc-review"
  if [ -f "$CC_REVIEW_PATH/core/commands/review.md" ]; then
    echo "$CC_REVIEW_PATH"
    exit 0
  fi
fi

# Tier 2: project-local or user-level installation (detect by core files, not config)
for candidate in ".cc-review" "${HOME}/.cc-review"; do
  if [ -f "$candidate/core/commands/review.md" ]; then
    echo "$candidate"
    exit 0
  fi
done

# Not found
exit 1
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | cc-review found, path on stdout |
| 1 | cc-review not found |

## Delegation Behavior

### When cc-review IS detected (FR-012)

`speckit.spex-deep-review.run` delegates to cc-review:

1. Run spec compliance check (existing Stage 1)
2. If compliance >= 95%, invoke cc-review's core review command with:
   - `--spec <spec-path>` (if spec available)
   - `--hints <review-hints-path>` (if review hints exist)
   - `--output <spec-dir>/review-findings.md`
   - External tool flags from deep-review config
3. cc-review runs its full agent dispatch, fix loop, and report
4. spex-deep-review reads the gate outcome and updates flow state

### When cc-review IS NOT detected (FR-011)

`speckit.spex-deep-review.run` runs its simplified built-in review:

1. Run spec compliance check (existing Stage 1)
2. Dispatch 6 review agents (same prompts as cc-review)
3. Skip external tool detection and dispatch (Steps 2 and 4)
4. Run fix loop (same logic as cc-review)
5. Write `review-findings.md` and update flow state

### Inputs passed during delegation

| Input | Source | Required |
|-------|--------|----------|
| Spec path | Branch-based resolution via `check-prerequisites.sh` | No |
| Review hints path | `.specify/review-hints.md` | No |
| Output path | `specs/<feature>/review-findings.md` | Yes |
| External tool config | `.specify/extensions/spex-deep-review/deep-review-config.yml` | No |
| Fix loop rounds | Config or default (3) | No |

### Triage delegation

When cc-review is detected, cc-spex removes its own triage command. The spec-kit adapter for cc-review provides triage via `speckit.cc-review.triage`.

If cc-review is NOT installed, cc-spex does not provide triage at all (triage was always part of spex-collab, which is being cleaned up).

## Integration points

```
User invokes /speckit-spex-gates-review-code
  → review-code gate runs spec compliance (Stage 1)
  → review-code checks: is deep-review extension enabled?
    → YES: invokes speckit.spex-deep-review.run
      → deep-review checks: is cc-review detected?
        → YES: delegates to cc-review (full agents + external tools)
        → NO: runs simplified fallback (agents only, no external tools)
    → NO: review-code runs basic compliance-only review
```
