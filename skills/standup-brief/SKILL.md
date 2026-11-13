---
name: standup-brief
description: Set up or run a personal weekday standup brief that reads the user's own activity from the previous workday in Slack, GitHub and Jira, and turns it into a paste-ready standup update (yesterday, today, blockers) plus a capacity call on whether they're free to help others. Use when the user asks to set up, change or run their standup brief, daily update, "what did I do yesterday", or invokes /standup-brief. Not for workspace-wide news; that's slack-morning-brief.
---

# Standup brief

Read only in Slack, GitHub and Jira. Two modes:

- **Setup**: first use, or the user asks to set the brief up or change it. Follow section 1.
- **Run**: the user asks for the brief now. Fill the template in section 2 from what the conversation already knows, ask only for missing fields, then follow it.

## 1. Setup

Ask in one round of questions:

- Name, role and team
- Time zone and standup time. The brief runs 30 minutes before standup, Monday to Friday, unless they say otherwise.
- Slack user ID, and the team channels where people ask for help or reviews
- Whether to include private channels and DMs in Slack searches (yes or no). A scheduled run can't ask, so record the answer.
- GitHub username and the orgs or repos to cover
- Jira site and project keys
- Optional: where the update gets posted (channel name), so the paste-ready block matches its usual style

Then check which sources this environment can actually reach, and tell the user in one line per source:

- Slack: a Slack connector with search
- Jira: an Atlassian connector with JQL search
- GitHub: a GitHub connector, or an authenticated `gh` CLI (`gh auth status`). If neither exists, say GitHub will be skipped and the brief will rely on PR links found in Slack and Jira.

Then:

1. List the existing scheduled tasks first. If a standup brief task already exists, offer to update it: replace its whole prompt with a freshly filled section 2 template, reuse the answers from the old prompt and ask only for fields the old prompt lacks. Never create a duplicate.
2. If scheduled-task tools are available (Cowork), create a recurring weekday task:
   - Schedule: standup time minus 30 minutes, as `CRON_TZ=<time zone> <min> <hour> * * 1-5`. If the tool's schema takes the time zone another way, follow the schema.
   - Push notification on.
   - Prompt: the run instructions from section 2 with every placeholder filled in, so it stands alone with no reference to this skill.
3. If they're not available, print the filled prompt in a code block with the cron line, and tell the user how to create the task themselves: a new scheduled task in Cowork, or `/schedule` in Claude Code.
4. Tell the user in one line that local scheduled tasks only run while the computer is awake and the app is open. A missed run fires on wake, so the brief arrives late rather than never. The schedule skips weekends but not public holidays.

## 2. Run instructions

The scheduled prompt template. Fill every placeholder; write "none" for empty optional fields.

```
Standup brief for {{name}}, {{role}} on {{team}}. Time zone {{timezone}}, standup at {{standup_time}}.
Slack user ID {{slack_user_id}}. GitHub user {{github_user}}, scope {{github_scope}}. Jira site {{jira_site}}, projects {{jira_projects}}.
Help channels: {{help_channels}}. Include Slack private channels and DMs: {{include_private}}.

READ ONLY, HARD RULE: never post, react, comment, edit, transition, assign or draft anything in Slack, GitHub or Jira. Use only search and read tools.

Lookback: from 00:00 local on the previous workday until now. On Monday that is Friday 00:00, so weekend work is included. Today is a workday by definition; if it is Saturday or Sunday, reply "Weekend, no brief." and stop.

1. Collect what {{name}} did in the lookback:
   - Slack: messages from {{slack_user_id}}, using the tool's timestamp filters, or `from:<@{{slack_user_id}}> on:<date>` once per day in the lookback. Search public channels; also private channels and DMs only if include_private is yes. Open threads {{name}} replied in to see how they ended.
   - GitHub: PRs authored and updated in the lookback (opened, merged, closed), PRs {{name}} reviewed, and commits pushed. With `gh`: `gh search prs --author={{github_user}} --updated=">=<date>"`, `gh search prs --reviewed-by={{github_user}} --updated=">=<date>"`, `gh search commits --author={{github_user}} --committer-date=">=<date>"`, each scoped with `--owner` or `--repo` from {{github_scope}}.
   - Jira: `issuekey IN updatedBy(currentUser(), "<start>", "<end>") AND project IN ({{jira_projects}})`, then for each issue note what {{name}} changed: status moves, comments, new issues created.
2. Collect what is on {{name}}'s plate today:
   - Jira: `assignee = currentUser() AND statusCategory != Done AND project IN ({{jira_projects}}) ORDER BY priority DESC, updated DESC`
   - GitHub: {{name}}'s open PRs and their state (changes requested, approved and unmerged, failing checks, waiting on review), and open review requests to {{github_user}}.
   - Slack: commitments {{name}} made in the lookback that aren't visibly done, e.g. "I'll check", "I'll confirm", "will follow up", "let me look". Check later messages, PRs and tickets before listing one as open.
3. Collect who could use help, max 3, only from {{team}} or {{help_channels}}:
   - Teammates' PRs waiting on review for more than one workday
   - Questions in help channels with no answer after 4 hours
   - Unassigned support or bug tickets in {{jira_projects}} created in the lookback
4. Merge across sources. One piece of work usually shows up as a Jira ticket, a PR and a Slack thread; group them under the ticket key (PR titles and branches often contain it). Drop noise: emoji-only replies, routine acks, bot messages, drafts.
5. Decide capacity, and give the reason in one clause:
   - Booked: an in-progress ticket with real work left, a PR with changes requested, or an incident or hotfix in flight.
   - Some room: work is waiting on others (review, QA, deploy) or small follow-ups only.
   - Free to help: nothing in progress that needs {{name}}'s hands today.
   When unsure, pick the busier level. Don't infer capacity from calendar or meetings; that isn't in scope.
6. Reply with exactly this, phone-friendly, readable in under 1 minute:

**Standup brief, <Weekday> <D Mon>**

Paste-ready:
> **Yesterday**
> - <What was done, outcome first, with ticket key or PR number>
> **Today**
> - <Top priority first>
> **Blockers**
> - <Blocker and who it's waiting on, or "None">
> **Capacity:** <Booked | Some room | Free to help>, <reason>

For you, not for standup:
- **Follow-ups you promised:** <commitment> · link
- **Waiting on you:** <review request or question> · link
- **Could help:** <person, thing, how long it's been waiting> · link

Rules: the paste-ready block is in first person, written like {{name}} would say it at standup, max 4 bullets under Yesterday and 3 under Today. Each bullet names the specific thing and its state (merged, deployed, in review, confirmed fixed), not the activity ("worked on", "looked into"). Today comes from Jira priority, open PRs and open commitments, in that order; don't invent tasks. Omit empty lines in "For you"; if all three are empty, omit the section. "Could help" appears only when capacity is Some room or Free to help. Every item needs a link. No preamble or closing summary. No emojis. Straight apostrophes, no em dashes.

If a source is unavailable or fails, still produce the brief from the others and add one line at the end: "Missing: <source>". Never invent tickets, PRs, people or links. If all sources fail, reply with one line saying so.
```

## Rules

- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
