"""Read-only Reddit research via the official Data API (PRAW).

Searches subreddits for queries and saves matching threads with their top
comments as JSON + Markdown, for the skill-reception research in docs/research.

Credentials come only from environment variables and are never written to disk:
    REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_USER_AGENT (optional)

Usage:
    python tools/reddit/reddit_research.py queries.json --out out_dir
    queries.json: [{"q": "grill-me skill", "subs": ["ClaudeAI", "ClaudeCode"], "limit": 15}]
"""
import argparse
import json
import os
import pathlib
import sys
import time

DEFAULT_SUBS = ["ClaudeAI", "ClaudeCode", "cursor", "ChatGPTCoding", "ExperiencedDevs"]


def client():
    try:
        import praw
    except ImportError:
        sys.exit("praw is not installed: python -m pip install praw")
    cid, secret = os.environ.get("REDDIT_CLIENT_ID"), os.environ.get("REDDIT_CLIENT_SECRET")
    if not cid or not secret:
        sys.exit("Set REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET (from reddit.com/prefs/apps, app type 'script').")
    agent = os.environ.get("REDDIT_USER_AGENT", "c-skills-research/0.1 (read-only research)")
    # Application-only OAuth: read access to public content, no user login.
    return praw.Reddit(client_id=cid, client_secret=secret, user_agent=agent, check_for_async=False)


def thread(sub, top_comments):
    sub.comment_sort = "top"
    sub.comments.replace_more(limit=0)
    comments = [
        {"score": c.score, "body": c.body, "author": str(c.author) if c.author else None}
        for c in list(sub.comments)[:top_comments]
    ]
    return {
        "id": sub.id, "subreddit": str(sub.subreddit), "title": sub.title,
        "url": f"https://www.reddit.com{sub.permalink}", "score": sub.score,
        "num_comments": sub.num_comments, "created_utc": sub.created_utc,
        "selftext": sub.selftext, "top_comments": comments,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("queries")
    ap.add_argument("--out", default="reddit_out")
    ap.add_argument("--top-comments", type=int, default=10)
    ap.add_argument("--time", default="year", help="all, year, month, week")
    args = ap.parse_args()
    reddit = client()
    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    seen, results = set(), []
    for spec in json.loads(pathlib.Path(args.queries).read_text(encoding="utf-8")):
        subs = "+".join(spec.get("subs") or DEFAULT_SUBS)
        for sub in reddit.subreddit(subs).search(spec["q"], sort="relevance",
                                                time_filter=args.time, limit=spec.get("limit", 15)):
            if sub.id in seen:
                continue
            seen.add(sub.id)
            item = thread(sub, args.top_comments)
            item["query"] = spec["q"]
            results.append(item)
            print(f"[{item['subreddit']}] {item['title'][:90]} ({item['num_comments']} comments)", file=sys.stderr)
            time.sleep(1)  # stay well under the API rate limit
    (out / "threads.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    lines = []
    for t in results:
        lines += [f"## {t['title']}", f"{t['url']} - r/{t['subreddit']}, score {t['score']}, query: {t['query']}", "",
                  (t["selftext"] or "")[:1500], ""]
        lines += [f"> ({c['score']}) {c['body'][:600]}".replace("\n", " ") for c in t["top_comments"]]
        lines.append("")
    (out / "threads.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"{len(results)} threads -> {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
