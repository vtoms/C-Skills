---
name: unslop
description: Rewrites prose to remove the tells of AI-generated writing (filler, inflated vocabulary, hedging, chatbot phrases, decorative formatting) while keeping its meaning and tone. Use when the user says "unslop", "de-AI this", or "make this sound human", or asks to polish a README, PR description, doc, or message before others read it.
argument-hint: "[file path, or paste the text]"
disable-model-invocation: true
---

# Unslop

Edit the given text so it reads like a careful person wrote it. Keep every fact, claim, and instruction. Never change code blocks, commands, quotes, or names.

## What to cut or fix

- **Chatbot residue** - "Great question", "I hope this helps", "Certainly!", "Let me know if…". Delete.
- **Inflated words** - delve, crucial, pivotal, robust, seamless, leverage, utilize, facilitate, showcase, landscape, tapestry, testament, underscore. Use the plain word.
- **Fake depth** - trailing "-ing" clauses ("…, ensuring reliability"), "not just X but Y", "serves as" for "is", groups of three that exist for rhythm. State the point once.
- **Filler and hedging** - "in order to" → "to"; "it's important to note that" → delete; "could potentially" → "may".
- **Vague claims** - "experts say", "significantly faster", "best-in-class". Name the source or give the number; otherwise cut.
- **Metaphor where a literal word exists** - north star, flywheel, surface (verb), substrate, unlock. Say the concrete thing.
- **Generic closers** - "The future looks bright", "In summary, …" that repeats the body. Cut or replace with the actual next step.
- **Decorative formatting** - emoji bullets, bold on every other phrase, "**Label:** Label restated" lists, Title Case Headings. Use sentence case and prose where the list adds nothing.
- **Over-compression** - arrows, dropped articles, verbless fragments. Write full sentences.

## How

1. Read the whole text first; identify its audience and tone and keep both.
2. Edit in place. Prefer deleting over rewording.
3. Do one pass for meaning: compare against the original and restore anything lost.
4. Reply with the revised text (or edit the file), then one line: how many changes and the two most common patterns fixed. No commentary beyond that.

If the text is already clean, say so and change nothing.
