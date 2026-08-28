#!/usr/bin/env bash
# Install the personal Claude Code layer into ~/.claude/.
#
# This is the layer that follows you into every repository on this machine, so
# it is installed conservatively:
#
#   - Nothing is overwritten. An existing file is left alone and reported.
#   - --force overwrites, but backs up to <file>.bak-<timestamp> first.
#   - settings.json is never modified. If one exists, the suggested keys are
#     printed for you to merge by hand.
#   - Skills are namespaced my-* so they can never shadow a project skill of
#     the same name. Personal skills win over project skills silently, which is
#     a good way to override your team's policy without noticing.
#
# Usage:  ./install.sh              install, skipping anything that exists
#         ./install.sh --force      overwrite, keeping timestamped backups
#         ./install.sh --dry-run    show what would happen, change nothing

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"

FORCE=0; DRY=0
for arg in "$@"; do
  case "$arg" in
    --force)   FORCE=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

installed=0; skipped=0; backed_up=0

say() { printf '%s\n' "$*"; }

place() {            # place <relative path>
  local rel="$1" from="$SRC/$1" to="$DEST/$1"
  [[ -f "$from" ]] || { say "  missing in source: $rel"; return; }

  if [[ -e "$to" ]]; then
    if [[ "$FORCE" -eq 0 ]]; then
      say "  skip     $rel  (exists — use --force to replace)"
      skipped=$((skipped+1)); return
    fi
    if [[ "$DRY" -eq 0 ]]; then
      cp "$to" "$to.bak-$STAMP"
    fi
    say "  backup   $rel -> $rel.bak-$STAMP"
    backed_up=$((backed_up+1))
  fi

  if [[ "$DRY" -eq 0 ]]; then
    mkdir -p "$(dirname "$to")"
    cp "$from" "$to"
  fi
  say "  install  $rel"
  installed=$((installed+1))
}

say "Installing personal layer into $DEST"
[[ "$DRY" -eq 1 ]] && say "(dry run — nothing will be written)"
say ""

place "CLAUDE.md"
place "skills/my-bugfix/SKILL.md"
place "skills/my-handoff/SKILL.md"
place "agents/verifier.md"

say ""
say "installed $installed · skipped $skipped · backed up $backed_up"

# settings.json is yours. Never touch it; suggest instead.
if [[ -e "$DEST/settings.json" ]]; then
  say ""
  say "$DEST/settings.json already exists and was NOT modified."
  say "If you want the read-only allowlist, merge these into its permissions.allow:"
  say ""
  say '    "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",'
  say '    "Bash(ls:*)", "Bash(cat:*)", "Bash(rg:*)", "Bash(find:*)"'
  say ""
  say "Run /permissions in a session to see what is already in effect."
else
  say ""
  say "No $DEST/settings.json found. Create one with /permissions in a session,"
  say "or start from the project settings in this repo's .claude/settings.json."
fi

say ""
say "Verify with:  claude  then  /context  and  /skills"
say "Skills appear as /my-bugfix and /my-handoff."
