#!/usr/bin/env bash
# Links every skill in this repo into ~/.claude/skills.
# Safe to run again: pulls the latest changes, links new skills
# and removes links to skills that no longer exist.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [[ "${1:-}" != "--no-pull" ]]; then
  git -C "$repo" pull --ff-only --quiet
fi

mkdir -p "$target"

for dir in "$repo"/skills/*/; do
  name="$(basename "$dir")"
  link="$target/$name"
  if [[ -e "$link" && ! -L "$link" ]]; then
    echo "skip   $name: $link exists and isn't a symlink"
    continue
  fi
  ln -sfn "${dir%/}" "$link"
  echo "linked $name"
done

for link in "$target"/*; do
  if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$repo"/* ]]; then
    rm "$link"
    echo "removed $(basename "$link") (no longer in the repo)"
  fi
done
