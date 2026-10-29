#!/usr/bin/env bash
# Zips skills into dist/ for upload to Claude Desktop and claude.ai
# (Customize > Skills). Pass skill names, or none for the skills
# that work without a local repo. --since <rev> packs only those
# that changed between <rev> and HEAD.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dist="$repo/dist"
defaults=(peer-feedback-notes handover-prompt slack-morning-brief should-this-exist)
note=""

if [[ "${1:-}" == "--since" ]]; then
  rev="${2:?--since needs a revision}"
  set --
  for name in "${defaults[@]}"; do
    if ! git -C "$repo" diff --quiet "$rev" HEAD -- "skills/$name"; then
      set -- "$@" "$name"
    fi
  done
  [[ $# -eq 0 ]] && exit 0
  note=", re-upload in Customize > Skills"
elif [[ $# -eq 0 ]]; then
  set -- "${defaults[@]}"
fi

mkdir -p "$dist"

for name in "$@"; do
  if [[ ! -f "$repo/skills/$name/SKILL.md" ]]; then
    echo "skip   $name: no skills/$name/SKILL.md"
    continue
  fi
  if grep -q '^description:.*<' "$repo/skills/$name/SKILL.md"; then
    echo "skip   $name: description contains <...>, which the upload rejects as an XML tag"
    continue
  fi
  zip_path="$dist/$name.zip"
  rm -f "$zip_path"
  (cd "$repo/skills" && zip -qr "$zip_path" "$name" -x '*.DS_Store' '*/.claude/*')
  echo "packed $zip_path$note"
done
