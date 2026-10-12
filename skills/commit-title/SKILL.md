---
name: commit-title
description: Write a gitmoji commit title for the current work.
disable-model-invocation: true
allowed-tools: Bash(git diff *) Bash(git status *)
---

## Working tree

!`git status --short`

### Staged

!`git diff --staged`

### Unstaged

!`git diff`

## Your task

Write one commit title for the current work. Describe the first of these that exists:

1. `$ARGUMENTS`, if given.
2. The staged changes above.
3. The unstaged changes above.
4. The work done in this conversation.

Format: `:<gitmoji>: <type>: <Subject>`

- `<gitmoji>`: one alias from gitmoji.dev that fits the change, e.g. `:sparkles:`, `:bug:`, `:recycle:`, `:memo:`, `:tada:`.
- `<type>`: one conventional commit type: feat, fix, refactor, docs, test, chore, perf, style, build or ci.
- `<Subject>`: imperative mood, capitalised, no full stop, technically specific.
- 72 characters at most, counting the alias as typed (`:sparkles:` is 10).

Example: `:tada: chore: Add README and MIT licence`

If there is nothing to describe, say so and stop.

Output only the title in a code block. No body, no explanation. Do not run `git commit`.

If asked to commit afterwards, use the title alone as the message. Never add `Co-Authored-By` or any other AI attribution trailer.
