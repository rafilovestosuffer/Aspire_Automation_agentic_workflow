# Aspire Automation — agentic workflow

A working reference implementation of the professional Claude Code workflow:
the artifact chain, layered steering, and agent configuration that is
regression-tested like code.

## Start here

| Document | What it is |
|---|---|
| **[docs/workflow-audit.md](docs/workflow-audit.md)** | Verification of the source workflow document against the live Claude Code docs (checked 2026-08-28). What holds, five corrections, and the gaps. |
| **[docs/cheatsheet.md](docs/cheatsheet.md)** | What to type, in order. The one-page daily reference. |
| **[docs/operating-guide.md](docs/operating-guide.md)** | How to actually run this — adoption order, the daily loop, choosing where an instruction goes, finishing a session without supervision. |
| **[CLAUDE.md](CLAUDE.md)** | The project's own instructions. 77 lines, mostly gotchas. |
| **[REVIEW.md](REVIEW.md)** | The review passes every PR gets, and what counts as blocking. |

## The idea in one line

Every stage leaves a committed file, and every claim of "done" has a check
behind it. The chain of commits is the audit trail.

```
intent.md  →  spec.md  →  plan.md  →  diff + tests  →  PR + review  →  incident
   ↑                                                                       │
   └───────────────────────────────────────────────────────────────────────┘
```

## Layout

```
CLAUDE.md                     facts and gotchas, loaded every session
REVIEW.md                     what review checks, and what blocks a merge
artifacts/                    the chain, plus templates for each stage
docs/                         the audit and the operating guide
.claude/
  settings.json               permissions + hook registration
  hooks/                      the two things that must not depend on judgment
  rules/                      path-scoped constraints
  skills/                     /plan-change and /ship
  agents/                     plan-reviewer, runs in isolated context
evals/                        cases that gate changes to this configuration
  run.sh                      claude -p harness, exits non-zero below threshold
setup/personal-layer/         the ~/.claude/ layer that follows you everywhere
  install.sh                  never clobbers; backs up on --force
.github/workflows/            runs the suite when CLAUDE.md or .claude/** changes
```

## Using it

```bash
# Plan a change: writes spec.md and plan.md, commits them before any code
/plan-change

# Implement in a fresh session, then run the full pre-merge gate
/ship

# Regression-test the configuration itself
./evals/run.sh
```

Both hooks are **opt-in and do nothing by default**:

```bash
export CLAUDE_PROTECT_TESTS=1       # refuse edits to test files during a fix
export CLAUDE_ENFORCE_PLAN_SYNC=1   # block a turn if plan.md drifted from the code
```

Install the personal layer once per machine — it follows you into every repo:

```bash
./setup/personal-layer/install.sh --dry-run   # see what it would do
./setup/personal-layer/install.sh             # skips anything that exists
```

It adds `/my-bugfix`, `/my-handoff`, a `verifier` subagent, and a short personal
`CLAUDE.md`. Skills are namespaced `my-*` on purpose: a personal skill silently
shadows a project skill of the same name, which is an easy way to override your
team's policy without noticing.

Adapt before adopting. The eval cases and the permission allowlist assume an
`npm` project; change them to match your stack.
