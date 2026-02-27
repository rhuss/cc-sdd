---
name: teams-orchestrate
description: "Vanilla team orchestration for parallel task implementation via Claude Code Agent Teams"
---

# Teams Orchestration: Parallel Task Implementation

## Overview

This skill orchestrates parallel task implementation using Claude Code Agent Teams. The lead session analyzes the task dependency graph, spawns teammates for independent task groups, and waits for all work to complete before proceeding.

## Prerequisites

### CC Teams Feature Flag

Check if Agent Teams is enabled:

```bash
# Check settings.local.json for the feature flag
FLAG=$(jq -r '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS // ""' .claude/settings.local.json 2>/dev/null)
```

**If the flag is not set (`""` or missing):**

1. Set it in `.claude/settings.local.json`:
   ```bash
   jq '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"' .claude/settings.local.json > /tmp/settings.json && mv /tmp/settings.json .claude/settings.local.json
   ```
2. Inform the user: "Agent Teams feature flag has been enabled. Please restart Claude Code for teams to activate."
3. **Fall back to sequential implementation** for this session (teams will work on next run).

**If the flag is set:** Proceed with team orchestration.

## Task Graph Analysis

Read the tasks.md file and analyze the dependency structure:

1. **Parse all tasks** with their IDs, descriptions, and phase membership
2. **Identify dependency relationships** from the Dependencies section and phase ordering
3. **Group tasks by independence**: tasks that can execute simultaneously (no shared dependencies, different files)
4. **Identify blocked tasks**: tasks that must wait for others to complete first

### Parallelism Assessment

Evaluate whether teams add value:

- **If 0-1 independent task groups exist** (everything is sequential): Skip team creation, execute tasks sequentially in the current session. Report: "Tasks are sequential, no parallelism benefit. Executing directly."
- **If 2+ independent task groups exist**: Proceed with team spawning.

## Teammate Spawning

### Spawn Rules

- Spawn **one teammate per independent task group** (not one per task)
- **Maximum 5 teammates** (CC Teams best practice for coordination overhead)
- If more than 5 independent groups, batch them: assign multiple groups to the same teammate sequentially
- **Never spawn more teammates than independent groups**

### Spawn Prompt Template

Each teammate receives this context in its spawn prompt:

```
You are implementing tasks for the [feature-name] feature.

## Your Assigned Tasks

[List the specific tasks assigned to this teammate]

## Spec Context

[Contents of spec.md for this feature]

## Working Rules

1. Implement each task completely before moving to the next
2. Mark each task as complete in the shared task list when done
3. Commit after each task with a descriptive message
4. If you encounter a blocker, message the lead with details
5. Do not modify files outside your assigned task scope
```

### Spawning Process

Tell Claude to create an agent team:

```
Create an agent team for parallel implementation of [feature-name].

Spawn [N] teammates:
- Teammate 1: [task group description] - tasks [IDs]
- Teammate 2: [task group description] - tasks [IDs]
...

Each teammate should implement their assigned tasks independently.
Wait for all teammates to complete before proceeding.
```

## Completion Waiting

After spawning teammates:

1. **Wait for all teammates to finish** their assigned tasks
2. **Do not implement tasks yourself** while teammates are working (coordinate only)
3. **Monitor for stuck teammates**: if a teammate stops responding or errors, note the issue
4. **Handle teammate failures**: if a teammate crashes mid-task, either:
   - Spawn a replacement teammate for the remaining tasks
   - Fall back to implementing the remaining tasks directly

## Post-Completion

After all teammates have finished:

1. Verify all assigned tasks are marked complete in the shared task list
2. Proceed to any post-implementation quality gates (spec review, verification)
3. Clean up the team

## Sequential Fallback

When teams cannot be used (feature flag not active, single task, linear dependencies):

Execute tasks sequentially in the current session following the standard implementation flow from tasks.md. This is the normal behavior when the teams-vanilla trait is not active.

## Key Principles

- **Teams for parallelism, not complexity**: Only use teams when genuine parallel work exists
- **Lead coordinates, doesn't implement**: While teammates are working, the lead monitors and coordinates
- **Graceful degradation**: Always fall back to sequential if teams can't help
- **Respect task dependencies**: Never assign dependent tasks to different teammates
