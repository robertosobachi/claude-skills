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

## Mode

`create`, `fold` or `check`. With no argument: `create` if the doc doesn't exist, `check` if there's an uncommitted diff or the user mentions a PR about to open, otherwise `fold`.

## Create

1. **Gather sources:** review notes and reply drafts in the plans folder; the user's last 10 to 20 merged PRs and their review comments (`gh pr list --author @me --state merged --limit 20`, then `gh api --paginate repos/{owner}/{repo}/pulls/<n>/comments`); any review rounds on design docs the user names. If `gh` fails, give the user the commands and ask them to paste the output. If `gh auth status` fails, or a call returns 404 for a repo you know exists, treat `gh` as unavailable. If there's no review history, say so; the doc starts from the seed rules and the user's answers. If the doc already exists, switch to Fold.
2. **Seed** with [references/seed-rules.md](references/seed-rules.md). Keep a seed rule only if it fits this repo, and mark rules the history shows reviewers actually asked for.
3. **Add the repo's own rules** from the sources: each reasoned comment that could recur becomes a rule. Merge duplicates. Check every "In <repo>" note against the code (`git grep`) before writing it.
4. **Ask about house style** the sources don't settle: test framework and style, logging and telemetry conventions, the PR description shape, and commit format. Point to `CLAUDE.md` rather than copying it.
5. **Write the doc** in the shape below, once `git check-ignore -v <path>` confirms the path is ignored (ask otherwise). Keep each rule short.
6. **Report:** the sections, which sources fed which rules, and the source files the doc can replace (for the user to delete).

## Fold

1. Take the new comments from the user, the latest `answer-review` output, or a PR number (fetch its comments as in Create).
2. For each comment that has a reason and could recur, find the section it belongs in. Tighten an existing rule if one covers it. Otherwise add a rule with its reason, and a checklist line that cites it.
3. Skip one-offs and comments without a reason. List what you skipped and why.
4. If a reviewer's preference contradicts an existing rule, keep both visible: note whose preference it is in the reviewer appendix and ask the user which wins in this repo.
5. Report each change with its source (PR and comment link) and the rule number.

## Check

1. Read the doc's checklist. If there's no doc, say so, offer Create, and use the checklist in [references/seed-rules.md](references/seed-rules.md) for now. Then read the diff: `git diff` plus untracked files; if that's empty, `git diff <base>...HEAD`, where the base is the parent branch for a stacked PR, otherwise `git symbolic-ref --short refs/remotes/origin/HEAD`. If both are empty, say there's nothing to check and stop.
2. Go through the checklist item by item. For each, say pass, fail (with `file:line` and the fix), or not applicable.
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

## 2. Structure and naming
## 3. Logging and jobs
## 4. Tests
## 5. Migrations and deploy order
## 6. PR descriptions
## 7. Working the review

## 8. Pre-PR checklist
- [ ] <check> (<rule numbers>)

## Appendix: reviewer profiles
### <reviewer>
- <what they consistently ask for, and how far their suggestions can be trusted>
```

Drop sections the repo doesn't need, and add ones it does. Keep reviewer profiles factual and about review behaviour only.
