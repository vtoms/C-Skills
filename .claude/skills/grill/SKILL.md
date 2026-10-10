---
name: grill
description: Interview the user about a plan, feature, or design until every open decision is settled, then write the decisions down. Use when the user says "grill me", "stress-test this plan", "poke holes in this", or asks to align before building something non-trivial. Not for one-line fixes or questions with an obvious answer.
---

# Grill

Reach shared understanding before code exists. Every answer settled here is a decision nobody has to reverse in review.

## Size the grill first

Before asking anything, estimate how many real decisions the task has and say so in one line ("This looks like ~6 decisions; I'll ask in 2–3 rounds.").

- **Tiny task** (≤2 decisions): don't grill. State your assumptions and proceed, or ask the one question that matters.
- **Normal task**: rounds of **at most 4 questions**.
- **Large task**: same cap per round; more rounds. Never dump 10+ questions at once.

If the user says "one at a time", ask one question per turn for the rest of the session.

## Map the decision tree

Each decision unlocks decisions that depend on it. The **frontier** is the set of decisions whose prerequisites are already settled. Ask only frontier questions; a question whose answer depends on something still open waits for a later round.

## Facts are mine, decisions are theirs

Never ask the user something I can look up (file layout, existing patterns, library versions, what a function does). Read the code, or send a subagent to explore, while asking the rest of the frontier. Only *choices* go to the user.

## Round format

```
**Q1 — <short title>**
<the question, with the concrete options if there are any>
→ Recommended: <my answer and a one-line why>
```

Word each question so "yes" accepts the recommendation. Lead with the highest-impact question. Skip questions where every option leads to the same code.

## Stop rule

Stop when the frontier is empty or every remaining question is low-impact. Say which low-impact choices I'll make by default. Do not start implementing until the user confirms the summary.

## Leave a durable record

When done, write the settled decisions to `docs/decisions/<topic>.md` (or the path the user prefers): one line per decision, with the chosen option and the reason. Later work cites this file instead of re-asking. If the user does not want a file, put the summary in chat.
