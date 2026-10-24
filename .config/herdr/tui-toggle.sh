#!/bin/sh
# Toggle a per-workspace TUI tab (lazygit, tuicr, ...). Bound from herdr config:
#
#   command = "sh ~/.config/herdr/tui-toggle.sh lazygit lazygit"
#   command = "sh ~/.config/herdr/tui-toggle.sh tuicr tuicr tui"
#
# Usage: tui-toggle.sh <label> <command...>
#
# Hiding (switching tabs) keeps the process alive, so its panel selection,
# scroll position, and filters survive. Quitting the app closes the tab, so the
# next press starts a clean instance.
set -eu

label="${1:-}"
[ -n "$label" ] || { printf 'usage: tui-toggle.sh <label> <command...>\n' >&2; exit 1; }
shift
[ "$#" -gt 0 ] || { printf 'usage: tui-toggle.sh <label> <command...>\n' >&2; exit 1; }
cmd="$*"

ws="${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}"
cur="${HERDR_ACTIVE_TAB_ID:-${HERDR_TAB_ID:-}}"
cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"

die() { printf 'tui-toggle: %s\n' "$*" >&2; exit 1; }

[ -n "$ws" ] || die "not running inside a herdr pane"
[ -n "$cur" ] || die "not running inside a herdr pane"

state_dir="${XDG_RUNTIME_DIR:-/tmp}/herdr-tui-toggle"
mkdir -p "$state_dir"
state="$state_dir/$ws.$label.prev"

tabs=$(herdr tab list --workspace "$ws")
tab=$(printf '%s' "$tabs" \
  | jq -r --arg label "$label" '.result.tabs[] | select(.label == $label) | .tab_id' \
  | head -n 1)

# Already looking at the app: hide it by returning to the tab we came from.
if [ -n "$tab" ] && [ "$cur" = "$tab" ]; then
  prev=$(cat "$state" 2>/dev/null || true)
  if [ -n "$prev" ] && [ "$prev" != "$tab" ] && herdr tab get "$prev" >/dev/null 2>&1; then
    herdr tab focus "$prev" >/dev/null
  else
    other=$(printf '%s' "$tabs" | jq -r --arg tab "$tab" \
      '[.result.tabs[] | select(.tab_id != $tab)] | sort_by(.number) | last | .tab_id // empty')
    [ -z "$other" ] || herdr tab focus "$other" >/dev/null
  fi
  exit 0
fi

printf '%s' "$cur" > "$state"

if [ -n "$tab" ]; then
  herdr tab focus "$tab" >/dev/null
  exit 0
fi

out=$(herdr tab create --workspace "$ws" --cwd "$cwd" --label "$label" --focus)
pane=$(printf '%s' "$out" | jq -r '.result.root_pane.pane_id // empty')
[ -n "$pane" ] || die "could not create $label tab"

herdr pane run "$pane" "$cmd; herdr tab close \"\$HERDR_TAB_ID\" >/dev/null 2>&1"
