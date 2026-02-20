# Feature Specification: Brainstorm Persistence

**Feature Branch**: `004-brainstorm-persistence`
**Created**: 2026-02-20
**Status**: Draft
**Input**: Extend the brainstorm command to create multiple brainstorm documents in `brainstorm/`. Directory created if not existent. A `00-overview.md` should be created and kept updated.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete brainstorm session produces a document (Priority: P1)

A plugin user runs `/sdd:brainstorm` and works through the full conversation flow. At session end, after the spec is created (or the user decides to park the idea), the skill writes a structured summary document to `brainstorm/NN-topic-slug.md`. The `brainstorm/` directory is created automatically if it doesn't exist.

**Why this priority**: This is the core value proposition. Without persisted documents, the feature doesn't exist.

**Independent Test**: Run `/sdd:brainstorm`, complete the conversation, confirm a numbered markdown file appears in `brainstorm/` with correct structure.

**Acceptance Scenarios**:

1. **Given** no `brainstorm/` directory exists, **When** a brainstorm session completes, **Then** the directory is created and the document is written as `brainstorm/01-topic-slug.md`
2. **Given** `brainstorm/` already contains `01-auth-system.md` and `02-comment-threading.md`, **When** a new brainstorm session completes, **Then** the new document is numbered `03-topic-slug.md`
3. **Given** a completed brainstorm session, **When** the document is written, **Then** it contains: date, status, problem framing, approaches considered, decision/outcome, and open threads sections

---

### User Story 2 - Overview index tracks all sessions (Priority: P1)

After any brainstorm document is written (or updated), the skill creates or updates `brainstorm/00-overview.md`. The overview contains a sessions index table, an open threads section aggregated from all docs, and a parked ideas section.

**Why this priority**: The overview is what makes multiple documents navigable. Without it, the user must open each file to understand the brainstorming landscape.

**Independent Test**: After two brainstorm sessions, open `00-overview.md` and verify both sessions appear in the index with correct status, and open threads from both are aggregated.

**Acceptance Scenarios**:

1. **Given** the first brainstorm session in a project, **When** the session completes, **Then** `00-overview.md` is created with one entry in the sessions table
2. **Given** an existing `00-overview.md` with two entries, **When** a third brainstorm session completes, **Then** the overview is updated (not overwritten) to include the new entry, and open threads are re-aggregated from all three documents
3. **Given** a brainstorm doc status changes from `active` to `spec-created`, **When** the overview is regenerated, **Then** the sessions table reflects the updated status and linked spec number

---

### User Story 3 - Incomplete sessions offer save choice (Priority: P2)

A user starts a brainstorm but decides to stop before creating a spec (parks the idea, abandons it, or bails early). The skill asks whether to save a brainstorm document for the session.

**Why this priority**: Prevents clutter from trivially short sessions while preserving meaningful exploration that didn't lead to a spec.

**Independent Test**: Start a brainstorm, answer two questions, then say "let's stop". Verify the skill asks whether to save, and respects the answer.

**Acceptance Scenarios**:

1. **Given** a brainstorm session that explored approaches but the user chose to park, **When** the user says to stop, **Then** the skill asks "Save this brainstorm session?" and writes the doc only if confirmed
2. **Given** a brainstorm session where the user bailed after one question, **When** the user says to stop, **Then** the skill asks "Save this brainstorm session?" with a default of not saving
3. **Given** the user confirms saving an incomplete session, **When** the document is written, **Then** the status is set to `parked` or `abandoned` as appropriate

---

### User Story 4 - Revisiting an existing topic (Priority: P2)

A user starts a brainstorm on a topic where a related brainstorm document already exists. The skill detects the overlap and asks whether to create a new document or update the existing one.

**Why this priority**: Prevents confusion from multiple unlinked documents on the same topic, while preserving the option of distinct evolution records.

**Independent Test**: Create a brainstorm about "auth system", then start another brainstorm about "auth". Verify the skill detects the existing doc and offers the choice.

**Acceptance Scenarios**:

