#!/usr/bin/env bash
# Links every skill in this repo into ~/.claude/skills, and with
# --with-agents every subagent in agents/ into ~/.claude/agents.
# Safe to run again: pulls the latest changes, links new items
# and removes links to items that no longer exist. Also enables
# githooks/, so a plain git pull does the same from then on.
# --with-agents is remembered in this clone's git config, so the
# hooks keep linking agents; undo with --without-agents.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_target="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
agents_target="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"

pull=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-pull) pull=0 ;;
    --with-agents) git -C "$repo" config claude-skills.agents true ;;
    --without-agents) git -C "$repo" config --unset claude-skills.agents || true ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done
with_agents="$(git -C "$repo" config --get claude-skills.agents || true)"

dirty="$(git -C "$repo" status --porcelain -- skills agents)"
if [[ -n "$dirty" ]]; then
  echo "warn   local edits under skills/ or agents/ will diverge, commit them upstream or git restore:"
  printf '%s\n' "$dirty" | sed 's/^/         /'
fi

if [[ $pull -eq 1 ]]; then
  CLAUDE_SKILLS_INSTALLING=1 git -C "$repo" pull --ff-only --quiet
fi

# link_dir <source glob dir> <target dir>: links each entry, then removes
# links into this repo whose source is gone. Never touches a real file.
link_dir() {
  local src="$1" target="$2" entry name link
  mkdir -p "$target"
  for entry in "$src"/*; do
    [[ -e "$entry" ]] || continue
    name="$(basename "$entry")"
    link="$target/$name"
    if [[ -e "$link" && ! -L "$link" ]]; then
      echo "skip   $name: $link exists and isn't a symlink"
      continue
    fi
    ln -sfn "$entry" "$link"
    echo "linked $name"
  done
  for link in "$target"/*; do
    if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$repo"/* ]]; then
      rm "$link"
      echo "removed $(basename "$link") (no longer in the repo)"
    fi
  done
}

link_dir "$repo/skills" "$skills_target"

if [[ "$with_agents" == true ]]; then
  link_dir "$repo/agents" "$agents_target"
else
  # Opted out: remove only the agent links that point into this repo.
  for link in "$agents_target"/*; do
    if [[ -L "$link" && "$(readlink "$link")" == "$repo"/agents/* ]]; then
      rm "$link"
      echo "removed $(basename "$link") (agents not enabled, use --with-agents)"
    fi
  done
fi

if [[ "$(git -C "$repo" config --get core.hooksPath || true)" != githooks ]]; then
  git -C "$repo" config core.hooksPath githooks
  echo "hooks  githooks/ enabled, git pull now relinks and repacks"
fi
