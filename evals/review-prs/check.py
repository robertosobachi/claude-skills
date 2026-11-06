#!/usr/bin/env python3
"""Script checks S1-S10 from checklist.md on one saved review-prs report.

Usage: check.py <report.md>
Prints one line per check and exits 1 if any check fails.
"""
import re
import sys

COMMENT_EMOJI = ("🔴", "❓", "💡", "✅", "⚠", "❌")
FINAL_EMOJI = ("✅", "⚠", "❌")
VERDICTS = ("✅ OK to merge", "⚠️ Merge after fix", "❌ Not yet")
BANNED = (
    "delve", "robust", "seamless", "crucial", "comprehensive", "leverage",
    "ensure", "regression", "edge case", "race condition", "idempotent",
    "side effect", "refactor",
)
PRONOUNS = re.compile(r"\b(we|you|let's)\b", re.IGNORECASE)
MAX_WORDS = 35


def strip_code(text):
    return re.sub(r"`[^`]*`", "", text)


def parse(report):
    """Return (lines outside quotes, comments). A comment is a dict with text and has_why."""
    report = re.sub(r"<!--.*?-->", "", report, flags=re.DOTALL)
    report = re.sub(r"```.*?```", "", report, flags=re.DOTALL)
    lines = report.splitlines()
    outside, comments = [], []
    i = 0
    while i < len(lines):
        if not lines[i].lstrip().startswith(">"):
            outside.append(lines[i])
            i += 1
            continue
        block = []
        while i < len(lines) and lines[i].lstrip().startswith(">"):
            block.append(re.sub(r"^\s*>\s?", "", lines[i]))
            i += 1
        text, has_why = [], False
        for line in block:
            if line.strip().startswith("Why:"):
                has_why = True
                break
            text.append(line)
        if not has_why:
            nxt = next((l for l in lines[i:] if l.strip()), "")
            has_why = nxt.strip().startswith("Why:")
        body = " ".join(t.strip() for t in text if t.strip())
        if body:
            comments.append({"text": body, "has_why": has_why})
    return outside, comments


def check(report):
    outside, comments = parse(report)
    n_prs = sum(1 for l in outside for v in VERDICTS if v in l)
    results = []

    def add(key, ok, detail=""):
        results.append((key, ok, detail))

    def short(c):
        return c["text"][:60]

    add("S1 verdict", n_prs >= 1, f"{n_prs} verdict line(s)")

    bad = [short(c) for c in comments if not c["text"].startswith(COMMENT_EMOJI)]
    add("S2 emoji", not bad, "; ".join(bad))

    bad = [short(c) for c in comments if not c["has_why"]]
    add("S3 why", not bad, "; ".join(bad))

    bad = [f"{len(c['text'].split())}w: {short(c)}" for c in comments
           if len(c["text"].split()) > MAX_WORDS]
    add("S4 length", not bad, "; ".join(bad))

    finals = sum(1 for c in comments if c["text"].startswith(FINAL_EMOJI))
    add("S5 final comment", n_prs >= 1 and finals >= n_prs, f"{finals} for {n_prs} PR(s)")

    bad = [short(c) for c in comments
           if "LGTM" in c["text"] and not c["text"].startswith("✅")]
    add("S6 LGTM", not bad, "; ".join(bad))

    bad = [short(c) for c in comments if "—" in strip_code(c["text"])]
    add("S7 em dash", not bad, "; ".join(bad))

    bad = []
    for c in comments:
        text = strip_code(c["text"]).lower()
        hits = [w for w in BANNED if re.search(rf"\b{w}", text)]
        if hits:
            bad.append(f"{','.join(hits)}: {short(c)}")
    add("S8 words", not bad, "; ".join(bad))

    ideas = sum(1 for c in comments if c["text"].startswith("💡"))
    add("S9 suggestions", ideas <= 2 * max(n_prs, 1), f"{ideas} for {n_prs} PR(s)")

    bad = [short(c) for c in comments
           if not c["text"].startswith("❓") and PRONOUNS.search(strip_code(c["text"]))]
    add("S10 pronouns", not bad, "; ".join(bad))

    return results


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip())
    with open(sys.argv[1], encoding="utf-8") as f:
        results = check(f.read())
    for key, ok, detail in results:
        print(f"{'PASS' if ok else 'FAIL'}  {key}" + (f"  ({detail})" if detail else ""))
    passed = sum(ok for _, ok, _ in results)
    print(f"{passed}/{len(results)} script checks passed")
    sys.exit(0 if passed == len(results) else 1)


if __name__ == "__main__":
    main()
