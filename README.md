# claude-skills

Skills for [Claude Code](https://code.claude.com/docs/en/skills) that I use day to day, generalised so they work for anyone.

## Why

This is my working toolkit. I use it and improve it on personal projects, when practising and at work, so changes come from real use. The skills follow my practices but contain nothing personal or company-specific: copy them or install them as they are.

## Skills

| Skill | What it does | Use when | Takes action | Invoke |
|---|---|---|---|---|
| [`ai-practice`](skills/ai-practice/SKILL.md) | Turns the session into practice at building AI tooling on the task at hand, with a measure agreed up front. Appends each session to `~/notes/ai-practice-log.md`, outside the repo. | Starting a session where you want to build tooling, not just prompt | Appends to the log | `/ai-practice` |
| [`answer-review`](skills/answer-review/SKILL.md) | Works through review comments on your own PR or design doc: checks each reviewer's premise against the code, gives a verdict, drafts the change and a short reply, and tracks every thread to an end state. Never posts, resolves, commits or pushes. | You got review comments on your PR or doc | No | `/answer-review <PR or doc URL>` |
| [`commit`](skills/commit/SKILL.md) | Stages and commits the current work, one commit per separate piece, each with a `commit-title` style title. Splits by whole file, rates the push risk of each commit (🟢/🟡/🔴), never pushes and prints the command to undo. | The work is done and you want it committed in clean groups | Stages and commits | `/commit [hint]` |
| [`commit-title`](skills/commit-title/SKILL.md) | Writes a gitmoji and conventional-type title for the staged changes, falling back to unstaged changes, then the conversation. One title per separate piece, each with a push risk rating (🟢/🟡/🔴), prints paste-ready `git add` and `git commit` commands and copies a single title to the clipboard. | You want the title but will commit yourself | No | `/commit-title [hint]` |
| [`handover-prompt`](skills/handover-prompt/SKILL.md) | Writes a prompt that lets a fresh session pick up the current work where it stands: goal, gating, what to read first, verified state, decisions not to reopen, what's open and the task. Points at existing docs instead of copying them. | You're ending a session and will continue in a new one | Writes the prompt file and updates the plan's notes, never commits or posts | `/handover-prompt [what the next session is for]` |
| [`kickoff`](skills/kickoff/SKILL.md) | Turns a requirements page or ticket into a plan of small, independently reviewable PRs: reads the requirements and review conventions, maps the existing feature to copy, slices the work and records a review baseline. Writes no code and stops for approval. | You're starting a feature, epic or ticket in an existing repo | Writes the plan and session log to a git-ignored folder, never commits or posts | `/kickoff <requirements URL or ticket key>` |
| [`next-pr`](skills/next-pr/SKILL.md) | Builds the next PR from a `kickoff` plan, or any plan with a PR list: re-checks the plan against the code, stops for approval, then builds, tests, mutation-tests new assertions and reviews the diff. Hands over the unstaged diff with commit title, PR title and description. | A plan is approved and you're ready to build the next PR | Edits code and updates the plan and session log, never stages, commits or pushes | `/next-pr [PR number or name]` |
| [`peer-feedback-notes`](skills/peer-feedback-notes/SKILL.md) | Turns what you noticed about a colleague into dated, evidence-based notes for the performance review, rated 🟢/🟡/🔴. Flags what needs action now instead of at review time, separates individual behaviour from process problems and drafts escalation messages. Optional `gh` scripts for PR and review evidence. | You want to record something a colleague did, good or bad, for peer feedback | No, notes stay in chat and are never written to disk or sent | `/peer-feedback-notes`, or describe what happened |
| [`pr-description`](skills/pr-description/SKILL.md) | Drafts the PR title and description for the current branch from its commits and diff, in the repo's format: PR template first, then its recent titles. A plain-words summary, the changes as bullets and the blast radius as bullets. Never creates, edits or posts the PR. | The branch is ready and you need the PR text | No | `/pr-description [base branch]` |
| [`review-conventions`](skills/review-conventions/SKILL.md) | Creates, folds into or checks a repo's review conventions doc: every reasoned review comment becomes a rule with its reason and a pre-PR checklist line. Seeds from generic rules plus the repo's review history. | Starting in a repo with no conventions doc, after a review round, or before opening a PR | Writes the doc to a git-ignored folder, never commits or posts | `/review-conventions [create\|fold\|check]` |
| [`review-prs`](skills/review-prs/SKILL.md) | Light, unblocking review of one or more GitHub PRs, stacked ones included, with a merge verdict and approval trade-off per PR. Never posts anything. | You have PRs to review | No | `/review-prs`, or paste PR URLs and ask for a review |
| [`slack-morning-brief`](skills/slack-morning-brief/SKILL.md) | Sets up or runs a weekday brief of decisions, changes and incidents across the Slack workspace, channels you're not in included. Read only in Slack. | You want to know what changed overnight before you start work | Creates a scheduled task at setup, never posts in Slack | `/slack-morning-brief` |
| [`which-skill`](skills/which-skill/SKILL.md) | Reads the conversation and git state and suggests the skill to start with, from every skill installed, not just this repo. | You're about to start and aren't sure which skill fits | No | `/which-skill [task]` |

## Why some steps stay manual

Some skills stop before the last step and print a command to paste or text to retype instead. That's deliberate.

- **Keep the skill sharp.** Doing these steps by hand keeps the muscle working. They take seconds, and that's worth more than the time the AI would save.
- **Review before anything critical.** Steps that could trigger a deploy or a release, or change code in production, stay manual so there's a chance to review them before they run. A mistake there can damage the integrity of the system itself. `commit` never pushes, `commit-title` prints the commands instead of running them, `review-prs` never posts and `answer-review` never posts or resolves.

On top of this, I keep my own restrictions and guardrails in place to block unwanted actions by the AI.

## Install

Needs Claude Code, git and bash. `review-prs` uses `gh` if it works, otherwise it asks you to run a `git fetch`. `answer-review` does the same, asking you to run the `gh` commands and paste the output; for docs it uses a wiki connector or pasted text. `pr-description` uses `gh` if it works, otherwise it works from git alone and lists the `gh` commands it skipped. `slack-morning-brief` needs a Slack connector, and scheduled-task tools (Cowork) to run on its own. `peer-feedback-notes` works from what you tell it; its GitHub scripts are optional and need `gh` authenticated with access to the org's repos.

```
git clone https://github.com/robertosobachi/claude-skills
cd claude-skills && ./install.sh
```

Each skill is symlinked into `~/.claude/skills`, or `$CLAUDE_SKILLS_DIR` if set. An existing folder with the same name that isn't a symlink is skipped. Invoke a skill by name, e.g. `/commit-title`.

## Update

Run `./install.sh` again. It pulls the latest changes, links new skills and removes links to skills that were deleted. Use `--no-pull` to relink without pulling.

## Claude Desktop and claude.ai

Chat in Claude Desktop and claude.ai doesn't read `~/.claude/skills`. Upload the skills there as zips instead.

```
./package.sh
```

- With no arguments it packs `peer-feedback-notes`, `handover-prompt` and `slack-morning-brief`. The other skills need a local repo, git or `gh`, which chat can't reach. Pass names to pack others, e.g. `./package.sh which-skill`.
- Upload each zip from `dist/` in Customize > Skills. Uploaded skills sync to every device signed in to the same account.
- Uploads don't update. After changing a skill, run `./package.sh` again and replace the upload.

## Licence

[MIT](LICENSE)
