# claude-skills

Skills for [Claude Code](https://code.claude.com/docs/en/skills) that I use day to day, generalised so they work for anyone.

## Install

1. Clone the repo:

   ```
   git clone https://github.com/robertosobachi/claude-skills
   cd claude-skills
   ```

2. Link the skills into `~/.claude/skills`, or `$CLAUDE_SKILLS_DIR` if set. A folder with the same name that isn't a symlink is skipped.

   ```
   ./install.sh
   ```

3. Optional: also link the subagents in [`agents/`](agents/) into `~/.claude/agents`, or `$CLAUDE_AGENTS_DIR`. See [Subagents](#subagents).

   ```
   ./install.sh --with-agents
   ```

4. Check it worked: the script prints `linked <name>` for each skill. In Claude Code, type `/which-skill`.

## Update

- Run `./install.sh` again: it pulls, links new skills and removes links to deleted ones. `--no-pull` relinks without pulling.
- Or `git pull`: the hooks `./install.sh` enables (`core.hooksPath`) relink on their own. Undo with `git config --unset core.hooksPath`.

## Skills

| Skill | What it does | Invoke |
|---|---|---|
| [`adversarial-review`](skills/adversarial-review/SKILL.md) | Four fresh reviewers try to prove your change wrong and a judge keeps only findings the code backs; never edits, commits, pushes or comments. | `/adversarial-review [PR, branch or path] [base]` |
| [`ai-practice`](skills/ai-practice/SKILL.md) | Turns the session into practice at building AI tooling, with a measure agreed up front, and appends it to `~/notes/ai-practice-log.md`. | `/ai-practice` |
| [`annotate-pr`](skills/annotate-pr/SKILL.md) | Drafts the comments to leave on your own PR so reviewers get the why the code doesn't show; never posts. | `/annotate-pr [PR number, URL or base branch]` |
| [`answer-review`](skills/answer-review/SKILL.md) | Checks each review comment on your PR or doc against the code, then drafts the change and reply; never posts, resolves, commits or pushes. | `/answer-review <PR or doc URL>` |
| [`commit`](skills/commit/SKILL.md) | Stages and commits the current work, one commit per piece with a push risk rating; never pushes and prints the undo command. | `/commit [hint]` |
| [`commit-title`](skills/commit-title/SKILL.md) | Writes a gitmoji or repo-format title per piece, prints `git add` and `git commit` commands and copies a single title to the clipboard; never commits. | `/commit-title [hint]` |
| [`explain-the-diff`](skills/explain-the-diff/SKILL.md) | Explains your mostly agent-written change in plain words, then quizzes you one question at a time and says if it's ready to send; read only. | `/explain-the-diff [PR or branch] [base]` |
| [`grill-me`](skills/grill-me/SKILL.md) | Interviews you one question at a time, each with a recommended answer, until the decisions are settled; writes a file only if you ask. | `/grill-me [topic, doc or plan]` |
| [`handover-prompt`](skills/handover-prompt/SKILL.md) | Writes a prompt file that lets a fresh session pick up the current work where it stands, and updates the plan's notes; never commits or posts. | `/handover-prompt [what the next session is for]` |
| [`kickoff`](skills/kickoff/SKILL.md) | Turns a requirements page or ticket into a plan of small reviewable PRs in a git-ignored folder, then stops for approval; writes no code. | `/kickoff <requirements URL or ticket key>` |
| [`next-pr`](skills/next-pr/SKILL.md) | Builds the next PR from a plan: stops for approval after re-checking it, then builds, tests and hands over the unstaged diff; never stages or commits. | `/next-pr [PR number or name]` |
| [`peer-feedback-notes`](skills/peer-feedback-notes/SKILL.md) | Turns what you noticed about a colleague into dated, evidence-based review notes and flags what needs action now; stays in chat, never saved or sent. | `/peer-feedback-notes`, or describe what happened |
| [`pr-description`](skills/pr-description/SKILL.md) | Drafts the PR title and description for the current branch in the repo's format, from its commits and diff; never creates, edits or posts it. | `/pr-description [base branch]` |
| [`review-conventions`](skills/review-conventions/SKILL.md) | Creates, folds comments into or checks a repo's review conventions doc in a git-ignored folder, one rule and checklist line per comment; never commits or posts. | `/review-conventions [create\|fold\|check]` |
| [`review-evidence-log`](skills/review-evidence-log/SKILL.md) | Collects evidence of your work and teammates' from Slack, GitHub, Confluence and Zoom into one local log, weekly and unattended; read only on every source. | `/review-evidence-log`, or "update my review log" |
| [`review-prs`](skills/review-prs/SKILL.md) | Light, unblocking review of GitHub PRs or a local branch, with a merge verdict and paste-ready comments; can add an adversarial pass; never posts. | `/review-prs [PR URLs]` or `/review-prs quick <head> <base>` |
| [`review-tests`](skills/review-tests/SKILL.md) | Reviews your branch's new or changed tests for clear names and assertions that can go red, then edits test files after approval; never commits. | `/review-tests [base branch]` |
| [`should-this-exist`](skills/should-this-exist/SKILL.md) | Challenges a task, report or automation before you do it and gives one verdict: drop, delegate, defer, shrink or do; waits for your go. | `/should-this-exist [task]` |
| [`slack-morning-brief`](skills/slack-morning-brief/SKILL.md) | Sets up or runs a weekday brief of decisions, changes and incidents across Slack, channels you're not in included; never posts. | `/slack-morning-brief` |
| [`standup-brief`](skills/standup-brief/SKILL.md) | Sets up or runs a weekday standup update from your own Slack, GitHub and Jira activity, with a capacity call; never posts. | `/standup-brief` |
| [`ticket`](skills/ticket/SKILL.md) | Moves a ticket to its next stage: reads the plan's state, git and the PR, runs the skill for that stage and stops at its gate; never commits, pushes or posts. | `/ticket [ticket key or URL]` |
| [`which-model`](skills/which-model/SKILL.md) | Suggests the model and effort level for a task, or the next step when a result falls short, and prints the `/model` and `/effort` commands. | `/which-model [task, or what went wrong]` |
| [`which-skill`](skills/which-skill/SKILL.md) | Reads the conversation and git state and suggests the skill to start with, from every skill installed, not just this repo. | `/which-skill [task]` |

## Requirements

Every skill needs Claude Code, git and bash. These need more:

| Skill | Needs |
|---|---|
| `adversarial-review` | Subagents, 5 per review (four reviewers and a judge) |
| `annotate-pr` | `gh` if it works, otherwise git alone |
| `answer-review` | `gh`, or pasted `gh` output. For docs, a wiki connector or pasted text |
| `next-pr` | Subagents |
| `peer-feedback-notes` | Optional: `gh` with access to the org's repos, for its GitHub scripts |
| `pr-description` | `gh` if it works, otherwise git alone, listing the `gh` commands it skipped |
| `review-evidence-log` | Slack, Atlassian and Zoom connectors (each optional), a read-only GitHub token or a pasted `gh` prompt, and Cowork scheduled tasks on your machine to run on its own. Cloud routines can't reach the local log |
| `review-prs` | `git fetch`, `gh` if it works, `review-tests` for the test check, subagents for the adversarial pass. `quick` needs git alone |
| `slack-morning-brief` | A Slack connector, and scheduled-task tools (Cowork) to run on its own |
| `standup-brief` | Slack and Atlassian connectors, a GitHub connector or `gh` (each optional), and scheduled-task tools (Cowork) to run on its own |

## Subagents

- `./install.sh --with-agents` links [`agents/Explore.md`](agents/Explore.md), which overrides the built-in Explore subagent to run on `haiku`. The choice is saved in this clone's git config; `./install.sh --without-agents` removes the links.
- `haiku` is Haiku 5.5 only on the Anthropic API with Claude Code 2.1.293+; on Bedrock, Google Cloud or Foundry it's Haiku 4.5.
- `adversarial-review`, `next-pr` and `review-prs` don't pin a model. Their subagents run on the session's model, or lower if your own `CLAUDE.md` sets a model policy.
- Don't set `CLAUDE_CODE_SUBAGENT_MODEL`: it moves every subagent without a `model:` to that model, the reviewers and the judge included. Put a policy in your `CLAUDE.md` instead.

## Claude Desktop and claude.ai

Chat there doesn't read `~/.claude/skills`, so upload zips instead: run `./package.sh`, then upload each zip from `dist/` in Customize > Skills. Uploads sync to every device on the same account.

- With no arguments it packs the skills that work without a local repo, git or `gh`: `grill-me`, `handover-prompt`, `peer-feedback-notes`, `review-evidence-log`, `should-this-exist`, `slack-morning-brief` and `standup-brief`. Pass names to pack others, e.g. `./package.sh which-skill`.
- Uploads don't update. After a pull, the hook repacks the zips whose skill changed and names each one to re-upload. After changing a skill yourself, run `./package.sh` again and replace the upload.

## Evals

[`evals/review-prs/`](evals/review-prs/README.md) is a regression check for `review-prs`, comparing each edit to the skill with the version before it.

## Lint

Run `bash lint.sh` after changing a skill. It's manual, so a broken lint never blocks an install.

## Why

This is my working toolkit. I use it and improve it on personal projects, when practising and at work, so changes come from real use. The skills follow my practices but contain nothing personal or company-specific: copy them or install them as they are.

## Why some steps stay manual

Some skills stop before the last step and print a command to paste or text to retype instead. That's deliberate.

- **Keep the skill sharp.** Doing these steps by hand keeps the muscle working. They take seconds, and that's worth more than the time the AI would save.
- **Review before anything critical.** Steps that could trigger a deploy or a release, or change code in production, stay manual so there's a chance to review them before they run. A mistake there can damage the integrity of the system itself.

On top of this, I keep my own restrictions and guardrails in place to block unwanted actions by the AI.

## Licence

[MIT](LICENSE)
