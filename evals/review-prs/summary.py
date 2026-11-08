#!/usr/bin/env python3
"""Pass counts per skill version, and judge agreement with your own scores.

Usage: summary.py <case dir> [<case dir> ...]

Groups runs by (skill, Claude Code version, model): only runs in the same
group are comparable. If a run has a <run>.me.md with your own J1-J7
verdicts, it also reports how often the judge agreed with you per item.
"""
import os
import re
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check import check  # noqa: E402

JUDGE_LINE = re.compile(r"^(J\d+)\S*\s*:\s*(PASS|FAIL)", re.MULTILINE)


def header(text):
    m = re.search(r"<!-- eval\n(.*?)-->", text, re.DOTALL)
    fields = {}
    if m:
        for line in m.group(1).splitlines():
            key, _, value = line.partition(": ")
            fields[key.strip()] = value.strip()
    return fields


def verdicts(path):
    if not os.path.exists(path):
        return {}
    with open(path, encoding="utf-8") as f:
        return dict(JUDGE_LINE.findall(f.read()))


def judge(run):
    a, b = verdicts(run + ".judge1.md"), verdicts(run + ".judge2.md")
    return {k: (a[k] if a.get(k) == b.get(k) else "UNSURE") for k in set(a) | set(b)}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())
    groups = defaultdict(lambda: {"runs": 0, "script": 0, "script_total": 0,
                                  "judge": defaultdict(lambda: defaultdict(int))})
    agreement = defaultdict(lambda: [0, 0])
    for case in sys.argv[1:]:
        runs_dir = os.path.join(case, "runs")
        if not os.path.isdir(runs_dir):
            continue
        for name in sorted(os.listdir(runs_dir)):
            if not name.endswith(".md") or name.count(".") > 1:
                continue
            run = os.path.join(runs_dir, name[:-3])
            with open(run + ".md", encoding="utf-8") as f:
                text = f.read()
            h = header(text)
            key = (h.get("skill", "?"), h.get("claude", "?"), h.get("model", "?"))
            g = groups[key]
            results = check(text)
            g["runs"] += 1
            g["script"] += sum(ok for _, ok, _ in results)
            g["script_total"] += len(results)
            j = judge(run)
            for item, v in j.items():
                g["judge"][item][v] += 1
            mine = verdicts(run + ".me.md")
            for item, v in mine.items():
                if item in j:
                    agreement[item][0] += j[item] == v
                    agreement[item][1] += 1

    for (skill, claude, model), g in sorted(groups.items()):
        print(f"skill {skill} | claude {claude} | model {model} | {g['runs']} run(s)")
        print(f"  script: {g['script']}/{g['script_total']}")
        for item in sorted(g["judge"], key=lambda k: int(k[1:])):
            c = g["judge"][item]
            print(f"  {item}: {c['PASS']} pass, {c['FAIL']} fail, {c['UNSURE']} unsure")
    if agreement:
        print("judge agreement with your scores:")
        for item in sorted(agreement, key=lambda k: int(k[1:])):
            agreed, total = agreement[item]
            note = "  -> check this item by hand" if total - agreed > 1 else ""
            print(f"  {item}: {agreed}/{total}{note}")


if __name__ == "__main__":
    main()
