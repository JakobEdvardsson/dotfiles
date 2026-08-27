function codex-personal --wraps='env CODEX_HOME="$HOME/.codex-personal" codex' --description 'alias codex-personal env CODEX_HOME="$HOME/.codex-personal" codex'
    env CODEX_HOME="$HOME/.codex-personal" codex $argv
end
