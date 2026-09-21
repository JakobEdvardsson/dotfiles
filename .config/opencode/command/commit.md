---
description: Generate a commit message from staged changes and commit them.
agent: build
---

Review the currently staged git changes and create a commit.

1. Run `git diff --staged` (and `git status` if needed) to inspect what is
   staged. If nothing is staged, say so and stop.
2. Read the surrounding code where useful so the message reflects the actual
   intent, not just the diff text.
3. Write a commit message with:
   - A concise title on the first line (imperative mood, roughly under 72
     characters, no trailing period).
   - A blank line.
   - A short description of a few sentences. Use bullet points when the change
     touches several distinct things or is very large.
4. Create the commit with that message, staging only files that are already
   staged.
5. Report the resulting commit hash and message.

Do not push. Do not amend an existing commit. Do not add files that were not
already staged.
