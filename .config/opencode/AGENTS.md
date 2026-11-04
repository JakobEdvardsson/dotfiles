# Global instructions

## Never go hunting for secrets

- Do not read, dump, or search for secrets, tokens, passwords, or credentials — this includes Doppler, AWS SSO, 1Password, keychains, `~/.aws`, `.env` files, and similar stores.
- If a task needs a credential, a login, or a secret value, stop and ask me. Tell me exactly which command to run or which value to provide.
- Never print secret values into the conversation.

## Git remotes

- Use SSH only. Never push or fetch over HTTPS, and never fall back to an HTTPS URL or the `gh` credential helper.
- Never run `gh auth setup-git` or add HTTPS credential helpers.
- If SSH fails (for example `Permission denied (publickey)`), stop and report the exact error. Do not work around it by changing protocols, rewriting remotes, or disabling checks.
- Do not push, force-push, or open pull requests unless I explicitly ask.
