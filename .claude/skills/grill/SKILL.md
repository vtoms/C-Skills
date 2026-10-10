---
name: grill
description: Interviews the user about a plan, feature, or design in short rounds of high-impact questions, each with a recommended answer, until every open decision is settled, then records the decisions in a file. Use when the user says "grill me", asks what they are missing, asks to be challenged, wants gaps or risks in a plan found, or hasn't yet decided key parts of a design before building. Not for reviewing code, impact analysis of a concrete change (blast-radius), debugging, or obvious questions.
argument-hint: "[plan, file, or topic to grill]"
---

# Grill

Reach shared understanding before work starts. The value is in the few decisions that change the outcome - code, plan, or rollout - not in volume.

## Size it first

Estimate how many open decisions change the outcome and say so in one line ("~6 real decisions; 2–3 short rounds.").

- **≤2 decisions, and the skill was triggered automatically:** ask the one question that matters, or state the assumptions and wait for a go-ahead. **If the user explicitly asked to be grilled, challenged, or for gaps or risks, grill anyway (and do Holes first).**
- **Otherwise:** rounds of **at most 4 questions**, highest impact first.
- **Too big** (over ~15 real decisions, or several shippable pieces): propose a split and grill one piece.
- **Can't be settled by talking** (look and feel, "does library X really do Y", performance): offer `/spike` for that question and park what depends on it.
- **Mode:** default to rounds. If the user says "one at a time", switch for the rest of the session.

## Holes first (when asked to challenge the plan, find gaps or risks, or say what is missing)

Before the first round, list the top 3–5 risks or unstated assumptions in the plan, each with severity and a possible mitigation. Any that need the user's choice become questions in the rounds.

## Only ask the frontier

Ask only questions whose prerequisites are settled. **If any plausible answer to Q1 would change or remove Q2, Q2 waits for the next round.** Re-plan the frontier after every answer.

Drop questions where every option leads to the same outcome. Collect low-stakes choices into one closing line ("Unless you object, I'll also: …").

## Facts are mine, decisions are theirs

Never ask what can be looked up - file layout, existing patterns, versions, what a function does. Read the code or send a subagent while asking the rest of the frontier.

When the code settles a likely answer, don't ask: list it under "Assuming (from code):" with the file it rests on, for the user to correct.

## Terms and claims

- If the user uses a term two ways or unlike the code ("account": Customer or User?), ask which.
- If the user says how something works and the code disagrees, say so with file:line and ask which is right.
- If the repo already has a glossary (GLOSSARY.md, CONTEXT.md, docs/glossary), add resolved terms there; never start one.

## Asking

Prefer the `AskUserQuestion` tool when available (up to 4 questions with options; put the recommendation first, labelled "(Recommended)"). Otherwise:

```
**Q1 — <short title>**
<question, with concrete options>
→ Recommended: <answer> — <one-line why>
```

Word each question so "yes" accepts the recommendation. Mark **⚠** questions that are hard to reverse (stored data, public interfaces, money, security); a blanket "ok" doesn't cover them. End the round with: "Reply 'ok' to take all unmarked recommendations, or answer by number."

## Stop

Stop when no remaining question would change the outcome, or the user says "you decide" or "enough". List the defaults being taken. **Do not implement until the user confirms the summary** - running out of questions is not permission to start.

## Record

After the user confirms, write the decisions to the repo's existing ADR/decisions location if there is one, else `docs/decisions/<topic>.md` (or where the user prefers) - one line each: decision, choice, reason, and `chosen` (the user picked it) or `default` (via recommendation, "ok", or "you decide"). Suggest an ADR only for decisions hard to reverse, surprising, and a real trade-off. Never overwrite an existing file; append a dated section to it instead. Later work cites this file instead of re-asking. Say the file is uncommitted and offer to commit it (ask before pushing); if the work spans several PRs, suggest `/spec <path>` next. If the session is long, suggest continuing in a fresh session that starts from that file.
