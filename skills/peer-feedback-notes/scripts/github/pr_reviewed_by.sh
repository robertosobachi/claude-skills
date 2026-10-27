#!/usr/bin/env bash
# Usage: pr_reviewed_by.sh <login> <since YYYY-MM-DD> (--owner <org> | --repo <owner/repo> ...)
set -euo pipefail
LOGIN="$1"; SINCE="$2"; shift 2
[ $# -gt 0 ] || { echo "Scope required: --owner <org> or --repo <owner/repo>" >&2; exit 1; }
LIMIT=200
prs="$(gh search prs --reviewed-by "$LOGIN" --created ">=$SINCE" --sort created --order desc --limit "$LIMIT" "$@" \
  --json repository,number,title,author,createdAt,state \
  --jq '.[] | ["\(.repository.nameWithOwner)#\(.number)", .author.login, .createdAt[0:10], .state, .title] | @tsv')"
[ -n "$prs" ] || exit 0
if [ "$(printf '%s\n' "$prs" | wc -l)" -ge "$LIMIT" ]; then
  echo "Warning: hit --limit $LIMIT, results are truncated. Narrow the date or scope." >&2
fi
printf '%s\n' "$prs"
