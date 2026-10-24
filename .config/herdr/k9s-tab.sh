#!/bin/sh
# Open a new Herdr tab running k9s (bound to prefix+k).
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

tab=$(herdr tab create --label k9s --focus ${cwd:+--cwd "$cwd"})
pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')

herdr pane run "$pane" k9s
