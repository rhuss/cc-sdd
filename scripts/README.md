# Bundled Spec-Kit Scripts

This directory contains spec-kit shell scripts bundled with the cc-superpowers-sdd plugin.

## Available Scripts (bash/)

### common.sh
Common functions and utilities used by other scripts:
- `get_repo_root()` - Get repository root directory
- `get_current_branch()` - Get current branch name
- `check_feature_branch()` - Validate feature branch naming
- `get_feature_dir()` - Get feature directory path
- `find_feature_dir_by_prefix()` - Find feature directory by numeric prefix
- `get_feature_paths()` - Get all feature-related paths
- `check_file()` - Check if file exists
- `check_dir()` - Check if directory exists

### create-new-feature.sh
Create a new feature branch and spec structure:
- Generates feature branch name from description
- Checks for existing branches
- Creates feature directory in `specs/`
- Copies spec template
- Sets SPECIFY_FEATURE environment variable

**Usage:**
```bash
./create-new-feature.sh --json "Add user authentication"
./create-new-feature.sh --short-name "user-auth" --number 5 "Add user authentication"
```

### check-prerequisites.sh
Check project prerequisites:
- Verifies git repository
- Checks for required tools
- Validates project structure

**Usage:**
```bash
./check-prerequisites.sh
```

### setup-plan.sh
Set up implementation plan structure:
- Creates plan directory
- Initializes plan template
- Sets up phase directories

**Usage:**
```bash
./setup-plan.sh
```

### update-agent-context.sh
Update agent context files:
- Updates agent memory
- Tracks recent decisions
- Maintains context across sessions

**Usage:**
```bash
./update-agent-context.sh
```

## Using Bundled Scripts

The SDD skills use these scripts automatically. You can also use them directly:

```bash
# Get plugin directory
PLUGIN_DIR="${CLAUDE_PLUGINS_DIR}/cc-superpowers-sdd"

# Run bundled script
"$PLUGIN_DIR/scripts/bash/create-new-feature.sh" --json "Add user authentication"
```

## Source

These scripts are from [spec-kit](https://github.com/github/spec-kit) by GitHub, bundled with this plugin for convenience.
