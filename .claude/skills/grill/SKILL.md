---
name: grill
description: Interviews the user about a plan, feature, or design in short rounds of high-impact questions, each with a recommended answer, until every open decision is settled, then records the decisions in a file. Use when the user says "grill me", asks what they are missing, asks to be pushed back on or challenged, wants gaps or risks in a plan found, or wants to settle decisions before building. Not for reviewing code or PRs, debugging, one-line fixes, or questions with an obvious answer.
argument-hint: "[plan, file, or topic to grill]"
---

# Grill

Reach shared understanding before work starts. The value is in the few decisions that change the outcome - code, plan, or rollout - not in volume.

## Size it first

Estimate how many open decisions change the outcome and say so in one line ("~6 real decisions; 2–3 short rounds.").

- **≤2 decisions, and the skill was triggered automatically:** ask the one question that matters, or state the assumptions and wait for a go-ahead. **If the user explicitly asked to be grilled, grill anyway.**
- **Otherwise:** rounds of **at most 4 questions**, highest impact first.
- **Mode:** default to rounds. If the user says "one at a time", switch for the rest of the session.

## Holes first (when asked to stress-test or find gaps)

Before the first round, list the top 3–5 risks or unstated assumptions in the plan, each with severity and a possible mitigation. Any that need the user's choice become questions in the rounds.

## Only ask the frontier

Ask only questions whose prerequisites are settled. **If any plausible answer to Q1 would change or remove Q2, Q2 waits for the next round.** Re-plan the frontier after every answer.

Drop questions where every option leads to the same outcome. Collect low-stakes choices into one closing line ("Unless you object, I'll also: …").

## Facts are mine, decisions are theirs

Never ask what can be looked up - file layout, existing patterns, versions, what a function does. Read the code or send a subagent while asking the rest of the frontier.

## Asking

Prefer the `AskUserQuestion` tool when available (up to 4 questions with options; put the recommendation first, labelled "(Recommended)"). Otherwise:

```
**Q1 — <short title>**
<question, with concrete options>
→ Recommended: <answer> — <one-line why>
```

Word each question so "yes" accepts the recommendation, and end the round with: "Reply 'ok' to take all recommendations, or answer by number."

## Stop

Stop when no remaining question would change the outcome, or the user says "you decide" or "enough". List the defaults being taken. **Do not implement until the user confirms the summary** - running out of questions is not permission to start.

## Record

After the user confirms, write the decisions to the repo's existing ADR/decisions location if there is one, else `docs/decisions/<topic>.md` - one line each: decision, choice, reason. Never overwrite an existing file. If the session is long, suggest continuing in a fresh session that starts from that file.
