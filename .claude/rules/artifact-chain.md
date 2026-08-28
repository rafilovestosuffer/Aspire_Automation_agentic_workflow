---
paths:
  - "artifacts/**/*.md"
---

# Working on artifact-chain files

These files are the audit trail. They are read by people who were not in the
session that produced them.

- `intent.md` is the originator's words. Do not rewrite it into spec language,
  and do not resolve its open questions silently — answer them in `spec.md`.
- `spec.md` states requirements and design against the intent. Flag concerns
  explicitly rather than designing around them without comment.
- `plan.md` must clear one bar: an engineer who never saw the conversation can
  implement the change from the plan alone. Name the files that change, the
  order of work, the risks, and the check that will prove it works.
- When implementation departs from the plan, update `plan.md` in the same
  commit. The Stop hook in `.claude/hooks/plan-sync.sh` will remind you.
- Never delete a resolved open question. Strike it and record the answer, so
  the reasoning survives.
