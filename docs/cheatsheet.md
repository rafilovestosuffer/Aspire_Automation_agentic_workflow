# Cheat sheet

What to type, in order. The [operating guide](operating-guide.md) explains why;
this is the reference you keep open.

---

## Starting a piece of work

```bash
claude                       # one session per task, always
/plan                        # or Shift+Tab until "plan mode on"
```

| Situation | Do this |
|---|---|
| Change is one sentence to describe | Skip planning. Just ask. |
| Touches several files, or unfamiliar code | Plan mode, then `/plan-change` |
| You don't know what you want yet | `Interview me using AskUserQuestion, then write a spec` |
| Big investigation needed first | `Use subagents to investigate X` |

In plan mode: `Ctrl+G` opens the plan in your editor. Edit it there. Accepting a
plan you haven't read is how a bad plan becomes a bad day.

Then commit `spec.md` and `plan.md` **before** any code, `/clear`, and implement
in a fresh session.

---

## While working

| Key / command | When |
|---|---|
| `Esc` | Stop it mid-action. Context is kept, so redirect immediately. |
| `Esc Esc` or `/rewind` | Restore code or conversation to a checkpoint |
| `/clear` | Switching tasks. Also after two failed corrections. |
| `/compact <focus>` | Long single task worth continuing — `/compact focus on the auth bug` |
| `/context` | Anything feels off. Shows what actually loaded. |
| `/btw <question>` | Side question that shouldn't enter the conversation |

**The two-correction rule.** Corrected the same thing twice? Stop. The context
is now polluted with failed approaches. `/clear` and write a better opening
prompt with what you just learned. A clean session with a good prompt beats a
long one carrying wreckage.

---

## Finishing

```bash
/ship                        # checks, adversarial review, /code-review, /security-review
/verify                      # confirm against the running app, not just the tests
```

Never accept "done" without pasted output. If you can't verify it, don't ship it.

---

## Walking away mid-run

```bash
/goal `npm test` has been run and exits 0, with the output in the transcript
```

Write the condition so the **transcript** can demonstrate it — the evaluator
cannot run commands or read files. Add a bound: `or stop after 20 turns`.
Run in auto mode for unattended turns. `/goal clear` to cancel.

For a standard that should hold in *every* session, use a Stop hook instead.

---

## Bug fixes

```bash
/my-bugfix                   # failing test first, committed, then the fix
export CLAUDE_PROTECT_TESTS=1
```

A test written after the fix proves self-consistency. A test that existed before
it, and couldn't be rewritten, proves the bug is gone.

---

## Going wide

| Job | Reach for |
|---|---|
| A few focused side tasks | `Use subagents to...` |
| Independent tasks, different files | Separate sessions or worktrees |
| Large migration you want as reviewable PRs | `/batch <instruction>` — 5–30 units, one PR each |
| Audit, cross-checked findings, hundreds of files | `ultracode: <task>` or "use a workflow" |
| A whole session of audit work | `/effort ultracode`, back to `/effort high` after |

**Scope before you fan out.** Two prompts beat one: first `list every call site`,
then `use a workflow to migrate each in parallel`. Test on one directory before
the repo. An unscoped fan-out is the most expensive mistake available here.

---

## Ending a session

```bash
/my-handoff                  # state, decisions, dead ends, traps
```

Then ask the real question: **did anything go wrong twice today?** If so it is
not a handoff note — it is a missing rule. Put it in the layer that fits and it
never happens again.

---

## When something isn't working

| Symptom | First check |
|---|---|
| Instruction ignored | `/context` — if it isn't listed, Claude never saw it |
| Hook not firing | The env var. Then `/hooks`. Then the `matcher` is a string, not an array. |
| Skill behaves differently than a teammate's | `~/.claude/skills/` shadows the project's, silently |
| Settings key ignored | `settings.local.json` overrides `settings.json` |
| No idea | `claude --safe-mode` disables all customization. Problem gone? It's yours. |

Monthly: `/doctor`. After major upgrades too.

---

## Where an instruction belongs

> Fact → `CLAUDE.md` · Constraint on certain files → path-scoped rule ·
> Procedure → skill · Noisy side quest → subagent ·
> Must happen every time → hook · Must never happen → hook or `permissions.deny`

Context is read and then judged. Configuration holds regardless. If a rule
failing would matter, it doesn't belong in prose.
