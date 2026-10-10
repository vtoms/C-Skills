# Research findings (Claude pass, 2026-10-10)

Sources: four research subagents using WebFetch/WebSearch, plus local clones of both repos. Reddit, X replies, YouTube comments and Medium were blocked; that's what the Perplexity prompts are for.

## Matt Pocock: Skills For Real Engineers

- **Where and what:** [aihero.dev/skills](https://www.aihero.dev/skills) and [github.com/mattpocock/skills](https://github.com/mattpocock/skills). MIT licence, free, about 284k stars and 23.8k forks. Started Feb 2026; v1.0 on Jun 18, v1.3 on Oct 5, 2026.
- **Install:** `claude plugin install mattpocock-skills@claude-plugins-official` or `npx skills@latest add mattpocock/skills`. Run `/setup-matt-pocock-skills` once per repo.
- **Core skills:**
  - grilling / grill-me / grill-with-docs: decision-tree rounds, each question with a recommended answer
  - to-spec → to-tickets → implement, plus wayfinder
  - tdd
  - diagnosing-bugs: feedback loop first
  - code-review: Standards and Spec reviews run as parallel subagents
  - handoff, wait-what, domain-modeling (GLOSSARY.md plus ADRs), codebase-design (deep modules), prototype, retro
- **Philosophy:** fixes four failure modes: misalignment (grilling), jargon (a ubiquitous language), code that doesn't work (feedback loops and TDD), and a ball of mud (deep modules). Small, composable skills you fork; most are user-invoked to save tokens.
- **Praised:**
  - grill-me is the standout ("the only one I have found gets regular mileage", "the ultimate rubber ducky")
  - the grill → spec → tickets pipeline, tdd, handoff and diagnosing-bugs
  - Matt's video "A complete AI Coding workflow" has 616k views; Theo's "So I tried Matt's skills..." has 485k
- **Criticised:**
  - too many questions (issue #44, "200 questions"); rounds of 10+ questions (#831, closed wontfix)
  - GPT models skip straight to implementing after the grill (#240)
  - `/code-review` clashes with the built-in command (#483)
  - grilling leaves no durable output (#311), and decisions aren't traceable (#341)
  - no versioning or pinning; leans heavily on TypeScript; long grills cost a lot of context

## pstack (Lauren Tan / poteto; mirror by backnotprop)

- **Origin:** backnotprop/pstack is a harness-neutral **mirror** of Cursor's `cursor/plugins/pstack`, written by Lauren Tan (Cursor engineer, React core team). MIT licence. The mirror has about 1.5k stars and is at v0.15.15. backnotprop (Michael Ramos) also wrote Plannotator.
- **Contents:**
  - `/poteto-mode`, a router over 23 playbooks
  - about 27 functional skills: interrogate, arena, swarm, blast-radius, how, why, reflect, correct, unslop, tdd, and others
  - 24 `principle-*` skills, such as prove-it-works, fix-root-causes and encode-lessons-in-structure
  - multi-model routing: Grok writes code, Opus judges
- **Praised:** "verify it becomes a repository capability" (Flavio Copes); it goes deep before broad. The evidence ladder and the idea of proving the one load-bearing fact are distinctive.
- **Criticised:**
  - cost and ceremony: "a one-line fix doesn't need it"; with frontier models in every role, token bills grow fast
  - assumes a worktrees/PR/gh team workflow; works best in Cursor
  - an unverified benchmark claims +123% tokens and a 36% pass rate for poteto-mode
  - security audit (invox#71): `make-bot-ui` runs `curl | sudo sh`, `bun install` pulls `@latest`, and the autopilot playbooks auto-merge and force-push
  - interoperability: skill names containing spaces broke invocation outside Cursor (#4, fixed)
  - HN: "i want my agents to understand me, not poteto"
- **Comparison:** poteto says the two packs complement each other: Matt's builds understanding, while pstack is code-oriented (sketch and prototype rather than a big up-front plan).

## What C-Skills keeps from each

| From | Kept | Dropped |
|---|---|---|
| Pocock | grilling rounds with recommendations, feedback-loop debugging, vertical-slice TDD, handoff, plain re-pitch | issue-tracker pipeline (needs per-repo setup), GLOSSARY/ADR machinery, `code-review` name |
| pstack | evidence ladder, load-bearing-fact blast radius, lead-judgment review buckets, encode-lessons-in-structure | poteto-mode router, multi-provider routing, autopilot/shipping playbooks, unsafe installers |

## Perplexity round 1: AI Hero skills (full report: [research/perplexity-aihero.md](research/perplexity-aihero.md))

Key evidence:
- **Retention:** most to least retained: grill-me, grill-with-docs, to-spec/to-tickets, handoff, tdd. The rest of the pack is mostly dropped as "autocomplete noise" (#159).
- **Placebo test of `diagnosing-bugs`** (Reddit r/ClaudeAI):
  - In 16 headless trials it was never auto-invoked.
  - Forced runs scored 61.8 with no skill, 61.8 with a placebo and 62.6 with the real skill. Methodology alone did not change outcomes.
- **Superpowers vs Pocock** (The Gray Cat):
  - Superpowers took 78 min and about $34; Pocock took 148 min and about $92.
  - Pocock delivered more features but needed repair. Treat this as directional.
- **The "63% token reduction"** refers to skill-description tokens only, not end-to-end cost.
- **Complaints:**
  - too many questions, including dependent questions asked in the same batch (#895)
  - context and token cost
  - review findings not verified (#582)
  - name clashes (`code-review`, `prototype`)
  - handoff lost when the session ends first
  - GPT-family models skip the workflow gates

## Changes made in response (v0.1)

| Finding | Edit |
|---|---|
| Dependent questions asked in the same round (#895) | `grill`: "If any plausible answer to Q1 would change Q2, Q2 waits" |
| Minor questions bury the important ones | `grill`: drop questions where every option gives the same code; bundle low-stakes defaults into one line |
| Structured question UI request (#798) | `grill`: prefer `AskUserQuestion` (its 4-question limit matches our cap) |
| Agent starts implementing once the questions run out (#240, #1068) | `grill`: "running out of questions is not permission to start" |
| Long context, so reset (70% rule) | `grill`: persist decisions, then suggest a fresh session |
| Placebo test: methodology prose didn't change outcomes | `diagnose`: cut generic prose; kept only the gate (a command that goes red before any theory), an "if obvious, just fix" exit, and a check that the regression test fails on the old code |
| Review findings not verified (#582) | `interrogate`: every finding must be verified at the cited line before reaching Act on or Consider; unverified findings go to Noted |
| Handoff lost if the session ends first | `handoff`: write it early, commit and push it, add a paste-able resume prompt |
| TDD dilutes attention (#590); "direct proof over mandatory TDD" | `tdd`: two phases (seams and a list of behaviour names, then the loop); skip TDD for glue code and use `prove-it` |
| to-spec/to-tickets is the 3rd most retained layer; criticism of process inflation | new `spec`: 2–6 vertical slices max, a file instead of tracker setup, no external issues unless asked |
| `/prototype` clash (#1019) | validator now reserves `prototype` |
| `wait-what` replaced by output styles | README: for a permanent preference use an output style; `plain` is a one-off |
