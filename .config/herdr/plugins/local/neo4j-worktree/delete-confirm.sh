#!/bin/sh
# Runs inside the confirmation popup opened by delete-action.sh.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
wt="${WT_PATH:-}"
ws="${WT_WS:-}"

if [ -z "$wt" ]; then
  printf 'Delete worktree: missing path.\nPress enter to close.'
  read -r _
  exit 1
fi

main=$(git -C "$wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
main=${main%/.git}

printf 'Delete this worktree checkout?\n\n  %s\n\n' "$wt"
printf 'This runs: git worktree remove --force\n'
printf 'Untracked files copied by gwt (node_modules, venv, devenv.local) are deleted.\n'
printf 'The branch is kept.\n\n[y/N] '
read -r ans || ans=""
case "$ans" in
  y|Y|yes|YES) ;;
  *) printf 'Cancelled.\n'; sleep 1; exit 0 ;;
esac

if [ -z "$main" ]; then
  printf '\nCould not determine the main repository.\nPress enter to close.'
  read -r _
  exit 1
fi

if ! git -C "$main" worktree remove --force "$wt"; then
  printf '\ngit worktree remove failed.\nPress enter to close.'
  read -r _
  exit 1
fi

if [ -n "$ws" ]; then
  "$herdr" workspace close "$ws" >/dev/null 2>&1 || true
fi

printf '\nDeleted %s\n' "$wt"
sleep 1
