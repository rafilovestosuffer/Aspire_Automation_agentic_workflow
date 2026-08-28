# Audit: "The Professional Claude Code Workflow"

Verification of every substantive claim in the source document against the live
Claude Code documentation and Anthropic's engineering posts, checked 2026-08-28.

**Verdict: the document is accurate.** Every headline claim holds, most of them
verbatim. Five items need correction, one attribution cannot be verified, and
there are several substantive gaps. Nothing found here changes the document's
central argument.

---

## 1. Confirmed, quote-for-quote

| Claim | Status |
|---|---|
| "Removed over 80% of Claude Code's system prompt … with no measurable loss on our coding evaluations" | Exact quote, for Opus 5 and Fable 5 |
| Conflicting instructions inside one request, seen in internal transcripts | Exact — the post cites `"leave documentation as appropriate"` vs `"DO NOT add comments"` |
| The multi-line-comment rule replaced with "match the surrounding code" | Exact, both old and new wording |
| Artifact chain: `intent.md` → `spec.md` → `plan.md` → diff+tests → PR → incident | Confirmed; six stages |
| The `plan.md` bar: "an engineer who has never seen the conversation could implement the change from the plan alone" | Exact |
| A hook to keep `plan.md` and the implementation in sync | Exact: "Consider using a hook to enforce synchronization between the two" |
| "Build is no longer the constraint — the human-speed steps around it are" | Exact |
| CLAUDE.md under 200 lines; longer files "consume more context and reduce adherence" | Exact |
| The four wrong-layer symptoms (always→hook, never→hook/permission, 30-line procedure→skill, unscoped rule) | All four confirmed |
| Verification ladder: prompt → `/goal` → Stop hook → second model | Confirmed, in that order |
| Stop hook overridden after 8 consecutive blocks | Confirmed |
| The adversarial-reviewer over-engineering warning | Near-verbatim |
| Workflows: 16 concurrent, 1,000 total, `medium` default (<15), 25-agent / 1.5M-token advisory warning | All exact |
| `ultracode` keyword; `/effort ultracode` = xhigh + auto-orchestration; keyword renamed from `workflow` | Confirmed |
| `/batch` splits into 5–30 units, each in a worktree, each opening a PR | Exact |
| `/doctor`: unused skills/MCP/plugins vs context cost, slow hooks, CLAUDE.md dedup and trim, migration into skills, asks before changing | **All confirmed** — the full list is in the commands reference, not the debugging page |
| CI eval suite: 20–50 real tasks, `claude -p`, gate config changes on pass rate, incidents become permanent cases | Exact, including "A skill change that drops the pass rate gets reviewed before it merges" |
| Agent teams experimental and off by default | Confirmed |

The compaction column of the layer table is right, and the docs are more
specific than the document is: project-root CLAUDE.md and unscoped rules are
re-injected from disk; `paths:` rules and nested CLAUDE.md reload when a
matching file is read; output styles and the system prompt are untouched
because they were never in message history.

---

## 2. Corrections

### 2.1 Dynamic workflows are not a research preview

The document advises against building "load-bearing infrastructure on research
previews" and names dynamic workflows as one. They are generally available on
all paid plans (v2.1.154+), on the Anthropic API, Bedrock, Google Cloud, and
Microsoft Foundry. Pro accounts enable them from `/config`. `/deep-research`
ships bundled.

The caution is still right, but it applies to **agent view** (`claude agents`),
which is the research preview, and to **agent teams**, which are experimental
and disabled by default.

### 2.2 Rungs 2 and 3 are the same mechanism, not an escalation

`/goal` is documented as "a wrapper around a session-scoped prompt-based Stop
hook." So the ladder's middle rungs are not increasing strength — they are two
axes:

|  | `/goal` | Stop hook in settings |
|---|---|---|
| Scope | One session | Every session in scope |
| Check | A small fast model judges the condition | Your script decides |
| Set by | Typing a sentence | Editing a settings file |

Choose `/goal` for a condition specific to today's task, a Stop hook for a
standard that should hold on every session. They are not steps 2 and 3 of one
progression.

### 2.3 The `/goal` evaluator cannot run anything

The single most consequential omission. The evaluator "doesn't run commands or
read files independently" — it judges only what Claude has already surfaced in
the transcript.

`/goal all tests pass` therefore does nothing on its own. The condition must be
something Claude's own output can demonstrate, which means Claude has to
actually run the tests and let the result land in the conversation. Write
conditions with the check stated: `` /goal `npm test` exits 0 and the output is
in the transcript ``. Conditions cap at 4,000 characters, and a turn/time clause
("or stop after 20 turns") is how you bound the run.

### 2.4 An output style does not necessarily replace the coding instructions

The document says an output style "*replaces* the default coding instructions"
and should be reserved for "big role changes only." Half right: that is the
default, but `keep-coding-instructions: true` in the frontmatter keeps them.

