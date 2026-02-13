# Implementation Plan: Beads Integration for SDD Implementation

**Spec:** specs/001-beads-integration/spec.md
**Created:** 2026-02-13
**Status:** Draft

## Implementation Approach

This feature modifies a single file (`sdd/skills/implement/SKILL.md`) to add an alternative execution path when `--with-beads` is specified. The SKILL.md is an instruction file that guides the AI agent, not executable code. The implementation consists of writing precise, unambiguous instructions for the beads workflow that the agent follows at runtime.

No new skills are created. No existing commands are modified. The change is contained within the implement skill's SKILL.md.

## Technical Stack

- **Runtime**: Claude Code agent executing SKILL.md instructions
- **External tool**: `bd` CLI (beads issue tracker)
- **Data format**: tasks.md (markdown checkboxes), beads JSON output (`--json` flag)
- **Shell**: Bash for `bd` CLI invocations and tasks.md parsing

## Architecture

```
sdd:implement SKILL.md (MODIFIED)
├── Phase 1: Pre-Implementation (UNCHANGED)
│   ├── 1.1 Initialize spec-kit
│   ├── 1.2 Discover and select spec
│   ├── 1.3 Verify spec package
│   └── 1.4 Set up feature branch
│
├── Phase 1.5: Beads Bootstrap (NEW, only with --with-beads)
│   ├── 1.5.1 Verify bd CLI available; run bd init --quiet if .beads/ missing
│   ├── 1.5.2 Check for existing beads issues (resume detection)
│   ├── 1.5.3 Parse tasks.md into structured data
│   ├── 1.5.4 Create beads issues with dependencies
│   └── 1.5.5 Report bootstrap summary
│
├── Phase 2: Implementation (CONDITIONAL)
│   ├── Path A (no flag): Invoke /speckit.implement (UNCHANGED)
│   └── Path B (--with-beads): Beads-driven execution loop (NEW)
│       ├── 2B.1 Get next task via bd ready --json
│       ├── 2B.2 Implement task (TDD approach)
│       ├── 2B.3 Close beads issue
│       ├── 2B.4 Handle discovered work
│       └── 2B.5 Loop until bd ready returns empty
│
├── Phase 2.5: Sync-Back (NEW, only with --with-beads)
│   ├── 2.5.1 Read all beads issues
│   ├── 2.5.2 Match to tasks.md entries
│   ├── 2.5.3 Update checkbox states
│   ├── 2.5.4 Append discovered tasks section
│   └── 2.5.5 Run bd sync to persist state to JSONL
│
└── Phase 3: Post-Implementation (UNCHANGED)
    ├── 3.1 Code review against spec
    ├── 3.2 Handle deviations
    ├── 3.3 Verification before completion
    └── 3.4 Final summary
```

## Key Design Decisions

### 1. Dependency Mapping Strategy

**Decision:** Use "last sequential task as phase gate" pattern.

Phase N+1 tasks are blocked by the last sequential (non-`[P]`) task in Phase N. If Phase N ends with parallel tasks, all of them block Phase N+1.

**Rationale:** This minimizes the number of beads dependency edges while correctly enforcing phase ordering. Creating N*M edges (every task in Phase N blocks every task in Phase N+1) would be excessive and make `bd dep tree` unreadable.

**Within a phase:**
- Sequential tasks: T002 blocked by T001, T003 blocked by T002
- Parallel tasks `[P]`: Share the same predecessor but do not block each other
- Mixed: Sequential tasks blocked by previous sequential task AND all preceding parallel tasks at that position

### 2. Resume Detection

**Decision:** Check for `.beads/issues.jsonl` existence, then match task IDs from beads issue titles against tasks.md task IDs.

**Algorithm:**
1. If `.beads/` directory does not exist: first run, proceed to conversion
2. If `.beads/` exists: run `bd list --json`, extract issue titles
3. Parse task IDs (T001, T002, etc.) from titles
4. Match against task IDs in current tasks.md
5. If match ratio > 50%: resume (skip conversion)
6. If match ratio <= 50% or no matches: first run for this spec (convert)

**Rationale:** Title matching is simple and robust. The 50% threshold handles cases where `.beads/` has issues from a different spec while tolerating some renamed/reworded tasks.

### 3. Tasks.md Parsing

**Task line regex pattern:**
```
^- \[([ Xx])\] (T\d{3}) (\[P\] )?(\[US\d+\] )?(.+)$
```

**Captures:**
- Group 1: Checkbox state (space = unchecked, X/x = checked)
- Group 2: Task ID (T001, T002, etc.)
- Group 3: Optional parallel marker `[P]`
- Group 4: Optional user story label `[US1]`
- Group 5: Task description (including file path)

**Phase detection:** Phase boundaries are identified by markdown headings matching:
```
^##+ .*Phase|^##+ .*Setup|^##+ .*Foundational|^##+ .*User Story|^##+ .*Polish
```

### 4. Beads Issue Creation

For each task, the `bd create` command follows this pattern:

