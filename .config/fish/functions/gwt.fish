function gwt --description 'create a worktree with gwt, then cd into it'
    set -l dest (command gwt --print-dest $argv 2>/dev/null)
    command gwt $argv
    and not contains -- -n $argv
    and not contains -- --dry-run $argv
    and test -d "$dest[1]"
    and cd $dest[1]
end
