#!/usr/bin/env bash
# Zips skills into dist/ for upload to Claude Desktop and claude.ai
# (Customize > Skills). Pass skill names, or none for the skills
# that work without a local repo.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dist="$repo/dist"

if [[ $# -eq 0 ]]; then
  set -- peer-feedback-notes handover-prompt slack-morning-brief
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
  echo "packed $zip_path"
done
