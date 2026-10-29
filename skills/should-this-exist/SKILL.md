---
name: should-this-exist
description: Challenge a task, list, report, automation or piece of work before doing it. Decide whether to drop, delegate, defer, shrink or do it. Use when the user runs /should-this-exist or asks whether something is worth doing.
argument-hint: "[task]"
disable-model-invocation: true
---

# Should this exist

Purpose: use AI to select and remove work, not to multiply it. Do not start the task until this check is done.

## Step 1: ask before acting

Always establish ownership first: "Is this mine to decide, or whose is it (team, PM, lead, another team)?" Skip it only if the answer is obvious from the request. It counts towards the 3-question limit.

Ask at most 3 questions in one message. Choose the ones whose answers would most change the verdict:

- What decision or outcome does this serve? Who acts on it?
- What happens if it is never done? If it is done a week late?
- Is this a one-off or will it recur? How often?
- Could someone or something else own it (team, existing tool, automation already in place)?
- What would a much smaller version look like?

If the request already answers them, skip to Step 2 and state the assumptions you made.

## Step 2: run the lenses

Apply only the lenses that fit. One line each.

1. **Select, don't multiply.** Of the N items, which deserve time at all? Rank by value to the stated goal, not by how fast they can be finished.
2. **Movement vs action.** Sort each item: drop, delegate, defer, do. Default to drop for anything with no owner or no decision attached.
3. **Global before local.** Before improving it, ask whether it should exist at all or be replaced by something different (a dashboard instead of a report, a CI check instead of a review step, an async note instead of a meeting).
4. **Extract the principle.** If this will recur, what reusable rule, template or check would remove the need to think about it next time?
5. **Subtract.** What can be unsubscribed from, deleted, cancelled or stopped as a result?

## Step 3: verdict

Output only this:

- **Verdict:** drop / delegate / defer / shrink / do
- **Why:** one line
- **If doing it:** the smallest version that meets the goal
- **Stop doing:** anything this check shows can be removed
- **Raise with:** only if the work is shared or owned by someone else. Name the owner and give a two-line case to send them: who uses it, what decision it drives, and what replaces it if it's cut.

Then wait. Only do the task if the user confirms.

## Rules

- On shared work, every verdict except "do" is a proposal, not a decision. Don't recommend dropping or changing someone else's work without stating the evidence the owner would need.
- No praise, no reassurance, no productivity tips.
- Don't manufacture a cut. If it should be done as asked, say "do it as is" and why.
- For small tasks (under 15 minutes, no recurrence), say "just do it" and stop.
