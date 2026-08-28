#!/usr/bin/env bash
# PreToolUse hook: refuse edits to test files while a fix is in progress.
#
# Rationale: an agent fixing code must not be able to weaken the check on that
# code. Opt in per session with CLAUDE_PROTECT_TESTS=1 so ordinary test-writing
# work is unaffected.
#
# Blocking contract: exit 2 blocks the tool call and stderr becomes the reason
# Claude sees. Exit 0 means "no opinion" and normal permission flow continues.

set -uo pipefail

[[ "${CLAUDE_PROTECT_TESTS:-0}" == "1" ]] || exit 0

input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
[[ -n "$path" ]] || exit 0

case "$path" in
  *_test.*|*_spec.*|*.test.*|*.spec.*|*/tests/*|*/test/*|*/__tests__/*|*/spec/*)
    cat >&2 <<MSG
Blocked: $path is a test file and CLAUDE_PROTECT_TESTS=1 is set for this session.

The test is the evidence that the fix works. Changing it while fixing the code
under test invalidates that evidence. Fix the source instead.

If the test itself is genuinely wrong, stop and say so rather than editing it.
To lift this deliberately, unset CLAUDE_PROTECT_TESTS and restart the session.
MSG
    exit 2
    ;;
esac
exit 0
