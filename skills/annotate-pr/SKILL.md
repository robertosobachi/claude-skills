---
name: annotate-pr
description: Draft the comments the author should leave on their own PR's diff to explain the why behind changes a reviewer can't follow from the code alone. Sorts each one into a PR comment, a code comment or a question for the author, with verified line anchors. Never posts. Use when the user says "annotate my PR", "what should I comment on my PR", "explain my changes to reviewers", or runs /annotate-pr [PR number, URL or base branch].
argument-hint: "[PR number, URL or base branch]"
---

# Annotate PR

Draft the comments the author should add to their own PR so reviewers get the why behind changes the code doesn't explain. The code shows the what. Hand everything over as text. Never run `gh pr comment`, `gh pr review`, `gh api` writes or any other write. The user adds the comments.

## 1. Gather the context

Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.

`gh` often fails inside a sandbox or without auth. Try it once. If it fails, carry on with git alone.

1. The branch: `git branch --show-current`. If the argument is a PR number or URL and the branch doesn't match, ask the user to check it out or run `git fetch origin pull/<n>/head:refs/review/<n>` and work from that ref.
2. The base:
   - If the user passed a base branch, use it.
   - Otherwise, if a PR exists, `gh pr view --json baseRefName,number,body` gives the base and the description.
   - Otherwise, use the repo's default branch from `git symbolic-ref refs/remotes/origin/HEAD`. Don't assume `main`. If `git log --oneline <default>..HEAD` holds commits that aren't this branch's work, the branch is stacked: ask which branch it stacks on.
3. What changed: `git log <base>..HEAD` with full commit bodies, `git diff --stat <base>...HEAD`, then `git diff <base>...HEAD`.
4. Where the why lives: the commit bodies, the conversation, the repo's plan docs (e.g. `docs/plans/`), the PR description and the code around each hunk.

## 2. Pick the blocks

A block qualifies only if a competent reviewer would stop and ask "why?". Typical cases:

- A workaround, or an order of operations that matters but doesn't look like it
- A deleted guard, check or test
- A changed default, constant, timeout or limit
- A choice between two plausible approaches
- A dependency bump, pin or downgrade
- Behaviour that looks like a bug but is deliberate
- Something left out on purpose

Skip renames, formatting, moves, mechanical follow-ons of another change and anything the PR description already explains. There's no cap. If nothing qualifies, say so.

## 3. Sort each one

- **PR comment:** the why only matters during review. Why this approach over another, why this file was touched, what was left out of scope and where it goes instead.
- **Code comment:** the why will still matter after merge, to someone reading the code with no PR to hand. Workarounds, magic values, deliberate oddities. A PR comment disappears from view once the PR merges, so give the comment text to put in the code instead, for the user to add before pushing.
- **Question:** the why isn't in the evidence. Never invent a reason. Ask the user one short question for that block.

## 4. Write each comment

- Brief. One short sentence, two at most. The reviewer should get it on a single read, without stopping to think.
- The author's voice, plain everyday words. No jargon the reviewer would have to look up.
- The why, not the what. Don't restate what the diff shows. Name the change in a few words only when the why needs something to hang on, e.g. "Removing this guard because it's obsolete: we ran a migration and the column is now always present."
- Link the issue, doc or upstream bug when there is one. Never invent a link.
- A code comment follows the file's comment style and density.
- No hedging, filler or AI attribution.
- **Style pass.** If the `write-like-a-human` skill is installed, run it on the drafts before handing them over.

## 5. Anchor each comment

- Added or changed lines: the line number in the new file, which is where GitHub puts a comment on the right side of the diff.
- Removed lines: the line number in the old file, marked "deleted line", so the user comments on the left side.
- A range (`path:12-18`) when the comment covers a block. GitHub takes a range by dragging over the line numbers.
- Work every number out from the `@@` hunk headers in `git diff`. Never estimate one. A code comment gives the line it goes above.

## 6. Hand over (in chat)

1. One line naming who the comments are for, e.g. "Written for: reviewers of this PR."
2. **PR comments**, then **Code comments**, then **Questions for you**. Leave out an empty group. Each item is `path:line` on its own line, then the comment in a code block, ready to paste.
3. If nothing qualifies, say "No comments needed" and why in one line, and stop.

## Rules

- Never post, comment, review, edit the PR, edit files, commit or push.
- Never invent a reason or a link. A why with no evidence is a question.
- Every line anchor is checked against the hunk headers.
- Never hard-wrap prose. One comment paragraph is one line.
