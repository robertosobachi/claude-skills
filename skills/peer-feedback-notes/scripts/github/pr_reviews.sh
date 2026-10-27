#!/usr/bin/env bash
# Usage: pr_reviews.sh <owner/repo#number> [<owner/repo#number> ...]
# Env: TZ_OFF (UTC offset in seconds, default this machine's offset)
set -euo pipefail
[ $# -gt 0 ] || { echo "Usage: pr_reviews.sh <owner/repo#number> [...]" >&2; exit 1; }
export TZ_OFF="${TZ_OFF:-$(date +%z | awk '{s = substr($0, 1, 1) == "-" ? -1 : 1; print s * (substr($0, 2, 2) * 3600 + substr($0, 4, 2) * 60)}')}"
for ref in "$@"; do
  repo="${ref%#*}"; n="${ref##*#}"
  gh pr view "$n" -R "$repo" --json reviews \
    --jq '.reviews[] | select(.state == "APPROVED") | ($ENV.TZ_OFF | tonumber) as $o | [.author.login, (.submittedAt | fromdateiso8601 + $o | strftime("%a %m-%d %H:%M"))] | @tsv' |
  awk -v r="$ref" '{print r "\t" $0}'
done
