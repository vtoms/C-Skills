"""Collect first-hand user feedback on skill packs from GitHub issues/discussions and Hacker News.

Read-only. Uses the signed-in GitHub CLI (`gh api`) and the public HN Algolia API.

Usage:
    python tools/github/collect_feedback.py OUT_DIR [--repos owner/name ...] [--max-comment-issues N]
Writes OUT_DIR/<owner>__<repo>.json (issues + comments + discussions) and OUT_DIR/hn.json.
"""
import argparse
import json
import pathlib
import subprocess
import sys
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

REPOS = [
    "mattpocock/skills", "obra/superpowers", "garrytan/gstack", "anthropics/skills",
    "EveryInc/compound-engineering-plugin", "cursor/plugins", "addyosmani/agent-skills",
    "blader/humanizer",
]
# Claude Code's own tracker is huge: take only skill-related issues via search.
CLAUDE_CODE_QUERIES = ["skill not triggering", "skill description", "SKILL.md", "skills not loading",
                       "disable-model-invocation", "skill auto invoke"]
HN_QUERIES = ["grill-me", "mattpocock skills", "superpowers obra", "claude code skills", "gstack",
              "pstack", "agent skills SKILL.md", "systematic-debugging", "verification-before-completion",
              "claude code tdd", "humanizer skill", "claude code handoff"]


def gh(path, paginate=False):
    cmd = ["gh", "api", "-H", "Accept: application/vnd.github+json", path]
    if paginate:
        cmd[2:2] = ["--paginate", "--slurp"]  # one outer array of page arrays
    out = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if out.returncode != 0:
        print(f"  gh error {path}: {out.stderr.strip()[:200]}", file=sys.stderr)
        return []
    text = out.stdout.strip()
    if not text:
        return []
    data = json.loads(text)
    if paginate:
        data = [item for page in data for item in page]
    return data


def slim_issue(i):
    return {"number": i["number"], "title": i["title"], "state": i["state"], "url": i["html_url"],
            "created_at": i["created_at"], "comments": i["comments"],
            "reactions": (i.get("reactions") or {}).get("total_count", 0),
            "labels": [l["name"] for l in i.get("labels", [])], "body": (i.get("body") or "")[:4000]}


def comments_for(repo, number):
    cs = gh(f"repos/{repo}/issues/{number}/comments?per_page=100")
    return [{"user": (c.get("user") or {}).get("login"), "body": (c.get("body") or "")[:2500],
             "reactions": (c.get("reactions") or {}).get("total_count", 0)} for c in cs]


def discussions(repo):
    owner, name = repo.split("/")
    q = """query($o:String!,$n:String!){repository(owner:$o,name:$n){discussions(first:100,orderBy:{field:UPDATED_AT,direction:DESC}){nodes{number title url createdAt body category{name} comments(first:20){nodes{body author{login}}}}}}}"""
    out = subprocess.run(["gh", "api", "graphql", "-f", f"query={q}", "-f", f"o={owner}", "-f", f"n={name}"],
                         capture_output=True, text=True, encoding="utf-8", errors="replace")
    if out.returncode != 0:
        return []
    try:
        nodes = json.loads(out.stdout)["data"]["repository"]["discussions"]["nodes"]
    except (KeyError, TypeError, json.JSONDecodeError):
        return []
    return [{"number": d["number"], "title": d["title"], "url": d["url"], "created_at": d["createdAt"],
             "category": (d.get("category") or {}).get("name"), "body": (d.get("body") or "")[:4000],
             "comments": [{"user": (c.get("author") or {}).get("login"), "body": (c.get("body") or "")[:2500]}
                          for c in d["comments"]["nodes"]]} for d in nodes]


def collect_repo(repo, out, max_comment_issues):
    print(f"[{repo}] issues...", file=sys.stderr)
    raw = gh(f"repos/{repo}/issues?state=all&per_page=100", paginate=True)
    issues = [slim_issue(i) for i in raw if "pull_request" not in i]
    ranked = sorted([i for i in issues if i["comments"]], key=lambda i: -(i["comments"] + i["reactions"]))
    targets = ranked[:max_comment_issues]
    with ThreadPoolExecutor(8) as pool:
        for i, cs in zip(targets, pool.map(lambda i: comments_for(repo, i["number"]), targets)):
            i["thread"] = cs
    disc = discussions(repo)
    data = {"repo": repo, "issues": issues, "discussions": disc}
    (out / f"{repo.replace('/', '__')}.json").write_text(json.dumps(data, indent=1), encoding="utf-8")
    print(f"[{repo}] {len(issues)} issues ({len(targets)} with threads), {len(disc)} discussions", file=sys.stderr)


def collect_claude_code(out):
    seen, items = set(), []
    for q in CLAUDE_CODE_QUERIES:
        res = gh(f"search/issues?q={urllib.parse.quote(q + ' repo:anthropics/claude-code')}&per_page=50")
        for i in (res.get("items", []) if isinstance(res, dict) else []):
            if i["number"] in seen:
                continue
            seen.add(i["number"])
            item = slim_issue(i)
            item["query"] = q
            items.append(item)
    with ThreadPoolExecutor(8) as pool:
        for i, cs in zip(items, pool.map(lambda i: comments_for("anthropics/claude-code", i["number"]), items)):
            i["thread"] = cs[:15]
    (out / "anthropics__claude-code__skills.json").write_text(json.dumps({"repo": "anthropics/claude-code", "issues": items}, indent=1), encoding="utf-8")
    print(f"[claude-code] {len(items)} skill-related issues", file=sys.stderr)


def collect_hn(out):
    hits = {}
    for q in HN_QUERIES:
        url = f"https://hn.algolia.com/api/v1/search?query={urllib.parse.quote(q)}&tags=comment&hitsPerPage=100"
        with urllib.request.urlopen(url, timeout=30) as r:
            for h in json.load(r)["hits"]:
                hits.setdefault(h["objectID"], {"query": q, "author": h.get("author"), "created_at": h.get("created_at"),
                                                "story": h.get("story_title"), "text": (h.get("comment_text") or "")[:3000],
                                                "url": f"https://news.ycombinator.com/item?id={h['objectID']}"})
    (out / "hn.json").write_text(json.dumps(list(hits.values()), indent=1), encoding="utf-8")
    print(f"[hn] {len(hits)} comments", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--repos", nargs="*", default=REPOS)
    ap.add_argument("--max-comment-issues", type=int, default=400)
    args = ap.parse_args()
    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    collect_hn(out)
    collect_claude_code(out)
    with ThreadPoolExecutor(3) as pool:
        list(pool.map(lambda r: collect_repo(r, out, args.max_comment_issues), args.repos))


if __name__ == "__main__":
    main()
