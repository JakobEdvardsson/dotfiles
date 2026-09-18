function __gwt_branches
    git for-each-ref --format='%(refname:short)%09%(if)%(worktreepath)%(then)%(worktreepath)%(end)' refs/heads 2>/dev/null
end

function __gwt_needs_branch
    set -l tokens (commandline -opc | string match -rv '^-.*')
    test (count $tokens) -eq 1
end

complete -c gwt -f
complete -c gwt -s n -l dry-run -d 'Print what would be copied without creating anything'
complete -c gwt -s h -l help -d 'Show usage'
complete -c gwt -l from -r -d 'Base the new branch on this ref (default: HEAD)' -a '(__gwt_branches)'
complete -c gwt -n '__gwt_needs_branch' -a '(__gwt_branches)' -d 'Branch'