So a style that changes only voice or format — always lead with a diagram, always
answer concisely — while leaving engineering behavior intact is a perfectly
ordinary use, not a big role change. There is also now a built-in **Concise**
style (v2.1.237+). Note that `/output-style` was removed in v2.1.91; use
`/config` or the `outputStyle` setting.

### 2.5 One row of the then/now table drifted

The document renders row four as "Repeat instructions in multiple places → Say
it once, in the right place." The post's actual row is "Repeat yourself →
Simple tool descriptions." The document's version is a reasonable gloss on the
first half but attaches the wrong second half; the original is about tool
description design, not instruction placement.

### 2.6 Unverified attribution

The line *"a skill makes violations rare; a hook makes them close to
impossible"* is presented as Anthropic's framing worth memorizing. The meaning
is documented — "Claude will follow the instruction most of the time, but …
the model can fail to follow a prompted rule … A real guardrail needs to be
deterministic, and the enforcement methods are hooks and permissions" — but
that sentence is a paraphrase, not a quote.

Likewise, the CLAUDE.md section titled **"Things Claude gets wrong"** is
described as "the best CLAUDE.md section I have seen in the official material."
No such section exists in the documentation or in the three posts. The
*practice* is documented — "Claude makes the same mistake a second time" is
listed as a trigger to add to CLAUDE.md — so the advice is sound. It should be
marked `[JUDGMENT]`, not `[DOC]`.

---

## 3. Gaps worth closing

**`/verify` is missing entirely.** Best practices explicitly says to run it
after Claude's own check passes, to confirm the change against the running app.
Tests passing and the app working are different claims. Related:
`/run-skill-generator` records a per-project run recipe into
`.claude/skills/run-<name>/` so every later session and agent uses the same
steps instead of rediscovering them. Since v2.1.215 `/verify` runs only when
you invoke it.

**Personal skills shadow project skills.** With a `deploy` skill in both
`~/.claude/skills/` and the project's `.claude/skills/`, `/deploy` runs the
personal one. The document's advice to build a strong `~/.claude/` layer is
good, but a name collision silently overrides the team's version — a real
hazard for the "policy as skills" idea. A project skill named `code-review`
also replaces the bundled one, and the `/review` alias then never runs yours.

**Compaction numbers for skills.** Re-injected skill bodies keep the first
5,000 tokens each, 25,000 total, oldest dropped first. Truncation keeps the
*start* of the file — so put the instructions that matter at the top of every
`SKILL.md`. The document has the mechanism but not the actionable consequence.

**The plan survives compaction.** A plan written in plan mode is re-injected
from disk, like project-root CLAUDE.md. Files Claude read are not: only the
five most recently modified come back, and anything over 5,000 tokens returns
as a path reference without content. This *strengthens* the artifact-chain
argument — disk survives, conversation does not.

**Auto memory goes unexplained.** It appears once in the then/now table and
never again, but it is on by default and writes to
`~/.claude/projects/<project>/memory/`. `MEMORY.md` loads the first 200 lines
or 25KB every session. It is machine-local and not in version control, which is
in direct tension with "every stage leaves a committed artifact" — auto memory
is the one steering surface a teammate cannot see. Worth an explicit decision
rather than silence.

**The debugging layer is absent.** `/doctor` monthly is good advice, but the
per-session habit is `/context` — it is the only way to confirm what actually
loaded. Also `/status` (which settings sources are live), `/debug`,
`claude --safe-mode` (disables all customization to isolate a problem), and the
`InstructionsLoaded` hook for logging exactly which instruction files loaded and
why.

**Hook configuration traps**, none of which are in the document and all of which
fail silently: hooks go under the `hooks` key in `settings.json` and nowhere
else; `matcher` must be a string, and an array is a schema error that makes
Claude Code reject the entire settings file; matching is case-sensitive on
capitalized tool names; `,` as a separator only works from v2.1.191.

**Smaller items.** Claude Code skips a CLAUDE.md over 4 MiB entirely.
`claudeMdExcludes` skips other teams' files in a monorepo. `/effort` also has
`max`. `/code-review` takes a level, `--fix`, `--comment`, and an `ultra` cloud
mode. `/review` is a live alias for it, not merely a historical name.

---

## 4. What survives all of this

The two corrections in Part 0 are both sound, and they are the load-bearing
claims. The system prompt really did get 80% smaller. The professional/vibe
distinction really does rest on committed artifacts and runnable checks rather
than on prompt sophistication.

The document's weakest sections are its attributions — a paraphrase presented
as a quotation, a section title that does not exist — not its engineering. Its
strongest and least-practiced recommendation is the CI eval suite, which is
documented, specified down to the task count, and almost nobody does.

## Sources

Documentation (`code.claude.com/docs/en/`): `best-practices`, `memory`,
`features-overview`, `workflows`, `skills`, `goal`, `hooks`, `commands`,
`output-styles`, `context-window`, `debug-your-config`,
`claude_code_docs_map.md`.

Posts: [The AI-native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) ·
[The new rules of context engineering](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models) ·
[Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)
