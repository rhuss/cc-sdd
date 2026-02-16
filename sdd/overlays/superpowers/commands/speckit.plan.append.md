
<!-- SDD-TRAIT:superpowers -->
## SDD Quality Gates for Planning

**Before generating the plan:**
1. Invoke {Skill: sdd:review-spec} to validate the spec is sound
2. If review finds critical issues, stop and fix before planning

**After the plan is generated:**
1. Run `/speckit.tasks` to generate the task breakdown
2. Invoke {Skill: sdd:review-plan} to validate coverage, task quality, and generate review-summary.md
3. Commit spec artifacts (spec.md, plan.md, tasks.md, review-summary.md) to the feature branch
4. **Ask the user** before creating a spec PR. Do NOT create a PR automatically.
   - If approved, proceed with:
   - Target remote: `upstream` if configured, otherwise `origin`
   - PR title: feature name from spec
   - PR body: summarize the feature, then direct reviewers to review-summary.md
     in the spec directory for detailed review guidance
