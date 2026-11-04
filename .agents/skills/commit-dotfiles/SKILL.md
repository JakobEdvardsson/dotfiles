---
name: commit-dotfiles
description: Commit changes in the dotfiles repository at ~/dotfiles. Use whenever the user says "commit", "commit changes", "commit all", or asks to save work in this repo. Covers splitting unrelated changes into separate commits and adding new Omarchy plugin clones as git submodules instead of vendoring their source.
---

# Committing dotfiles changes

Read `~/dotfiles/AGENTS.md` first and follow it. The repo is a GNU Stow package rooted at `$HOME`.

## 1. Inspect before staging

```sh
cd ~/dotfiles
git status --short
git diff
git diff --cached
```

- Treat everything in the worktree as the user's work. Never discard or overwrite it.
- Check the index (`git diff --cached`). A file staged earlier for a different topic must not be swept into the current commit. Unstage it with `git restore --staged <path>` and let it be committed with its own topic.
- Keep secrets, logs, backups, and runtime state out. See `.gitignore`.

## 2. Split by topic

Make one commit per logical change, for example:

- a config tweak in `.config/hypr/...`
- a new plugin integration
- a skill or documentation addition
- a tool-manager change

Never combine unrelated files just because they were modified at the same time.

## 3. Omarchy plugin submodules

Plugins live in `.config/omarchy/plugins/<id>/` and are git clones. Keep them as submodules; never vendor their files into this repo.

New plugin clone:

```sh
git submodule add <origin-url> .config/omarchy/plugins/<id>
git submodule absorbgitdirs .config/omarchy/plugins/<id>
```

- Get the URL with `git -C .config/omarchy/plugins/<id> remote get-url origin`.
- This stages `.gitmodules` plus one `160000` gitlink. Commit them with the plugin's integration files (hook, template, shell.json entry).
- Never `git add -f` files inside a plugin, and never run `git add` from inside the submodule.

Plugin already tracked but updated (by Omarchy or `git submodule update --remote`):

```sh
git add .config/omarchy/plugins/<id>   # pointer only
git commit -m "Update <name> plugin"
```

Verify:

```sh
git ls-files -s .config/omarchy/plugins | grep 160000
git submodule status
```

A fresh clone needs `git submodule update --init --recursive` before `stow`.

## 4. Commit messages

- Sentence case, imperative subject, no trailing period.
- Keep the subject specific; put rationale or caveats in the body.
- Do not add attribution or generated-by lines.

## 5. Finish

```sh
git status --short     # clean unless the user asked to leave something
git submodule status   # pointers should be clean
```

Do not push unless asked. Report the new commit hashes and what each contains.
