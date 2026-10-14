# claude-skills

Skills for [Claude Code](https://code.claude.com/docs/en/skills) that I use day to day, generalised so they work for anyone.

## Why

This is my working toolkit. I use it and improve it on personal projects, when practising and at work, so changes come from real use. The skills follow my practices but contain nothing personal or company-specific: read them, copy them or install them as they are.

## Skills

- **`ai-practice`** (slash command only): turns a session into practice at building AI tooling on the task at hand, with a measure agreed up front. Run it at the start of a session. It appends each session to `~/notes/ai-practice-log.md`, outside the repo.
- **`commit`** (slash command only, optional argument): stages and commits the current work, one commit per separate piece of work, each with a `commit-title` style title. Splits by whole file, never pushes and prints the command to undo.
- **`commit-title`** (slash command only, optional argument): writes a gitmoji and conventional-type commit title for the staged changes, falling back to unstaged changes, then the conversation. Gives one title per piece when the work is separate, and copies a single title to the clipboard where one is available. Doesn't commit unless you ask.
- **`review-prs`** (slash command, or automatic when you paste PR URLs and ask for a review): light, unblocking review of one or more GitHub PRs, stacked ones included, with a merge verdict and approval trade-off per PR. Never posts anything.

## Install

Needs Claude Code, git and bash. `review-prs` uses `gh` if it works, otherwise it asks you to run a `git fetch`.

```
git clone https://github.com/robertosobachi/claude-skills
cd claude-skills && ./install.sh
```

Each skill is symlinked into `~/.claude/skills`, or `$CLAUDE_SKILLS_DIR` if set. An existing folder with the same name that isn't a symlink is skipped. Invoke a skill by name, e.g. `/commit-title`.

## Update

Run `./install.sh` again. It pulls the latest changes, links new skills and removes links to skills that were deleted. Use `--no-pull` to relink without pulling.

## Licence

[MIT](LICENSE)
