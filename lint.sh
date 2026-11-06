#!/usr/bin/env bash
# Checks the skills for drift that nothing else catches: frontmatter,
# descriptions the Desktop upload rejects, the per-skill guard rule,
# the blocks kept identical across skills, and README rows. Manual
# only, never run by install.sh, package.sh or the hooks.
# Prints file:line for each failure and exits 1 if any.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo" || exit 2
fails=0

fail() {
  echo "fail   $1: $2"
  fails=$((fails + 1))
}

# Prints the line number of the first line matching the pattern, or 1.
line_of() {
  local n
  n="$(grep -n -m1 -- "$2" "$1" | cut -d: -f1)"
  echo "${n:-1}"
}

# Prints the bullet lines that follow the "**Style pass.**" line.
style_block() {
  awk '
    /\*\*Style pass\.\*\*/ { on = 1; next }
    on && /^[[:space:]]*- / { print; seen = 1; next }
    on && seen { exit }
    on && /^[[:space:]]*$/ { next }
    on { exit }
  ' "$1"
}

# Prints the push-risk level bullets and the Format line.
risk_block() {
  grep -E '^(- (🟢 Low|🟡 Medium|🔴 High):|Format: `<emoji>)' "$1"
}

# 1. Claude Code's own validator, when claude is installed and can run.
if ! command -v claude >/dev/null 2>&1; then
  echo "note   claude plugin validate skipped: claude isn't on PATH here (a sandbox can hide it)"
else
  claude plugin validate skills
  rc=$?
  if [[ $rc -eq 126 || $rc -eq 127 ]]; then
    echo "note   claude plugin validate skipped: claude can't run here (exit $rc, a sandbox can block it)"
  elif [[ $rc -ne 0 ]]; then
    fail "skills" "claude plugin validate skills failed (output above)"
  fi
fi

# 2. Frontmatter, descriptions, argument-hints and the guard rule.
for file in skills/*/SKILL.md; do
  folder="$(basename "$(dirname "$file")")"
  name="$(sed -n 's/^name:[[:space:]]*//p' "$file" | head -n1)"
  if [[ "$name" != "$folder" ]]; then
    fail "$file:$(line_of "$file" '^name:')" "name '$name' doesn't match folder '$folder'"
  fi
  if grep -q '^description:.*<' "$file"; then
    fail "$file:$(line_of "$file" '^description:')" "description contains '<', which the Desktop upload rejects"
  fi
  hint="$(sed -n 's/^argument-hint:[[:space:]]*//p' "$file" | head -n1)"
  if [[ -n "$hint" && "$hint" != \"* ]]; then
    fail "$file:$(line_of "$file" '^argument-hint:')" "argument-hint isn't quoted (a value starting with [ parses as a YAML list)"
  fi
  if ! grep -q "Don't edit this skill's files" "$file"; then
    fail "$file:1" "missing the \"Don't edit this skill's files\" rule"
  fi
done

# 3. Style pass: the generic copies are identical, review-prs starts with them.
reference="skills/annotate-pr/SKILL.md"
shared="$(style_block "$reference")"
if [[ -z "$shared" ]]; then
  fail "$reference:1" "no style pass block found"
else
  for file in skills/answer-review/SKILL.md skills/pr-description/SKILL.md; do
    if [[ "$(style_block "$file")" != "$shared" ]]; then
      fail "$file:$(line_of "$file" 'Style pass')" "style pass differs from $reference"
    fi
  done
  file="skills/review-prs/SKILL.md"
  count="$(printf '%s\n' "$shared" | wc -l | tr -d ' ')"
  head_of_block="$(style_block "$file" | sed 's/^[[:space:]]*//' | head -n "$count")"
  if [[ "$head_of_block" != "$(printf '%s\n' "$shared" | sed 's/^[[:space:]]*//')" ]]; then
    fail "$file:$(line_of "$file" 'Style pass')" "style pass doesn't start with the shared lines from $reference"
  fi
fi

# 4. Push risk: the levels and format line match in commit and commit-title.
if [[ "$(risk_block skills/commit/SKILL.md)" != "$(risk_block skills/commit-title/SKILL.md)" ]]; then
  fail "skills/commit-title/SKILL.md:$(line_of skills/commit-title/SKILL.md '^## Push risk')" "push risk levels or format line differ from skills/commit/SKILL.md"
fi

# 5. README table rows and skill folders match one to one.
rows="$(sed -n 's/^| \[`\([a-z0-9-]*\)`\](skills\/.*/\1/p' README.md | sort)"
folders="$(for file in skills/*/SKILL.md; do basename "$(dirname "$file")"; done | sort)"
for name in $(comm -23 <(printf '%s\n' "$folders") <(printf '%s\n' "$rows")); do
  fail "README.md:$(line_of README.md '^## Skills')" "no table row for skills/$name"
done
for name in $(comm -13 <(printf '%s\n' "$folders") <(printf '%s\n' "$rows")); do
  fail "README.md:$(line_of README.md "\`$name\`")" "row for $name has no skills/$name/SKILL.md"
done

if [[ $fails -gt 0 ]]; then
  echo "$fails check(s) failed"
  exit 1
fi
echo "all checks passed"
