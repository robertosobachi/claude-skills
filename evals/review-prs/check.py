#!/usr/bin/env python3
"""Script checks S1-S12 from checklist.md on one saved review-prs report.

Usage: check.py <report.md>
Prints one line per check and exits 1 if any check fails.
"""
import re
import sys

LGTM = "LGTM 👍🏻"
COMMENT_EMOJI = ("🔴", "❓", "💡", LGTM, "⚠", "❌")
FINAL_EMOJI = (LGTM, "⚠", "❌")
VERDICTS = ("✅ OK to merge", "⚠️ Merge after fix", "❌ Not yet")
BANNED = (
    "delve", "robust", "seamless", "crucial", "comprehensive", "leverage",
    "ensure", "regression", "edge case", "race condition", "idempotent",
    "side effect", "refactor",
)
PRONOUNS = re.compile(r"\b(we|you|let's)\b", re.IGNORECASE)
MAX_WORDS = 35
MAX_FINAL_WORDS = 80
CHECKED = "What I checked:"
RUN_CLAIM = re.compile(r"\b(tested|ran)\b", re.IGNORECASE)


def is_final(c):
    """Loose on purpose: a near-miss opener ("✅ LGTM", "LGTM 👍") still counts as
    the final comment here, so only S2 and S6 fail for it, not S4, S5 and S10 too."""
    text = c["text"].lstrip("✅ ").lstrip()
    return text.startswith("LGTM") or text.startswith(("⚠", "❌"))


def checked_bullets(c):
    """Bullets after the `What I checked:` line, or None if there's no such line."""
    lines = c["lines"]
    for i, line in enumerate(lines):
        if CHECKED in line:
            n = 0
            for rest in lines[i + 1:]:
                if re.match(r"\s*[-*] ", rest):
                    n += 1
                elif rest.strip() and n:
                    break
            return n
    return None


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
            comments.append({"text": body, "lines": text, "has_why": has_why})
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
           if len(c["text"].split()) > (MAX_FINAL_WORDS if is_final(c) else MAX_WORDS)]
    add("S4 length", not bad, "; ".join(bad))

    finals = sum(1 for c in comments if is_final(c))
    add("S5 final comment", n_prs >= 1 and finals >= n_prs, f"{finals} for {n_prs} PR(s)")

    bad = [short(c) for c in comments
           if "LGTM" in c["text"] and not c["text"].startswith(LGTM)]
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
           if not c["text"].startswith("❓") and not is_final(c)
           and PRONOUNS.search(strip_code(c["text"]))]
    add("S10 pronouns", not bad, "; ".join(bad))

    finals = [c for c in comments if is_final(c)]
    bad = []
    for c in finals:
        n = checked_bullets(c)
        if n is None or not 2 <= n <= 4:
            bad.append(f"{'no list' if n is None else f'{n} bullets'}: {short(c)}")
    add("S11 checked list", bool(finals) and not bad, "; ".join(bad))

    bad = [short(c) for c in finals
           if RUN_CLAIM.search(strip_code(c["text"])) and "CI" not in c["text"]]
    add("S12 no run claims", not bad, "; ".join(bad))

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
