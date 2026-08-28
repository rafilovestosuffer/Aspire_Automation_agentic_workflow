# Review passes

Every PR gets the same passes. The point is that review is identical regardless
of who opened the PR, and that a human's attention goes to intent and risk
rather than to things a machine already checked.

## Machine passes (run before requesting human review)

| Pass | Command | Blocks merge |
|---|---|---|
| Correctness | `/code-review` | Yes, for correctness findings |
| Security | `/security-review` | Yes |
| Plan conformance | `plan-reviewer` subagent vs `artifacts/plan.md` | Yes, for unimplemented requirements |
| App verification | `/verify` | Yes, when the change is user-visible |
| Config regression | `./evals/run.sh` | Yes, when `CLAUDE.md` or `.claude/**` changed |

## What counts as a blocking finding

Blocking:
- Wrong behavior for inputs the change is supposed to handle
- A requirement in `spec.md` that is not implemented
- A security issue: injection, authz gap, secret in code, unsafe data handling
- A check named in `plan.md` that does not exist or does not run

Not blocking, and should be labeled "Optional":
- Style preferences the linter does not enforce
- Refactors the change did not require
- Defensive code for states that cannot occur
- Tests for impossible cases

A reviewer asked to find gaps will find some even when the work is sound. That
is what it was asked to do. Chasing every finding produces over-engineering, so
the "Optional" heading is not a courtesy — it is the mechanism that keeps
review from inflating the diff.

## What the human reviews

Intent and risk. Specifically:

1. Does `intent.md` describe a problem worth solving?
2. Does `spec.md` solve *that* problem, and is its "out of scope" honest?
3. Is the blast radius what the plan said it would be?
4. Is the proof convincing — did the check actually run, and is its output attached?

The mechanical evidence is already attached by the time a human looks. If you
find yourself reviewing syntax, a machine pass is missing.

## Feeding findings back

The second time a review pass flags the same class of problem, it stops being a
review finding and becomes a missing rule. Put it in the layer that fits:

- A fact about this repo → `CLAUDE.md`
- A constraint on certain files → a path-scoped rule in `.claude/rules/`
- A procedure → a skill in `.claude/skills/`
- Something that must happen every time → a hook
- Something that must never happen → a hook or a `permissions.deny` rule

Then add an eval case so the fix cannot silently regress.
