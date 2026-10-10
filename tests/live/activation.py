"""Live activation check: does Claude Code actually load a skill for a prompt?

Runs headless `claude -p` from the repo root (so .claude/skills is loaded),
streams JSON events, and records which skills the session invoked via the
Skill tool. Usage:

    python3 tests/live/activation.py cases.json [--runs N] [--out results.json]

cases.json: [{"id": "...", "prompt": "...", "expected": "<skill>|none"}]
"""
import argparse
import json
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
# Read-only probing: the session may look around but not edit or run commands.
TOOLS = "Skill,Read,Grep,Glob"
OURS = {d.name for d in (REPO / ".claude" / "skills").iterdir() if d.is_dir()}


def skills_invoked(prompt, timeout):
    cmd = ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose",
           "--max-turns", "3", "--allowedTools", TOOLS]
    proc = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True,
                          timeout=timeout, stdin=subprocess.DEVNULL)
    found = []
    for line in proc.stdout.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        message = event.get("message") or {}
        for block in message.get("content") or []:
            if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Skill":
                found.append(block.get("input", {}).get("skill") or block.get("input", {}).get("command"))
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cases")
    ap.add_argument("--runs", type=int, default=1)
    ap.add_argument("--timeout", type=int, default=240)
    ap.add_argument("--out", default="-")
    args = ap.parse_args()
    cases = json.loads(pathlib.Path(args.cases).read_text())
    results = []
    for case in cases:
        for run in range(args.runs):
            try:
                invoked = skills_invoked(case["prompt"], args.timeout)
            except subprocess.TimeoutExpired:
                invoked = ["<timeout>"]
            # "none" means none of this repo's skills should load (built-ins are fine).
            ours = [s for s in invoked if s in OURS]
            hit = case["expected"] in invoked if case["expected"] != "none" else not ours
            results.append({"id": case["id"], "run": run, "expected": case["expected"],
                            "invoked": invoked, "correct": hit})
            print(f"{case['id']} run{run}: expected={case['expected']} invoked={invoked} {'OK' if hit else 'MISS'}",
                  file=sys.stderr, flush=True)
    text = json.dumps(results, indent=2)
    if args.out == "-":
        print(text)
    else:
        pathlib.Path(args.out).write_text(text)
    ok = sum(r["correct"] for r in results)
    print(f"{ok}/{len(results)} correct", file=sys.stderr)


if __name__ == "__main__":
    main()
