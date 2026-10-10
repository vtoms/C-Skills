---
name: handoff
description: Compress the current session into a handoff document a fresh agent (or human) can pick up cold. Use when the user says "handoff", when context is getting long, or before ending a session with unfinished work.
argument-hint: "What will the next session focus on?"
disable-model-invocation: true
---

# Handoff

Write a document that lets a fresh agent continue without reading this conversation.

## Where

Save to `docs/handoffs/<YYYY-MM-DD>-<topic>.md` in the repo if the user wants it kept, otherwise to the session scratchpad. This container is ephemeral: anything worth keeping must be committed and pushed, so say where it went.

## Contents

1. **Goal** - what the user ultimately wants, in their words.
2. **State** - what is done (with commit SHAs / branch), what is in progress, what is untouched.
3. **Decisions made** - and the reason for each. Link to decision files rather than repeating them.
4. **Dead ends** - what was tried and why it failed, so nobody retries it.
5. **Next steps** - an ordered list, the first one concrete enough to start immediately.
6. **Open questions** for the user.
7. **Suggested skills** for the next agent (e.g. `diagnose`, `prove-it`).

## Rules

- Reference existing artifacts (specs, issues, commits, files) by path or URL; don't copy them.
- Redact secrets, tokens, and personal data.
- If the user gave a focus for the next session, tailor the doc to it and drop irrelevant history.
- Keep it under a page. A handoff nobody reads is worse than none.
