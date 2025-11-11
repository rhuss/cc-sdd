# Bundled Spec-Kit Templates

This directory contains spec-kit templates bundled with the cc-superpowers-sdd plugin.

## Available Templates

### spec-template.md
Feature specification template with:
- User scenarios and testing (mandatory)
- Functional requirements (mandatory)
- Success criteria (mandatory)
- Key entities (optional)
- Edge cases

Use this template when creating a new feature specification.

### plan-template.md
Implementation plan template with:
- Summary
- Technical context
- Constitution check
- Project structure
- Phase breakdown (research, design, implementation)
- Complexity tracking

Use this template when creating an implementation plan from a spec.

### tasks-template.md
Task breakdown template with:
- Task list with priorities
- Effort estimates
- Dependencies
- Test requirements
- Verification steps

Use this template when breaking down an implementation plan into tasks.

### checklist-template.md
Quality checklist template with:
- Content quality checks
- Requirement completeness
- Feature readiness
- Notes section

Use this template to validate specifications and plans.

### agent-file-template.md
Agent context file template with:
- Current context
- Active goals
- Recent decisions
- Open questions

Use this template for maintaining agent context across sessions.

## Usage

These templates are used automatically by the SDD skills. You can also use them directly:

```bash
# Get plugin directory
PLUGIN_DIR="${CLAUDE_PLUGINS_DIR}/cc-superpowers-sdd"

# Copy template to your project
cp "$PLUGIN_DIR/templates/spec-template.md" ./specs/001-my-feature/spec.md
```

## Source

These templates are from [spec-kit](https://github.com/github/spec-kit) by GitHub, bundled with this plugin for convenience.
