---
name: commit-title
description: Write a commit title in the repo's format for the current work, or one title per separate piece of work, and rate the push risk of each.
disable-model-invocation: true
allowed-tools: Bash(git diff *) Bash(git status *) Bash(git log *) Bash(git symbolic-ref *) Bash(${CLAUDE_SKILL_DIR}/copy.sh *)
---

## Working tree

!`git status --short`

### Staged

!`git diff --staged --stat`

### Unstaged

!`git diff --stat`

## Your task

Write a commit title for the current work. Describe the first of these that exists:

1. `$ARGUMENTS`, if given.
2. The staged changes above.
3. The unstaged changes and untracked files above.
4. The work done in this conversation.

Only the file stats are above. Before grouping or titling, read what you need: `git diff --staged`, or `git diff -- <paths>` for the files in a piece. Read untracked files directly.

Format, first match wins:

1. A commit format rule in the repo's `CLAUDE.md`.
2. The majority shape of `git log --oneline -20 origin/<default>`, where `git symbolic-ref --short refs/remotes/origin/HEAD` names the default branch (use the current branch if that fails). Match it: gitmoji or not, conventional type or not, ticket key or not, capitalisation.
3. Neither settles it: `:<gitmoji>: <type>: <Subject>`
   - `<gitmoji>`: one alias from gitmoji.dev that fits the change, e.g. `:sparkles:`, `:bug:`, `:recycle:`, `:memo:`, `:tada:`.
   - `<type>`: one conventional commit type: feat, fix, refactor, docs, test, chore, perf, style, build or ci.
   - `<Subject>`: imperative mood, capitalised, no full stop, technically specific.
   - Example: `:tada: chore: Add README and MIT licence`

Whatever the format, 72 characters at most, counting a gitmoji alias as typed (`:sparkles:` is 10).

If there is nothing to describe, say so and stop.

## Separate work

Staged changes are one commit. Otherwise, if the changes hold separate pieces of work, such as a feature and an unrelated docs update, write one title per piece, in commit order. Files that only make sense together stay in one piece. Pieces are whole files: if a file holds changes for two pieces, put it with the one it mostly belongs to. When in doubt, use fewer pieces.

## Push risk

Rate each piece on how much breaks, and for whom, if it is wrong once pushed. The highest level in a piece wins: one 🔴 file makes the whole piece 🔴.

- 🟢 Low: docs, comments or tests only, dev-only tooling, new code nothing calls yet, or a refactor with no behaviour change that tests cover.
- 🟡 Medium: a behaviour change in code with a few callers, a shared component or util, a user-visible UI change, non-trivial logic, or a minor dependency bump.
- 🔴 High: auth, payments, permissions, data migrations or schema, a public API or exported contract, a removed or renamed symbol that still has callers, build, CI, deploy or release config, env or secrets handling, a major dependency bump, or changes spread across many modules.

If a piece removes, renames or changes the signature of an exported symbol, search the repo for its callers and count them. Otherwise judge from the diff alone and explore nothing else.

Format: `<emoji> <Level>: <what it reaches and how it fails if wrong>`, one line under about 100 characters. Name the concrete caller, screen or system, never a generic phrase. Example: `🔴 High: changes token refresh used by every API call, a bug logs everyone out`. Low can be short: `🟢 Low: README only`.

## Output

Commands must paste and run as-is:

- `git add <files>`: files space-separated, paths as `git status --short` shows them. For a rename, list both paths. For a deletion, list the path. Single-quote any path with spaces or shell metacharacters.
- `git commit -m "<title>"`: escape any `"`, `$`, `` ` `` or `\` in the title with a backslash.

With one title, copy it to the clipboard by running `${CLAUDE_SKILL_DIR}/copy.sh '<title>'`, escaping any `'` in the title as `'\''`. Run it once and don't retry it outside the sandbox. Output the title in a code block. If the copy failed, add one line under it: `Not copied, run /copy.` Then output the command in a second code block: `git commit -m "<title>"` alone if the changes are staged, otherwise `git add <files>` on one line and `git commit -m "<title>"` on the next. Put the risk line under it, as plain text.

With several titles, don't copy. Output one code block per piece, in commit order, holding `git add <files>` on one line and `git commit -m "<title>"` on the next. Under each block put its risk line, then, if a file also holds changes for another piece, say so in one more plain line. Never put either inside a block. End with one line: `If /commit is installed, run it to stage and commit them.`

No body, no explanation beyond the risk lines. Do not run `git add` or `git commit`.

If asked to commit afterwards, use the title alone as the message. Never add `Co-Authored-By` or any other AI attribution trailer.

## Rules

- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
