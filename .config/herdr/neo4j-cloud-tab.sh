#!/bin/sh
# Open a new Herdr tab for neo4j-cloud (bound to prefix+d).
# If the current pane is already inside a neo4j-cloud repo/worktree, open the
# tab there and start devenv. Otherwise open a shell in ~/code/neo4j-cloud.
#
# Worktrees live under ~/code/worktrees/neo4j-cloud/<slug>, so the checkout's
# basename is not the repo name. Detect the repo from the common git dir.
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

common=$(git -C "${cwd:-$PWD}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
main_root=""
[ -n "$common" ] && main_root=$(dirname "$common")

case "$(basename "${main_root:-}")" in
  neo4j-cloud*)
    toplevel=$(git -C "$cwd" rev-parse --show-toplevel)
    tab=$(herdr tab create --label devenv --focus --cwd "$toplevel")
    pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')
    herdr pane run "$pane" devenv
    ;;
  *)
    herdr tab create --label neo4j-cloud --focus --cwd "$HOME/code/neo4j-cloud" >/dev/null
    ;;
esac
