# Superpowers-SDD

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-purple)
![Status](https://img.shields.io/badge/status-stable-success)

> Specification-Driven Development with Process Discipline for Claude Code

A Claude Code plugin that merges rigorous process discipline with specification-driven development, making specs your single source of truth while maintaining workflow flexibility.

## Acknowledgements

This plugin builds on the foundation of two excellent projects:

- **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent - Provides the process discipline, quality gates, and workflow enforcement that prevent shortcuts and ensure quality
- **[Spec-Kit](https://github.com/github/spec-kit)** by GitHub - Introduces specification-driven development workflows and tooling for executable specifications

Superpowers-SDD combines the best of both: superpowers' mandatory workflows with spec-kit's specification-first philosophy.

## What is Specification-Driven Development?

Specification-Driven Development (SDD) treats specifications as the single source of truth from which everything else flows:

```
Idea → Spec → Plan → Code → Verification
         ↑                      ↓
         └──── Spec Evolution ──┘
```

Unlike traditional development where specs (if they exist) quickly become outdated documentation, SDD keeps specs:
- **Executable** - Specs drive implementation, not just describe it
- **Living** - Specs evolve with implementation reality
- **Validated** - Code is continuously checked against spec compliance
- **Intentional** - "What" and "why" before "how"

## Why Superpowers-SDD?

### The Problem

- Traditional development: Code and docs drift apart
- Spec-first approaches: Specs become rigid contracts that block progress
- Move-fast approaches: Implementation details override design intent

### The Solution

Superpowers-SDD provides:

✅ **Specs as source of truth** - Everything flows from specifications
✅ **Process discipline** - All superpowers quality gates remain intact
✅ **Evolving specs** - AI-guided spec evolution when reality differs from plan
✅ **Intent before implementation** - Force clarity on "what" and "why"
✅ **Flexible entry points** - Start from idea, spec, or existing code
✅ **Automated compliance** - Continuous spec-to-code validation

## Features

- **Phase-specific workflows**: Different entry points for different contexts
  - `/sdd:brainstorm` - From rough idea to spec
  - `/sdd:spec` - Direct spec creation
  - `/sdd:implement` - Spec-guided implementation
  - `/sdd:evolve` - Spec/code reconciliation

- **Modified superpowers skills** for spec-awareness:
  - Plans generated FROM specs
  - Code reviews check spec compliance
  - Verification includes spec validation

- **New SDD-specific skills**:
  - Spec soundness review
  - Spec refactoring and consolidation
  - Constitution management

- **Intelligent spec evolution**:
  - AI detects spec/code mismatches
  - Recommends update spec vs. fix code
  - Configurable auto-updates for minor changes

- **Spec-kit integration**:
  - Leverages spec-kit CLI where beneficial
  - Adds workflow discipline on top
  - Can bypass when it creates friction

## Installation

### Prerequisites

1. **Claude Code** - Install from [claude.com/claude-code](https://claude.com/claude-code)
2. **Spec-Kit** (required) - Install from [github.com/github/spec-kit](https://github.com/github/spec-kit)
   - spec-kit provides the templates, scripts, and tooling that power SDD workflows
   - Must be installed and accessible in your PATH

### Install Superpowers-SDD Plugin

```bash
# Clone the plugin
cd ~/.claude/plugins
git clone https://github.com/rhuss/cc-superpowers-sdd.git

# Reload Claude Code or restart
```

### Initialize Your Project

Before using SDD workflows, initialize spec-kit in your project:

```bash
# Navigate to your project
cd /path/to/your/project

# Initialize spec-kit
speckit init
```

This creates the `.specify/` directory with:
- Templates for specs, plans, tasks, and checklists
- Shell scripts for automation
- Project constitution and memory

### Configuration

Create `.claude/settings.json` in your project:

```json
{
  "sdd": {
    "auto_update_spec": {
      "enabled": true,
      "threshold": "minor",
      "notify": true
    },
    "spec_kit": {
      "enabled": true,
      "path": "speckit"
    }
  }
}
```

## Quick Start

### New Feature from Scratch

```bash
# 1. Start with brainstorming
/sdd:brainstorm

# Claude will guide you through refining your idea
# and create a spec at specs/features/your-feature.md

# 2. Review the spec
/sdd:review-spec

# 3. Implement
/sdd:implement

# Claude will generate a plan from the spec,
# use TDD, and verify spec compliance
```

### From Clear Requirements

```bash
# Skip brainstorming if you know what you want
/sdd:spec

# Describe your requirements
# Spec created and validated

/sdd:implement
```

### Working with Existing Code

```bash
# Detect and reconcile spec/code mismatches
/sdd:evolve

# Claude analyzes divergence and recommends:
# - Update spec (implementation reveals better approach)
# - Fix code (deviation from intended design)
# - Clarify spec (ambiguity resolved)
```

## Workflow Phases

### Phase 1: Brainstorming (`/sdd:brainstorm`)

**When to use**: Starting from a rough idea

**What happens**:
1. Claude explores your idea through questions
2. Proposes 2-3 approaches with trade-offs
3. Refines design collaboratively
4. Creates formal spec using spec-kit

**Practical Example**:

```
You: I want to add user authentication to my app

Claude: Let me help you refine this idea.

What type of authentication are you considering?

A) Email/password with JWT tokens
B) OAuth 2.0 (Google, GitHub, etc.)
C) Magic links (passwordless email)
D) Multi-factor with one of the above

You: B - OAuth with Google and GitHub

Claude: Great. For OAuth integration, how should we handle session management?

A) Server-side sessions with Redis
B) JWT tokens stored in httpOnly cookies
C) JWT in localStorage with refresh tokens

[... dialogue continues ...]

Claude: Based on our discussion, I'm creating the spec:

specs/features/oauth-authentication.md

[Spec created with all discussed requirements]

Ready to review the spec, or shall we proceed to implementation?
```

**Output**: `specs/features/[feature-name].md`

### Phase 2: Specification (`/sdd:spec`)

**When to use**: You have clear requirements, skip brainstorming

**What happens**:
1. Interactive spec creation
2. Validates against constitution (if exists)
3. Checks spec soundness
4. Creates spec file via spec-kit

**Practical Example**:

```
You: /sdd:spec

I need a REST API endpoint for user profile updates.
- PUT /api/users/:id/profile
- Accepts: name, bio, avatar_url
- Returns: updated user object
- Auth: requires valid JWT
- Validation: name 2-50 chars, bio max 500 chars

Claude: I'll create a spec for the user profile update endpoint.

Should this endpoint:

A) Update profile immediately
B) Queue updates for async processing
C) Support partial updates (PATCH-like)

You: C - partial updates

Claude: For avatar_url, should we:

A) Accept URL and validate it
B) Accept URL and proxy/cache the image
C) Require upload to our storage first

[... continues ...]

Claude: Spec created at specs/features/user-profile-api.md

Validated against specs/constitution.md ✓
- Follows RESTful conventions ✓
- Includes auth requirements ✓
- Defines error responses ✓

Ready to implement?
```

**Output**: `specs/features/[feature-name].md`

### Phase 3: Implementation (`/sdd:implement`)

**When to use**: Spec exists and is validated

**What happens**:
1. Generates implementation plan FROM spec
2. Creates git worktree for isolation
3. Implements using TDD
4. Code review checks spec compliance
5. Verification includes spec validation

**Practical Example**:

```
You: /sdd:implement

Claude: Reading spec: specs/features/user-profile-api.md

Generating implementation plan...

Implementation Plan:
1. Create API route handler (src/api/users/profile.ts)
2. Add validation middleware (src/middleware/validation.ts)
3. Implement profile update service (src/services/userProfile.ts)
4. Add integration tests (tests/api/users/profile.test.ts)

Starting TDD implementation...

Test 1: Should reject unauthenticated requests
[Test written and failing]
[Implementing auth check]
[Test passing] ✓

Test 2: Should validate name length
[Test written and failing]
[Implementing validation]
[Test passing] ✓

[... continues through all requirements ...]

All tests passing ✓

Running spec compliance check...
✓ Endpoint path matches spec
✓ Request validation implemented
✓ Response format matches spec
✓ Error handling per spec
✓ Auth requirement enforced

Spec compliance: 100%

Ready for code review?
```

**Output**:
- `docs/plans/[date]-[feature]-implementation.md`
- Implementation code
- Tests

### Phase 4: Evolution (`/sdd:evolve`)

**When to use**: Spec/code mismatch detected or refinement needed

**What happens**:
1. Detects divergence between spec and code
2. AI analyzes and recommends resolution
3. User decides or auto-updates (if configured)
4. Updates spec or code accordingly

**Practical Example**:

```
Claude: Spec compliance check during verification detected mismatches:

Mismatch 1: Response format (MINOR)
  Spec says: { user: { id, name, bio, avatar_url } }
  Code returns: { id, name, bio, avatar_url, updated_at }

  Analysis: Code includes `updated_at` timestamp not in spec.
  This is useful for clients to know when profile was last modified.

  Recommendation: Update spec to include updated_at
  Reason: Better API design, non-breaking addition

  Auto-update? [Your config: auto_update_spec.threshold = "minor"]

You: Yes

Claude: Spec updated ✓

Mismatch 2: Validation behavior (MAJOR)
  Spec says: Reject requests with invalid avatar_url
  Code does: Accepts invalid URLs, sets avatar_url to null

  Analysis: Current implementation is more lenient.
  This prevents user frustration but diverges from spec intent.

  Options:
  A) Update spec - Allow lenient validation (user-friendly)
  B) Fix code - Strict validation per spec (fail fast)
  C) Clarify spec - Add fallback behavior explicitly

  Recommendation: Option C
  Reason: Best of both - validate but handle gracefully

You: C

Claude: I'll update the spec to explicitly define fallback behavior:

"When avatar_url fails validation:
- Set avatar_url to null
- Log validation error
- Return success with warning in response"

Spec updated and code now compliant ✓
```

**Output**: Updated spec and/or code with compliance restored

## Skills Reference

### Entry Point Skills

#### `sdd:using-superpowers-sdd`
The mandatory entry skill (like `superpowers:using-superpowers`). Establishes workflows and enforces skill usage.

#### `sdd:brainstorm`
Modified version of `superpowers:brainstorming` that outputs specs instead of design docs.

**Usage**: `/sdd:brainstorm`
**Output**: `specs/features/[feature].md`

#### `sdd:spec`
Direct spec creation for clear requirements.

**Usage**: `/sdd:spec`
**Output**: `specs/features/[feature].md`

#### `sdd:implement`
Spec-guided implementation with TDD and compliance checking.

**Usage**: `/sdd:implement`
**Output**: Code, tests, implementation plan

#### `sdd:evolve`
Reconcile spec/code mismatches.

**Usage**: `/sdd:evolve`
**Output**: Updated spec and/or code

### Modified Core Skills

#### `sdd:writing-plans`
Generates implementation plans FROM specs (not from scratch).

**Key change**: Reads spec as input, validates plan against spec

#### `sdd:review-code`
Reviews code-to-spec compliance, not just code quality.

**Key change**: Compliance scoring, mismatch detection, evolution triggers

#### `sdd:verification-before-completion`
Extended verification including spec compliance.

**Key change**: Tests + spec validation + drift detection

### New SDD-Specific Skills

#### `sdd:review-spec`
Review spec for soundness and implementability.

**Checks**:
- Structure and clarity
- Ambiguities and gaps
- Missing error handling
- Implementability

#### `sdd:spec-refactoring`
Consolidate and improve evolved specs.

**Use when**:
- Specs grown organically
- Inconsistencies detected
- Redundant requirements

#### `sdd:spec-kit`
Wrapper for spec-kit CLI operations with workflow discipline.

**Features**:
- Intelligent delegation
- TodoWrite integration
- Error handling

#### `sdd:constitution`
Create/manage project-wide principles.

**Creates**: `specs/constitution.md`
**Referenced by**: All spec validation

### Preserved Superpowers Skills

These work as-is with spec context:
- `test-driven-development`
- `systematic-debugging`
- `using-git-worktrees`
- `dispatching-parallel-agents`

## Configuration Reference

### `.claude/settings.json`

```json
{
  "sdd": {
    "auto_update_spec": {
      "enabled": true,
      "threshold": "minor",
      "notify": true
    },
    "spec_kit": {
      "enabled": true,
      "path": "speckit"
    },
    "constitution": {
      "path": "specs/constitution.md",
      "required": false
    },
    "specs": {
      "directory": "specs/features",
      "format": "markdown"
    }
  }
}
```

### Auto-Update Thresholds

- **`none`**: Never auto-update, always ask
- **`minor`**: Auto-update naming, organization, implementation details
- **`moderate`**: Include minor behavior changes that don't affect contracts
- **`always`**: Auto-update everything (not recommended)

## Complete Example: Todo App

See [examples/todo-app](examples/todo-app) for a complete walkthrough showing:

1. Creating a constitution
2. Brainstorming a todo app feature
3. Generating spec
4. Creating implementation plan from spec
5. TDD implementation
6. Spec compliance verification
7. Handling spec/code mismatches
8. Spec refactoring

The example includes all files: specs, plans, code, and tests.

## File Structure

Your project with the SDD plugin:

```
your-project/
├── specs/
│   ├── constitution.md              # Project principles (optional)
│   └── features/
│       ├── user-auth.md             # Feature specs
│       └── todo-crud.md
├── docs/
│   └── plans/
│       └── 2025-11-10-todo-crud-implementation.md
├── src/
│   └── ... (your code)
├── tests/
│   └── ... (your tests)
└── .claude/
    └── settings.json                # SDD configuration
```

## FAQ

### How is this different from regular superpowers?

Superpowers focuses on process discipline (TDD, systematic debugging, verification). Superpowers-SDD adds **specification as source of truth** - everything flows from and validates against specs.

### How is this different from spec-kit?

Spec-kit provides spec workflows and tooling. Superpowers-SDD adds **process enforcement** - quality gates, mandatory workflows, verification before completion, and spec evolution.

### Do I need spec-kit installed?

No. Superpowers-SDD can work without spec-kit, though integration is recommended for the best experience.

### Can I use this with existing superpowers skills?

Yes. Superpowers-SDD skills work alongside original superpowers skills. For non-SDD projects, use original skills. For spec-driven projects, use SDD skills.

### What if the spec becomes wrong during implementation?

This is expected! Use `/sdd:evolve` to reconcile. AI will analyze the mismatch and recommend whether to update the spec or fix the code, with reasoning.

### Do I always have to start with brainstorming?

No. Use `/sdd:brainstorm` for rough ideas, `/sdd:spec` for clear requirements, `/sdd:implement` for existing specs, or `/sdd:evolve` for existing code.

### Can I skip TDD?

No. TDD remains mandatory during implementation phase (from superpowers). But it comes AFTER spec creation, not before.

### How do I handle bugs with SDD?

Use `systematic-debugging` to find root cause, then check if bug reveals spec issue. Update spec if needed, fix code, verify spec compliance.

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

### Areas for Contribution

- Additional skills for specific SDD scenarios
- Better spec-kit integration
- Example projects in different domains
- Documentation improvements
- Spec validation tooling

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- Jesse Vincent ([@obra](https://github.com/obra)) - Superpowers plugin
- GitHub - Spec-Kit
- All contributors to both projects

---

**Built with process discipline. Guided by specifications.**
