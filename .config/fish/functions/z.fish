function z --description 'zoxide jump, preferring a directory in the current git worktree'
    # zoxide always jumps to the highest-scoring path in its database, so from a
    # worktree `z console-api` lands in whichever checkout you use most
    # (zoxide#613: it has no notion of proximity). For a bare name, first look
    # for an exact directory name inside the current worktree, shallowest match
    # wins. Everything else - paths, `-`, `..`, `~`, multiple keywords - goes to
    # zoxide untouched.
    if test (count $argv) -eq 1
        and test -n "$argv[1]"
        and not string match -qr -- '^[-~/.$]' $argv[1]
        and not string match -q -- '*/*' $argv[1]
        set -l root (command git rev-parse --show-toplevel 2>/dev/null)
        if test -n "$root"
            set -l best
            # fd respects .gitignore, so build output (out/, node_modules/) is
            # skipped; -F keeps the name literal, the basename test makes it exact.
            for hit in (command fd --type dir --fixed-strings --max-depth 6 --color never -- $argv[1] $root 2>/dev/null)
                test (path basename -- $hit) = $argv[1]; or continue
                if test -z "$best"; or test (string length -- $hit) -lt (string length -- $best)
                    set best $hit
                end
            end
            if test -n "$best"
                builtin cd $best
                return
            end
        end
    end

    __zoxide_z $argv
end
