---
name: help
description: Display SDD quick reference and offer to answer questions about the workflow
---

# SDD Help

## Overview

Display a one-page quick reference for all SDD commands, then offer to answer questions.

## Execution

1. **Read the quick reference file:**
   - Read `sdd/skills/help/quick-reference.md`

2. **Display the content:**
   - Present the entire quick reference as a single, scannable page
   - Use the content as-is (it's designed to be compact)

3. **Offer to help:**
   After displaying the reference, say:

   > Any questions about the SDD workflow? I can explain any command in detail, help you choose the right one for your situation, or walk you through a specific scenario.

4. **Answer follow-up questions:**
   - If the user asks about a specific command, explain it in detail
   - If they describe a situation, recommend the appropriate command
   - If they want to try something, offer to run that command with them
   - Point them to `/sdd:tutorial` if they want a deeper introduction

## GitHub Capability Check

When users ask about PR workflows or want to create PRs:

1. **Check for GitHub MCP server first** (preferred):
   - Look for `mcp__plugin_github_github__*` tools in available tools
   - If available, use MCP tools for PR operations

2. **Fall back to gh CLI**:
   - If no GitHub MCP server, check if `gh` CLI is available: `gh --version`
   - If available, use `gh pr create` for PR operations

3. **If neither is available**:
   - Inform the user that PR creation requires either:
     - GitHub MCP server (recommended)
     - `gh` CLI tool (`brew install gh` or similar)
   - They can still create PRs manually using the branch

## Guidelines

- Keep the initial display clean and uncluttered
- Don't add explanatory text around the reference; let it speak for itself
- Be ready to go deeper on any topic if asked
- For complex questions, consider recommending the tutorial
- When discussing team workflows, mention the two-PR pattern (spec PR, then code PR)
