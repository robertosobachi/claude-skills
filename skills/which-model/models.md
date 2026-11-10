# Models

Last checked: 2026-11-09. Source: [Which Claude model should you build with?](https://claude.dev/blog/which-claude-model-should-you-build-with/)

When a new model ships, re-read the source and update this file and the date. Most figures in the source are Anthropic's own benchmarks. They give a starting point, not a verdict on your work.

## Lineup

| Model | `/model` alias | Role | Relative cost per token | Latency |
|---|---|---|---|---|
| Haiku 5.5 | `haiku` | Classification, routing, extraction, mechanical side tasks | Lowest by far | Fastest |
| Sonnet 5.5 | `sonnet` | Well-scoped coding, documents, chat, repeated agent tasks | About half of Opus | Fast |
| Opus 5.5 | `opus` | Default for complex coding and knowledge work | Baseline | Moderate |
| Fable 5.2 | `fable` | Hardest coding, migrations, architecture, long unattended runs | About twice Opus | Moderate |

If an alias isn't recognised, pick the model from the `/model` list. Effort levels, lowest to highest: `low`, `medium`, `high`, `xhigh`, `max`.

## Task table

| Task | Model | Starting effort |
|---|---|---|
| Not sure yet | Opus | `medium` |
| Everyday engineering, debugging, features spanning several PRs | Opus | `medium`, then `high` |
| Well-scoped coding: a bug fix, iterating on a feature, work against a clear spec | Sonnet | `medium`, then `high` |
| Repeated agent tasks: investigation, review, drafting | Sonnet | `medium` |
| Chat and interactive sessions where you wait on each reply | Sonnet | `low` or `medium` |
| Everyday documents, slides, spreadsheets | Sonnet | `medium` |
| Complex financial models, documents built from a large pile of sources | Opus | `medium` |
| Computer use, vision-heavy work | Opus | `medium` |
| Major refactors, migrations, architecture planning, leading many subagents | Fable | `medium`, then `high` |
| Deep research, scientific or quantitative analysis | Fable | `medium`, then `high` |
| Long unattended runs | Fable | `medium` |
| Classification, routing, tagging, high-volume extraction | Haiku | `medium` |

A clear spec doesn't make a task small. Migrations and performance work can still need Opus, or Fable for a major one.

## Escalation order

When a result falls short, take the next step only:

1. Make sure the agent can check its own work: a test, a build or a script it can run.
2. Raise effort one level.
3. Move to the next model up, at a lower effort than the one that fell short.

Past `high`, one more effort level can cost as much as the next model up. In the source, Fable 5.2 at `high` scored about the same as Opus 5.5 at `max` for roughly half the cost per task. So on Opus, go to Fable at `medium` before `xhigh` or `max`.

Going the other way: if a cheaper setting still gets the result, take it. On Opus 5.5, `medium` scored about 2.5 points below `high` at about 70% of the cost.

## Switching models

- Switch at a natural break. The prompt cache belongs to the model that wrote it, so the first turn on a new model pays to re-cache the whole conversation. Run `/compact` first, or start a fresh session from a short written plan.
- A model reads the earlier reasoning of smaller models, not of bigger ones. A move down loses the earlier reasoning; a move down from Fable loses all of it.
- Fast mode on Opus or Fable buys speed without dropping capability.

## Measured

Rows here come from evals on real work. They win over the task table for the same task.

None yet.
