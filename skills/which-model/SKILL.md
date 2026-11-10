---
name: which-model
description: Suggest the Claude model and effort level to run a task on, or the next step when a result falls short. Prints the /model and /effort commands to type and changes nothing.
disable-model-invocation: true
argument-hint: "[task, or what went wrong]"
---

## Context

Read [models.md](models.md) in this skill's folder before anything else. It holds the task table, the escalation order and the date it was last checked against its source.

## Your task

Suggest the model and effort level for the user's work. Don't switch anything yourself; the user types the commands.

Work out what the user is doing from the first of these that tells you:

1. `$ARGUMENTS`, if given.
2. The conversation so far.

Take the current model from your session context. If the current effort level matters to the answer and you can't see it, assume `medium` and say so in the why line.

Then pick one mode:

- **Starting a task.** Match the task to a row in the table by what the work is, not by shared words. A clear spec doesn't by itself make a task well scoped: migrations, performance work and anything crossing many modules stay on the bigger model. If two rows fit, take the heavier one. If a row in the "Measured" section covers the task, it wins over the table.
- **Falling short.** Use this when the user says a result failed, keeps failing or a model isn't good enough. Give only the next step of the escalation order, starting from where they are now. Don't skip steps unless the user says an earlier one is already done.

If the recommendation equals the current model and effort, say "stay" and why.

## Output

- The commands, one per line: `/model <alias>` then `/effort <level>`. Leave out a command that wouldn't change anything.
- One line on why, naming the table row or escalation step.
- Only when the model changes mid-session, one more line: run `/compact` first, or start a fresh session from a short written plan. Add that a move down from the heaviest model loses its earlier reasoning when that's the move.
- If models.md was last checked more than 90 days ago, one line saying the table may be stale and to re-check its source.
- If the task is too thin to choose, ask one question instead.

Nothing else.

## Rules

- Recommend from models.md, not from memory. If the user names a model that isn't in it, say the table doesn't cover it.
- Never recommend raising effort past `high` on the default model. Recommend the next model up at `medium` instead.
- Don't recommend plan/execute split aliases, advisor setups or orchestrator patterns. They need measuring on the user's own work first.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
