---
name: spec
description: Turns already-settled decisions (a grill's decisions file, an issue, or this conversation) into a one-page spec at docs/specs/<topic>.md with 2-6 independently shippable vertical slices, each with a done-when check. Writes only the spec file; creates no issues or code unless asked afterwards.
argument-hint: "[decisions file, issue, or topic]"
disable-model-invocation: true
---

# Spec

Synthesis, not another interview.

## Source

Use the argument if given, else this conversation, else the newest file in `docs/decisions/`. If none of these contains decisions, say so and ask for them (or suggest running /grill first). If one open decision blocks every slice, ask that single question and stop; other open decisions go under **Open questions**. Don't invent requirements to fill gaps.

## Size it

- **Fits one PR:** say so and offer a 3-line plan instead. Write the full spec anyway if the user still wants it (a single slice is fine then).
- **Otherwise:** one spec file and **2–6 slices**.
- **Would need more than 6 slices:** say the scope is too big, propose a split, and stop until the user picks a part.

## The spec file

Save to `docs/specs/<topic>.md` (or the user's preferred place); never overwrite an existing file without asking - offer to update it in place or write to a new name. Keep it under a page and a half:

1. **Problem** - who hurts and how, in the user's words.
2. **Outcome** - what's true when this is done; observable, testable.
3. **Decisions** - link the decisions file if a grill produced one; otherwise one line each with the reason.
4. **Out of scope** - what is deliberately not being done.
5. **Slices** - see below.
6. **Open questions.**

## Slices

Each slice is a **vertical tracer bullet**: thin, end-to-end, demoable, mergeable on its own - never "all the schema", then "all the API".

**Exception - wide mechanical changes** (rename a column, retype a shared symbol): one edit breaks every caller, so slice them expand → migrate → contract. Expand adds the new form beside the old; migrate moves callers in batches (per package or directory), each green on its own; contract deletes the old form once no caller remains. If external consumers or persisted data exist, run `/blast-radius` before the contract slice.

For each slice:

```
### S<n>: <user-visible capability>
Delivers: <what a user/caller can do after this merges>
Touches: <modules/files, best guess from reading the code>
Done when: <the check that proves it - test name, command, or observed behaviour>
Blocked by: <S-numbers, or none>
```

Order so S1 is the smallest slice that proves the riskiest assumption.

## After writing

1. **Builder check.** Have a fresh subagent (or, without one, yourself) read the spec as a builder who can't ask the user anything and list only the places where it would have to guess and a wrong guess would change what gets built. Fold answers already in the conversation or code into the spec; settle minor ones yourself, marked "(my call)"; bring the rest to the user in one message. That is the only question round.
2. Show the slice list in chat.
3. Say the spec file is uncommitted and offer to commit it. In an ephemeral environment, an uncommitted file is lost when the session ends.
4. Create GitHub issues or tracker items only if the user asks - one per slice. Link to the spec only if it has been pushed (ask before pushing); otherwise inline the slice text.
5. Don't start implementing until the user picks a slice.
