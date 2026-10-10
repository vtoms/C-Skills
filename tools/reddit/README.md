# Reddit research (official API, read-only)

Pulls Reddit threads and their top comments for the skill-reception research, using Reddit's official Data API through PRAW. It doesn't scrape: Reddit's terms forbid scraping, and browser automation of reddit.com is blocked.

## One-time setup (you do this, signed in to Reddit)

1. Go to https://www.reddit.com/prefs/apps → **create another app** → type **script**, redirect URI `http://localhost:8080`. If Reddit shows an API access request form instead, complete it and describe the use as personal, non-commercial research.
2. Copy the client ID (under the app name) and the secret.
3. Set them for your session. They are read from the environment and never saved:
   ```powershell
   $env:REDDIT_CLIENT_ID = "..."
   $env:REDDIT_CLIENT_SECRET = "..."
   ```

## Run

```powershell
python -m pip install praw            # or use a venv
python tools/reddit/reddit_research.py tools/reddit/queries.json --out reddit_out
```

The output is `reddit_out/threads.json` and `reddit_out/threads.md`, with the thread, URL, score, post text and top 10 comments. Edit `queries.json` to change searches. The tool pauses between threads to stay under the rate limit and only reads public content.
