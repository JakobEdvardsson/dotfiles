#!/bin/sh
# Open a new Herdr tab running nvim (bound to prefix+n).
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

tab=$(herdr tab create --label nvim --focus ${cwd:+--cwd "$cwd"})
pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')

herdr pane run "$pane" nvim
