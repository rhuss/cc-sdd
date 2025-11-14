# Changelog

All notable changes to the **sdd** plugin (repository: cc-superpowers-sdd) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note**: The plugin name is `sdd` (for slash commands like `/sdd:brainstorm`), while the GitHub repository is `cc-superpowers-sdd`.

## [Unreleased]

### Added
- **Automatic spec-kit initialization** - Plugin automatically initializes projects on first SDD command
  - Checks if spec-kit CLI is installed
  - Automatically runs `speckit init` if project not initialized
  - Reminds user to restart if new `.claude/commands/` were installed
  - No manual setup required for users
- **Restart detection** - Plugin detects when spec-kit installs local commands and prompts restart
- **Clear error messages** - If spec-kit not installed, provides installation instructions
- **Canonical two-skill architecture** - Clear separation of concerns:
  - `spec-kit` - Technical integration layer (auto-init, layout validation, CLI wrappers)
  - `using-superpowers-sdd` - Methodology layer (workflow routing, process discipline)
  - All workflow skills call `spec-kit` for automatic setup

### Changed (BREAKING)
- **spec-kit is now a required dependency** - Plugin no longer bundles templates, scripts, or spec-kit commands
- Templates, scripts, and commands now live in local project (`.specify/` and `.claude/commands/`) via `speckit init`
- Single source of truth: spec-kit repository maintains all templates, scripts, and commands
- Cleaner separation of concerns: plugin focuses on Claude Code integration, spec-kit provides tooling

### Removed
- **Bundled templates** - Removed `templates/` directory (use `speckit init` instead)
- **Bundled scripts** - Removed `scripts/` directory (use `speckit init` instead)
- **Bundled spec-kit commands** - Removed `commands/speckit.*` files (installed to `.claude/commands/` via `speckit init`)

### Migration Guide
1. Ensure spec-kit CLI is installed and in your PATH
2. ~~Run `speckit init` in each project~~ - Now happens automatically on first SDD command!
3. Restart Claude Code when prompted (if new commands were installed to `.claude/commands/`)
4. Update any custom references from plugin templates to `.specify/templates/`
5. Update any custom references from plugin scripts to `.specify/scripts/`
6. `/speckit.*` commands now come from `speckit init`, not the plugin

## [1.0.0] - 2025-11-11

### Added

#### Core Skills
- **using-superpowers-sdd**: Entry skill establishing mandatory SDD workflows
- **brainstorm**: Refine rough ideas into executable specifications through collaborative dialogue
- **spec**: Create formal specifications directly from clear requirements
- **implement**: Implement features from validated specifications using TDD with spec compliance checking
- **evolve**: Reconcile spec/code mismatches with AI-guided evolution and user control

#### Modified Superpowers Skills
- **writing-plans**: Generate implementation plans FROM specifications with full requirement coverage
- **review-code**: Review code against spec compliance with scoring and deviation detection
- **verification-before-completion**: Extended verification including tests AND spec compliance validation

#### SDD-Specific Skills
- **review-spec**: Review specifications for soundness, completeness, and implementability
- **spec-refactoring**: Consolidate and improve evolved specs while maintaining feature coverage
- **spec-kit**: Wrapper for spec-kit CLI operations with workflow discipline
- **constitution**: Create and manage project constitution defining project-wide principles

#### Slash Commands
- `/sdd:brainstorm`: Interactive specification refinement
- `/sdd:spec`: Direct specification creation
- `/sdd:implement`: Feature implementation from specs
- `/sdd:evolve`: Spec/code reconciliation
- `/sdd:review-spec`: Specification review
- `/sdd:constitution`: Project constitution management

#### Bundled Resources
- **Templates**: 5 spec-kit templates (spec, plan, tasks, checklist, agent-file)
- **Scripts**: 5 bash scripts for feature management and automation
- **Reference Commands**: 8 spec-kit command implementations for reference

#### Configuration Schema
- Auto-update spec settings with configurable thresholds
- Spec-kit CLI integration settings
- Constitution path and requirement settings
- Specs directory configuration

#### Documentation
- Comprehensive README with workflow examples
- TESTING.md with integration testing guide
- Example todo-app project with walkthrough
- Plugin schema documentation

### Infrastructure
- Plugin structure following Claude Code standards
- Proper .claude-plugin/plugin.json manifest
- .gitignore for clean repository
- Local development marketplace setup
- MIT license
- GitHub repository and issue tracking

### Acknowledgements
- Built on [superpowers](https://github.com/obra/superpowers) by Jesse Vincent for process discipline foundation
- Integrates [spec-kit](https://github.com/github/spec-kit) by GitHub for specification workflows

## [Unreleased]

### Planned
- Additional example projects
- Video walkthrough of SDD workflow
- Integration with CI/CD pipelines
- Enhanced spec validation rules

---

## Release Notes Format

Each release will include:
- **Added**: New features and capabilities
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

For detailed commit history, see [GitHub Commits](https://github.com/rhuss/cc-superpowers-sdd/commits/main)
