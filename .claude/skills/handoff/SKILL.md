---
name: handoff
description: Writes a one-page handoff (goal, state with commit SHAs, decisions, dead ends, next steps, resume prompt) to docs/handoffs/<date>-<topic>.md so a fresh session can continue cold. Commits only that file and asks before pushing; prints the resume prompt in chat. Run before ending a session with unfinished work.
argument-hint: "[focus for the next session]"
disable-model-invocation: true
---

# Handoff

Write a document that lets a fresh agent continue without reading this conversation. If the user gave a focus, tailor the doc to it and drop irrelevant history.

## Contents

1. **Goal** - what the user ultimately wants, in their words.
2. **State** - branch; commits (SHA, pushed yes/no); uncommitted or untracked changes and whether they will survive; what's in progress; what's untouched. Tag each claim that something works, is broken, or is done as **verified** (the command you ran and its result, e.g. `npm test -> 3 failing`) or **unverified** (read or assumed) - never write a belief as a fact. Give the one command that shows current status and quote its output or errors verbatim.
3. **Decisions** - with the reason for each and whose call it was (the user's, or your own); list anything the user said not to do. Link decision files instead of repeating them.
4. **Dead ends** - what was tried and why it failed, so nobody retries it.
5. **Next steps** - ordered; the first concrete enough to start immediately.
6. **Open questions** for the user.
7. **Suggested skills** - by `/name`, only ones in `.claude/skills/` or built-ins; omit the section if none apply.
8. **Resume prompt** - 3–5 lines (longer if the file isn't pushed - see Saving) to paste into a new session: repo, branch, this file's path, the first next step, and an instruction to check the State against `git log`/`git status` (and the status command) and report any mismatch before acting.

Reference existing artifacts (specs, issues, commits, files) by path or URL; don't copy them. Redact secrets, tokens, and personal data. Keep it under a page.

## Saving it

- Write to `docs/handoffs/<YYYY-MM-DD>-<topic>.md`.
- Commit **only the handoff file** - `git commit -m "..." -- <file>` after `git add <file>`, so anything already staged stays out - on the current branch. If that is the default branch, ask first.
- **Ask before pushing.** Never commit or push other changes without the user's OK.
- If committing or pushing is declined or fails, say the file is temporary and will be lost with the environment (offer to move it to the scratchpad if one exists), and inline the next steps in the resume prompt instead of relying on the file path.

## Finish

Print the resume prompt in chat as the last thing in the reply.
