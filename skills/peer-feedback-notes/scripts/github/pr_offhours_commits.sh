#!/usr/bin/env bash
# Usage: pr_offhours_commits.sh <login> <since YYYY-MM-DD> (--owner <org> | --repo <owner/repo> ...)
# Env: TZ_OFF (required: the colleague's UTC offset in seconds), NIGHT_START (default 22), NIGHT_END (default 6)
set -euo pipefail
LOGIN="$1"; SINCE="$2"; shift 2
[ $# -gt 0 ] || { echo "Scope required: --owner <org> or --repo <owner/repo>" >&2; exit 1; }
[ -n "${TZ_OFF:-}" ] || { echo "TZ_OFF required: the colleague's UTC offset in seconds, e.g. 3600 for UTC+1. GitHub reports commit times in UTC." >&2; exit 1; }
export TZ_OFF
START="${NIGHT_START:-22}"; END="${NIGHT_END:-6}"
LIMIT=200
prs="$(gh search prs --author "$LOGIN" --created ">=$SINCE" --limit "$LIMIT" "$@" \
  --json repository,number --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)"')"
[ -n "$prs" ] || exit 0
if [ "$(printf '%s\n' "$prs" | wc -l)" -ge "$LIMIT" ]; then
  echo "Warning: hit --limit $LIMIT, results are truncated. Narrow the date or scope." >&2
fi
printf '%s\n' "$prs" |
while IFS=$'\t' read -r repo n; do
  gh pr view "$n" -R "$repo" --json commits \
    --jq '.commits[] | ($ENV.TZ_OFF | tonumber) as $o | [(.authoredDate | fromdateiso8601 + $o | strftime("%a %m-%d %H:%M")), .messageHeadline] | @tsv' |
  awk -v r="$repo" -v n="$n" '{print r "#" n "\t" $0}'
done |
awk -F'\t' -v s="$START" -v e="$END" '{split($2, a, " "); split(a[3], t, ":"); h = t[1] + 0;
  if (a[1] == "Sat" || a[1] == "Sun" || h >= s || h < e) print}'
