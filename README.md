# C-Skills

Agent Skills for Claude Code. They're distilled from the two most-discussed skill packs of 2026, Matt Pocock's [AI Hero skills](https://www.aihero.dev/skills) and Lauren Tan's [pstack](https://github.com/backnotprop/pstack), and rewritten to fix what their users complained about. See [NOTICE.md](NOTICE.md) for attribution.

**Status: v0.5.2, verified.** Both Perplexity rounds are folded in. The skills then went through three rounds of independent adversarial checks: a red-team pass, a regression pass, and a final pass on fresh held-out prompts. Results are in [docs/verification/](docs/verification/), summarised below.

## Skills

They live in `.claude/skills/`, so Claude Code loads them automatically in this repo. "Auto" means Claude can invoke the skill itself; "manual" means only you can, by typing `/name`.

| Skill | Mode | What it does | Fixes this complaint about the original |
|---|---|---|---|
| `grill` | auto | Interviews you until every design decision is settled, then writes the decisions down | Too many questions ("200 questions", "10+ at once"): estimates the decision count up front, caps rounds at 4 questions, skips trivial tasks, supports "one at a time". It also leaves a durable record, which grill-me lacked (#311) |
| `diagnose` | auto | Repro-first debugging loop: red-capable command → minimise → hypotheses → instrument → root-cause fix → regression test | Adds pstack's fix-root-causes rules (no silencing guards, suspect stale state on "after restart" bugs) |
| `prove-it` | auto | Verifies against the real artifact and reports an evidence level (1–5) before saying "done" | Sized to the task, because pstack is criticised for ceremony on small fixes |
| `blast-radius` | auto | Finds what a change breaks beyond the diff and proves the one load-bearing safety fact | Scales effort to the change |
| `tdd` | auto | Vertical-slice red/green with agreed seams; no tautological tests | Works without a user present (chooses and states the seams) |
| `interrogate` | manual | Parallel adversarial reviewer subagents with different lenses, then a lead verdict | Named to avoid clashing with the built-in `/code-review` (mattpocock/skills#483); single-model lenses replace pstack's Grok + Opus setup |
| `spec` | manual | Turns settled decisions into a short spec plus 2–6 independently shippable vertical slices | Avoids process inflation: no tracker setup, a hard cap on slices, nothing created externally unless you ask |
| `handoff` | manual | Writes a handoff doc so a fresh agent can continue cold | Write it early, commit it, include a paste-able resume prompt |
| `plain` | manual | Re-explains the last message in plain language | Combines `wait-what` and `/bro`. For a permanent preference, use a Claude Code output style instead |
| `unslop` | manual | Removes AI-writing tells from prose while keeping meaning, tone, and code untouched | pstack's best-received standalone skill, rewritten shorter; makes no changes if the text is already clean |
| `reflect` | manual | Turns session lessons into the strongest guard (type, test, lint, then a skill or CLAUDE.md edit) | Proposes changes before applying them; leaves out pstack's transcript-mining across workspaces |

**Left out on purpose:** autopilot, shipping and auto-merge playbooks, `sudo`/`curl | sh` installers, `@latest` dependencies, and multi-provider model routing. Those were the security and cost complaints raised about pstack. Skills may *recommend* a merge or push; enforce the real limits with branch protection and scoped tokens, not with instructions in a SKILL.md.

## Verification summary

- **Static checks:** `tests/validate_skills.py` parses real YAML and rejects unknown frontmatter keys, non-third-person descriptions, missing trigger clauses, over-long descriptions, reserved names and unsafe commands. It caught three invalid-YAML regressions during development.
- **Routing (blind, descriptions only):** 40/40 on a fresh held-out set, 48/48 on the original set.
- **Live activation (real headless sessions):** 67/80 on fresh prompts, with no false loads on any of the 20 should-not-fire prompts. `blast-radius` and `tdd` loaded every time. `diagnose` has the main gap: it is under-triggered on question-phrased bug reports, so invoke `/diagnose` when it matters.
- **Behaviour (blind three-arm test: none / placebo / real):** no measurable outcome gain on a strong model. All 18 runs succeeded in every arm. The value of these skills is consistency, safety rails, and a fixed report shape, not extra intelligence. See [round1-behaviour](docs/verification/round1-behaviour/RESULTS.md).
- **Safety fixes found by red-teaming:**
  - `handoff` used to commit and push all work without asking.
  - `handoff` could leak already-staged files into its commit.
  - `interrogate` silently dropped committed work when no merge base existed.
  - `diagnose`'s debug-log check matched its own text.

  All fixed and re-verified.

## Tests

```bash
python3 tests/validate_skills.py                                   # static frontmatter + safety checks
python3 tests/live/activation.py cases.json --runs 2 --jobs 10     # live: does Claude Code actually load the skill?
```

`tests/fixtures/` holds the v0 behavioural fixtures:
- `cart-bug`: a hidden mutable-default bug
- `rename-field`: a JSON key rename with a grep-invisible consumer and stale persisted data

v0 results are summarised in the verification plan. In short: the skills improved process and evidence reporting, but these fixtures are too easy to separate outcomes from a baseline run. Harder, independently written fixtures come next.

## Research

- [docs/research-findings.md](docs/research-findings.md): what the two packs contain and how people received them
- [docs/perplexity-prompts.md](docs/perplexity-prompts.md): follow-up prompts for Reddit, X and YouTube comments, which Claude could not reach
