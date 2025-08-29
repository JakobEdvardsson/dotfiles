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
end
