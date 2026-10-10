# Perplexity Deep Research prompts — round 3 (skill-by-skill benchmark)

Run each in Perplexity **Deep Research** mode. They target Reddit, X replies, YouTube comments and Discord, which Claude cannot reach. Paste results back as files.

---

## Prompt A — Our 11 skills vs. the best-known equivalents (reception on Reddit/forums)

```
Deep research, October 2026. For AI coding agents (Claude Code, Codex, Cursor, Antigravity), find first-hand practitioner reports — prioritise Reddit (r/ClaudeAI, r/ClaudeCode, r/cursor, r/ChatGPTCoding, r/ExperiencedDevs, r/LocalLLaMA), X replies, YouTube comments, Hacker News and Discord — about how well these specific agent skills work in daily use. For each, report what people keep using, what they drop, concrete complaints, workarounds, and any measured results (tokens, time, bugs caught, A/B or placebo tests). Cite a URL for every claim.

1. Interview/plan skills: mattpocock "grill-me"/"grilling"/"grill-with-docs", superpowers "brainstorming" and "writing-plans", gstack "office-hours"/"plan-ceo-review"/"plan-eng-review", spec-kit, OpenSpec, BMAD.
2. Debugging: superpowers "systematic-debugging"/"root-cause-tracing", mattpocock "diagnosing-bugs" (including the r/ClaudeAI placebo test: 61.8 vs 61.8 vs 62.6), pstack bug-fix playbook. Do these skills get auto-invoked in practice?
3. Verification: superpowers "verification-before-completion", gstack "qa"/"browse", pstack "prove-it-works"/"create-verification-skill", Claude Code's built-in /verify and /run.
4. Code review: Anthropic's code-review plugin, superpowers "requesting-code-review"/"receiving-code-review", gstack "review", pstack "interrogate"/"blast-radius". False-positive rates and noise complaints.
5. TDD: superpowers "test-driven-development" (iron law), mattpocock "tdd", tdd-guard hook. Include the tdd-guard 54-run benchmark and arXiv 2603.17973 finding that "do TDD" prompts increased regressions.
6. Session continuity: mattpocock "handoff", claude-mem, compound-engineering "compound", pstack "reflect"/"correct", ever-growing CLAUDE.md complaints.
7. Writing: humanizer / "signs of AI writing" skills, pstack "unslop", mattpocock "wait-what", caveman.

Output: a table per category (skill, sentiment, retention evidence, best quote, URL), then the top 10 cross-cutting lessons for designing such skills, then contradictions in the evidence.
```

---

## Prompt B — Candidate additions: are they worth it?

```
Deep research, October 2026. I maintain a small, lean Claude Code skill pack and am deciding whether to add these skill types. For each, find practitioner evidence (Reddit first — r/ClaudeAI, r/ClaudeCode, r/cursor, r/ExperiencedDevs — plus X, YouTube comments, HN, blogs) on whether it changes outcomes or just adds ceremony/tokens. Cite URLs.

1. Architecture improvement / deep-module refactor finder (mattpocock "improve-codebase-architecture", "codebase-design"; ~1.1M installs on skills.sh).
2. Throwaway prototyping (mattpocock "prototype"; EveryInc equivalent; "Don't waste time on specs: /prototype instead").
3. Implementing a spec/plan via subagents (mattpocock "implement"/"implement-spec", superpowers "executing-plans"/"subagent-driven-development"). Reports of over-orchestration, cost, quality.
4. PR / finish-a-branch / merge-conflict skills (mattpocock "pr", "resolving-merge-conflicts"; superpowers "finishing-a-development-branch"; gstack "ship").
5. Git guardrails / destructive-command blocking hooks (mattpocock "git-guardrails-claude-code", gstack "careful/freeze/guard") vs. plain permission rules.
6. Test-quality review for existing tests (mutation-style "would it pass if the code returned undefined?").
7. "Explain the codebase" skills (pstack "how"/"why"), and "receiving code review feedback" skills.

For each: verdict (worth adding / skip / only for X), the strongest evidence for and against, and the minimum design that captures the value. End with a ranked list.
```

---

## Prompt C — Reddit deep-dive on the two most-starred packs

```
Deep research on Reddit specifically (r/ClaudeAI, r/ClaudeCode, r/cursor, r/ChatGPTCoding, r/vibecoding, r/ExperiencedDevs), October 2026: threads discussing obra/superpowers (~297k stars) and mattpocock/skills (~284k stars). Summarise: which individual skills users say they kept after a month, which they uninstalled and why, head-to-head comparisons between the two, token/cost complaints, conflicts when both are installed, and any custom trimmed forks people share. Quote and link at least 20 distinct threads; mark anything older than June 2026.
```
