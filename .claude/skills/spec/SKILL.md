---
name: spec
description: Turns settled decisions from a grill, discussion, or issue into a short spec file with 2-6 independently shippable vertical slices that another agent or person can execute. Use when the user says "write a spec", "turn this into tickets", or "plan the PRs", or when work must survive across sessions or people.
argument-hint: "[decisions file, issue, or topic]"
disable-model-invocation: true
---

# Spec

Synthesis, not another interview. If a decision the spec needs is still open, list it under **Open questions** rather than starting a grill - unless it blocks every slice.

## Size it

- Work that fits one PR: skip the spec; a 3-line plan in chat is enough.
- Otherwise: one spec file and **2–6 slices**. More than 6 means the scope is too big - say so and propose a split.

## The spec file

Save to `docs/specs/<topic>.md` (or the user's preferred place). Keep it under a page and a half:

1. **Problem** - who hurts and how, in the user's words.
2. **Outcome** - what's true when this is done; observable, testable.
3. **Decisions** - link `docs/decisions/<topic>.md` if a grill produced one; otherwise one line each with the reason.
4. **Out of scope** - what we're deliberately not doing.
5. **Slices** - see below.
6. **Open questions.**

## Slices

Each slice is a **vertical tracer bullet**: thin, end-to-end, demoable, mergeable on its own - never "all the schema", then "all the API". For each:

```
### S<n>: <user-visible capability>
Delivers: <what a user/caller can do after this merges>
Touches: <modules/files, best guess from reading the code>
Done when: <the check that proves it - test name, command, or observed behaviour>
Blocked by: <S-numbers, or none>
```

Order so S1 is the smallest slice that proves the riskiest assumption.

## After writing

Show the slice list in chat and ask before creating anything external. Only create GitHub issues (or any tracker items) when the user asks, one per slice, linking back to the spec. Don't start implementing until the user picks a slice.
