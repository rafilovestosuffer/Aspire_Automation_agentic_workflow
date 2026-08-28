---
name: ship
description: Run the full pre-merge gate on a change - checks, adversarial review against the plan, and the review passes in REVIEW.md. Use before opening a PR or calling work done.
disable-model-invocation: true
---

# Ship a change

Run these in order. Paste real output at each step; do not assert that a step
passed.

## 1. Run the project's own checks

Run the commands in CLAUDE.md under "Commands". Fix what fails. Show the output.

## 2. Adversarial review against the plan

Spawn a reviewer that sees only the diff and the plan, not the reasoning that
produced the change:

> Use a subagent to review the current diff against artifacts/plan.md. Check
> that every requirement is implemented, that the listed risks are addressed,
> and that nothing outside the plan's scope changed. Flag only gaps that affect
> correctness or the stated requirements. Style preferences are optional and
> should be labeled as such.

The last sentence matters. A reviewer told to find gaps will find some even
when the work is sound; chasing all of them produces over-engineering.

## 3. Run the standard passes

Run `/code-review` and `/security-review`. Apply the findings that affect
correctness. For each finding you decline, say why in one line.

## 4. Verify against the running app

Run `/verify` to confirm the change works in the real app, not only in tests.

## 5. Reconcile the plan

If the implementation departed from `artifacts/plan.md`, update the plan in the
same commit so the artifact chain stays honest.

## 6. Feed the lesson back

If a review pass flagged something for the second time, it is no longer a
review finding — it is a missing rule. Add it to CLAUDE.md, a path-scoped rule,
or a hook, whichever layer fits. Say which one you chose and why.
