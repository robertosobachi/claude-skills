# claude-skills

My personal skills for [Claude Code](https://code.claude.com/docs/en/skills).

## Skills

- `ai-practice`: turns a working session into practice at building AI tooling on the real task at hand, and logs honest results.
- `commit-title`: writes a gitmoji commit title for the staged changes.

## Install

```
git clone https://github.com/robertosobachi/claude-skills ~/Developer/claude-skills
mkdir -p ~/.claude/skills
for d in ~/Developer/claude-skills/skills/*/; do ln -s "${d%/}" ~/.claude/skills/; done
```

Invoke by name in Claude Code, e.g. `/commit-title`.

## Licence

MIT
