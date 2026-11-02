# Working in this dotfiles repo

This repository is the source of truth for the user's home-directory config. It
is a GNU Stow package rooted at `$HOME`; paths in the repo mirror their final
locations under the home directory. Edit files here, not through `~` symlinks.

## Before changing things

- Read the relevant config and nearby documentation first.
- Check `git status --short` and preserve unrelated worktree changes.
- Keep secrets, runtime state, logs, and local app data out of the repo. See
  `.gitignore` and `README.md`.
- Changes to Linux desktop/Omarchy user config should follow the `omarchy`
  skill instructions.

## Stow workflow

After adding or changing files, preview the links from the repo root:

```sh
stow --simulate --verbose .
```

If the preview is expected, apply it:

```sh
stow --verbose .
```

Stow does not automatically install a newly added sibling file just because
another file in that app's directory is already linked. Verify each expected
home path, especially scripts referenced by a config:

```sh
ls -l ~/.config/herdr/config.toml ~/.config/herdr/nvim-tab.sh
readlink -f ~/.config/herdr/nvim-tab.sh
```

The resolved paths should point back into this checkout. `~/.config` is
intentionally a real directory; do not replace it with a symlink.

## Herdr config

- Source: `.config/herdr/config.toml`; command scripts live beside it.
- The installed config is `~/.config/herdr/config.toml`. Validate edits with
  `herdr config check` and apply server-side settings with
  `herdr server reload-config`.
- The `herdr server reload-config` command reloads server config. For local TUI
  keybindings, use Herdr's **Reload config** UI action so the client reloads its
  local config too.
- Prefix bindings are sequential: with `prefix = "ctrl+t"`, `prefix+n` means
  press Ctrl+t, release, then press n. Check the in-app keybind help (`prefix+?`)
  if a custom binding appears not to run.
- Check for collisions with built-in bindings. Herdr may keep the built-in
  action and disable the custom command; inspect `~/.config/herdr/herdr-client.log`
  for `config diagnostic` messages. Explicitly unbind an action if its key is
  needed by a custom command.
- Custom shell commands run from the focused pane's working directory. Verify
  both the script path exists in `~/.config/herdr/` and the command works when
  run directly before debugging the keybinding itself.

## Verification and commits

Run the narrowest relevant validation (for example, `bash -n ~/.bashrc`,
`herdr config check`, or a script syntax check), then check `git diff` and
`git status --short`. Do not stage or commit unless asked; when asked to commit
separate unrelated changes into separate commits.
