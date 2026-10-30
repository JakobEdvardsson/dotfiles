#!/bin/sh
# Seed a neo4j-cloud worktree with the local state git does not carry.
#
# Event payload (HERDR_PLUGIN_EVENT_JSON):
#   .data.worktree.path                   -> the new checkout
#   .data.workspace.worktree.repo_root    -> the main checkout
#
# Also used as a workspace action ("Re-seed local files"): in that mode there
# is no event payload, so the checkout comes from the plugin context JSON.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
state="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-neo4j-worktree}"
logfile="$state/log"
mkdir -p "$state"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$logfile"; }
notify() { "$herdr" notification show "neo4j-cloud worktree" --body "$*" >/dev/null 2>&1 || true; }

event="${HERDR_PLUGIN_EVENT:-}"
event_json="${HERDR_PLUGIN_EVENT_JSON:-}"
context_json="${HERDR_PLUGIN_CONTEXT_JSON:-}"

json_get() { printf '%s' "$1" | jq -r "$2 // empty" 2>/dev/null || true; }

dest=""
src=""

if [ "$event" = "worktree.created" ]; then
  dest="$(json_get "$event_json" '.data.worktree.path')"
  src="$(json_get "$event_json" '.data.workspace.worktree.repo_root')"
  branch="$(json_get "$event_json" '.data.worktree.branch')"
  mode=full
else
  # Workspace action: re-seed the current checkout.
  dest="$(json_get "$context_json" '.workspace_cwd')"
  branch=""
  mode=seed
fi

if [ -z "$dest" ]; then
  log "skip: no checkout path (event=$event)"
  exit 0
fi
if [ -z "$src" ]; then
  common="$(git -C "$dest" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  [ -n "$common" ] && src="$(dirname "$common")"
fi
if [ -z "$src" ] || [ ! -d "$src" ]; then
  log "skip: no source checkout for $dest"
  exit 0
fi

# Only operate on neo4j-cloud worktrees. Tolerate a renamed checkout root
# (e.g. neo4j-cloud-2) by matching the prefix.
src_name="$(basename "$src")"
case "$src_name" in
  neo4j-cloud*) ;;
  *) log "skip: source repo is $src_name"; exit 0 ;;
esac

# Never seed the main checkout onto itself.
git_dir="$(git -C "$dest" rev-parse --path-format=absolute --git-dir 2>/dev/null || true)"
git_common="$(git -C "$dest" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
if [ -z "$git_dir" ] || [ "$git_dir" = "$git_common" ]; then
  log "skip: not a linked worktree: $dest"
  exit 0
fi
if [ "$(realpath "$src")" = "$(realpath "$dest")" ]; then
  log "skip: source equals destination"
  exit 0
fi

gwt_bin="${GWT_BIN:-}"
if [ -z "$gwt_bin" ]; then
  if [ -x "$HOME/.local/bin/gwt" ]; then
    gwt_bin="$HOME/.local/bin/gwt"
  else
    gwt_bin="$(command -v gwt 2>/dev/null || true)"
  fi
fi

if [ "$mode" = "full" ]; then
  notify "seeding ${branch:-$dest}…"
fi
log "seed start: src=$src dest=$dest branch=${branch:-?} mode=$mode"

if [ -n "$gwt_bin" ] && [ -x "$gwt_bin" ]; then
  if "$gwt_bin" seed "$src" "$dest" >> "$logfile" 2>&1; then
    log "seed ok"
  else
    log "seed FAILED (see above)"
    notify "seeding failed; see plugin log"
  fi
else
  log "seed skipped: gwt not found"
  notify "gwt not found; worktree not seeded"
fi

log "bootstrap done: dest=$dest mode=$mode"
if [ "$mode" = "full" ]; then
  notify "worktree ready: ${branch:-$dest}"
fi
