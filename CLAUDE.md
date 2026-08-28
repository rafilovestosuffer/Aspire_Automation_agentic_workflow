# Aspire Automation — agentic workflow

A reference implementation of the professional Claude Code workflow: the
artifact chain, layered steering, and configuration that is tested like code.

## Commands

```bash
./evals/run.sh              # regression-test the agent configuration
./evals/run.sh <filter>     # run one case
bash -n .claude/hooks/*.sh  # syntax-check hooks after editing them
```

There is no application code here yet. When there is, its build, test, and lint
commands belong in this section — they are the first thing a session needs and
the last thing it should have to discover by reading the file tree.

## Layout

- `artifacts/` — the chain: `intent.md` → `spec.md` → `plan.md`, plus templates
- `.claude/rules/` — path-scoped constraints
- `.claude/skills/` — procedures (`/plan-change`, `/ship`)
- `.claude/hooks/` — the two things that must not depend on judgment
- `evals/` — cases that gate changes to this configuration

## Conventions

- Branch names: `claude/<topic>-<suffix>`.
- One change, one artifact chain. Start with `intent.md`, not with code.
- Commit `spec.md` and `plan.md` *before* implementing. That commit is what
  review checks the diff against.
- Never assert a check passed. Paste its output.

## Gotchas

These are the things that have actually cost time. Everything else in this file
you could work out by reading the repo.

- **Both hooks are opt-in by environment variable and do nothing by default.**
  `CLAUDE_PROTECT_TESTS=1` blocks edits to test files. `CLAUDE_ENFORCE_PLAN_SYNC=1`
  turns the plan-sync reminder into a blocking Stop hook. If a hook "isn't
  working", check the variable before debugging the script.

- **Hooks live under the `hooks` key in `.claude/settings.json`.** There is no
  standalone hooks file. A `matcher` must be a *string* (`"Edit|Write"`), never
  a JSON array — an array is a schema error that makes Claude Code reject the
  entire settings file, so every hook in it silently disappears. Tool names are
  case-sensitive and capitalized.

- **A rule in `.claude/rules/` without `paths:` frontmatter loads every session**,
  at the same priority as CLAUDE.md. It is not cheaper than pasting the text
  here — it is the same cost, just harder to find. Scope it or move it.

- **A personal skill shadows a project skill of the same name.** A `/ship` in
  `~/.claude/skills/` wins over this repo's `/ship`, silently. If a teammate
  reports different behavior from the same command, check their personal
  skills first.

- **Skill bodies are truncated from the *end* after compaction** — the first
  5,000 tokens of each survive, 25,000 total across all invoked skills, oldest
  dropped first. Put the instructions that matter at the top of a `SKILL.md`.

- **`/goal`'s evaluator cannot run commands or read files.** It judges only what
  is already visible in the transcript. `/goal tests pass` does nothing unless
  Claude actually runs the tests and the output lands in the conversation.
  Write conditions that Claude's own output can demonstrate.

- **`git status --porcelain` output is parsed by `plan-sync.sh`.** Paths with
  spaces or renames (`R old -> new`) will confuse its `awk '{print $NF}'`.
  Fine for this repo; fix it before relying on it somewhere with messier paths.

## Things Claude gets wrong here

Append when a mistake happens twice. A correction typed into chat a second time
belongs in this file instead.

- (nothing yet)
