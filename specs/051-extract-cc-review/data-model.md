# Data Model: Extract Review into Standalone cc-review Plugin

**Date**: 2026-08-02 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## Entities

### Finding

A specific issue discovered by a review agent or external tool.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Sequential ID (`FINDING-1`, `FINDING-2`, ...) |
| `severity` | enum | Yes | `Critical`, `Important`, `Minor`, `Notable` |
| `confidence` | integer | Yes | 0-100, minimum 70 to report (50 for Critical) |
| `file` | string | Yes | Relative file path |
| `line_start` | integer | Yes | Starting line number |
| `line_end` | integer | No | Ending line number (defaults to `line_start`) |
| `category` | enum | Yes | `correctness`, `architecture`, `security`, `production-readiness`, `test-quality`, `goal-alignment`, `external`, `regression` |
| `description` | string | Yes | What is wrong |
| `rationale` | string | Yes | Why it matters |
| `fix` | string | Yes | Concrete fix suggestion |
| `source_agent` | string | Yes | Agent name that found this |
| `also_reported_by` | string[] | No | Other agents that reported same issue (after dedup) |
| `external_rationale` | string | No | Full rationale from external tool (CodeRabbit/Copilot) |
| `resolution` | enum | Yes | `pending`, `fixed`, `unresolved` |
| `round_found` | integer | Yes | Fix loop round when discovered (1 = initial review) |

**Validation rules**:
- `confidence` must be 0-100
- `severity` values are ordered: Critical > Important > Minor > Notable
- Notable findings never enter the fix loop and never count toward gate check
- `goal-alignment` findings do not deduplicate against other categories

### Review Session

A single invocation of the review command.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | string | Yes | ISO date |
| `branch` | string | Yes | Git branch name |
| `rounds` | integer | Yes | Number of fix loop rounds executed |
| `gate_outcome` | enum | Yes | `PASS`, `FAIL` |
| `invocation` | enum | Yes | `standalone`, `speckit`, `manual` |
| `agents_completed` | integer | Yes | Count of agents that finished |
| `agents_failed` | string[] | No | Names of agents that errored |
| `external_tools` | object | No | Status of each external tool |

**State transitions**:
- Session starts in `review` state
- After agent dispatch: `merging`
- After gate check: `fixing` (if Critical/Important > 0) or `complete` (if PASS)
- After fix loop: `complete` (PASS or FAIL)

### Triage Session

A single invocation of the triage command against a PR.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `pr_number` | integer | Yes | PR/MR number |
| `owner` | string | Yes | Repository owner |
| `repo` | string | Yes | Repository name |
| `platform` | enum | Yes | `github`, `gitlab` |

### Triage Comment State

Per-comment state tracked across triage passes.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment_id` | string | Yes | Database ID of the comment (key) |
| `action` | enum | Yes | `accepted`, `rejected`, `deferred`, `skipped` |
| `reply_id` | string | No | ID of the reply posted |
| `handled_at` | string | Yes | ISO timestamp when handled |

**Validation rules**:
- State is keyed by `(pr_number, comment_id)` pair
- Re-evaluation triggers when new comments appear after `handled_at`

### Bot Profile

Configuration for how to handle a specific bot's review comments.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `login` | string | Yes | Bot's GitHub/GitLab login (e.g., `coderabbitai[bot]`) |
| `self_resolves` | boolean | Yes | Whether the bot resolves its own threads after fix |
| `auto_resolve` | boolean | Yes | Whether to auto-resolve after triage handles the comment |

**Built-in profiles**:

| Bot | self_resolves | auto_resolve |
|-----|--------------|--------------|
| `coderabbitai[bot]` | true | false |
| `copilot[bot]` | false | true |
| `devin-ai-integration[bot]` | false | true |

### Review Agent

A specialized review perspective.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Agent identifier (e.g., `correctness`, `architecture`) |
| `name` | string | Yes | Display name (e.g., `Correctness`, `Architecture & Idioms`) |
| `prompt_file` | string | Yes | Path to agent prompt template |
| `category` | string | Yes | Finding category this agent produces |
| `scope` | string | Yes | What this agent IS responsible for |
| `exclusions` | string | Yes | What this agent is NOT responsible for |

**Fixed set** (6 agents):
1. `correctness` - bugs, logic errors, resource cleanup
2. `architecture` - code smells, dead code, duplication, naming
3. `security` - vulnerabilities, injection, secret handling
4. `production-readiness` - resource leaks, concurrency, observability
5. `test-quality` - coverage gaps, weak assertions, test isolation
6. `goal-alignment` - goal delivery, undeclared changes (requires PR context)

### Configuration

cc-review configuration, resolved from multiple sources.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `external_tools.coderabbit` | boolean | `true` | Enable CodeRabbit integration |
| `external_tools.copilot` | boolean | `false` | Enable Copilot CLI integration |
| `external_tools.codex` | boolean | `true` | Enable Codex CLI integration |
| `test_command` | string | `""` (auto-detect) | Override test command for fix loop |
| `test_timeout_seconds` | integer | `300` | Test suite timeout |
| `triage.bot_profiles` | BotProfile[] | built-in | Custom bot profile overrides |
| `triage.codecov.patch_threshold` | integer | `80` | Minimum patch coverage percentage |
| `triage.codecov.auto_remediate` | boolean | `true` | Auto-write tests for coverage gaps |
| `max_fix_rounds` | integer | `3` | Maximum fix loop iterations |
| `output_dir` | string | `"."` | Where to write review-findings.md |

**Resolution order**: CLI flags > project `.cc-review/config.yml` > user `~/.cc-review/config.yml` > built-in defaults.

## Relationships

```
ReviewSession 1---* Finding          (session produces findings)
ReviewSession 1---6 ReviewAgent      (session dispatches agents)
Finding *---1 ReviewAgent            (each finding has a source agent)
Finding *---* Finding                (dedup merges via also_reported_by)
TriageSession 1---* TriageCommentState (session tracks comment states)
TriageSession *---* BotProfile       (session uses bot profiles for classification)
Configuration 1---1 ReviewSession    (config governs session behavior)
Configuration 1---1 TriageSession    (config governs triage behavior)
```
