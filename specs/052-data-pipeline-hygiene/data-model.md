# Data Model: Data-Pipeline Hygiene

## Entities

### Preset

A markdown file containing pre-written checklist items for a specific domain.

| Attribute | Description |
|-----------|-------------|
| name | Domain identifier (e.g., "data-pipeline") |
| level | "built-in" (shipped with extension) or "project" (in `.specify/checklists/presets/`) |
| categories | Ordered list of category sections, each containing checklist items |

**Resolution order**: project-level > built-in. No merging.

**Built-in location**: `spex/extensions/spex-gates/presets/{name}.md`
**Project location**: `.specify/checklists/presets/{name}.md`

### Checklist Item

A requirement-quality question within a preset or generated checklist.

| Attribute | Description |
|-----------|-------------|
| id | Unique identifier (e.g., CHK001) |
| question | Requirement-quality question in "Are X defined/specified?" pattern |
| category_tag | Quality dimension tag (e.g., [Completeness], [Clarity], [Consistency]) |
| traceability | Optional spec section reference (e.g., [Gap], [Spec section]) |

### Spec-Declared Constant

A named value parsed from the spec's `## Constants` section.

| Attribute | Description |
|-----------|-------------|
| name | Constant identifier (e.g., NULL_THRESHOLD) |
| value | String value as declared in spec (e.g., "5%") |
| source_line | Line number in spec where declared |

**Supported formats**:
- `- NAME = value`
- `- NAME: value`

Values are compared as strings. No numeric or expression parsing.

## Relationships

```
Preset 1---* Checklist Item
  (a preset contains many items grouped by category)

Spec 1---* Spec-Declared Constant
  (a spec's ## Constants section declares zero or more constants)

Spec-Declared Constant ---check-against--- Code Module
  (drift check compares spec values to code definitions)
```

## State Transitions

### Checklist Generation

```
No checklist → Generated (from preset) → Updated (if re-run with new preset)
```

### Constants Drift Check

```
No ## Constants section → Skip (no check performed)
## Constants found → Parse → Compare against code → Report findings
```
