#!/bin/sh
# Open a new Herdr tab for neo4j-cloud (bound to prefix+d).
# If the current pane is already inside a neo4j-cloud repo/worktree, open the
# tab there and start devenv. Otherwise open a shell in ~/code/neo4j-cloud.
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

toplevel=$(git -C "${cwd:-$PWD}" rev-parse --show-toplevel 2>/dev/null || true)

case "$(basename "${toplevel:-}")" in
  neo4j-cloud*)
    tab=$(herdr tab create --label devenv --focus --cwd "$toplevel")
    pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')
    herdr pane run "$pane" devenv
    ;;
  *)
    herdr tab create --label neo4j-cloud --focus --cwd "$HOME/code/neo4j-cloud" >/dev/null
    ;;
esac
