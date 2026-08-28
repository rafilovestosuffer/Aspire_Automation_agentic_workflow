#!/usr/bin/env bash
# Regression-test the agent configuration itself.
#
# Your .claude/ directory steers every session in this repo. It deserves the
# same regression testing your code gets. Each case in evals/cases/ is a real
# task with a check that decides pass or fail.
#
# Usage:  ./evals/run.sh            run every case
#         ./evals/run.sh naming     run cases matching "naming"
#
# Exit 0 if the pass rate meets THRESHOLD, 1 otherwise.

set -uo pipefail

THRESHOLD="${THRESHOLD:-80}"     # required pass percentage
FILTER="${1:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v claude >/dev/null || { echo "claude CLI not found on PATH"; exit 127; }

pass=0; fail=0; failed_cases=()

for case_file in "$ROOT"/evals/cases/*.md; do
  [[ -e "$case_file" ]] || { echo "No cases in evals/cases/"; exit 1; }
  name="$(basename "$case_file" .md)"
  [[ -z "$FILTER" || "$name" == *"$FILTER"* ]] || continue

  prompt="$(sed -n '/^## Prompt$/,/^## Check$/p' "$case_file" | sed '1d;$d')"
  check="$(sed -n '/^## Check$/,$p'            "$case_file" | sed '1d')"

  [[ -n "${prompt// }" ]] || { echo "SKIP $name (no ## Prompt section)"; continue; }
  [[ -n "${check// }"  ]] || { echo "SKIP $name (no ## Check section)";  continue; }

  work="$(mktemp -d)"
  git -C "$ROOT" archive HEAD | tar -x -C "$work" 2>/dev/null || cp -r "$ROOT"/. "$work"/

  output="$(cd "$work" && claude -p "$prompt" --output-format text 2>&1)"

  if (cd "$work" && OUTPUT="$output" bash -c "$check") >/dev/null 2>&1; then
    echo "PASS  $name"; pass=$((pass+1))
  else
    echo "FAIL  $name"; fail=$((fail+1)); failed_cases+=("$name")
  fi
  rm -rf "$work"
done

total=$((pass+fail))
[[ $total -gt 0 ]] || { echo "No cases ran."; exit 1; }
rate=$(( pass * 100 / total ))

echo
echo "─────────────────────────────────────"
echo "passed $pass/$total  (${rate}%)  threshold ${THRESHOLD}%"
[[ ${#failed_cases[@]} -eq 0 ]] || printf 'failed: %s\n' "${failed_cases[*]}"

[[ $rate -ge $THRESHOLD ]] || { echo "BELOW THRESHOLD"; exit 1; }
echo "OK"
