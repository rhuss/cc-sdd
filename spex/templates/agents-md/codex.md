<!-- >>> spex managed Codex guidance >>>
This block is managed by spex:init. Edit guidance outside the sentinels.
-->

# spex: Spec-Driven Development Plugin

## Workflow

spex enforces a spec-first development workflow. All features follow:
specify -> clarify -> plan -> tasks -> implement -> review -> verify

## Enforcement

Hooks enforce this workflow mechanically via PreToolUse and UserPromptSubmit hooks.
You do not need to remember the rules; the hooks will block invalid actions.

## Interactive Prompts

Codex does NOT have the AskUserQuestion tool. When presenting choices,
use an inline numbered list and wait for the user's response.

## Parallel Work

Use **subagents** when explicitly requested for parallel task dispatch.
Each subagent should work on independent tasks. Coordinate completion
before proceeding to review.

## Context Management

Start a **new session** to reset context when token usage is high.
There is no /clear command on Codex.

## Worktrees

Codex does NOT have the EnterWorktree tool. To create isolated workspaces,
use git commands directly:

```bash
git worktree add ../<feature-name> -b <branch-name>
```

When done, clean up with:

```bash
git worktree remove ../<feature-name>
```

## Skills

- `$speckit-spex-using-superpowers` - Choose the appropriate Spex workflow
- `$speckit-spex-ship` - Full autonomous workflow (specify through verify)
- `$speckit-spex-brainstorm` - Refine ideas into specifications
- `$speckit-spex-help` - Quick reference for all skills
- `$speckit-specify` - Create feature specification
- `$speckit-plan` - Create implementation plan
- `$speckit-tasks` - Generate task breakdown
- `$speckit-implement` - Execute implementation

<!-- <<< spex managed Codex guidance <<< -->
