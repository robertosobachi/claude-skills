---
name: review-conventions
description: Create, refresh or apply a repo's review conventions doc, the one place where every reasoned review comment becomes a rule with its reason and a pre-PR checklist line. Create seeds it from generic rules plus the repo's review history. Fold adds new review comments to it. Check runs its checklist on the current diff. Use when starting work in a repo with no conventions doc, after a review round ("fold these comments in"), before opening a PR ("run the checklist"), or when the user runs /review-conventions [create|fold|check].
argument-hint: "[create | fold | check]"
---

# Review conventions

One document per repo that collects what reviewers ask for and why, so the same comment doesn't come back on the next PR. Default path `docs/plans/review-conventions.md`, in a git-ignored folder, because it holds notes about named reviewers. Ask before using another path.

## Ground rules

- One document. Every new reasoned comment is folded into it, never into a new notes file.
- Each rule is stated generally, with its reason. Where the repo already has a mechanism for it, an "In <repo>:" note names the file or helper.
- Don't delete source notes the doc replaces until the user has read the merged doc and says so.
- Never stage, commit, push or post. No AI attribution. Never hard-wrap prose.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## Mode

`create`, `fold` or `check`. With no argument: `create` if the doc doesn't exist, `check` if there's an uncommitted diff or the user mentions a PR about to open, otherwise `fold`.

## Create

1. **Gather sources:** review notes and reply drafts in the plans folder; the user's last 10 to 20 merged PRs and their review comments (`gh pr list --author @me --state merged --limit 20`, then `gh api --paginate repos/{owner}/{repo}/pulls/<n>/comments`); any review rounds on design docs the user names. If `gh` fails, give the user the commands and ask them to paste the output. If `gh auth status` fails, or a call returns 404 for a repo you know exists, treat `gh` as unavailable. If there's no review history, say so; the doc starts from the seed rules and the user's answers. If the doc already exists, switch to Fold.
2. **Seed** with [references/seed-rules.md](references/seed-rules.md). Keep a seed rule only if it fits this repo, and mark rules the history shows reviewers actually asked for.
3. **Add the repo's own rules** from the sources: each reasoned comment that could recur becomes a rule. Merge duplicates. Check every "In <repo>" note against the code (`git grep`) before writing it. Propose an enforcement for each rule as in Fold step 3. Where a rule can be searched for, `git grep` for code that already breaks it and list the hits under that rule in the report, without fixing them: an agent working in the repo copies what the code already does, so an unfixed violation teaches the opposite of the rule.
4. **Ask about house style** the sources don't settle: test framework and style, logging and telemetry conventions, the PR description shape, and commit format. Point to `CLAUDE.md` rather than copying it.
5. **Write the doc** in the shape below, once `git check-ignore -v <path>` confirms the path is ignored (ask otherwise). Keep each rule short.
6. **Report:** the sections, which sources fed which rules, and the source files the doc can replace (for the user to delete).

## Fold

1. Take the new comments from the user, the latest `answer-review` output, or a PR number (fetch its comments as in Create). Two more sources count as comments, taken from the user or from logs they point to. First, a human's agree or disagree reply to an agent reviewer's comment: the human's reason is the comment, not the agent's verdict. Second, the user's rejections of agent output in their own local sessions, with the reason they gave: review increasingly happens there and never reaches the PR.
2. For each comment that has a reason and could recur, find the section it belongs in. Tighten an existing rule if one covers it. Otherwise add a rule with its reason, and a checklist line that cites it.
3. For each new or tightened rule, decide whether a machine can check it: a pattern, an import boundary, a file or function size limit, a banned API, a required wrapper such as a timeout around every fetch. If it can, add an **Enforce:** line under the rule proposing a lint rule, a test over the source or a git hook, using tools the repo already has. Its failure message states the fix and cites the rule number. A checklist line can be skipped; a check fails every time. Don't write or install it; the user decides. Keep the checklist line until the check exists, then mark it enforced by that check.
4. Skip one-offs and comments without a reason. List what you skipped and why. A miss is not a one-off: a change that passed review and then broke something becomes a rule the first time, stated as the check that would have caught it (often a search, such as who still reads what the change removes or renames).
5. If a reviewer's preference contradicts an existing rule, keep both visible: note whose preference it is in the reviewer appendix and ask the user which wins in this repo.
6. Report each change with its source (PR and comment link), the rule number and any proposed enforcement.

## Check

1. Read the doc's checklist. If there's no doc, say so, offer Create, and use the checklist in [references/seed-rules.md](references/seed-rules.md) for now. Then read the diff: run `git merge-base <base> HEAD`, then `git diff <merge-base>`, which covers the branch's commits and uncommitted changes to tracked files, and add untracked files from `git status --short`. The base is the parent branch for a stacked PR, otherwise the default branch from `git symbolic-ref --short refs/remotes/origin/HEAD`. If there's nothing, say there's nothing to check and stop.
2. Go through the checklist item by item. Skip items marked enforced by a check that already ran green on this diff, and name the check; if you don't know it ran, check the item. For the rest, say pass, fail (with `file:line` and the fix), or not applicable.
3. Fix nothing yourself unless the user asks. End with the failures in order of how likely a reviewer is to comment.

## Doc shape

```
---
title: Review conventions
summary: Rules reviewers have asked for in <repo>, with reasons, and a pre-PR checklist.
---

# Review conventions

## How to use this
<Check your own PR against it before opening, and someone else's when reviewing. Every reasoned review comment gets folded in here as a rule and a checklist line.>

## 1. Where reasoning lives
### 1.1 <Rule as an instruction>
<The rule in one to three sentences. Then the reason.>
**In <repo>:** <where the mechanism lives, if any>
**Enforce:** <optional: lint rule, source test or git hook, its failure message, and "proposed" or the file it lives in>

## 2. Structure and naming
## 3. Logging and jobs
## 4. Tests
## 5. Migrations and deploy order
## 6. PR descriptions
## 7. Working the review

## 8. Pre-PR checklist
- [ ] <check> (<rule numbers>)
- [ ] <check> (<rule numbers>, enforced by <check>)

## Appendix: reviewer profiles
### <reviewer>
- <what they consistently ask for, and how far their suggestions can be trusted>
```

Drop sections the repo doesn't need, and add ones it does. Keep reviewer profiles factual and about review behaviour only.
