---
name: grill
description: Interviews the user about a plan, feature, or design in short rounds until every open decision is settled, then records the decisions in a file. Use when the user says "grill me", "stress-test this plan", or "poke holes in this", or wants to align before building something non-trivial. Not for one-line fixes or questions with an obvious answer.
argument-hint: "[plan or topic to grill]"
---

# Grill

Reach shared understanding before code exists. The value is in the few decisions that reshape the design - not in volume.

## Size it first

Before asking anything, estimate how many decisions actually change the code and say so in one line ("~6 real decisions; 2–3 short rounds.").

- **≤2 decisions:** don't grill. State assumptions and proceed, or ask the one question that matters.
- **Otherwise:** rounds of **at most 4 questions**, highest impact first.
- **Mode:** default to rounds. If the user says "one at a time", switch for the rest of the session.

## Only ask the frontier

Each decision unlocks others. Ask only questions whose prerequisites are settled. **If any plausible answer to Q1 would change or remove Q2, Q2 waits for the next round.** Re-plan the frontier after every answer.

Drop questions where every option leads to the same code. Collect low-stakes choices into one closing line ("Unless you object, I'll also: …") instead of asking each.

## Facts are mine, decisions are theirs

Never ask what I can look up - file layout, existing patterns, versions, what a function does. Read the code or send a subagent while asking the rest of the frontier.

## Asking

Prefer the `AskUserQuestion` tool when available (it takes up to 4 questions with options; put the recommendation first, labelled "(Recommended)"). Otherwise use:

```
**Q1 — <short title>**
<question, with concrete options>
→ Recommended: <answer> — <one-line why>
```

Word each question so "yes" accepts the recommendation.

## Stop

Stop when no question left would change the code. List the defaults I'm taking. **Do not implement until the user confirms the summary** - running out of questions is not permission to start.

## Persist, then reset

Write the decisions to `docs/decisions/<topic>.md` (or where the user prefers): one line each - decision, choice, reason. Later work cites this file instead of re-asking. If the session is long, suggest continuing implementation in a fresh session from that file (or via `handoff`) rather than carrying the whole interview in context.
