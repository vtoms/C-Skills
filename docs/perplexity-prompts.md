# Perplexity research prompts

Paste each prompt into Perplexity on its own (Pro Search / Deep Research). They are written to cover what the Claude research couldn't reach: Reddit, X/Twitter replies, YouTube comments, Discord, and Medium.

---

## Prompt 1: Matt Pocock's AI Hero skills (aihero.dev/skills · github.com/mattpocock/skills)

```
Research how working developers actually experience Matt Pocock's "Skills For Real Engineers" agent-skill pack (https://www.aihero.dev/skills, repo github.com/mattpocock/skills, ~284k GitHub stars, v1.3 released Oct 5 2026). Focus on first-hand user reports, not marketing.

Prioritise these sources, which I could NOT access myself:
- Reddit: r/ClaudeAI, r/ClaudeCode, r/ChatGPTCoding, r/cursor, r/ExperiencedDevs, r/typescript, r/webdev, r/LocalLLaMA. Search for "grill-me", "grill me skill", "mattpocock skills", "to-spec", "to-tickets", "wayfinder", "/handoff", "diagnosing-bugs", "Matt Pocock skills vs superpowers".
- X/Twitter: replies and quote-tweets to @mattpocockuk announcing grill-me, v1.0 (Jun 18 2026), v1.2 and v1.3, and the "63% token reduction" claim.
- YouTube comment sections: Matt Pocock's "mattpocock/skills: A complete AI Coding workflow, end-to-end", "/handoff is my new favourite skill", "I stopped using /grill-me for coding"; Theo's "So I tried Matt's skills..."; Eric Tech's "Matt Pocock's Claude Code Skills Beat Superpowers Now".
- Medium (e.g. Marc Bara's piece on skills that "add friction"), Discord servers, Hacker News comment threads.

Answer these questions, citing a URL for every claim:
1. Which individual skills do people keep using after the first week, and which do they drop? Rank them by how often they're mentioned positively (grilling/grill-me, grill-with-docs, tdd, diagnosing-bugs, handoff, to-spec/to-tickets, wayfinder, implement, code-review, wait-what, prototype).
2. Concrete complaints: too many questions per grill round, long sessions and context/token cost, behaviour on non-Claude models (GPT-5.x, Gemini), TypeScript bias, name clashes with built-in commands, update/versioning pain, Desktop app vs CLI problems. How common is each?
3. Any measured results: token usage, time saved, bugs caught, before/after comparisons, A/B tests against obra/superpowers, gstack, GSD, BMAD, Spec-Kit or plain plan mode.
4. Workarounds and modifications people made: forks, CLAUDE.md tweaks such as "ask one question at a time", trimmed versions, and how they combine these skills with other packs.
5. Expert or senior-engineer critiques of the philosophy (grilling before code, ubiquitous language/GLOSSARY.md, deep modules, tracer-bullet tickets).

Output: a table of skill, sentiment (+/−/mixed), mention count, best quote and URL; then a list of the top 10 criticisms with sources; then the top 5 workarounds. Mark anything older than April 2026 as possibly outdated.
```

---

## Prompt 2: pstack (github.com/backnotprop/pstack, a mirror of Cursor's pstack by Lauren Tan / poteto)

```
Research real-world reception of "pstack", the agent-skill/plugin pack by Lauren Tan ("poteto", Cursor engineer, React core team). It is published at github.com/cursor/plugins/tree/main/pstack and mirrored for Claude Code, Codex and Pi at github.com/backnotprop/pstack (by Michael Ramos / backnotprop, author of Plannotator; ~1.5k stars, version 0.15.15, Oct 2026). Key parts: /poteto-mode (a router with 23 playbooks), interrogate (multi-model adversarial review), arena, swarm, blast-radius, how, why, reflect, correct, unslop, tdd, and 24 "principle-*" skills (prove-it-works, fix-root-causes, subtract-before-you-add, etc.).

Prioritise sources I could NOT access:
- Reddit: r/cursor, r/ClaudeAI, r/ClaudeCode, r/ChatGPTCoding, r/ExperiencedDevs. Search "pstack", "poteto-mode", "poteto mode", "Lauren Tan skills", "pstack vs gstack", "pstack claude code".
- X/Twitter: replies to @poteto's "How I Use Cursor" and "The Complete Guide to pstack" Pt. 1/2 articles, @steffen_dybvik's "How i use the pstack plugin", and @backnotprop posts about the mirror.
- Cursor forum (forum.cursor.com), Discord, YouTube videos/comments, and blogs beyond flaviocopes.com and webreactiva.com.

Answer, citing a URL for every claim:
1. Which pstack skills and playbooks do people actually use day to day, and which are ignored? Is poteto-mode really "the one command you'll type most"?
2. Cost and overhead: token usage, the reported +123% tokens / 36% pass-rate benchmark for poteto-mode (find the source, e.g. DecimalAI or a skills directory, and check it), complaints about ceremony on small tasks.
3. How well it works outside Cursor (Claude Code, Codex, Pi), and how the backnotprop mirror compares with other ports (michael-denyer/pstack-claude, Tonikprofik/pstack, tim-mcdonnell/pstack, uni-pstack, potetos-for-everyone).
4. Security/safety concerns: the make-bot-ui `curl | sudo sh`, auto-merge/force-push in the shipping/autopilot playbooks, unpinned `bun install` dependencies. Did anyone else audit it?
5. Head-to-head comparisons with Garry Tan's gstack, obra/superpowers, and Matt Pocock's skills. Include poteto's own statement that pstack and Matt's skills "complement each other".
6. Which ideas from pstack (evidence ladder in blast-radius, multi-model interrogate, encode-lessons-in-structure, reflect) have other people copied into their own setups?

Output: a summary verdict; a table of skill/playbook, sentiment, evidence and URL; the top criticisms; and a list of ideas worth borrowing even without the full pack. Note where evidence is thin or comes only from the author.
```
