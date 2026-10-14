# claude-skills

Skills for [Claude Code](https://code.claude.com/docs/en/skills) that I use day to day, generalised so they work for anyone.

## Why

This is my working toolkit. I use it and improve it on personal projects, when practising and at work, so changes come from real use. The skills follow my practices but contain nothing personal or company-specific: read them, copy them or install them as they are.

## Skills

| Skill | What it does | Use when | Invoke |
|---|---|---|---|
| [`ai-practice`](skills/ai-practice/SKILL.md) | Turns the session into practice at building AI tooling on the task at hand, with a measure agreed up front. Appends each session to `~/notes/ai-practice-log.md`, outside the repo. | Starting a session where you want to build tooling, not just prompt | `/ai-practice` |
| [`commit`](skills/commit/SKILL.md) | Stages and commits the current work, one commit per separate piece, each with a `commit-title` style title. Splits by whole file, never pushes and prints the command to undo. | The work is done and you want it committed in clean groups | `/commit [hint]` |
| [`commit-title`](skills/commit-title/SKILL.md) | Writes a gitmoji and conventional-type title for the staged changes, falling back to unstaged changes, then the conversation. One title per separate piece, and copies a single title to the clipboard. | You want the title but will commit yourself | `/commit-title [hint]` |
| [`review-prs`](skills/review-prs/SKILL.md) | Light, unblocking review of one or more GitHub PRs, stacked ones included, with a merge verdict and approval trade-off per PR. Never posts anything. | You have PRs to review | `/review-prs`, or paste PR URLs and ask for a review |
| [`which-skill`](skills/which-skill/SKILL.md) | Reads the conversation and git state and suggests the skill to start with, from every skill installed, not just this repo. | You're about to start and aren't sure which skill fits | `/which-skill [task]` |

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
