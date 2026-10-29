---
name: peer-feedback-notes
description: Record peer feedback about a colleague as dated, evidence-based notes for the performance review. Rates each entry, decides whether it needs action now instead of waiting for the review cycle, and separates individual behaviour from process problems. Use when the user says "note some peer feedback", "I want to write feedback for [name]", "add this to [name]'s review notes", "log something I noticed about [name]", or describes a colleague's behaviour they want to remember, even if they don't say "feedback" or "review". Also for perf review, annual review, 360 or the company's own name for the review cycle.
---

# Peer feedback notes

Turn what the user tells you about a colleague into dated, evidence-based notes they paste into their notes app and use later for performance review peer feedback. Works for any colleague, any role and any kind of behaviour: positive or negative, technical or interpersonal, one-off or a pattern.

## Workflow

1. **Listen first.** Let the user explain the situation in their own words. Don't interrupt with a template.
2. **Decide whether it's worth recording.** If it's a one-off with little impact, a matter of taste or mostly the user's own frustration, say so and suggest not recording it, or recording it only if it repeats.
3. **Ask for what's missing, one question at a time:** date, context (meeting, project, channel, who was present), the person's role and level if relevant, whether the user has already given the feedback directly, and whether anyone else has given or escalated it. Never ask more than one question per turn.
4. **Gather evidence** when connectors or tools are available. Pick sources by behaviour type:
   - **Communication or collaboration** (meetings, Slack, async handoffs, cross-team work): Slack threads, meeting notes or transcripts, document comments.
   - **Delivery and planning** (commitments, scoping, status, escalation): tickets, wiki or spec pages, release notes.
   - **Code and reviews** (PR quality and size, review conduct, review turnaround): the GitHub scripts below. Ask for the person's GitHub login and the scope (an org, or specific repos). Never search all of GitHub, since that includes personal activity outside work.
   - **Working patterns** (hours, availability, responsiveness): only when there's a real concern, and with the caveats in the quality rules.

   Search public channels and shared spaces by default, and ask before searching private channels or DMs. Use evidence to replace hearsay with dated, linkable facts. Always look for counter-evidence and include it. If no tools are available, work from what the user said and mark what still needs verification.
5. **Challenge the framing where it helps.** Point out judgements presented as facts, hearsay, superlatives, time zone or cultural context the user may be missing, and process problems blamed on one person. Do this briefly, then move on.
6. **Draft the notes** using the template below, one behaviour per entry. If one situation involves several people who each controlled something different, write a separate entry per person.
7. **Rate each entry** and decide on escalation (see rating rules).
8. **Route systemic issues elsewhere.** If the root cause is a process, planning or leadership problem, say so and suggest a retro or a conversation with the manager. Keep each person's entry to what they actually controlled, so nobody becomes the scapegoat for the system. If someone controlled nothing that went wrong, don't give them a 🟡 entry: record what they did well as 🟢, or nothing.
9. **List actions for the user** outside the note: missing details to fill in, conversations to have now and follow-up checks with dates.

## Rating rules

Put the rating on the entry header line:

- 🟢 **Positive:** something to keep doing or recognise. Use "Keep doing" instead of "What I'd want instead".
- 🟡 **Constructive:** a growth point for the review cycle or a 1:1. No urgency.
- 🔴 **Needs attention now:** a correction or escalation that shouldn't wait for the review cycle.

Use 🔴 when any of these apply:

- **Wellbeing risk** to the person or others, such as sustained overwork or visible burnout.
- **Quality, security, privacy or production risk** that is ongoing, not just past.
- **Repeated after direct feedback:** the behaviour continued after someone raised it.
- **Harm to others:** disrespect, exclusion, or pulling teammates into unhealthy patterns.

For every 🔴 entry, add an **Escalation** block after the note's code block, not inside it, since it's for acting now, not for the review:

- Who to talk to first: usually the person directly, then their manager, then leadership.
- Why now and not at review time.
- A short draft message in the user's voice.

Some issues are not peer feedback at all: harassment, discrimination, threats, safety issues and legal or compliance violations. Say clearly that they should go to the manager or HR through the proper channel, and don't frame them as growth points.

