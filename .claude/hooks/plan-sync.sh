#!/usr/bin/env bash
# Stop hook: keep artifacts/plan.md honest about what was actually built.
#
# The playbook's rule is "when implementation departs from the plan, update
# plan.md in the same commit." This hook notices when source changed but the
# plan did not.
#
# Advisory by default (exit 0, message to stdout). Set CLAUDE_ENFORCE_PLAN_SYNC=1
# to block the turn instead. Claude Code overrides a Stop hook after 8
# consecutive blocks, so this cannot wedge a session permanently.

set -uo pipefail

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
[[ -f artifacts/plan.md ]] || exit 0

changed=$(git status --porcelain -- . 2>/dev/null | awk '{print $NF}')
[[ -n "$changed" ]] || exit 0

# Any change outside artifacts/ and docs/ counts as implementation work.
impl=$(printf '%s\n' "$changed" | grep -Ev '^(artifacts|docs)/' || true)
plan_touched=$(printf '%s\n' "$changed" | grep -c '^artifacts/plan\.md$' || true)

[[ -n "$impl" ]] || exit 0
[[ "$plan_touched" -eq 0 ]] || exit 0

msg="artifacts/plan.md was not updated, but these files changed:
$(printf '%s\n' "$impl" | sed 's/^/  /')

If the implementation departed from the plan, record that in plan.md now so the
next reader sees what was actually built. If it did not depart, say so and move on."

if [[ "${CLAUDE_ENFORCE_PLAN_SYNC:-0}" == "1" ]]; then
  printf '%s\n' "$msg" >&2
  exit 2
fi
printf '%s\n' "$msg"
exit 0
