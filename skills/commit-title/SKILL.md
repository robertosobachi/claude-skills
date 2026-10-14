---
name: commit-title
description: Write a gitmoji commit title for the current work, or one title per separate piece of work.
disable-model-invocation: true
allowed-tools: Bash(git diff *) Bash(git status *) Bash(${CLAUDE_SKILL_DIR}/copy.sh *)
---

## Working tree

!`git status --short`

### Staged

!`git diff --staged`

### Unstaged

!`git diff`

## Your task

Write a commit title for the current work. Describe the first of these that exists:

1. `$ARGUMENTS`, if given.
2. The staged changes above.
3. The unstaged changes and untracked files above. Read untracked files if you need to see what they are.
4. The work done in this conversation.

Format: `:<gitmoji>: <type>: <Subject>`

- `<gitmoji>`: one alias from gitmoji.dev that fits the change, e.g. `:sparkles:`, `:bug:`, `:recycle:`, `:memo:`, `:tada:`.
- `<type>`: one conventional commit type: feat, fix, refactor, docs, test, chore, perf, style, build or ci.
- `<Subject>`: imperative mood, capitalised, no full stop, technically specific.
- 72 characters at most, counting the alias as typed (`:sparkles:` is 10).

Example: `:tada: chore: Add README and MIT licence`

If there is nothing to describe, say so and stop.

## Separate work

Staged changes are one commit. Otherwise, if the changes hold separate pieces of work, such as a feature and an unrelated docs update, write one title per piece, in commit order. Files that only make sense together stay in one piece. Pieces are whole files: if a file holds changes for two pieces, put it with the one it mostly belongs to. When in doubt, use fewer pieces.

## Output

Commands must paste and run as-is:

- `git add <files>`: files space-separated, paths as `git status --short` shows them. For a rename, list both paths. For a deletion, list the path. Single-quote any path with spaces or shell metacharacters.
- `git commit -m "<title>"`: escape any `"`, `$`, `` ` `` or `\` in the title with a backslash.

With one title, copy it to the clipboard by running `${CLAUDE_SKILL_DIR}/copy.sh '<title>'`, escaping any `'` in the title as `'\''`. Run it once and don't retry it outside the sandbox. Output the title in a code block. If the copy failed, add one line under it: `Not copied, run /copy.` Then output the command in a second code block: `git commit -m "<title>"` alone if the changes are staged, otherwise `git add <files>` on one line and `git commit -m "<title>"` on the next.

With several titles, don't copy. Output one code block per piece, in commit order, holding `git add <files>` on one line and `git commit -m "<title>"` on the next. If a file also holds changes for another piece, say so in one plain line under the block, never inside it. End with one line: `Run /commit to stage and commit them.`

No body, no other explanation. Do not run `git add` or `git commit`.

If asked to commit afterwards, use the title alone as the message. Never add `Co-Authored-By` or any other AI attribution trailer.
