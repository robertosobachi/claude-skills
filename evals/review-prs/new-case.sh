#!/usr/bin/env bash
# Drafts a review-prs eval case from a GitHub PR, in your private evals repo.
# Run it inside a clone of the PR's repo. Needs gh.
#
# Usage: new-case.sh <PR URL> [--head <sha>] [--name <case>]
#   --head  the commit to review (default: the commit the first reviewer
#           commented on, else the PR's current head)
#   --name  case folder name (default: <repo>-<number>)
set -euo pipefail

: "${SKILL_EVALS_DIR:?set SKILL_EVALS_DIR to your private evals repo}"

url="${1:?usage: new-case.sh <PR URL> [--head <sha>] [--name <case>]}"
shift
head=""
name=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --head) head="${2:?--head needs a sha}"; shift 2 ;;
    --name) name="${2:?--name needs a name}"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done

if [[ ! "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
  echo "not a PR URL: $url" >&2
  exit 2
fi
owner="${BASH_REMATCH[1]}"
repo="${BASH_REMATCH[2]}"
n="${BASH_REMATCH[3]}"
name="${name:-$repo-$n}"

repo_root="$(git rev-parse --show-toplevel)"
remote="$(git -C "$repo_root" remote get-url origin)"
case_dir="$SKILL_EVALS_DIR/review-prs/$name"
if [[ -e "$case_dir" ]]; then
  echo "$case_dir already exists" >&2
  exit 1
fi

title="$(gh pr view "$url" --json title --jq .title)"
body="$(gh pr view "$url" --json body --jq .body)"
author="$(gh pr view "$url" --json author --jq .author.login)"
first_commit="$(gh pr view "$url" --json commits --jq '.commits[0].oid')"
final_head="$(gh pr view "$url" --json headRefOid --jq .headRefOid)"

# Reviewer comments: commit, path, line, reviewer, body (one line each).
comments="$(gh api --paginate "repos/$owner/$repo/pulls/$n/comments" --jq \
  ".[] | select(.user.login != \"$author\") | [.original_commit_id, .path,
   ((.original_line // .line // 0) | tostring), .user.login,
   (.body | gsub(\"[\\t\\n\\r]+\"; \" \"))] | @tsv")"

if [[ -z "$head" ]]; then
  head="$(printf '%s\n' "$comments" | awk -F'\t' 'NF { print $1; exit }')"
  head="${head:-$final_head}"
fi

git -C "$repo_root" fetch -q origin "pull/$n/head"
for sha in "$first_commit" "$head" "$final_head"; do
  git -C "$repo_root" cat-file -e "$sha^{commit}" 2>/dev/null \
    || git -C "$repo_root" fetch -q origin "$sha"
done
base="$(git -C "$repo_root" rev-parse "$first_commit^")"
if ! git -C "$repo_root" merge-base --is-ancestor "$base" "$head"; then
  echo "warn   $head doesn't descend from $base (PR rebased after review?). Pass --head." >&2
fi

git -C "$repo_root" update-ref "refs/eval/$name/base" "$base"
git -C "$repo_root" update-ref "refs/eval/$name/head" "$head"

mkdir -p "$case_dir/runs"
{
  echo "remote: $remote"
  echo "pr: $url"
  echo "base: $base"
  echo "head: $head"
  echo "title: $title"
  echo
  echo "## Body"
  echo
  printf '%s\n' "$body"
} > "$case_dir/case.md"

if [[ -f "$repo_root/docs/plans/review-conventions.md" ]]; then
  mkdir -p "$case_dir/guidelines/docs/plans"
  cp "$repo_root/docs/plans/review-conventions.md" "$case_dir/guidelines/docs/plans/"
  copied="copied docs/plans/review-conventions.md as it is today, not as it was at review time"
else
  copied="no review conventions doc in this repo"
fi

{
  echo "DRAFT: confirm every line, then delete this line. Runs skip DRAFT cases."
  echo
  echo "## Verdict"
  echo
  echo "✅ OK to merge | ⚠️ Merge after fix | ❌ Not yet (keep one)"
  echo
  echo "## Must fix"
  echo
  echo "Reviewer comments, drafted from the PR. Keep only real blockers, reworded as what must be raised."
  echo "\"fixed later\" means a later commit touched the file. \"on head\" means the comment was on the reviewed commit."
  echo
  printf '%s\n' "$comments" | while IFS=$'\t' read -r sha path line who text; do
    [[ -z "$sha" ]] && continue
    on_head=no; [[ "$sha" == "$head" ]] && on_head=yes
    fixed=no
    if [[ -n "$(git -C "$repo_root" log --format=%H "$head..$final_head" -- "$path" 2>/dev/null)" ]]; then
      fixed=yes
    fi
    echo "- $path:$line | $who | on head: $on_head | fixed later: $fixed | $text"
  done
  echo
  echo "## Must not flag"
  echo
  echo "- "
  echo
  echo "## Repo rules"
  echo
  echo "One line per rule the diff breaks: rule | source file | path:line"
  echo
  echo "- "
} > "$case_dir/expected.md"

local_map="$SKILL_EVALS_DIR/repos.local"
touch "$local_map"
if ! awk -F'\t' -v r="$remote" '$1 == r { found = 1 } END { exit !found }' "$local_map"; then
  printf '%s\t%s\n' "$remote" "$repo_root" >> "$local_map"
fi
gitignore="$SKILL_EVALS_DIR/.gitignore"
grep -qx 'repos.local' "$gitignore" 2>/dev/null || echo 'repos.local' >> "$gitignore"

echo "created $case_dir"
echo "        head $head, base $base"
echo "        $copied"
echo "next   edit $case_dir/expected.md and delete the DRAFT line"
