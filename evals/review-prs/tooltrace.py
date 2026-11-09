#!/usr/bin/env python3
"""Reads a `claude -p --output-format stream-json --verbose` trace.

Usage:
  tooltrace.py --result <run>.trace.jsonl   print the final report text
  tooltrace.py <run>.trace.jsonl            print tool calls, errors and retries

A retry is a tool call that failed and was followed by another call to the
same tool. Runs that hit outdated instructions or sandbox blocks and work
around them show up here, never in the report.
"""
import json
import sys


def events(path):
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def content(event):
    message = event.get("message") or {}
    blocks = message.get("content")
    return blocks if isinstance(blocks, list) else []


def result(path):
    text = ""
    for e in events(path):
        if e.get("type") == "result":
            text = e.get("result") or ""
    return text


def calls(path):
    """Return tool calls in order, each a dict with name, label and error."""
    order, by_id = [], {}
    for e in events(path):
        for block in content(e):
            if block.get("type") == "tool_use":
                inp = block.get("input") or {}
                label = inp.get("command") or inp.get("file_path") or inp.get("pattern") or ""
                call = {"name": block.get("name", "?"), "label": str(label), "error": False}
                order.append(call)
                by_id[block.get("id")] = call
            elif block.get("type") == "tool_result" and block.get("is_error"):
                call = by_id.get(block.get("tool_use_id"))
                if call:
                    call["error"] = True
    return order


def stats(path):
    order = calls(path)
    retries = sum(1 for a, b in zip(order, order[1:]) if a["error"] and a["name"] == b["name"])
    return {"tools": len(order), "errors": sum(c["error"] for c in order), "retries": retries}


def main():
    args = sys.argv[1:]
    if args[:1] == ["--result"] and len(args) == 2:
        print(result(args[1]))
        return
    if len(args) != 1:
        sys.exit(__doc__.strip())
    s = stats(args[0])
    print(f"tools {s['tools']}, errors {s['errors']}, retries {s['retries']}")
    for c in calls(args[0]):
        if c["error"]:
            print(f"  error  {c['name']}: {c['label'][:100]}")


if __name__ == "__main__":
    main()
