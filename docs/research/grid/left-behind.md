# Left behind: skills from Pocock and pstack that C-Skills did not port

Date: 2026-10-10. Scope: every skill in `mattpocock/skills` (engineering, productivity, misc, in-progress) and `backnotprop/pstack` that has no counterpart in C-Skills v0.5.2 (grill, spec, diagnose, prove-it, blast-radius, tdd, interrogate, handoff, plain, unslop, reflect).

## Method and evidence base

- I read every candidate SKILL.md from the local clones as data and ran nothing from them.
- Prior reception came from `docs/research-findings.md` and `docs/research/perplexity-aihero.md`. The latter has retention rankings and counts of positive mentions. The pstack Perplexity report survives only as the summary in research-findings.
- Fresh reception for this pass (2026-10-10):
  - **HN Algolia comment search.** Queries: "wayfinder pocock", "improve-codebase-architecture", "mattpocock skills teach", "pstack poteto".
  - **GitHub issue search pages fetched over the web** (not the GitHub tools): mattpocock/skills issues filtered by wayfinder (145 hits), architecture/domain/glossary (225 hits), and to-tickets/implement-spec/triage/prototype/retro (652 hits, loose match). Also issues #1162, #1180 and #1071, and the backnotprop/pstack tracker, which holds only 2 issues, both about invocation names.
  - **Flavio Copes' "A deep dive into pstack"**, the only substantive third-party write-up of pstack's non-core skills.
  - **Web searches** on git-guardrails, writing-for-agents and create-verification-skill. These found only directory listings and no user reports.
- **Caveat.** For most unported skills there is little or no independent evidence. Under the conservative rule used in the Perplexity round, "no evidence of retention" is the default and is not by itself a negative. Where a verdict rests on merit rather than reception, I say so.

### Fresh evidence highlights

