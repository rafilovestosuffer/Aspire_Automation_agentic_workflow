# Operating guide

How to actually run this, every time. The audit says what is true; this says
what to do on Monday.

---

## The one rule

**Every stage leaves a file, and every "done" has a check behind it.**

Everything below is mechanics. If you remember nothing else: when you cannot
point at a file that says what you were trying to do, and a command that proves
you did it, you are vibe coding regardless of how good the prompt was.

---

## Adoption order

Do not build the whole setup first. It will be wrong, and you will not know
which parts. Add each piece when its trigger fires.

| Week | Do this | Why now |
|---|---|---|
| 1 | Artifact chain on one real change. `/plan-change`, then a fresh session to implement, then `/ship`. | The habit is the whole thing. The tooling is optional until the habit exists. |
| 1 | End every task with a check the agent runs and pastes. | Closes the loop that otherwise runs through your attention. |
| 2 | Move every "always"/"never" out of CLAUDE.md into a hook or a `permissions.deny` rule. Cut the rest to gotchas. | Prompted rules fail under pressure; this is the only guaranteed layer. |
| 3 | Build `~/.claude/` — your CLAUDE.md, rules, skills, agents. **Namespace them** (`my-ship`, not `ship`) so they never shadow a team skill. | Every new repo starts configured. |
| 4 | Write 5 eval cases from tasks you actually ran. Wire up CI. Grow to 20–50. | Configuration steers everything; untested configuration decays silently. |
| Monthly | `/doctor`. After major upgrades too. | Last year's necessary instruction is this year's noise. |

---

## The daily loop

**Start clean.** One session per task. `/clear` between unrelated work. A
kitchen-sink session degrades long before it hits the context limit.

**Load the intent, never your memory.** Point at `artifacts/intent.md` or the
ticket. If you are re-explaining something you explained last week, that is a
missing file, not a prompting problem.

**Explore through subagents.** "Use subagents to investigate X." Reading forty
files in your main window spends the session's remaining capacity on
orientation. The subagent reads them; you get the summary.

**Plan mode, then edit the plan.** `/plan`, iterate, `Ctrl+G` to open it in
your editor. Claude cannot touch files until you accept, so this is the window
where changing your mind is free. Commit `spec.md` and `plan.md` before writing
code — that commit is what review checks the diff against.

**Implement in a fresh session.** Clean context, written plan. With a good plan
this is usually one pass.

**Verify, then verify differently.** The agent runs the check and pastes the
output. Then `/verify` against the running app — tests passing and the app
working are different claims.

**Review adversarially.** `/ship` runs it: a subagent that sees only the diff
and the plan. Tell it to flag correctness and requirements only, everything else
labeled Optional. Then `/code-review` and `/security-review`.

**Feed back.** Second time something is flagged, it becomes a rule, not another
correction. Then an eval case, so it cannot regress.

---

## Choosing where an instruction goes

> Fact → CLAUDE.md. Constraint on certain files → path-scoped rule. Procedure →
> skill. Noisy side quest → subagent. Must happen every time → hook. Must never
> happen → hook or `permissions.deny`.

CLAUDE.md, rules, and skills are **context**: Claude reads them and then
decides. Hooks and permissions are **configuration**: they hold regardless of
what Claude decides. Under a long session, an ambiguous situation, or hostile
text in a file it reads, a prompted rule can fail. If a rule failing would
matter, it does not belong in prose.

Four symptoms you picked wrong:

1. "Always do X" in CLAUDE.md → hook. Claude *choosing* to run your formatter
   is not the formatter running.
2. "Never do X" in CLAUDE.md → hook or `permissions.deny`.
3. A 30-line procedure in CLAUDE.md → skill. CLAUDE.md is facts; skills are
   procedures.
4. A rule for `src/api/**` with no `paths:` frontmatter → it loads every
   session at CLAUDE.md priority. It is not cheaper than CLAUDE.md, just
   harder to find.

And the fifth, the one solo developers get wrong: personal preferences in a
project CLAUDE.md. Those belong in `~/.claude/`. The repo's file is for what is
true for anyone working on that repo.

---

## Making a session finish correctly without you

Pick by what should decide the next turn:

| You want | Use | Watch out for |
|---|---|---|
| Iterate until a check passes, this task only | Ask for it in the prompt | Works today, zero setup |
| A condition to hold across many turns, this session | `/goal <condition>` | The evaluator **cannot run commands or read files** |
| A standard on every session in scope | Stop hook | Overridden after 8 consecutive blocks |
| The grader not to be the worker | Verification subagent, or a workflow that cross-checks | The reviewer trap below |

