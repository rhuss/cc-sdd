# Upstream Proposal: Native Preset System for speckit-checklist

**Target Repository**: github/spec-kit
**Proposed By**: cc-spex (feature 052-data-pipeline-hygiene)
**Date**: 2026-08-04

## Problem Statement

When a specification covers domain-specific work (data pipelines, security hardening, API design), the same quality checks recur every time. Today, these domain-specific checklist items must be remembered and re-typed for each feature. The `/speckit-checklist` command generates generic requirement-quality checks but has no mechanism for loading pre-written, domain-specific item sets.

The cc-spex extension (`spex-gates`) currently ships a workaround: a separate `/speckit-spex-gates-data-checklist` command that generates data-pipeline-specific items from a preset file. This works but requires users to know about a different command name and duplicates some checklist generation logic. The proper fix belongs upstream in spec-kit.

## Proposed Solution: Two-Level Preset System

Extend `/speckit-checklist` to accept an optional preset name that loads domain-specific checklist items from a preset file.

### Usage

```bash
# Generate a data-pipeline checklist from a preset
speckit-checklist data-pipeline

# Generate a security checklist from a preset
speckit-checklist security

# Default behavior (no preset, existing functionality unchanged)
speckit-checklist
```

### Preset Loading Logic

Presets are markdown files containing pre-written checklist items grouped by category. The loading follows a two-level resolution order:

1. **Project-level preset** (highest priority): `.specify/checklists/presets/{name}.md`
2. **Built-in preset** (default): Shipped with spec-kit at `presets/{name}.md` within the package

Project-level presets **fully replace** built-in presets of the same name. There is no merging, deduplication, or item-level override. This keeps the override model simple and predictable: if a project has a custom `data-pipeline.md`, it is the complete preset for that domain.

### Preset File Format

Presets use the same markdown checklist format as existing `/speckit-checklist` output:

```markdown
# Domain Name Checklist

**Preset**: domain-name
**Version**: 1.0.0
**Categories**: Category1, Category2, Category3

## Category1

- [ ] CHK001 [Completeness] Are X requirements defined?
- [ ] CHK002 [Clarity] Does the spec specify Y?

## Category2

- [ ] CHK003 [Consistency] Are Z conventions documented?
```

Each item follows the "unit tests for English" pattern: questions about requirement quality, not implementation behavior. Items include category tags ([Completeness], [Clarity], [Consistency], [Coverage], [Gap]) for traceability.

### Built-In Presets

Spec-kit could ship with a starter set of domain presets:

- `data-pipeline`: Lineage, row counts, fan-out checks, schema assertions, output conventions, visualization standards
- Additional presets contributed by the community over time

### Project-Level Override

Teams customize presets by placing a modified file at `.specify/checklists/presets/{name}.md`. This allows:

- Adding project-specific items (e.g., internal compliance requirements)
- Removing irrelevant items (e.g., visualization checks for backend-only projects)
- Replacing built-in items entirely with team-specific conventions

To start from the built-in preset: copy it to the project directory and modify as needed.

## Migration Path

When upstream ships the preset system:

1. The cc-spex `/speckit-spex-gates-data-checklist` command becomes deprecated
2. The built-in preset file (`spex/extensions/spex-gates/presets/data-pipeline.md`) moves upstream
3. Existing project-level overrides at `.specify/checklists/presets/data-pipeline.md` continue to work unchanged (same path convention)
4. The extension command can be retired in a future cc-spex release

## Motivating Use Case

The cc-spex project (github.com/rhuss/cc-spex) implemented a data-pipeline hygiene checklist as feature #052. The checklist covers six categories of data-engineering best practices that recur across every data-oriented spec. The extension command and preset file demonstrate the pattern working in practice and serve as a reference implementation for the upstream preset system.

See: https://github.com/rhuss/cc-spex/issues/49
