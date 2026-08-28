---
name: my-handoff
description: Write a handoff note before ending a session or clearing context, capturing state, decisions, and traps for whoever picks this up next. Use before /clear on unfinished work, or at the end of a working session.
disable-model-invocation: true
---

# Hand off the session

Context dies at `/clear`. Anything not on disk is gone, including the reasoning
that would stop the next session repeating a dead end.

Write `HANDOFF.md` in the repo root (gitignored, or committed on a branch if
someone else picks this up). Overwrite the previous one — this is current state,
not a log.

## What goes in it

```markdown
# Handoff — <date>

## Where this stands
<One paragraph. What works now that didn't before.>

## What is left
- [ ] <Next concrete action, specific enough to start without re-reading code>

## Decisions made
- <Choice> — because <reason>. Revisit if <condition>.

## Dead ends
<What was tried and did not work, and why. This is the highest-value
section — it is the part the next session would otherwise repeat.>

## Traps
<Anything surprising: a test that must run from a specific directory, a
service that must be up, a file that regenerates.>

## Verified / not verified
Verified: <what was actually run, with the command>
Not verified: <what was assumed>
```

## Rules

- Write it from what actually happened, not from the plan. If the plan was
  abandoned, say so and say when.
- The "not verified" line is not optional. An honest gap is useful; a silent
  one is a trap.
- If a mistake happened twice this session, it does not belong in the handoff.
  It belongs in the project's CLAUDE.md, permanently. Put it there instead.
