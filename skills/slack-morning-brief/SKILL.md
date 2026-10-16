---
name: slack-morning-brief
description: Set up or run a personal weekday Slack brief of decisions, launch go/no-gos, scope changes and incidents across the workspace, before the workday starts.
---

# Slack morning brief

Read only in Slack. Two modes:

- **Setup**: first use, or the user asks to set the brief up or change it. Follow section 1.
- **Run**: the user asks for the brief now. Fill the template in section 2 from what the conversation already knows, ask only for missing fields, then follow it.

## 1. Setup

Ask in one round of questions:

- Name, role and team (used to judge relevance)
- Time zone and work start time. The brief runs 35 minutes before start, Monday to Friday, unless they say otherwise.
- Watch terms: partners, products and projects to always search for, e.g. bank or partner names
- Optional: channels to always include or always skip

Then:

1. List the existing scheduled tasks first. If a Slack brief task already exists, offer to update it. Never create a duplicate.
2. If scheduled-task tools are available (Cowork), create a recurring weekday task:
   - Schedule: start time minus 35 minutes, as `CRON_TZ=<time zone> <min> <hour> * * 1-5`. If the tool's schema takes the time zone another way, follow the schema.
   - Push notification on.
   - Prompt: the run instructions from section 2 with every placeholder filled in, so it stands alone with no reference to this skill.
3. If they're not available, print the filled prompt in a code block with the cron line, and tell the user how to create the task themselves: a new scheduled task in Cowork, or `/schedule` in Claude Code.
4. Tell the user in one line that local scheduled tasks only run while the computer is awake and the app is open. A missed run fires on wake, so the brief arrives late rather than never.

## 2. Run instructions

The scheduled prompt template. Fill every placeholder; write "none" for empty optional fields.

```
Slack morning brief for {{name}}, {{role}} on {{team}}. Time zone {{timezone}}, workday starts {{start_time}}.

READ ONLY, HARD RULE: never post, react, edit, draft or send anything in Slack. Use only search and read tools.

Lookback: Tuesday to Friday, from 18:00 local the previous day. Monday, from 18:00 local the previous Friday.

1. Search the whole workspace first, including channels {{name}} is not in. Search public and private; if that fails, fall back to public only. Run targeted queries:
   - Decisions: decided, decision, go/no-go, no-go, going with, agreed, approved, reverted, rolled back
   - Changes: postponed, delayed, moved to, rescheduled, cancelled, deprioritized, deprioritised, descoped, deadline, launch, release, freeze
   - Risk: incident, outage, blocked, blocker, hotfix, rollback
   - Watch terms: {{watch_terms}}, plus partner or product names that come up in results
   - Role scope: terms relevant to {{role}} and {{team}}
   Always include: {{include_channels}}. Always skip: {{skip_channels}}.
2. Open promising threads to confirm what was decided and whether it is final. Then check {{name}}'s own channels for anything the searches missed.
3. Keep only items that change what {{name}} or their team does, plans or knows. Drop chit-chat, routine pings, bot noise and things resolved with no lasting impact. Merge duplicates. Skip personal and HR matters.
4. Reply with exactly this, phone-friendly, readable in under 2 minutes:

**Slack brief, <Weekday> <D Mon>**
<One-line TL;DR, or "Quiet night, nothing that changes your day.">

**Must know** (max 3)
- **<Headline naming the specific thing, ~10 words>**
  <One sentence: what changed and what it means for {{name}}.> #channel · link

**Good to know** (max 4)
- **<Headline>** <half-sentence> · #channel · link

Rules: max 7 items, then "+N minor items skipped". Omit empty sections. Mark "(not in channel)" and "(not final)" where they apply. Headlines must make sense without opening the link. No preamble or closing summary. No emoji, straight apostrophes, no em dashes.

If Slack tools are unavailable, reply with one line saying so. Never invent items, channels or links.
```
