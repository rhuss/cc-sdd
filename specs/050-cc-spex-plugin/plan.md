# Implementation Plan: Thin cc-spex Plugin

Use the standard Codex plugin and marketplace scaffold. Bundle one init skill
and one bootstrap script. During development it uses the checkout; otherwise it
shallow-clones the canonical repository temporarily and executes `spex/setup.yml`.

Lifecycle hooks are deferred until a workflow feature needs them. Discovery
therefore stays independent from enforcement machinery.
