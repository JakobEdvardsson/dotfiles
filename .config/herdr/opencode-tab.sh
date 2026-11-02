#!/bin/sh
# Open a new Herdr tab running opencode (bound to prefix+o).
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

tab=$(herdr tab create --label opencode --focus ${cwd:+--cwd "$cwd"})
pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')

herdr pane run "$pane" opencode
