#!/bin/sh
# Create a neo4j-cloud worktree and open a Herdr workspace with
# nvim / opencode / devenv tabs. Bound to prefix+shift+t.
set -eu

repo="$HOME/code/neo4j-cloud"
base="master"

die() { printf '\nerror: %s\nPress enter to close...' "$*" >&2; read -r _; exit 1; }

printf 'Branch (new from %s, or existing): ' "$base"
read -r branch || die "no input"
[ -n "$branch" ] || die "no branch given"

cd "$repo" || die "cannot cd to $repo"

# Branch only on origin -> create a local tracking branch (gwt then attaches it).
if ! git show-ref --verify --quiet "refs/heads/$branch"; then
  if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    git fetch --quiet origin "$branch" || die "fetch failed"
    git branch --track "$branch" "origin/$branch" || die "could not track origin/$branch"
  fi
fi

dest=$(gwt --print-dest "$branch") || die "gwt --print-dest failed"
gwt --from "$base" "$branch" || die "gwt failed"

# Use just the branch's last path segment as the workspace label so the
# sidebar stays readable.
label=${branch##*/}

# If a workspace already exists for this checkout, just focus it.
existing=$(herdr pane list 2>/dev/null \
  | jq -r --arg p "$dest" '.result.panes[] | select(.cwd == $p) | .workspace_id' \
  | head -n1)
if [ -n "$existing" ]; then
  herdr workspace focus "$existing" >/dev/null
  exit 0
fi

# A standalone workspace (not worktree.open) so it is not nested under the
# parent repo workspace in the sidebar.
out=$(herdr workspace create --cwd "$dest" --label "$label" --focus) \
  || die "workspace create failed"
ws=$(printf '%s' "$out" | jq -r '.result.workspace.workspace_id // empty')
[ -n "$ws" ] || die "no workspace in response"

tab=$(printf '%s' "$out" | jq -r '.result.tab.tab_id')
pane=$(printf '%s' "$out" | jq -r '.result.root_pane.pane_id')

# Tab 1: nvim (root tab of the new workspace)
herdr tab rename "$tab" nvim >/dev/null
herdr pane run "$pane" nvim

# Tab 2: opencode
t2=$(herdr tab create --workspace "$ws" --cwd "$dest" --label opencode --no-focus)
herdr pane run "$(printf '%s' "$t2" | jq -r '.result.root_pane.pane_id')" "if test -f devenv; devenv; end; opencode"

# Tab 3: devenv (fish function; cwd is the worktree root)
t3=$(herdr tab create --workspace "$ws" --cwd "$dest" --label devenv --no-focus)
herdr pane run "$(printf '%s' "$t3" | jq -r '.result.root_pane.pane_id')" devenv