```bash
bd create "T001 Create project structure per implementation plan" \
  -t task \
  -p <priority> \
  --json
```

**Priority mapping:**
- Setup/Foundational phase tasks: priority 1 (highest)
- User Story P1 tasks: priority 2
- User Story P2+ tasks: priority 3
- Polish tasks: priority 4

**Dependency creation:**
```bash
bd dep add <child-id> <parent-id> --type blocking
```

### 5. Sync-Back Logic

**Algorithm:**
1. Run `bd list --json` to get all issues with their status
2. For each closed issue whose title starts with a task ID (T001, T002, etc.):
   - Find matching line in tasks.md
   - Replace `- [ ]` with `- [X]`
3. For issues without matching task IDs (discovered work):
   - Collect into a list
   - Append `## Discovered During Implementation` section at end of tasks.md
   - Format: `- [X] DISCOVERED: <title>` or `- [ ] DISCOVERED: <title>`
4. Preserve all existing content, ordering, and phase structure

### 6. Discovered Work Handling (FR-012)

When the agent identifies new work during implementation (missing utility, unforeseen dependency, bug found):

1. Create a beads issue: `bd create "DISCOVERED: <description>" -t task -p 2 --json`
2. If it blocks the current task: `bd dep add <current-task-id> <discovered-id> --type blocking`
3. If it does not block: no dependency needed, it will appear in `bd ready` when its own blockers (if any) are resolved
4. Continue with the current task if not blocked, or move to the discovered task if it blocks

Discovered issues are identified during sync-back by titles starting with `DISCOVERED:` or by having no matching task ID in the original tasks.md.

### 7. Verification After Bootstrap

After creating all beads issues and dependencies (Phase 1.5.5), run a verification step:

```bash
bd dep tree <root-task-id> --json
```

Visually confirm the DAG matches the expected phase structure. Report the total number of issues created and the dependency depth. This satisfies SC-001.

### 8. Error Handling for Beads CLI Failures

**`bd` CLI not found (FR-002):**
```
Error: beads CLI (bd) is not installed.

Install beads: brew install beads
Or see: https://github.com/steveyegge/beads

Cannot proceed with --with-beads without the bd CLI.
```

**Beads initialization (FR-018):**
If `.beads/` does not exist after verifying `bd` is available, run:
```bash
bd init --quiet
```
This creates the `.beads/` directory with `beads.db`, `issues.jsonl`, and config files. The `--quiet` flag suppresses interactive prompts. This MUST happen before any `bd create` calls.

**Beads sync at session end (FR-019):**
After sync-back updates tasks.md, run:
```bash
bd sync
```
This persists all in-memory/SQLite state to the git-tracked `issues.jsonl` file. Without this step, resume detection in the next session may not find the latest issue states.

**`bd create` failure:** Stop conversion, report how many tasks were created successfully out of the total. Suggest running `bd sync` and retrying. Do not proceed to the implementation loop with a partial set of issues.

**`bd close` failure:** Report the error with the issue ID and error message. Do not mark the task as done. Continue to the next `bd ready` result. The failed close will cause the task to reappear in `bd ready` on the next iteration.

**`bd ready` failure or malformed JSON:** Stop the implementation loop. Report the raw error output. Suggest checking beads health with `bd list --json` and `bd sync`.

**`bd list` failure during resume detection or sync-back:** If `bd list --json` fails, treat as first run (skip resume) or skip sync-back (report that manual sync is needed). Never crash silently.

**Circular dependency (bd ready empty but open issues exist):**
1. Run `bd list --json` to identify all open issues
2. For each open issue, run `bd show <id> --json` to display its blockers
3. Present the dependency chain to the user
4. Ask user: (a) manually close a blocking issue to break the cycle, (b) stop and investigate

**Tasks.md parse error:** Report the specific line number, the line content, and what was expected. Suggest running `/speckit.tasks` to regenerate tasks.md in the correct format.

**Sync-back write failure:** If tasks.md cannot be written (permissions, disk), report the error and print the intended changes to stdout so the user can apply them manually. Never lose sync-back data silently.

### 9. Stale Beads Issues on Resume

When `.beads/` exists but the match ratio is <= 50% (issues from a different spec):
- Do NOT delete or modify existing beads issues
- Create new beads issues for the current tasks.md alongside the old ones
- The old issues remain in beads (they can be cleaned up manually with `bd list` and `bd close`)
- Report: "Found N existing beads issues that don't match current tasks.md. Creating new issues for current spec."

## File Changes

| File | Change Type | Description |
|------|-------------|-------------|
| `sdd/skills/implement/SKILL.md` | Modify | Add `--with-beads` conditional flow: beads bootstrap, beads execution loop, sync-back, error handling |

## Out of Scope

- Modifying `/speckit.implement` (stays unchanged)
- Creating new skills or commands
- Installing or auto-updating beads
- Modifying tasks.md format or generation (`/speckit.tasks`)
- Beads daemon management
- Multi-agent beads coordination
