---
name: reflect
description: Reviews the current session for repeated mistakes and reusable facts, then proposes a concrete guard for each (test, lint rule, type, hook, skill edit, or CLAUDE.md line) and applies only the ones the user approves.
argument-hint: "[optional: which problem to focus on]"
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

Keep a candidate only if it is likely to recur in this project; drop typos and one-time slips. If early context was compacted away, say so.

## 2. Pick the strongest home whose cost fits

- **Code defects** → a test, type, or lint rule that makes the mistake fail CI.
- **Costly or repeated process mistakes** → a script or hook that checks automatically.
- **Workflow gaps** → an edit to an existing skill in `.claude/skills/` (edit; don't append duplicates). A new skill only when a repeated, non-trivial workflow has no home.
- **One-line conventions and facts** → the project CLAUDE.md.

## 3. Propose, then apply

1. Show a table: lesson → home → exact edit (diff or new lines).
2. Apply only what the user approves. If nothing is approved, stop.
3. Touch only the project CLAUDE.md and `.claude/skills/` unless the user asks otherwise. Keep each edit minimal, in the target file's style, and never add a rule that contradicts an existing one without resolving it.
4. For each test, hook, or lint rule added, show it catching the original mistake before calling it done.