1. **Given** `brainstorm/01-auth-system.md` exists, **When** the user starts a brainstorm about authentication, **Then** the skill asks: "An existing brainstorm on a related topic exists (01-auth-system.md). Create a new document or update the existing one?"
2. **Given** the user chooses "new document", **When** the session completes, **Then** a new file is created (e.g., `03-auth-revisited.md`) and `00-overview.md` is updated
3. **Given** the user chooses "update existing", **When** the session completes, **Then** the existing document is updated with a new dated section appended, and `00-overview.md` is refreshed

---

### Edge Cases

- **First brainstorm ever**: Both `brainstorm/` directory and `00-overview.md` are created in one operation
- **`brainstorm/` exists but `00-overview.md` is missing**: Regenerate the overview by scanning all existing `NN-*.md` files in the directory
- **Manually deleted brainstorm docs**: Next number is `max_existing + 1`, not gap-filling. If docs 01 and 03 exist, the next is 04
- **Multiple brainstorms on the same topic**: Each gets a distinct file with a differentiated slug (e.g., `01-auth-system.md`, `03-auth-revisited.md`)
- **User bails after zero meaningful interaction**: No document is created, no overview update, no prompt to save

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Brainstorm skill MUST create `brainstorm/` directory at project root if it does not exist when a brainstorm document needs to be written
- **FR-002**: Brainstorm skill MUST auto-detect the next sequential number by scanning existing `NN-*.md` files in `brainstorm/` and using `max + 1`
- **FR-003**: Brainstorm skill MUST write a structured summary document at session end containing: date, status, problem framing, approaches considered, decision/outcome, and open threads
- **FR-004**: Brainstorm skill MUST create `brainstorm/00-overview.md` if it does not exist when a brainstorm document is written
- **FR-005**: Brainstorm skill MUST update `brainstorm/00-overview.md` after every brainstorm document write or update, containing: sessions index table (number, date, topic, status, linked spec), open threads section, parked ideas section
- **FR-006**: Brainstorm skill MUST ask the user whether to save a brainstorm document when a session ends without creating a spec
- **FR-007**: Brainstorm skill MUST detect existing brainstorm documents on related topics at session start and ask the user whether to create a new document or update the existing one
- **FR-008**: Each brainstorm document MUST have a status field with one of: `active`, `parked`, `abandoned`, `spec-created`
- **FR-009**: When a brainstorm leads to a spec, the status MUST be `spec-created` with a reference to the spec number/path
- **FR-010**: Overview regeneration MUST be idempotent (re-running produces the same result)
- **FR-011**: Open threads from individual brainstorm documents MUST be aggregated into the Open Threads section of `00-overview.md`

### Key Entities

- **Brainstorm Document**: A structured markdown file (`NN-topic-slug.md`) capturing one brainstorm session's problem framing, approaches, decisions, and open threads. Has a status lifecycle: active, parked, abandoned, or spec-created.
- **Overview Index**: A single markdown file (`00-overview.md`) providing a navigable view of all brainstorm sessions, aggregated open threads, and parked ideas.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every completed brainstorm session that the user elects to save produces a document in `brainstorm/` with all required sections populated
- **SC-002**: `00-overview.md` accurately reflects the state of all brainstorm documents after any write or update operation
- **SC-003**: Open threads from across all brainstorm sessions are findable in one location (`00-overview.md`) without opening individual documents
- **SC-004**: A user returning to the project after time away can reconstruct the reasoning behind any spec by reading the linked brainstorm document(s)

## Dependencies

- Existing brainstorm skill (`sdd/skills/brainstorm/SKILL.md`) provides the conversational framework
- Spec creation flow (`/speckit.specify`) is unchanged; brainstorm persistence is additive

## Assumptions

- The brainstorm document structure is defined in the skill prompt, not as a template in `.specify/templates/`. This keeps it lightweight and avoids the overlay/trait complexity.
- Topic detection for revisits uses simple keyword matching against existing document titles, not semantic analysis.
- The skill writes the document at session end (single write), not incrementally during conversation.

## Out of Scope

- No template file in `.specify/templates/` for brainstorm documents
- No trait overlay mechanism (this is a core skill change)
- No retroactive generation of brainstorm docs from past sessions
- No cross-linking from spec back to brainstorm doc (brainstorm links forward to spec, not the reverse)
- No search or filtering of brainstorm documents beyond what the overview provides
