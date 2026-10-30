function gwt --description 'create a worktree with gwt, then cd into it'
    # seed/help are pass-through: they do not create or move to a worktree.
    if test (count $argv) -gt 0; and contains -- $argv[1] seed help --help -h
        command gwt $argv
        return
    end

    set -l dest (command gwt --print-dest $argv 2>/dev/null)
    command gwt $argv
    and not contains -- -n $argv
    and not contains -- --dry-run $argv
    and test -d "$dest[1]"
    and cd $dest[1]
end
