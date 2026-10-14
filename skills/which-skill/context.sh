#!/usr/bin/env bash
# Prints the frontmatter of every installed skill and the current git state,
# for which-skill to choose from. Always exits 0: a failing injected command
# aborts the skill.
shopt -s nullglob

echo "## Installed skills"
echo
for file in "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"/*/SKILL.md ./.claude/skills/*/SKILL.md; do
  [[ -r "$file" ]] || continue
  echo "### $(basename "$(dirname "$file")")"
  awk '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    /^[A-Za-z_-]+:/ { keep = $0 ~ /^(name|description|when_to_use|disable-model-invocation):/ }
    NR > 1 && keep { print }
  ' "$file"
  echo
done

echo "## Working state"
echo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Branch: $(git branch --show-current)"
  echo
  echo "Status:"
  git status --short
  echo
  echo "Recent commits:"
  git log --oneline -5 2>/dev/null || echo "None"
else
  echo "Not in a git repo."
fi

exit 0
