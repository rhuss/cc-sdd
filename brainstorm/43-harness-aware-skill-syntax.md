# Brainstorm: Harness-Aware Skill Invocation Syntax

**Date:** 2026-07-25
**Status:** active

## Problem Framing

Spex keeps one shared body of skills, extension commands, help text, tutorials,
generated project guidance, and follow-up messages for multiple agent harnesses.
Those sources still contain many Claude-style slash invocations such as
`/speckit-specify`, `/speckit-spex-help`, and `/spex:init`. When the Codex
distribution presents that text, it teaches users syntax that does not invoke
the installed skills. Codex uses `$skill-name` for user-provided skills, while
its `/...` namespace is reserved for built-in controls such as `/permissions`
and `/status`.

The mismatch is broader than the help page. Literal command examples appear in
skill instructions, generated follow-up messages, tutorials, error messages,
and the managed `AGENTS.md` block. Correcting a few visible files would leave
other paths inconsistent, and duplicating every document per harness would
make the shared methodology drift.

The goal is for every harness-facing artifact and runtime message to use the
native invocation syntax of its active harness, without losing one canonical
source of workflow meaning or rewriting genuine built-in commands.

## Approaches Considered

### A: Harness-Aware Rendering from Neutral Sources

Represent invokable skills in canonical content without assuming a presentation
prefix. Render those references through the harness adapter when distributions
and project-local skills are generated. Give every Codex skill a concise
preamble rule requiring `$skill-name` in generated output, and validate the
finished Codex inventory for leaked Claude-style Spex references.

- Pros: One source of truth; correct static and generated output; explicit
  harness ownership; testable release boundary; extends naturally to OpenCode.
- Cons: Requires a complete rendering contract and inventory; migration must
  distinguish Spex skills from real built-in slash commands.

### B: Codex-Only Mechanical Post-Processing

Keep canonical Markdown Claude-oriented and replace known `/speckit-*` and
`/spex:init` patterns after Codex materialization.

- Pros: Small initial change; existing Claude content remains untouched;
  immediately fixes many visible examples.
- Cons: Canonical content remains harness-biased; new patterns can escape the
  rewrite; generated prose still needs a separate instruction; replacements
  become fragile as syntax evolves.

### C: Separate Codex Documentation and Skills

Maintain Codex-specific copies of help, tutorials, and skill instructions with
native `$...` syntax.

- Pros: Every file can be written directly for Codex; minimal rendering logic.
- Cons: Duplicates workflow semantics; corrections and feature changes must be
  synchronized; drift becomes likely across hundreds of references.

## Decision

Choose **Approach A: harness-aware rendering from neutral sources**.

Canonical Spex content will identify a skill semantically, while each harness
adapter owns how that invocation is displayed. Claude continues to receive
slash-style Spec-Kit and Spex commands. Codex receives `$skill-name`, including
`$init` for the plugin's initialization skill. Genuine Codex built-ins retain
their `/...` form. OpenCode receives no inferred syntax; its adapter must make
an explicit choice.

Static rendering alone is not sufficient because skills also compose new
follow-up messages at runtime. Every materialized Codex skill therefore receives
a durable instruction: when displaying or recommending an invokable skill,
always use `$skill-name`; never use slash syntax or internal dotted identifiers
for Codex skills.

## Key Requirements

- Apply native invocation syntax to every Codex-facing surface: installed
  skills, help, tutorials, generated `AGENTS.md`, error and recovery messages,
  summaries, and recommended next actions.
- Render `/speckit-*` equivalents as `$speckit-*` for Codex.
- Render the plugin initialization entry point as `$init` for Codex rather than
  `/spex:init`.
- Preserve genuine Codex built-in slash commands such as `/permissions`,
  `/status`, `/model`, and `/plugins`.
- Do not attempt to register custom Codex slash aliases; the supported plugin
  workflow surface is skills.
- Keep canonical workflow semantics shared. Harness-specific prefixes and
  invocation wording belong to adapters or materialization.
- Add a Codex skill preamble rule that governs dynamically generated follow-up
  messages and examples.
- Ensure rendering covers both distribution artifacts and the project-local
  skills installed by the Spec-Kit extension workflow.
- Validate materialized Codex output and fail the release if Claude-style
  `/speckit-*` or `/spex:init` references remain in user-facing content.
- Validate that Codex output does not expose internal dotted identifiers such
  as `speckit.spex.ship` as user commands.
- Preserve Claude syntax and behavior byte-for-byte except where canonical
  neutralization necessarily changes shared source representation.
- Make OpenCode invocation syntax an explicit adapter contract rather than
  assuming it matches either Claude or Codex.
- Test representative static help, skill-to-skill handoffs, validation/error
  messages, and runtime next-action recommendations for each supported harness.

## Open Questions

- What neutral source notation best identifies skill references without making
  Markdown unreadable: structured harness tokens, a compact semantic marker, or
  a generated reference helper?
- Which packaged files are user-facing and should be rendered, versus historical
  or contributor documentation that should retain literal cross-harness examples?
- Should validation use a strict allowlist of genuine built-in slash commands,
  or reject only known Spex/Spec-Kit slash patterns in Codex artifacts?
- How should code blocks that intentionally compare Claude and Codex syntax be
  marked so leakage validation recognizes them as explanatory examples?
