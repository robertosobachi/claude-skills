#!/usr/bin/env bash
# Copies the first argument to the system clipboard.
# Tries each clipboard tool in turn and exits 1 if none works.
set -uo pipefail

text="${1:?usage: copy.sh <text>}"

for cmd in pbcopy wl-copy "xclip -selection clipboard" "xsel --clipboard --input" clip.exe; do
  if command -v "${cmd%% *}" >/dev/null 2>&1; then
    printf '%s' "$text" | $cmd 2>/dev/null && exit 0
  fi
done

echo "no clipboard available" >&2
exit 1
