---
name: reflect
description: Reviews the current session (or, on request, recent commits and reverts) for repeated mistakes and reusable facts, then proposes a concrete guard for each (test, lint rule, type, hook, skill edit, or CLAUDE.md line) and applies only the ones the user approves.
argument-hint: "[optional: which problem to focus on, or 'repo' to mine recent history]"
disable-model-invocation: true
---

# Reflect

A lesson that lives only in chat is forgotten next session. Encode it in structure.

Worth running after a difficult, failed, or heavily corrected session. After a smooth one, say there's nothing durable to learn and stop.

## 1. Collect candidates

Review the session (or just the part the user named) for:

- Corrections the user had to make ("no, not like that").
- Wrong assumptions, missed checks, wasted detours that were later fixed.
- Facts that had to be discovered and the next agent will also need.
- Workflows that worked well and should be repeated.

For each candidate, quote the session moment that shows it; drop any you can't point to. Keep it only if it is likely to recur in this project and the code alone won't teach it: would the next agent, reading the final code, still make this mistake? Drop typos, one-time slips, and facts tied to a SHA or version that will drift. If early context was compacted away, say so.

**Repo mode** (`/reflect repo`): read the last ~50 commits, reverts, and review comments instead; a mistake counts once it happened twice, and the quote is the commit or comment.

## 2. Pick the strongest home whose cost fits

- **Code defects** → a test, type, or lint rule that makes the mistake fail CI.
- **Process mistakes that recurred despite a written rule, or are costly** → a script or hook that checks automatically; otherwise a CLAUDE.md line first.
- **Workflow gaps** → an edit to an existing skill in `.claude/skills/` (edit; don't append duplicates). A new skill only when a repeated, non-trivial workflow has no home.
- **One-line conventions and facts** → CLAUDE.md only if it applies across the whole repo; a narrower one goes in a path-scoped rule file (e.g. `.claude/rules/<topic>.md`) or the relevant skill. If CLAUDE.md is near 200 lines, pair the addition with a removal.

A written rule that was still broken needs a check (test, lint, or hook), not another line.

## 3. Propose, then apply

1. Show a table: lesson → home → exact edit (diff or new lines).
2. Apply only what the user approves. If nothing is approved, stop.
3. Edit only files in this project named in the rows the user approved - never `~/.claude` or other user-level files unless the user asks. Keep each edit minimal, in the target file's style, and never add a rule that contradicts an existing one without resolving it.
4. For each test, hook, or lint rule added, show it catching the original mistake before calling it done. Its error message names the fix (the function, file, or command to use instead); if the bad pattern already exists elsewhere, fail only on new occurrences.
5. In the same table, propose deleting the prose rules each new check supersedes.
