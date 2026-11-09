#!/usr/bin/env bash
# Runs review-prs on eval cases, judges each run and prints a summary.
# Needs claude and SKILL_EVALS_DIR. Cases still marked DRAFT are skipped.
#
# Usage: run.sh [--runs N] [--no-judge] [case ...]   (default: every case, 3 runs)
#
# Env:
#   CLAUDE_EVAL_MODEL  model for the review runs (default: your default model)
#   CLAUDE_JUDGE_MODEL model for the judge (default: your default model)
#   CLAUDE_EVAL_FLAGS  extra flags for the review runs
#                      (default: --allowedTools Bash(git:*),Read,Grep,Glob)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_repo="$(cd "$here/../.." && pwd)"
: "${SKILL_EVALS_DIR:?set SKILL_EVALS_DIR to your private evals repo}"
cases_root="$SKILL_EVALS_DIR/review-prs"
local_map="$SKILL_EVALS_DIR/repos.local"

runs=3
judge=1
cases=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs) runs="${2:?--runs needs a number}"; shift 2 ;;
    --no-judge) judge=0; shift ;;
    -*) echo "unknown option $1" >&2; exit 2 ;;
    *) cases+=("$1"); shift ;;
  esac
done
if [[ ${#cases[@]} -eq 0 ]]; then
  for dir in "$cases_root"/*/; do cases+=("$(basename "$dir")"); done
fi

# Flags go after the prompt: --allowedTools takes several values and would swallow it.
read -r -a run_flags <<< "${CLAUDE_EVAL_FLAGS:---allowedTools Bash(git:*),Read,Grep,Glob}"
[[ -n "${CLAUDE_EVAL_MODEL:-}" ]] && run_flags+=(--model "$CLAUDE_EVAL_MODEL")
judge_flags=()
[[ -n "${CLAUDE_JUDGE_MODEL:-}" ]] && judge_flags+=(--model "$CLAUDE_JUDGE_MODEL")

skill_sha="$(git -C "$skills_repo" rev-parse --short HEAD)"
[[ -n "$(git -C "$skills_repo" status --porcelain -- skills/review-prs)" ]] && skill_sha+="-dirty"
claude_version="$(claude --version 2>/dev/null | head -1)"
global_hash="$(shasum -a 256 "$HOME/.claude/CLAUDE.md" 2>/dev/null | cut -c1-12 || true)"

field() { sed -n "s/^$1: //p" "$2" | head -1; }

wt=""
repo_path=""
cleanup() {
  if [[ -n "$wt" && -n "$repo_path" ]]; then
    git -C "$repo_path" worktree remove --force "$wt" 2>/dev/null || true
  fi
}
trap cleanup EXIT

judge_run() {
  local case_dir="$1" out="$2" base="$3" head="$4" pass="$5"
  {
    echo "You are grading one code review report against a checklist. Use only the text below."
    echo "Answer each item on its own line, exactly as: J<n>: PASS | <one-line reason> or J<n>: FAIL | <one-line reason>."
    echo "Answer J1 to J7 and nothing else."
    echo
    echo "# Checklist"
    sed -n '/^## Judge checks/,$p' "$here/checklist.md"
    echo
    echo "# Expected"
    cat "$case_dir/expected.md"
    echo
    echo "# Report"
    cat "$out"
    echo
    echo "# Diff"
    git -C "$repo_path" diff "$base...$head" | head -3000
  } | claude -p "Grade the report as instructed in the input." ${judge_flags[@]+"${judge_flags[@]}"} \
    > "${out%.md}.judge$pass.md"
}

done_cases=()
for name in "${cases[@]}"; do
  case_dir="$cases_root/$name"
  if [[ ! -f "$case_dir/case.md" ]]; then
    echo "skip   $name: no case.md"
    continue
  fi
  if grep -q '^DRAFT' "$case_dir/expected.md" 2>/dev/null; then
    echo "skip   $name: expected.md still marked DRAFT"
    continue
  fi
  remote="$(field remote "$case_dir/case.md")"
  base="$(field base "$case_dir/case.md")"
  head="$(field head "$case_dir/case.md")"
  repo_path="$(awk -F'\t' -v r="$remote" '$1 == r { print $2; exit }' "$local_map" 2>/dev/null || true)"
  if [[ -z "$repo_path" || ! -d "$repo_path" ]]; then
    echo "skip   $name: no local clone of $remote in $local_map (add: <remote><TAB><path>)"
    continue
  fi
  for sha in "$base" "$head"; do
    if ! git -C "$repo_path" cat-file -e "$sha^{commit}" 2>/dev/null \
      && ! git -C "$repo_path" fetch -q origin "$sha"; then
      echo "skip   $name: can't fetch $sha (force-pushed and gone?), recreate the case"
      continue 2
    fi
  done

  wt="$(mktemp -d "${TMPDIR:-/tmp}/review-prs-eval.XXXXXX")"
  git -C "$repo_path" worktree add -q --detach "$wt" "$head"
  [[ -d "$case_dir/guidelines" ]] && cp -R "$case_dir/guidelines/." "$wt/"
  if [[ -f "$case_dir/case.patch" ]]; then
    git -C "$wt" apply --index "$case_dir/case.patch"
    git -C "$wt" -c user.name=eval -c user.email=eval@localhost commit -q --no-verify -m "eval patch"
    head="$(git -C "$wt" rev-parse HEAD)"
  fi

  batch="$(date +%Y%m%d-%H%M%S)-$$"
  for i in $(seq 1 "$runs"); do
    out="$case_dir/runs/$batch-$skill_sha-$i.md"
    mkdir -p "$case_dir/runs"
    {
      echo "<!-- eval"
      echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "machine: $(hostname -s)"
      echo "skill: $skill_sha"
      echo "claude: $claude_version"
      echo "model: ${CLAUDE_EVAL_MODEL:-default}"
      echo "global_claude_md: ${global_hash:-none}"
      echo "case: $name"
      echo "-->"
    } > "$out"
    echo "run    $name $i/$runs"
    trace="${out%.md}.trace.jsonl"
    (cd "$wt" && claude -p "/review-prs quick $head $base" --output-format stream-json --verbose \
      "${run_flags[@]}") > "$trace" \
      || echo "warn   $name $i: claude exited non-zero, see $trace"
    python3 "$here/tooltrace.py" --result "$trace" >> "$out"
    python3 "$here/check.py" "$out" | tail -1 || true
    python3 "$here/tooltrace.py" "$trace" || true
    if [[ $judge -eq 1 ]]; then
      judge_run "$case_dir" "$out" "$base" "$head" 1
      judge_run "$case_dir" "$out" "$base" "$head" 2
    fi
  done

  git -C "$repo_path" worktree remove --force "$wt"
  wt=""
  done_cases+=("$case_dir")
done

if [[ ${#done_cases[@]} -gt 0 ]]; then
  python3 "$here/summary.py" "${done_cases[@]}"
fi
