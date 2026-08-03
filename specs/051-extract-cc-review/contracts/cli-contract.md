# CLI Contract: cc-review Commands

**Date**: 2026-08-02

## /review Command

Entry point for multi-agent code review.

### Invocation

```
/review [options]
```

### Options

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--pr <number>` | integer | (current branch) | Review a specific PR instead of the branch diff |
| `--spec <path>` | string | (none) | Path to spec.md for compliance checking |
| `--hints <path>` | string | (none) | Path to review hints file |
| `--output <path>` | string | `./review-findings.md` | Output path for findings report |
| `--no-fix` | flag | (fix enabled) | Skip the autonomous fix loop |
| `--max-rounds <n>` | integer | `3` | Maximum fix loop rounds |
| `--no-external` | flag | (external enabled) | Disable all external tools |
| `--no-coderabbit` | flag | (config) | Disable CodeRabbit |
| `--no-copilot` | flag | (config) | Disable Copilot |
| `--no-codex` | flag | (config) | Disable Codex |
| `--parallel` | flag | (auto) | Force parallel agent dispatch |
| `--sequential` | flag | (auto) | Force sequential agent dispatch |

### Outputs

1. **Console**: Progress updates per agent, gate outcome summary table
2. **File**: `review-findings.md` at the output path (see [findings-report-contract.md](findings-report-contract.md))
3. **Exit status**: 0 on PASS, 1 on FAIL

### Behavior

1. Determine changed files (branch diff or PR diff)
2. Detect external tools (if enabled)
3. Dispatch 6 review agents (parallel or sequential)
4. Dispatch external tools (if available)
5. Merge and deduplicate findings
6. Gate check (Critical + Important = 0 for PASS)
7. Fix loop (if findings and `--no-fix` not set)
8. Write findings report
9. Output console summary

## /triage Command

Entry point for PR comment triage.

### Invocation

```
/triage [options]
```

### Options

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--pr <number>` | integer | (current branch PR) | PR number to triage |
| `--spec <path>` | string | (none) | Path to spec.md for spec-aware assessment |
| `--no-coverage-fix` | flag | (auto-remediate) | Skip coverage remediation |
| `--idea-inbox <path>` | string | (none) | Path for capturing deferred findings |

### Outputs

1. **Console**: Bot comment processing progress, human comment interactive review, summary table
2. **GitHub/GitLab**: Reply comments posted to PR threads
3. **Git**: Commit with applied bot fixes (if any)
4. **State file**: `.cc-review/.triage-state.json` tracking handled comments

### Behavior

1. Resolve PR context (number, owner, repo)
2. Initialize triage state
3. Fetch all review threads (paginated)
4. Partition into bot vs human threads
5. Assess and apply bot fixes
6. Batch commit and push fixes
7. Post reply comments
8. Resolve handled threads
9. Interactive review of human comments
10. Output summary

## Adapter Contract

Each adapter MUST implement:

1. **Locate core**: Find the cc-review core installation path
2. **Translate arguments**: Map harness-specific arguments to cc-review CLI flags
3. **Invoke core**: Execute the core command with translated arguments
4. **Post-process**: Handle harness-specific cleanup (optional)

Each adapter MUST NOT:
- Contain review logic
- Duplicate finding schema or agent prompts
- Implement its own fix loop or triage workflow
- Exceed 50 lines of content
