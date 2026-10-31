# dotfiles

Omarchy (Arch + Hyprland) configuration, managed as a stow package rooted at `$HOME`.

## Install

```bash
sudo pacman -S --needed stow
cd ~/dotfiles
stow --simulate -v .   # review
stow -v .              # symlink into $HOME
```

## Layout

The repo mirrors `$HOME`, so `stow .` from the repo root links each entry into
place:

- `.config/` — Hyprland, omarchy shell, terminals, nvim, btop, tmux, etc.
- `.local/bin/` — small user scripts (mise-based agent wrappers)
- `.bashrc`, `.bash_profile`, `.XCompose`

Not tracked on purpose: browser profiles (`BraveSoftware`, `chromium`, …),
runtime state (`pulse`, `dconf`, `ibus`, `fcitx` sockets), logs, and
`.config/opencode/service.json` (local service password).

## Notes

- `~/.config` itself stays a real directory so untracked app state survives.
- Apps that rewrite config via rename (e.g. `omarchy refresh shell`) can replace
  a symlinked file with a real one. Check with `readlink` and re-run `stow` if
  needed.
- Fedora-era config lives in the `fedora` tag and `fedora-snapshot` branch.
