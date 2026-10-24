#!/bin/sh
# Open a new Herdr tab running devenv (bound to prefix+shift+a).
set -eu

cwd=$(herdr pane list | jq -r '[.result.panes[] | select(.focused)][0].cwd // empty')

tab=$(herdr tab create --label devenv --focus ${cwd:+--cwd "$cwd"})
pane=$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')

herdr pane run "$pane" devenv