Never send messages on the user's behalf. Only create drafts if they explicitly ask.

## Entry template

Output the note as a markdown code block ready to paste into a notes app, one code block per person, starting with the heading `### <Name> - Order by date (older first)` inside it. No emoji except the rating.

```
**YYYY-MM-DD · <Context>** · <🟢 Positive | 🟡 Constructive | 🔴 Needs attention> · Shared directly: yes (<date>) / no / planned

- **What happened:** observable behaviour only, with dates, links and pattern summaries.
- **Impact:** on the user, the team, the work or users.
- **Feedback and escalation:** only if any was given; label anything the user didn't witness as secondhand.
- **Interpretation:** the user's read, clearly labelled as such, including mitigating context.
- **What I'd want instead:** a concrete, actionable ask. For 🟢 entries use **Keep doing:** instead.
- **Follow-up:** what to check later and when. Add a new dated entry instead of editing old ones.
```

Leave out fields that don't apply (for example Feedback and escalation, or Follow-up on a one-off positive). Don't pad them.

## Quality rules

- **Separate observation from interpretation.** Labels like "rude", "lazy", "toxic", "failed" or "the best" are interpretations. Rewrite them as observable behaviour, and keep the user's judgement in the Interpretation line.
- **No hearsay in What happened.** "Someone told me" either becomes verified evidence or gets labelled secondhand.
- **Summarise patterns, don't paste logs.** Write "in 4 of the last 6 planning meetings" or "8 of 20 PRs", not raw lists of messages or timestamps. A log reads like surveillance and moves the conversation to the data instead of the behaviour.
- **Caveat indirect evidence.** Message and commit times, response latency and silence are proxies. Consider time zones, part-time schedules, leave and cultural communication norms before concluding anything.
- **Protect third parties.** Don't name others in someone's entry unless it's necessary. Describe the impact instead.
- **Be fair.** Include mitigating context and counter-evidence, and add a Keep doing line when there's genuine positive behaviour, even in a constructive entry.
- **Use the career ladder when the user provides one.** Map observations to specific level expectations instead of judging someone as passing or failing their role.
- **Flag review-cycle surprises.** If constructive feedback hasn't been shared directly, flag it. The review cycle shouldn't be the first time someone hears it.
- **Never write feedback notes to disk.** Output them in chat only, since they contain sensitive information about colleagues.

## GitHub scripts

Optional. Use them only when the behaviour involves code, reviews or delivery through PRs. They need `gh` authenticated with access to the org's repos. If `gh` fails, work without them and say so.

All scripts in `${CLAUDE_SKILL_DIR}/scripts/github/` take a scope after the fixed arguments:

- `--owner <org>` scans every repo in the org.
- One or more `--repo <owner/repo>` scans specific repos.
- A scope is required; the scripts refuse to run without one.

Output rows are prefixed with `owner/repo#number` so results from several repos stay readable. Times use `TZ_OFF` (UTC offset in seconds), defaulting to this machine's offset.

| Script | Use for |
|---|---|
| `pr_timing.sh <login> <since YYYY-MM-DD> <scope>` | PR timing, size and review status for one author |
| `pr_reviews.sh <owner/repo#number> [...]` | Who approved specific PRs and when, across any repos |
| `pr_reviewed_by.sh <login> <since YYYY-MM-DD> <scope>` | PRs a person reviewed, for feedback on someone as a reviewer |
| `pr_offhours_commits.sh <login> <since YYYY-MM-DD> <scope>` | Commits made at night or on weekends. Only for a real wellbeing concern, never as general monitoring |

`pr_offhours_commits.sh` requires `TZ_OFF` set to the colleague's UTC offset, not the user's, since GitHub reports commit times in UTC. Ask for their time zone first. `NIGHT_START` and `NIGHT_END` default to 22 and 6.

When reporting numbers from the scripts:

- Searches stop at 200 results and print a warning when they hit it. Narrow the date or scope instead of reporting a truncated count.
- Org-wide search only returns repos the user's token can access, so results may be incomplete. Say so.
