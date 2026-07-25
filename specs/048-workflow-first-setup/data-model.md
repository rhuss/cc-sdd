# Data Model: Workflow-First Spex Setup

## Spex Project Configuration

Team-owned requested intent stored in `.specify/spex.json`.

| Field | Type | Rules |
|-------|------|-------|
| `schema_version` | integer | Required; initially `1` |
| `harness` | string | Required; `auto`, `claude`, `codex`, or legacy-compatible `opencode` |
| `extensions` | array of strings | Required, unique, contains `spex`, known bundled extensions only |
| `security` | string | Required; `safe`, `autonomous`, or `yolo` |

The declaration excludes detected capabilities, generated paths, effective security, timestamps, workflow state, and revision counters so it changes only when user intent changes.

## Setup Request

Transient candidate produced by applying precedence independently to every field:

```text
explicit input > stored project configuration > recommended default
```

The complete request is validated before persistence or extension mutation.

## Setup Resolution

Validated normalized request consumed by workflow steps. Extension dependency closure is applied before persistence, so the declaration records the actual requested installation.

## State transitions

```text
absent configuration
        ↓ resolve defaults or interactive selections
candidate request
        ↓ validate fields and dependency closure
validated resolution
        ↓ atomic replacement after accepted selection
persisted project configuration
        ↓ later explicit override
new validated resolution → atomic replacement
```

Validation failure leaves the previous persisted configuration byte-identical.
