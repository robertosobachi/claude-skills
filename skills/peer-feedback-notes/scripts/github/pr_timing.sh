#!/usr/bin/env bash
# Usage: pr_timing.sh <login> <since YYYY-MM-DD> (--owner <org> | --repo <owner/repo> ...)
# Env: TZ_OFF (UTC offset in seconds, default this machine's offset)
set -euo pipefail
LOGIN="$1"; SINCE="$2"; shift 2
[ $# -gt 0 ] || { echo "Scope required: --owner <org> or --repo <owner/repo>" >&2; exit 1; }
export TZ_OFF="${TZ_OFF:-$(date +%z | awk '{s = substr($0, 1, 1) == "-" ? -1 : 1; print s * (substr($0, 2, 2) * 3600 + substr($0, 4, 2) * 60)}')}"
LIMIT=200
prs="$(gh search prs --author "$LOGIN" --created ">=$SINCE" --sort created --order desc --limit "$LIMIT" "$@" \
  --json repository,number --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)"')"
[ -n "$prs" ] || exit 0
if [ "$(printf '%s\n' "$prs" | wc -l)" -ge "$LIMIT" ]; then
  echo "Warning: hit --limit $LIMIT, results are truncated. Narrow the date or scope." >&2
fi
printf '%s\n' "$prs" |
while IFS=$'\t' read -r repo n; do
  gh pr view "$n" -R "$repo" \
    --json createdAt,mergedAt,additions,deletions,changedFiles,reviewDecision,title \
    --jq '($ENV.TZ_OFF | tonumber) as $o | [
      (.createdAt | fromdateiso8601 + $o | strftime("%a %m-%d %H:%M")),
      (if .mergedAt then (.mergedAt | fromdateiso8601 + $o | strftime("%a %m-%d %H:%M")) else "not merged" end),
      "+\(.additions)/-\(.deletions)",
      "\(.changedFiles) files",
      (.reviewDecision // "no review"),
      .title
    ] | @tsv' |
  awk -v r="$repo" -v n="$n" '{print r "#" n "\t" $0}'
done
