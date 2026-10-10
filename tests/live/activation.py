"""Live activation check: does Claude Code actually load a skill for a prompt?

Runs headless `claude -p` from the repo root (so .claude/skills is loaded),
streams JSON events, and records which skills the session invoked via the
Skill tool. Usage:

    python3 tests/live/activation.py cases.json [--runs N] [--out results.json]

cases.json: [{"id": "...", "prompt": "...", "expected": "<skill>|none"}]
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
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
    # Decode as UTF-8 explicitly: on Windows the default is the ANSI code page,
    # and one undecodable byte leaves proc.stdout as None.
    proc = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True,
                          encoding="utf-8", errors="replace",
                          timeout=timeout, stdin=subprocess.DEVNULL)
    found = []
    for line in (proc.stdout or "").splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        message = event.get("message") if isinstance(event, dict) else None
        if not isinstance(message, dict):
            continue
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
    ap.add_argument("--start", type=int, default=0, help="skip the first N cases (resume)")
    ap.add_argument("--jobs", type=int, default=8, help="sessions to run in parallel")
    args = ap.parse_args()
    cases = json.loads(pathlib.Path(args.cases).read_text(encoding="utf-8"))
    def run_one(job):
        case, run = job
        try:
            invoked = skills_invoked(case["prompt"], args.timeout)
        except subprocess.TimeoutExpired:
            invoked = ["<timeout>"]
        except Exception as exc:  # one failed session must not abort the whole run
            invoked = [f"<error: {type(exc).__name__}>"]
        # "none" means none of this repo's skills should load (built-ins are fine).
        ours = [s for s in invoked if s in OURS]
        hit = case["expected"] in invoked if case["expected"] != "none" else not ours
        print(f"{case['id']} run{run}: expected={case['expected']} invoked={invoked} {'OK' if hit else 'MISS'}",
              file=sys.stderr, flush=True)
        return {"id": case["id"], "run": run, "expected": case["expected"], "invoked": invoked, "correct": hit}

    jobs = [(case, run) for case in cases[args.start:] for run in range(args.runs)]
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(run_one, jobs))
    text = json.dumps(results, indent=2)
    if args.out == "-":
        print(text)
    else:
        pathlib.Path(args.out).write_text(text, encoding="utf-8")
    ok = sum(r["correct"] for r in results)
    print(f"{ok}/{len(results)} correct", file=sys.stderr)


if __name__ == "__main__":
    main()