`/goal` is itself a session-scoped prompt-based Stop hook, so these are not four
rungs of one ladder — they are session-scoped vs persistent, and model-judged vs
deterministic.

**Write `/goal` conditions the transcript can demonstrate.** The evaluator sees
only what Claude has already surfaced. Not `/goal the tests pass` but ``/goal
`npm test` has been run and exits 0, with the output in the transcript``. Add a
bound: "or stop after 20 turns." Run it in auto mode if you want the turns
unattended.

**For bug fixes, write the failing test first.** Reproduce the bug as a test,
confirm it fails for the right reason, commit it, *then* fix — without touching
the test. A test that existed before the fix and could not be rewritten is
proof. Set `CLAUDE_PROTECT_TESTS=1` and the hook enforces it.

**The reviewer trap.** A reviewer told to find gaps will find some even when
the work is sound — that is what you asked for. Chasing all of them produces
abstraction you do not need, defensive code, and tests for impossible states.
Constrain it to correctness and stated requirements; everything else is
Optional.

---

## Scaling out

The question is always **who holds the plan**.

| Mechanism | Plan held by | Reach for it when |
|---|---|---|
| Subagent | Claude, turn by turn | A few focused side tasks |
| Skill | Claude, following your steps | A procedure you want to watch |
| Parallel sessions / worktrees | You | Independent tasks, different files |
| Agent team | A lead agent | Long-running peers *(experimental, off by default)* |
| Dynamic workflow | **A script** | Dozens to hundreds of agents |

Workflows are generally available on paid plans — not a research preview. Only
the final answer enters your context, so the orchestration costs no model
tokens and the plan does not drift as the job grows.

Trigger one by saying "use a workflow" or typing `ultracode` in a prompt you
type yourself. `/effort ultracode` makes it a session policy — right for an
audit session, wasteful for routine edits; drop back with `/effort high`.

**Scope before you fan out.** Two prompts beat one: first ask Claude to *list*
every call site, then ask for a workflow to migrate them in parallel. Test on
one directory before the whole repo — an unscoped fan-out is the most expensive
mistake available in this tool. Limits: 16 concurrent, 1,000 per run, `medium`
default aims under 15 agents, and a "Large workflow" warning past 25 agents or
1.5M projected tokens (advisory only — it does not pause anything).

For migrations, `/batch` is often more reviewable: 5–30 units, each in its own
worktree, each opening a normal PR.

---

## Staying current

1. **Do not trust any model's memory of Claude Code, including this repo's
   docs.** `code.claude.com/docs/en/claude_code_docs_map.md` is regenerated
   automatically. Ask Claude to fetch it before answering questions about
   itself. Writing this audit found five drifted claims in a document that was
   already careful.
2. **Read the changelog, not blog posts.** Things get renamed — the workflow
   keyword became `ultracode`, `/output-style` was removed in v2.1.91.
   Community guides go stale in weeks.
3. **Run `/context` every session that feels off**, and `/doctor` monthly. If an
   instruction is not in `/context`, Claude never saw it.
4. **Pin your floor** with `requiredMinimumVersion` so organizational controls
   run on a build that was actually assessed.
5. **Keep the eval suite honest.** When a case fails after an upgrade, read it
   before lowering the threshold. That failure is the suite doing its job.

---

## Where this repo's pieces fit

| Piece | Layer | Notes |
|---|---|---|
| `CLAUDE.md` | Context, every session | 77 lines, mostly gotchas |
| `.claude/rules/artifact-chain.md` | Context, `artifacts/**` only | Path-scoped, so it costs nothing elsewhere |
| `/plan-change`, `/ship` | Procedure, on demand | `disable-model-invocation: true` — you trigger them |
| `.claude/agents/plan-reviewer.md` | Isolated context | Sees the diff and the plan, not the reasoning |
| `.claude/hooks/protect-tests.sh` | **Enforcement** | `CLAUDE_PROTECT_TESTS=1`; blocks via exit 2 |
| `.claude/hooks/plan-sync.sh` | Reminder → enforcement | `CLAUDE_ENFORCE_PLAN_SYNC=1` to block |
| `evals/` + CI | Regression gate | Fires on `CLAUDE.md` and `.claude/**` changes |

Both hooks use exit code 2 to block, with stderr as the reason. That contract is
stable and documented; the JSON `hookSpecificOutput` form has more fields but
more ways to be subtly wrong.
