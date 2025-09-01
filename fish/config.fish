set -gx EDITOR nvim
set -gx ZELLIJ_AUTO_ATTACH true

if status is-interactive
    eval (zellij setup --generate-auto-start fish | string collect)

    zoxide init fish | source

    # Aliases
    alias cat 'bat --style plain --pager never'
    alias cd z
    alias cp 'cp -i'
    alias cpp 'cp -R'
    alias df 'df -h'
    alias du 'du -ch'
    alias free 'free -m'
    alias ga 'git add'
    alias gc 'git commit'
    alias gca 'git commit --amend'
    alias gco 'git checkout'
    alias gd 'git diff'
    alias gdc 'git diff --cached'
    alias gdpr 'gh pr create --draft'
    alias gir 'git rebase -i'
    alias gl 'git log --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
    alias gpr 'gh pr create'
    alias gs 'git status'
    alias k kubectl

    alias ls 'lsd --group-dirs=first -g'
    alias l 'lsd --group-dirs=first -g -l -F --git --icon=always'
    alias ll 'lsd --group-dirs=first -g -l -F --git --icon=always'
    alias la 'lsd --group-dirs=first -g -l -a -h -i -S --date=+%Y-%m-%d\ %H:%M --git --icon=always'
    alias lt 'lsd --group-directories-first -g --tree'
    alias tree 'lsd --tree'
    alias lsblk 'lsblk -o name,mountpoint,label,size,type,uuid'
    alias mkdir 'mkdir -pv'
    alias mux 'tmux a'
    alias mv 'mv -i'
    alias pull 'git pull'
    alias push 'git push'
    alias rmm 'rm -rvI'
    alias tempty trash-empty
    alias tl trash-list
    alias tp trash-put

    # TokyoNight Color Palette
    set -l foreground c8d3f5
    set -l selection 2d3f76
    set -l comment 636da6
    set -l red ff757f
    set -l orange ff966c
    set -l yellow ffc777
    set -l green c3e88d
    set -l purple fca7ea
    set -l cyan 86e1fc
    set -l pink c099ff

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan
    set -g fish_color_keyword $pink
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_option $pink
    set -g fish_color_error $red
    set -g fish_color_param $purple
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $pink
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
    set -g fish_pager_color_selected_background --background=$selection

end
