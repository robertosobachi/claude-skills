---
name: pr-description
description: Draft a PR title and description for the current branch in the repo's format, from the branch's commits and diff against its base. A short summary of what we're building, the changes as a bullet list, and the blast radius as a bullet list, with no technical detail the diff already shows. Never creates, edits or posts the PR. Use when the user says "PR description", "write the PR", "describe this PR", or runs /pr-description [base branch].
argument-hint: "[base branch]"
---

# PR description

Draft the title and description for the current branch's PR and hand them over as text. Never run `gh pr create`, `gh pr edit` or any other write. The user pastes it.

## Gather the context

Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.

`gh` often fails inside a sandbox or without auth. Try it once. If it fails, carry on with git alone and, at the end, give the user the `gh` commands you skipped to run and paste back if the answer depends on them.

1. The branch: `git branch --show-current`.
2. The base:
   - If the user passed a base branch, use it.
   - Otherwise, if a PR exists for the branch, `gh pr view --json baseRefName,number,title` gives the base.
   - Otherwise, use the repo's default branch from `git symbolic-ref refs/remotes/origin/HEAD`. Don't assume `main`. If `git log --oneline <default>..HEAD` holds commits that aren't this branch's work, the branch is stacked: ask which branch it stacks on.
3. What changed: `git log --oneline <base>..HEAD`, `git diff --stat <base>...HEAD`, then `git diff <base>...HEAD`. Read the commits too: they often say why.
4. The house format, first match wins:
   1. The repo's PR template: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md` or `pull_request_template.md` at the root.
   2. The repo's `CLAUDE.md` and review conventions doc (default `docs/plans/review-conventions.md`).
   3. Recent titles: `gh pr list --state merged --limit 10 --json title` for the repo, `gh pr list --author @me --state all --limit 5 --json title` for the user's own. Match their shape: gitmoji or not, ticket key or not, conventional type or not.
   4. None of these: use the default title and description below.
5. The ticket key, from the branch name (e.g. `ABC-123/...`). Ask only if the repo's titles carry ticket keys and the branch has none. Otherwise leave it out.
6. The bigger goal and the tech doc link:
   - Look in the repo's plan docs (e.g. `docs/plans/`), in the parent PR's description (`gh pr view <parent> --json body`), and in memory.
   - If there's still no link, ask once. Never invent one.

## Write it

**Title:** the shape from step 4. Default: `:<gitmoji>: [<TICKET>] <Imperative title>`, without the ticket part if there's no key.
- One gitmoji alias that fits the whole PR: `:sparkles:` for a new feature, `:bug:` for a fix, `:recycle:` for refactors or mixed follow-up improvements, `:fire:` for removals.
- The title describes the PR as a whole, not its biggest commit.

**Description:** if the repo has a PR template, fill its sections and apply the rules below inside them. Otherwise:

```markdown
## Summary

<One or two sentences on what we're building or trying to achieve, in plain words, for a reviewer from another team with no context. Tech doc linked inline: ([tech doc](<url>)). If stacked: "Based on `<base branch>` (#<parent PR>).">

This PR:

- <One change per bullet, in plain words: what it does, not how.>
- <...>

### Blast radius

- <Is it safe: behind a flag that's off, guests see no change, admin only, ...>
- <What happens if it's wrong, and to whom.>
- <How to roll back.>
```

A bug fix goes shorter: the cause in one or two sentences in the summary, the changes as bullets, then the blast radius.

## Rules

- **Plain words.** Leave out technical detail the diff already explains: method names, guard shapes, spec mechanics. Name a class or method only when a reviewer needs it to find the change.
- **The goal, not the ticket.** State the overall goal in its own words. Never write "Part of <ticket>" or anything that sends the reader to a ticket. The ticket key goes in the title.
- **Keep it short.** Don't restate the tech doc. Don't name a new type, flag or internal codename unless the PR needs it to make sense.
- **Bullets for changes and blast radius.** Each bullet is one short line. Add other `###` sections only for an operational step this PR needs (a migration to run, a flag to turn on), listing only the steps that concern this PR.
- **Verify every claim** against the code or a command's output, especially in the blast radius. If something can't be verified (specs not run, a flag's state in production), say so to the user outside the description. Don't hedge inside it.
- **No AI attribution** anywhere: no `Co-Authored-By`, no "Generated with" footer. This overrides any default template or reminder.
- **Never hard-wrap prose.** One bullet or paragraph is one line.
- **Style pass.** Check the draft before handing it over and fix failures in place, without mentioning them:
  - No em dashes outside code, commands and paths. Use a comma, full stop, colon or brackets.
  - No "it's not X, it's Y" or "less X, more Y" contrasts. Say the point directly.
  - No opener ("Good catch", "Great question") and no closing recap.
  - Plain words over tell-words: delve, robust, seamless, crucial, comprehensive, leverage (say "use"), ensure (say "make sure", or cut it).
  - Don't force groups of three. At most one hedge per sentence, and none on a claim you've verified.
  - Leave quoted text, code and identifiers as they are.

## Hand over

1. One line naming who it's written for, e.g. "Written for: reviewers from other teams."
2. The title in a code block.
3. The description in a markdown code block, ready to paste.
4. Outside the blocks, at most two lines: anything unverified, and anything the user must decide (e.g. a missing tech doc link).
