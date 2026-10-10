---
name: reflect
description: Mines a finished session for durable lessons and turns each into a concrete guard (a test, lint rule, type, skill edit, or CLAUDE.md line) so the mistake cannot recur. Use when the user says "reflect", "retro", or "what should we learn from this".
disable-model-invocation: true
---

# Reflect

A lesson that lives only in chat is forgotten next session. Encode it in structure.

Worth running after a difficult, failed, or heavily corrected session. After a smooth one, say there's nothing durable to learn and stop. Reflection on every session is its own overhead.

## 1. Collect candidates

Review the session for:

- Corrections the user had to make ("no, not like that").
- Things I got wrong and then fixed - wrong assumption, missed check, wasted detour.
- Facts I had to discover that the next agent will also need.
- Workflows that worked well and should be repeated.

Discard one-offs. A candidate needs to plausibly happen again.

## 2. Route each lesson to the strongest home

Prefer the home that makes the mistake impossible over one that merely warns about it:

1. **Type, test, or lint rule** - the mistake can't compile or pass CI.
2. **Script or hook** - the check runs automatically.
3. **Skill edit** - an existing skill in `.claude/skills/` gains a line or a step. Edit, don't append duplicates.
4. **CLAUDE.md** - a short, project-wide fact or convention.
5. **New skill** - only when a repeated workflow has no home and is non-trivial.

## 3. Propose, then apply

Show a table: lesson → home → exact edit (diff or new lines). Apply only what the user approves. Keep each edit minimal and in the target file's existing style. Never add a rule that contradicts an existing one without resolving the conflict.
