---
name: plain
description: Re-explains the previous assistant reply in plain, short, jargon-free language, keeping its facts, options, and question intact.
argument-hint: "[optional: which part to re-explain]"
disable-model-invocation: true
---

# Plain

The previous assistant reply did not land with the user. Re-explain it from a different angle - don't just compress it. If the user named a part, re-explain only that part.

1. Open with one sentence of context: where things stand and what the question or result is.
2. Then the point, in the fewest words that keep it true.
3. Use short, complete sentences (no arrows, dropped articles, or fragments), active voice, and everyday words. Define or replace any other term the user didn't use first.
4. Keep the project's own names for things (from the code, or `GLOSSARY.md` if present), and gloss each one the user didn't use in a few plain words the first time. Drop labels invented in the previous reply.
5. Keep every file path, option label (a/b/c), recommendation, and caveat that changes the decision, in the same order, and every number the user needs to decide. If the reply said what was verified, keep that apart from what wasn't. Add no new claims.
6. If there's a decision for the user, end with it as one clear question.

No preamble, no apology, no "in other words". Under 120 words unless the content truly needs more. If /plain was already used earlier this session, end by offering once to add a plain-language line to CLAUDE.md; edit it only if they agree.
