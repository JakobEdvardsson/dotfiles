function review --description 'Check out a PR at its head in a seeded worktree and review it in tuicr'
    set -l target $argv[1]
    if test -z "$target"
        echo "usage: review <pr-number|pr-url|branch> [tuicr args...]" >&2
        return 2
    end
    set -l extra $argv[2..-1]

    set -l top (git rev-parse --show-toplevel 2>/dev/null); or begin
        echo "review: not inside a git repo" >&2
        return 1
    end

    # Primary checkout, even when called from a linked worktree or a subdir.
    set -l common (git -C $top rev-parse --path-format=absolute --git-common-dir)
    set -l main_top (path dirname $common)
    set -l repo (path basename $main_top)

    # A branch, a PR number, and a PR URL all resolve here.
    set -l n (gh pr view $target --json number -q .number 2>/dev/null); or begin
        echo "review: no PR matches '$target'" >&2
        return 1
    end

    set -l wt $HOME/code/worktrees/$repo/pr-$n

    if not test -d $wt
        git worktree add --detach --quiet $wt; or return 1

        # Check out the PR head inside the new worktree so gh handles fork
        # remotes and never touches the checkout we were called from.
        set -l prev $PWD
        cd $wt; or return 1
        gh pr checkout $n --detach --force
        set -l rc $status
        cd $prev
        if test $rc -ne 0
            git worktree remove --force $wt
            return $rc
        end

        # Copy the local state git does not carry (venv, devenv.local,
        # node_modules) so the editor and tests work without a rebuild.
        gwt seed $top $wt; or return 1
    else if git -C $wt diff --quiet; and git -C $wt diff --cached --quiet
        # Clean review worktree: refresh it to the current PR head. A dirty one
        # keeps its contents so in-progress notes or edits survive a re-run.
        git -C $wt fetch --quiet origin "+pull/$n/head:refs/review/pr-$n"
        and git -C $wt checkout --detach --quiet refs/review/pr-$n
    end

    cd $wt; or return 1
    echo "review: $(git rev-parse --short HEAD) in $wt"
    tuicr pr $n $extra
end
