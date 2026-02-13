
<!-- SDD-TRAIT:sdd -->
## SDD Quality Gates for Planning

**Before generating the plan:**
1. Invoke {Skill: sdd:review-spec} to validate the spec is sound
2. If review finds critical issues, stop and fix before planning

**After the plan is generated:**
1. Run `/speckit.tasks` to generate the task breakdown
2. Invoke {Skill: sdd:review-plan} to validate coverage, task quality, and generate review-summary.md
