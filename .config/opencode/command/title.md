---
description: Generate a commit title and description from staged changes without committing.
agent: build
---

Review the currently staged git changes and propose a commit message. Do not
create a commit.

1. Run `git diff --staged` (and `git status` if needed) to inspect what is
   staged. If nothing is staged, say so and stop.
2. Read the surrounding code where useful so the message reflects the actual
   intent, not just the diff text.
3. Output a commit message with:
   - A concise title on the first line (imperative mood, roughly under 72
     characters, no trailing period).
   - A blank line.
   - A short description of a few sentences. Use bullet points when the change
     touches several distinct things or is very large.
4. Stop there. Do not stage anything, do not commit, do not push.
