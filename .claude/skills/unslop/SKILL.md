---
name: unslop
description: Edits prose to remove AI-writing tells (filler, inflated words, hedging, chatbot phrases, decorative formatting) while keeping every fact, code block, quote, and name unchanged. Works on a file, pasted text, or the last assistant reply.
argument-hint: "[file path or pasted text; empty = last reply]"
disable-model-invocation: true
---

# Unslop

Edit the text so it reads like a careful person wrote it.

**Input:** a file path, pasted text, or - with no argument - the last assistant reply.

**Never change:** facts, numbers, instructions, code blocks, inline code, commands, URLs, quotes, names, frontmatter, or headings that are link anchors or contain product names - even if they contain the patterns below. Cutting an unsupported claim or a pure restatement is allowed; list each cut claim after the text.

## What to cut or fix

- **Chatbot residue** - "Great question", "I hope this helps", "Certainly!", "Let me know if…". Delete.
- **Inflated words** - delve, crucial, pivotal, robust, seamless, leverage, utilize, facilitate, showcase, landscape, tapestry, testament, underscore. Use the plain word.
- **Fake depth** - trailing "-ing" clauses ("…, ensuring reliability"), "not just X but Y", "serves as" for "is", groups of three that exist for rhythm. State the point once.
- **Filler and hedging** - "in order to" → "to"; "it's important to note that" → delete; "could potentially" → "may".
- **Vague claims** - "experts say", "significantly faster", "best-in-class". Name the source or give the number if it's in the text; otherwise cut and list it.
- **Metaphor where a literal word exists** - north star, flywheel, surface (verb), substrate, unlock. Say the concrete thing.
- **Generic closers** - "The future looks bright", an "In summary" that repeats the body. Cut, or replace with the actual next step.
- **Decorative formatting** - emoji bullets, bold on every other phrase, "**Label:** label restated" lists, Title Case Headings. Use sentence case, and prose where a list adds nothing.
- **Over-compression** - arrows, dropped articles, verbless fragments. Write full sentences.

## How

1. Read the whole text first; keep its audience and tone.
2. Edit. Prefer deleting over rewording. For a file, skip generated files, licences, and past CHANGELOG entries; apply the edits and show a diff.
3. Do one pass comparing against the original; restore anything protected or lost.
4. Reply with the revised text (for a file, the diff), then one line: the number of changes and the two most common patterns fixed, then the list of cut claims, if any. No other commentary.

If the text is already clean, say so and change nothing.
