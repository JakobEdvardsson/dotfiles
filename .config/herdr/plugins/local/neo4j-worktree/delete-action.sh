#!/bin/sh
# Invoked from the Spaces context menu (contexts = ["workspace"]).
# Opens a confirmation popup for deleting the workspace's git worktree.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
ws="${HERDR_WORKSPACE_ID:-}"
cwd=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-{\}}" | jq -r '.workspace_cwd // empty')

if [ -z "$cwd" ] && [ -n "$ws" ]; then
  cwd=$("$herdr" pane list --workspace "$ws" 2>/dev/null \
    | jq -r '.result.panes[0].cwd // empty')
fi

if [ -z "$cwd" ] || [ "$(git -C "$cwd" rev-parse --is-inside-work-tree 2>/dev/null || true)" != "true" ]; then
  "$herdr" notification show "Delete worktree" --body "Not a git worktree: ${cwd:-unknown}" >/dev/null 2>&1 || true
  exit 0
fi

git_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-dir 2>/dev/null || true)
git_common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
if [ -z "$git_dir" ] || [ "$git_dir" = "$git_common" ]; then
  "$herdr" notification show "Delete worktree" --body "Not a linked worktree: $cwd" >/dev/null 2>&1 || true
  exit 0
fi

"$herdr" plugin pane open --plugin local.neo4j-worktree --entrypoint confirm-delete \
  --env "WT_PATH=$cwd" --env "WT_WS=$ws" >/dev/null 2>&1 \
  || "$herdr" notification show "Delete worktree" --body "Could not open confirmation" >/dev/null 2>&1 \
  || true