| Source | Finding |
|---|---|
| HN: wccrawford (2026-08-21) | Uses wayfinder and grilling, but "it still kept trying to scope creep the crap out of the project" (shopping-list app). |
| HN: james_ross (2026-07-13) | Wayfinder: "make sure the path through the fog is clear enough to proceed". Highly recommends it. |
| HN: tylerjharden (2026-09-22) | Wayfinder maps were "a Godsend". Credits the shared glossary and splitting along seams (domain-modeling). |
| HN: Bossie (2026-07-03) | Grilling plus wayfinding turns ideas into specs and Linear issues, then Sandcastle executes them. "Highly valuable in practice." |
| HN: newswasboring, sathish316, ElijahLynn (Aug 2026) | Pocock's `teach` used to learn Dutch (passed the reading test), for 20 Java-concurrency lessons, and to generate learning sites. It is the best-evidenced unported skill, but none of this use is engineering workflow. |
| HN: pramodbiligiri (2026-06-05) | Points at improve-codebase-architecture. The one HN mention, with no usage report. |
| HN: m3h (2026-08-21) | Only pstack mention on HN: `/unslop`, which we already ported. |
| GitHub #1180 (Wayfinder feedback, open) | Likes it for complex designs. Complaints: unreliable save and push, too many ticket and ADR ids, questions with no context, "endless" over-detailed tickets, "words no-one uses in real life". |
| GitHub #1162 (closed) | "grill-me is the only skill that changed how I use agents". The rest (specs, tickets, ADRs, domain modelling, architecture review, retros) is a methodology that "should probably become smaller as models get better". |
| GitHub #1071 (closed, not planned) | The vocabulary is so confusing the user needs `/wait-what` "on nearly every reply". Asks "why are there 3 grilling skills?". ask-matt routes inconsistently. |
| GitHub issue mix | Active defect traffic on wayfinder (#1170s–#1240s: re-floating settled decisions, duplicate tickets, missing argument docs), implement (#1215 and #1216: bare-name code-review call, committing onto merged branches), domain-modeling (#1235 conflates glossary and ADRs; #1153 rename with no migration path), to-tickets (#1204), wizard (#1220), retro (#1207). Issue volume shows use but also fragility. |
| Flavio Copes, pstack deep dive | Strongest praise is for `create-verification-skill`: "I like this part of pstack a lot because" verification becomes "a repository capability instead of a new conversation every time". `/how`: "For unfamiliar systems, I would start here". `/why`: slower but "keeps the explanation tied to evidence". `/architect`: starting from the caller is good. The others are described without evaluation. On the system overall: "sometimes more ceremony than a task needs", "the tokens add up fast". |
| Prior Perplexity round 2 | Of pstack's skills, only poteto-mode, unslop and the verification discipline have usage reports. why, arena, interrogate, reflect, correct and blast-radius have "almost no independent usage reports". |

### Claude Code built-ins that already cover ground

- `/code-review`, `/simplify` (cleanup of a diff), `/security-review` and `/init`.
- The Explore/general-purpose subagents and the Workflow tool for fan-out.
- `deep-research` and `skill-creator` (Anthropic skills).
- Permission `deny` rules and hooks in `settings.json`, via the `update-config` skill.
- Output styles and plan mode.
- A hidden built-in `prototype` (mattpocock/skills#1019). Our validator already reserves that name.

## Verdict table: Pocock

| Skill | What it does | Evidence of use and value | Cost and ceremony risk | Overlap | Verdict |
|---|---|---|---|---|---|
| **to-tickets** | Splits a plan into tracer-bullet tickets with blocking edges and publishes them to a tracker or local files. Wide refactors use expand–contract. | to-spec/to-tickets is the 3rd most retained layer (5 positive mentions). Issue #1204. | Tracker setup is needed (`/setup-matt-pocock-skills`), and it can inflate process (rockatanescu on X). | `spec` already does slices with "Blocked by", files instead of a tracker, and issues only on request. **Gap:** spec forces vertical slices even for wide mechanical refactors, which cannot land green as vertical slices. | **FOLD-INTO-spec.** Add the expand → migrate-in-batches → contract rule. |
| **implement** | About 100 words: implement a ticket, call tdd at seams, typecheck often, call code-review, commit. | 1 positive mention (140k LOC of Go/C#). Shipped unregistered once (#371). Bugs #1215 and #1216. #1124 asked it to choose a verification strategy before reaching for tdd. | Low cost, but it auto-commits and chains a reserved-name skill. | spec ("don't implement until the user picks a slice"), tdd, prove-it, and built-in /code-review. | **SKIP as a skill.** Optionally add one line to spec: "to build a slice: tdd if it fits, else build, then prove-it against Done-when". |
| **implement-spec** | Orchestrates parallel implementer subagents in worktrees, merger subagents and an integration branch, then code-review. | New in v1.3, no retention evidence. The Gray Cat comparison: Pocock route 148 min / ~$92 vs Superpowers 78 min / ~$34, with an invocation defect. #1244 asks for context compression. | High: tokens, worktree churn, autonomous merges. | Workflow tool and Agent fan-out. | **SKIP.** Cost, plus merge authority that we deliberately keep out of skills. |
| **wayfinder** | Charts a multi-session effort as a "map" issue with decision tickets (research/prototype/grilling/task), a frontier, "fog of war", and out-of-scope. One ticket per session. | Positive and niche: 4 HN users ("Godsend", "highly recommend", "highly valuable"). Perplexity rank 6 ("kept for ambiguous, multi-stage projects"). Heavy defect traffic (~145 issue hits) and #1180 complaints: ids, over-detail, jargon, unreliable push. Scope creep reported on HN. | High: 2,075 words, depends on a tracker, labels, claim-by-assignment, research branches that are never merged. | grill (decisions file) and spec. The gap is efforts too big for one grill: spec's >6-slice answer is "split and stop", with no shared map across sessions. | **FOLD-INTO-grill** as a file-based "map mode". Keep destination / decided / frontier / not-yet-specified / out-of-scope and one decision cluster per session. Drop the tracker, labels and ids. |
| **prototype** | Throwaway code to answer a design question: a single-HTML state-machine walkthrough or N switchable UI variants. | No post-first-week endorsement found. #1019 (built-in clash) and #1020 (throwaway branches accumulate). | Medium. Branch clutter. | Hidden CC built-in `prototype` and Artifacts. Name reserved in our validator. | **SKIP.** At most one line in grill: "if the open question is how it looks or feels, offer a throwaway prototype outside the repo". |
| **research** | Background agent researches primary sources and writes a cited Markdown note. | No specific reports. It is a sub-step of wayfinder. #1241 (git ownership for research agents). | Low. | Built-in `deep-research` skill and subagents. grill's "facts are mine". | **SKIP** (built-in covers it). |
| **domain-modeling / grill-with-docs** | During a grill: challenge terms against GLOSSARY.md, sharpen overloaded words, invent edge scenarios, check claims against code, update the glossary inline, and offer ADRs only when a decision is hard to reverse, surprising and a real trade-off. | **Strongest unported evidence:** grill-with-docs is the #2 retained skill (5 positive mentions). Pocock himself stopped using grill-me for code in favour of it. tylerjharden credits the glossary. Counter-evidence: "vocabulary theater" (HN "materialization cascade"), #1071 (confusing vocabulary), #1235 (glossary and ADR conflated), #1153 (rename with no migration). | Medium if it brings GLOSSARY-MAP / multi-context machinery. Low if it is reduced to a few rules. | grill already records decisions to an existing ADR location or `docs/decisions/`. The missing parts are terminology challenges and code cross-checks. | **FOLD-INTO-grill.** Add a "Terms and claims" section. Use a glossary only if the repo already has one or the user asks. Apply the three-part ADR filter. |
| **codebase-design** | A vocabulary skill for deep modules (module, interface, depth, seam, adapter, leverage, locality, deletion test, "one adapter = hypothetical seam"). | Praise explains the idea rather than measuring it. HN critics say generic concepts "need not be redefined in elaborate prompt prose". #1071 vocabulary complaint. | Low cost, but always-loaded vocabulary pressure. | tdd (seams), built-in /simplify. | **SKIP as a skill.** The deletion test and the two-adapters rule belong in the body of a future `deepen` skill (see runner-ups). |
| **improve-codebase-architecture** | Finds hot spots from git history, spots shallow modules (deletion test), writes a visual HTML report of candidates, then grills the one you pick. | Weak to moderate: one Medium post ("run it every few days"), one HN pointer, issues #1163 and #1165 show use. Not in any retention top-5. | Medium to high: a subagent walk plus a Tailwind/Mermaid HTML report via CDN. | /simplify works on a diff, not the whole codebase. interrogate's simplicity lens is diff-scoped. | **SKIP now. Runner-up** (a lean `deepen`: markdown list, git hot spots, deletion test, then `/grill`). |
| **triage** | Tracker state machine (needs-triage, needs-info, ready-for-agent and so on), verifies claims, writes agent briefs, `.out-of-scope/` knowledge base. | Maintainer-only use. Mostly Pocock's own repo (every triage comment is labelled AI-generated). | High: label setup, posts to a public tracker, reads untrusted issue text (prompt-injection surface). | diagnose (reproduce first), spec. | **SKIP.** |
| **wizard** | Generates an interactive bash script that walks a human through manual setup (dashboards, secrets, `.env`, `gh secret`). | Niche. #1220 shows real use. | Needs a shipped `template.sh` library. Writes secrets. | None in our pack. | **SKIP for now.** A good idea, but niche, and it adds a script asset and secret handling to audit. |
| **retro** | Session retrospective. Proposes environment changes: navigation pointers, automated checks (an unwired or missing guardrail is itself a finding), mechanical vs judgement rules, AGENTS.md bloat, tool economy, no-op instructions, information access. | #1207 (per-item owner and route). No independent reports. Overlaps reflect almost completely. | Low. | `reflect`. | **FOLD-INTO-reflect** (with pstack `correct`). Add "existing-but-unwired check", "no guardrail at all is a finding", and "delete no-op instructions". |
| **writing-for-agents** | A long reference for writing skills and CLAUDE.md: context pointers, information hierarchy, completion criteria, leading words, negation, no-op pruning. | No reception found anywhere. Its own vocabulary is the #1071 complaint. | 1,775 words, plus a mechanics file. | Anthropic `skill-creator`. Our validator plus verification plan. | **SKIP as a skill.** Two ideas (the no-op test; phrasing rules positively) are worth a contributor note and the reflect fold. |
| **teach** | Stateful multi-session tutor: MISSION.md, lessons as HTML, learning records, spaced retrieval. | Real use: 3 HN users (Dutch exam, Java concurrency, learning sites). | High (a stateful workspace), but it is opt-in. | None. Out of scope for an engineering-discipline pack. | **SKIP (out of scope).** Note it as the best-received unported skill if the pack ever widens beyond engineering. |
| **to-questionnaire** | Turns a decision the user can't answer alone into an async questionnaire for someone else. | None found. | Low. | grill (decisions with "facts are mine"). | **SKIP.** Optionally one grill line: "if a decision belongs to someone else, offer to write their questions into the decisions file as a hand-off". |
| **pr** | PR body template: smallest diagram/diff-sketch summary, before/after evidence, merge danger (one- or two-way door, blast radius). Credited to HumanLayer's show-me. | New in v1.3 (Oct 5). No reception yet. | Low. | prove-it (evidence), blast-radius (danger). Claude Code writes PR bodies ad hoc. | **SKIP for now. Runner-up** to fold into prove-it's report ("when the report becomes a PR body…"). |
| **git-guardrails-claude-code** | Installs a PreToolUse hook blocking `git push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .`. | Directory listings only. No user reports. | Low, but it edits settings and installs a script. | **Built-in:** `settings.json` permission `deny` rules and the `update-config` skill do this without a script. Our README already says enforcement belongs outside SKILL.md. | **SKIP.** Instead, add a recommended `permissions.deny` snippet to the README. |
| **setup-pre-commit** | Husky + lint-staged + Prettier + typecheck/test hooks. | Cited as evidence of TS/web bias. | Low, but JS-only and installs dependencies. | reflect (a hook as a guard). | **SKIP** (stack-specific). |
| Others not asked about (ask-matt, setup-matt-pocock-skills, migrate-to-shoehorn, scaffold-exercises, writing-*, chief-of-staff, loop-me, claude-handoff) | Routers, setup, TypeScript-specific or in-progress. | ask-matt has inconsistent routing (#1071). | — | — | **SKIP.** |

## Verdict table: pstack

| Skill | What it does | Evidence | Cost | Overlap | Verdict |
|---|---|---|---|---|---|
| **how** | Explains how a subsystem works through parallel explorers and an Opus explainer (Overview / Key concepts / How it works / Where things live / Gotchas). | Flavio: "For unfamiliar systems, I would start here." No independent usage reports. | Multi-model, and needs a pstack-models settings file. | The built-in Explore subagent and plain Claude do this well. `plain` handles readability. | **SKIP.** |
| **why** | Code archaeology: anchors on blame/log/PR bodies, then one investigator per evidence source (tracker, docs, chat, observability, errors, warehouse), and a synthesizer with strict confidence tiers. Can convert to Preserve/Change/Avoid/Risk constraints. | Flavio: "keeps the explanation tied to evidence", slower. Perplexity: almost no independent use. | High as written: 1,608 words plus ~8k words of references, 7 investigators. A lean git+gh version is cheap. | Nothing in the built-ins or our pack. blast-radius looks forward; why looks back. | **Runner-up PORT (lean).** See the end. |
| **recall** | Mines your chat transcripts plus the shared record to rebuild working context. | One mention (Flavio, descriptive). | High. Reads private transcripts, which we deliberately dropped from reflect. | handoff, plus Claude Code `--resume` and `/resume`. | **SKIP** (privacy and overlap). |
| **teach** (pstack) | Runs how + why, then a plain spoken explanation built up diagram by diagram. | Descriptive mention only. | Medium. | plain, the built-in Explore subagent. | **SKIP.** |
| **architect** | Grounds via how/why, sketches types and signatures with stub bodies via arena (multi-model, at least 2 distinct designs), then implements against the sketch and scraps on recurring friction. | Flavio likes starting from the caller. No usage reports. | High (arena underneath, multi-model). The default has no human checkpoint. | tdd Phase 1 (seams, stubs with the final signature), grill. | **SKIP.** The "scrap signals" list and "write the caller's usage first" could go into a future `deepen`. |
| **arena** | N parallel candidates, cross-judge, pick a base, graft the best parts from the others. | Descriptive only. | High: N full attempts plus a judge. | Workflow tool and Agent fan-out. | **SKIP.** |
| **swarm** | Fans out N Cursor cloud workers (slices or races) and aggregates PASS/ISSUES/BLOCKED. | None. | High. Cursor-cloud specific. | Workflow tool. | **SKIP.** |
| **correct** | Mines recent commits, reverts and review comments for mistake classes (counted at 2+ occurrences). Fixes each at the highest level (architecture > types > lint whose error names the fix > test > docs), proves each check fails on a real past mistake, and keeps a rule→enforcer table. | Perplexity: almost no independent usage. On merit it is the sharpest statement of "encode lessons in structure", and both packs converged on it (retro). | Low to medium: reads git history, one commit per class. | `reflect` covers session-scoped lessons, not repo-history ones. | **FOLD-INTO-reflect** (repo mode, enforcement ladder, rule table, "documented but unenforced = repeat → escalate"). |
| **show-me-your-work** | Append-only TSV decision log for long or unattended runs, audited against the transcript and reviewed by a second model. | Descriptive only. | Medium: the transcript audit, and cross-model review isn't available. | handoff (a snapshot, not a log). | **SKIP now.** Possible small handoff addition later ("for unattended runs keep `decisions.tsv`, one row per fork, evidence as a pointer"). |
| **benchmark-checklist** | Seven questions before reporting a performance number: why not double (limiter), tuned, broke limits, errored, reproduces (≥5 alternating runs, median and range), matters end to end, did the work happen. | No reception, but the content matches standard benchmarking practice. Our pack has nothing on performance claims beyond diagnose's "record a baseline". | Low if gated to "only when a number is claimed". | prove-it (evidence ladder), diagnose (perf baseline). | **FOLD-INTO-prove-it** (a "Measured numbers" section). |
| **create-verification-skill** | Generates a project-local `verify-<app>` skill (Launch, Doctor, Drive with real selectors, Evidence, Cleanup) plus a feature map, and proves it end to end once before handing over. | **Best-received pstack skill after unslop:** Flavio's strongest praise. Research-findings calls "verify becomes a repository capability" pstack's most transferable idea. | Medium: one session to generate, then cheap to reuse. Must be written to stay safe (kill only what it started, keep evidence after cleanup). | prove-it only *proposes* scripting after the same manual check twice. The built-in `run` skill launches apps but leaves no repo artifact. | **PORT** (with maintain-verification-skill folded in as a refresh mode). |
| **maintain-verification-skill** | Periodic audit of the verify skill: a source reader per feature, one live pass over every feature, at most one PR of proven corrections. | None. | Medium to high. | — | **FOLD into the ported verifier** as a short "refresh" section. |
| **technical-writing** | Diátaxis mode choice, Google developer style, STE, Global English. | Descriptive only. | 1,636 words. | unslop and plain, plus the base model's writing. | **SKIP.** |
| **no-comments** | Spawns the "Comment Sicko" reviewer to delete comments, then encodes constraint comments as types, tests or lints. | None. | High. Cursor subagent, a multi-stage acceptance protocol, may call /architect. | Built-in /simplify, interrogate's simplicity lens. | **SKIP.** |
| **typescript-best-practices** | A path-scoped TS rule table (discriminated unions, brands, no `as`, exhaustiveness, schemas). | None specific. | Low, but always on for .ts files. | Language-specific. Belongs in project rules or CLAUDE.md. | **SKIP** (the pack stays language-neutral). |
| **figure-it-out** | Meta-playbook for big unmatched tasks: frame a falsifiable predicate, design phases, hypothesis loop, decision log. Starts by reading poteto-mode's principles. | None. | High. Depends on poteto-mode, architect, arena and show-me-your-work. | spec (Outcome, slices), prove-it. | **SKIP.** |
| **automate-me** | Mines transcripts and interviews you to build a personal `<handle>-mode` skill. | None. | High. Reads private transcripts. | CLAUDE.md, memory, skill-creator. | **SKIP.** |

### The principle-* skills: which ideas are not yet in C-Skills

Already carried by our skills:
- prove-it-works → `prove-it`
- fix-root-causes → `diagnose` (step 6, "after restart" → stale state)
- encode-lessons-in-structure → `reflect`
- test-behavior-not-implementation → partly in `tdd` (expected values from an independent source, no `a+b` tautologies)
- sequence-verifiable-units → `spec` slices and the `tdd` loop
- guard-the-context-window → partly in `grill` (persist decisions, then start a fresh session)

Not embodied, and worth a line or two inside an existing skill (cheap, behaviour-changing):

| Principle | Missing idea | Home |
|---|---|---|
| attack-the-premise | After **two** fixes that share an assumption fail the same check, write the shared premise down and test it before attempting a third fix. | `diagnose` step 4 (it currently says "go back and shrink or widen", not "suspect the premise") |
| test-behavior-not-implementation | The concrete test: "would this test still pass if every imported function returned `undefined`?", and the five failing shapes (weak assertion, mock-only, self-referential, constant pin, fixture asserts fixture). | `tdd` "Tests worth keeping" |
| explain-the-number | A measured number needs a named limiter, a run count and a spread. Otherwise it is inconclusive. | `prove-it` (Top-6 #5) |
| build-the-lever | For more than a handful of repetitive edits, do the first unit by hand, write a codemod or script, and prove it by rerunning it on that unit and diffing. | `spec` (wide-refactor rule, Top-6 #6) |
| make-operations-idempotent | "What happens if this runs twice? If it crashed halfway?" | `blast-radius` (migrations, scripts, jobs, cron) |
| exhaust-the-design-space | For novel, hard-to-reverse designs, compare ≥2 structurally distinct options before committing. | `grill` (one line, applying only to a one-way door) |

Leave out as style opinions, which belong in a project's CLAUDE.md or a future `deepen` skill rather than a discipline pack:
- laziness-protocol, subtract-before-you-add, minimize-reader-load and redesign-from-first-principles. These partly overlap the built-in /simplify.
- boundary-discipline, type-system-discipline and model-the-domain.
- foundational-thinking, experience-first and outcome-oriented-execution.
- separate-before-serializing-shared-state, which matters only for multi-agent orchestration that we don't ship.
- migrate-callers-then-delete-legacy-apis. It contradicts expand–contract when external consumers exist, and blast-radius already reasons about consumers.

never-block-on-the-human is deliberately **not** adopted. It conflicts with grill's "do not implement until the user confirms" and with our ask-before-push rules.

## Top 6 to port or fold (ranked)

Ranking weights independent evidence of retention first, then the size of the gap in C-Skills, then cost (words added and ceremony). The four folds add roughly 60–150 words each. The one new skill is manual-only, so it costs no auto-routing budget.

### 1. FOLD-INTO-grill: terms and claims (from domain-modeling / grill-with-docs)

Evidence: #2 most retained Pocock skill (5 positive mentions). Pocock switched to it for coding. HN credits the glossary. Guard against the vocabulary complaints (#1071, "materialization cascade").

Add to `grill/SKILL.md`, after "Facts are mine, decisions are theirs" (about 120 words):

```markdown
## Terms and claims

- **Overloaded word → ask once.** When the user uses a term two ways, or a term that clashes with the code or an existing glossary ("account": Customer or User?), make it a question in the next round.
- **Check claims against code.** When the user states how something works, read the code. If it disagrees, say so with file:line ("checkout cancels whole Orders; you said partial cancellation exists - which is right?").
- **Edge scenarios.** For a domain rule, invent one concrete case at the boundary and ask what happens.
- **Glossary only if one exists** (GLOSSARY.md, CONTEXT.md, docs/glossary) or the user asks: add resolved terms there, one line each, plain words a developer would say out loud, no implementation detail. Never invent coined names.
- **ADR filter.** When recording, flag a decision for its own ADR only if it is hard to reverse, surprising without context, and a real trade-off; everything else stays a one-line entry in the decisions file.
```

Description change: none needed. "challenged" and "gaps" already route there. Validate against the blind routing set again, since grill is auto-invoked.

### 2. PORT a new skill: `verifier` (from create-verification-skill + maintain-verification-skill)

Evidence: Flavio Copes' strongest praise of pstack ("verification becomes a repository capability instead of a new conversation every time"). Our own research called it pstack's most transferable idea. Currently prove-it only *proposes* scripting.

```yaml
---
name: verifier
description: Generates a project-local verify-<app> skill that launches this repo's app, checks it is healthy, drives one feature the way a user does, captures evidence, and cleans up - then runs it once end to end to prove it works. Use when a repo has no scripted way to prove UI, CLI, or service behaviour, or to refresh an existing verify skill after the app changed.
argument-hint: "[app or surface to cover; 'refresh' to audit an existing verify skill]"
disable-model-invocation: true
---
```

Key rules (target ≤ 450 words):
- **Interview the repo, not the user.** Surface (web/CLI/API/desktop), the documented dev command, an existing harness (Playwright, expect, curl), the observable evidence, and whether two instances can run side by side. Ask only what can't be observed.
- **The generated `.claude/skills/verify-<app>/SKILL.md` has fixed sections:** Launch (command plus readiness signal), Doctor (one read-only health check), Drive (real selectors and commands from this repo, stable handles), Evidence (what to capture and where; real user path, side effects checked), Cleanup (kill only what it started, never by process name; evidence survives).
- **Feature map:** `features/README.md` plus the top 3–5 user-facing features, each with how to reach it, how to drive it, and the end state that proves it works.
- **Prove before handing over:** launch → doctor → drive ONE feature → evidence → cleanup, then confirm the evidence still exists. A generated skill that was never run is a draft.
- **Safety:** local or staging only, no production, no `sudo`, no installers that run curl-piped-to-shell, pinned dependencies. Generated helpers must be executable and documented. Writes only inside the new skill directory, plus scratch that it removes. Commits nothing unless asked.
- **Refresh mode** (`/verifier refresh`): reread the map, run doctor and drive every listed feature once, and classify each failure as doc drift (fix the skill), harness gap (fix the helper) or product bug (report it, don't paper over it). Result: clean / changed / blocked.
- **Wiring:** prove-it's "Use the repo's own checks first" should name `verify-*` skills explicitly.

### 3. FOLD-INTO-reflect: repo mode and the enforcement ladder (from pstack correct + Pocock retro)

Evidence: both packs independently converged on the idea (retro and correct). #1207 shows retro is in use. Independent usage is thin, so this is ranked on merit and low cost. It also answers the "skills should get smaller" critique (#1162) by deleting no-op instructions.

Additions to `reflect/SKILL.md` (about 150 words). Optionally widen the description to "…or recent repo history (reverts, review comments) when asked".
- **Repo mode** (`/reflect repo`): read the last ~50 commits, reverts and review comments. A mistake class counts only if it happened **twice**.
- **Enforcement ladder.** Replace step 2's list with an explicit order: make it impossible (one owner, one way, delete the old path) > type > lint or CI check *whose error names the fix* > behaviour test > CLAUDE.md line. Say why each higher level didn't work.
- **Check what already exists first.** An existing lint, typecheck or test command that isn't wired into a hook or CI is the finding, not a reinvention. A repo with no guardrail at all is itself a finding.
- **Prove each new check fails on a real past mistake** (the commit or snippet), not on a synthetic one. This tightens the existing step 3.4.
- **Rule table.** If CLAUDE.md lists rules, keep them paired with their enforcer. A rule that was written down and broken again with nothing enforcing it is a repeat, so escalate it one level.
- **Prune no-ops.** Propose deleting CLAUDE.md lines the model already follows by default, or that are now enforced by a check.

### 4. FOLD-INTO-grill: map mode for multi-session efforts (from wayfinder)

Evidence: 4 positive HN reports ("Godsend", "highly recommend", "highly valuable in practice"). Perplexity rank 6 ("kept for ambiguous multi-stage projects"). The failure modes are known: #1180 (ids, over-detail, jargon, unsaved state), HN scope creep, ~145 issue hits of defects.

Add to `grill/SKILL.md` "Size it first" (about 130 words):

```markdown
- **Too big for one session** (more than ~12 open decisions, or the user says it spans weeks): switch to a map. The decisions file gets five sections:
  **Destination** (1-2 lines: the spec, decision, or change this is heading to) ·
  **Decided** (one line each, newest last) ·
  **Frontier** (questions sharp enough to ask now, with what blocks each) ·
  **Not yet specified** (fog: in scope but not sharp enough to ask; graduate items as answers clear them) ·
  **Out of scope** (ruled out, with why).
  Resolve one frontier cluster per session, update the file, offer to commit it, and stop. Refer to items by name, not number. Plan, don't build: when nothing on the frontier changes the outcome, suggest `/spec <file>`.
```

Explicitly omit the issue tracker, labels, claim-by-assignment, research branches and per-ticket files. Each of these drove the defect traffic.

### 5. FOLD-INTO-prove-it: measured numbers (from benchmark-checklist + principle-explain-the-number)

Evidence: no reception (pstack's perf material is unreviewed), but it fills a real gap. Neither pack's ported skills vet a speedup or regression claim, and a plausible-looking wrong number is a classic "sounds right ≠ evidence" failure. Cost is near zero when no number is claimed.

Add to `prove-it/SKILL.md` (about 110 words):

```markdown
## Measured numbers (only when claiming a speedup, regression, or capacity)

- Run each side ≥5 times, alternating A/B; report median and range. A gap inside the run-to-run range is "no measurable difference".
- Name the limiter (CPU core, lock, disk, network, the load generator) from a profile or counters taken in a separate run - not from reading code.
- Count errors and check outputs are correct; confirm the work actually ran inside the timed region (awaited, iterated, written).
- Both sides tuned the same way (release build, same data, same flags, same cache warmth).
- Sanity-check against limits: removing a piece that takes 10% of the run can't make it more than ~11% faster.
- Otherwise the verdict is INCONCLUSIVE - say which check is missing.
```

### 6. FOLD-INTO-spec: wide refactors and levers (from to-tickets + principle-build-the-lever)

Evidence: to-spec/to-tickets is the #3 retained Pocock layer (5 positive mentions). The expand–contract rule is the one piece of to-tickets our `spec` lacks, and without it spec's "never horizontal" rule gives wrong advice for renames and retypes.

Add to `spec/SKILL.md` "Slices" (about 100 words):

```markdown
**Exception - wide mechanical changes** (rename a column, retype a shared symbol) can't be vertical: one edit breaks every caller. Slice them as expand → migrate → contract:
- S1 expand: add the new form beside the old; nothing breaks.
- S2..n migrate: move callers in batches sized by blast radius (per package/directory), each green on its own.
- Last: contract - delete the old form once `git grep` finds no caller. If external consumers or persisted data exist, run `/blast-radius` before the contract slice.
For more than a handful of identical edits, do the first by hand, then write a codemod/script, rerun it on that first unit and diff against the hand edit before applying it everywhere.
```

## Runner-ups (next tier, in order)

1. **`why` (lean PORT, manual).** Use git blame, log and `gh pr view` archaeology only, plus any MCPs that happen to be connected. Keep a three-tier confidence split (found / inferred / unknown), list sources consulted including empty ones, and end with Preserve / Change / Avoid / Risk when a change is planned. It complements blast-radius (backward vs forward). Evidence: Flavio values it; there is no built-in. Held back because there are no independent usage reports and the original costs 7 investigators.
2. **Small principle folds.** attack-the-premise → diagnose step 4 (after two failed fixes, write the shared premise and test it). The "returns undefined" test → tdd. "Runs twice / crashed halfway" → blast-radius. One line each. No reception data, all cheap.
3. **`deepen` (lean improve-codebase-architecture plus codebase-design and architect's scrap signals).** Git hot spots, deletion test, "one adapter = hypothetical seam", a markdown candidate list ranked Strong / Worth exploring / Speculative, then `/grill` on the one picked. Held back: weak evidence, and the vocabulary complaints apply.
4. **PR body format (from Pocock `pr`)** in prove-it's report: smallest diff-sketch, before/after evidence, one-way vs two-way door plus a blast-radius word. Too new to judge (released Oct 5).
5. **Decision log for unattended runs (from show-me-your-work)** in handoff.

## Notable SKIPs and why

- **implement-spec, arena, swarm, architect, figure-it-out.** Multi-agent orchestration with the worst measured cost: Pocock route $92 vs $34; one Ultra user burned 75% of a monthly allowance in a day. Some auto-merge. The built-in Workflow and Agent tools cover ad hoc fan-out.
- **wayfinder as written, triage, to-tickets publishing.** They need tracker setup and labels. Wayfinder and triage carry the most open defects (#1180, #1231, #1174, #1070…).
- **how, teach (pstack), research.** The built-in Explore subagent, `deep-research` and our `plain` cover them.
- **recall, automate-me, show-me-your-work's transcript audit.** They read private chat transcripts, which C-Skills already chose not to do.
- **git-guardrails-claude-code.** Use built-in `permissions.deny` in settings.json; add a README snippet instead of a skill.
- **writing-for-agents, technical-writing, no-comments, typescript-best-practices, setup-pre-commit.** Long, language-specific or stack-specific, with no reception evidence and heavy overlap with unslop, /simplify and skill-creator.
- **Pocock teach.** The best-received unported skill (3 HN users with real learning outcomes), but out of scope for an engineering-discipline pack.
- **prototype.** Name clash with the hidden built-in (#1019, already reserved) and branch clutter (#1020).

## Sources

- Local: `repo/skills/skills/**/SKILL.md`, `pstack/skills/**/SKILL.md`, `/home/user/C-Skills/docs/research-findings.md`, `/home/user/C-Skills/docs/research/perplexity-aihero.md`, `/home/user/C-Skills/tests/validate_skills.py` (name, description and reserved-name constraints the outlines respect).
- HN Algolia: https://hn.algolia.com/api/v1/search?query=wayfinder%20pocock&tags=comment · …query=improve-codebase-architecture · …query=mattpocock%20skills%20teach · …query=pstack%20poteto
- GitHub (web): https://github.com/mattpocock/skills/issues/1162 · /issues/1180 · /issues/1071 · issue searches for wayfinder, architecture/domain/glossary, to-tickets/implement-spec/triage/prototype/retro · https://github.com/backnotprop/pstack/issues
- https://flaviocopes.com/pstack
- Directory listings with no user reports: agentskillsfinder.com (git-guardrails), skills.sh and skills-hub.ai (create-verification-skill: unsigned, 0 reviews), claude.com/plugins/mattpocock-skills.
