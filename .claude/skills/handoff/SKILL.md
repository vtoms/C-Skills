---
name: handoff
description: Compresses the current session into a committed handoff document with a paste-able resume prompt, so a fresh agent or person can continue cold. Use when the user says "handoff", when context is getting long, or before ending a session with unfinished work.
argument-hint: "What will the next session focus on?"
disable-model-invocation: true
---

# Handoff

Write a document that lets a fresh agent continue without reading this conversation.

## Durability first

This container is ephemeral and sessions can end abruptly. Write the handoff **before** context runs low, not at the last moment. Save it to `docs/handoffs/<YYYY-MM-DD>-<topic>.md` and commit and push it with the work - a file only in the scratchpad dies with the container. If the user doesn't want it in the repo, put it in the scratchpad and say it is temporary.

## Contents

1. **Goal** - what the user ultimately wants, in their words.
2. **State** - done (commit SHAs, branch), in progress, untouched.
3. **Decisions** - with the reason for each; link decision files instead of repeating them.
4. **Dead ends** - what was tried and why it failed, so nobody retries it.
5. **Next steps** - ordered; the first concrete enough to start immediately.
6. **Open questions** for the user.
7. **Suggested skills** for the next agent.
8. **Resume prompt** - a 3–5 line message the user can paste into a new session: repo, branch, this file's path, and the first next step.

## Rules

- Reference existing artifacts (specs, issues, commits, files) by path or URL; don't copy them.
- Redact secrets, tokens, and personal data.
- If the user gave a focus for the next session, tailor to it and drop irrelevant history.
- Keep it under a page.
