# Grid search: planning / interview / spec skills (2026-10-10)

Our skills under test: `.claude/skills/grill/SKILL.md`, `.claude/skills/spec/SKILL.md`.

Method notes:
- Star counts come from the GitHub repo pages via WebFetch. GitHub rounds them, and `gh api` and curl to api.github.com were blocked in this session.
- "Last activity" is the HEAD commit date of a `--depth 1` clone made today, in `scratchpad/grid/clones/`.
- Trending comes from github.com/trending (weekly and monthly).
- Reddit could not be fetched ("unable to fetch from www.reddit.com"). Reddit sentiment below is second-hand, quoted from blogs that cite threads.
- All cloned content was read as data only. Nothing from it was executed.

---

## 1. Repos

| Repo | Stars | Last commit | Trending? | Planning skills |
|---|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | ~297k | 2026-10-09 | no | `brainstorming` (+ `builder-check-prompt.md`, visual companion), `writing-plans`, `executing-plans`, `subagent-driven-development` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | ~284k | 2026-10-09 | **#2 weekly (+8,156 this week)** | `grilling` (+ `grill-me` alias), `grill-with-docs` (= grilling + `domain-modeling`), `to-spec`, `to-tickets`, `wayfinder`, `implement-spec`, `prototype`, `to-questionnaire` |
| [anthropics/skills](https://github.com/anthropics/skills) | ~180k | 2026-10-09 | no | none for planning (closest is `frontend-design`, which sets a visual direction before code) |
| [github/spec-kit](https://github.com/github/spec-kit) | ~141k | 2026-10-09 | no | `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/converge`, `/taskstoissues` |
| [garrytan/gstack](https://github.com/garrytan/gstack) | ~136k | 2026-10-10 | no | `office-hours`, `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `plan-devex-review`, `autoplan`, `spec` |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ~104.5k | 2026-10-10 | **monthly (+11,155)** | `interview-me`, `idea-refine`, `spec-driven-development`, `planning-and-task-breakdown` |
| [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | ~71.6k | 2026-10-06 | no | `openspec-explore`, `-propose`, `-new-change`, `-ff-change`, `-apply-change`, `-verify-change` |
| [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | ~64.3k | 2026-05-31 | **archived 2026-06-26**; moved to [open-gsd/gsd-core](https://github.com/open-gsd/gsd-core) (~10.4k) | `discuss-phase` (modes: default, batch, **assumptions**, power, auto), `spec-phase`, `plan-phase`, `ultraplan-phase` |
| [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | ~54.0k | 2026-10-06 | no | `bmad-brainstorming`, `bmad-prd`, `bmad-spec` (memlog-derived kernel), `bmad-build` (clarify-and-route) |
| [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | ~25.5k | 2026-10-10 | no | `ce-brainstorm`, `ce-plan`, `ce-ideate` (settled-decisions protocol) |
| [cursor/plugins](https://github.com/cursor/plugins) | n/a | — | weekly + monthly | `orchestrate` planner/subplanner, `poteto-mode` multi-phase-plan (not deep-read) |
| affaan-m/ECC | n/a | — | monthly (+22,710) | general Claude Code skill suite; planning content not verified |

### Install counts

Source: skills.sh scrape dated 2026-09-26, via [developertoolkit.ai](https://developertoolkit.ai/en/ecosystem/skills/top-practice-skills/).

| Skill | Installs | Rank |
|---|---|---|
| `grill-me` (+ `grilling` 776,905) | 1,225,243 | #2 of all practice skills |
| `grill-with-docs` | 1,046,834 | #3 |
| `prototype` (mattpocock) | 840,310 | #9 |
| `wayfinder` | 567,931 | |
| `to-spec` / `to-tickets` | 564,128 / 553,947 | |
| superpowers `brainstorming` | 376,352 | |
| superpowers `writing-plans` | 259,438 | |

On installs, Pocock's grill family is clearly the most-used planning skill. Ours is a derivative of `grilling`: it uses the same "frontier", recommendation and "yes accepts" wording.

---

## 2. Mechanisms extracted (top 8)

### mattpocock `grilling` (current canonical text)
- **Design tree and frontier:** ask the whole frontier per round, numbered, each question with a recommended answer. "A question whose answer depends on another question still open in this round belongs to a later round." The text moved from one-question-at-a-time to rounds. Mirrors on skills.sh still carry the older one-at-a-time text.
- **Facts are the agent's job:** dispatch a sub-agent for facts. "A running exploration is an unsettled prerequisite," so only downstream questions wait for it.
- **Stop rule:** the frontier is empty. "Do not act on it until the user confirms shared understanding."
- **Artifact:** none. `grill-with-docs` adds `domain-modeling`, which:
  - updates `GLOSSARY.md` inline;
  - challenges terms that conflict with the glossary;
  - cross-references the user's claims against the code ("Your code cancels entire Orders, but you just said partial cancellation is possible");
  - offers ADRs only when a decision is hard to reverse, surprising without context, and the result of a real trade-off.
- **Escape hatches (from AI Hero guidance):**
  - prototype "ungrillable" questions;
  - use `wayfinder` when the work is too big for one session;
  - split the work when a session hits ~200 questions.

### mattpocock `to-spec` / `to-tickets` / `wayfinder`
- **`to-spec`:**
  - "Do NOT interview the user." Pure synthesis.
  - Sketches test seams ("highest seam possible… the ideal number is one") and checks them with the user.
  - Template: Problem, Solution, a LONG user-story list, Implementation decisions, Testing decisions, Out of scope.
  - No file paths ("they go stale").
- **`to-tickets`:**
  - Vertical tracer bullets, each "sized to fit in a single fresh context window", with prefactoring first ("make the change easy, then make the easy change").
  - **Wide-refactor exception:** expand → batched migrate → contract, so each ticket can still land green.
  - Quizzes the user on granularity and blocking edges before publishing.
- **`wayfinder`:**
  - A map issue holding Destination, Decisions so far (an index), "Not yet specified" (fog) and Out of scope.
  - Decision tickets typed research (AFK), prototype, grilling or task.
  - "Never resolve more than one ticket per session."

### obra/superpowers `brainstorming` → `writing-plans` → `executing-plans`
- **Brainstorming**
  - First message offers to skip the questions, then asks one open, concrete question ("What's the moment you find yourself wishing this existed?").
  - Open questions come first; "Options steer". A short menu is offered only when the user is stuck. "A guess they can correct often beats a question."
  - **Play it back:** 200–300-word chunks, with guesses marked as guesses.
  - **Size the work:** quick task, small change in chat, or a design doc.
  - **Builder check:**
    - A fresh subagent reads the design doc as "a talented builder… you will not be able to talk to the person who wrote it".
    - It reports only questions "where you'd have to guess and a wrong guess would matter", ranked.
    - Questions are sorted into **answered already** (put in the doc), **minor** (settle it yourself and mark it as *your call*) and **theirs**, which go to the user in ONE message. "That's the only round of questions the check produces."
  - The "Red flags" table includes: "A default they never heard is one they couldn't reject", and "Approval covers what you showed them".
- **Writing-plans**
  - Header carries Global Constraints and a **Review Focus**: "the five input classes or failure modes the spec implies but no task's tests exercise". Each gets a test in its owning task.
  - Self-review:
    - spec coverage;
    - step scan (no "TBD / handle edge cases");
    - type consistency across tasks;
    - **proportion** ("A plan longer than the code it describes has written the code instead").
- **Executing-plans:** "Rulings, not stalls". Each deviation is ledgered as `Ruling: <what> — <why> — <cost if wrong>`, and the rulings are listed to the user at the end.

### addyosmani `interview-me`
- Opens with `HYPOTHESIS` and `CONFIDENCE: ~30%`, plus what is missing.
- Asks one question at a time, each with a `GUESS:` attached.
- Probes "want vs should want": "If you didn't have to justify this to anyone, what would you actually want?"
- Restate: Outcome / User / Why now / Success / Constraint / **Out of scope** ("non-negotiable").
- Stop test: "Can I predict the user's reaction to the next three questions?" Also a floor: after several rounds with no rising confidence, step back.
- "Sounds good" and "whatever you think" are not a yes.

### github/spec-kit `/clarify` and `/specify`
- Coverage scan over a fixed taxonomy, each category marked Clear / Partial / Missing. Categories include out-of-scope, edge cases, NFRs with numbers, terminology, and **ambiguous adjectives ("robust", "intuitive") lacking quantification**.
- **Max 5 questions per session.** Priority is Impact × Uncertainty, asked one at a time.
- Each question has a `**Recommended:**` option and a **"Why it matters"** sentence. "yes" accepts.
- Integrates each answer into the spec **and saves after every answer** ("to minimize risk of context loss"). A `## Clarifications / ### Session YYYY-MM-DD` log keeps `Q → A` lines, and contradicted text is replaced, not duplicated.
- `/specify`: "make informed guesses… document assumptions", with at most 3 `[NEEDS CLARIFICATION]` markers.

### GSD `discuss-phase` (assumptions mode)
- "Read the codebase FIRST, form opinions SECOND, ask ONLY about what's genuinely unclear."
- Each assumption carries:
  - a confidence badge (Confident / Likely / Unclear);
  - `↳ Evidence: <file paths>`;
  - `↳ If wrong: <consequence>`.
- Then one prompt: "These all look right? Yes / Let me correct some." Their stated yield: "~2-4 corrections vs ~15-20 questions".
- Scope guardrail: new capabilities go to "Deferred Ideas".
- The CONTEXT.md output has numbered decisions `D-01…` and a **"Claude's Discretion"** section for items the user delegated.

### gstack `office-hours` / `plan-eng-review`
- **Premise challenge:**
  - "Is this the right problem? What happens if we do nothing? What existing code already partially solves this?"
  - The user must agree or disagree with numbered PREMISES.
- **Forced alternatives:** 2–3 approaches. One must be "minimal viable" (smallest diff) and one "ideal architecture". Each carries effort, risk and reuses. Then a hard STOP for the user's choice.
- **Anti-sycophancy:** "Never say 'That could work'… take a position and state what evidence would change it."
- **Weight:** office-hours is 1,359 lines compiled. It includes telemetry, a builder profile and founder-signal scoring. `plan-eng-review` is a 705-line review gate.

### EveryInc `ce-brainstorm` / `ce-plan`
- **Settlement test:**
  - **Settled** means "a tradeoff, alternative, or risk was raised and the user chose with it in view".
  - A **directive** is an unexamined assertion. It gets exactly one challenge.
  - Labels: `user-directed` vs `user-approved`. "No self-settling: an agent never… upgrades bare assent to user-directed."
- **Rule 9:** "Recommend what the user's goal needs, and nothing it does not." Expensive-to-add-later items (stored data, shared interfaces, money, security) are put to the user as explicit choices *without* a recommendation.
- **Tiered output:** Direct / Chat brief / Durable. "When the tier is still uncertain, take the heavier one". A risk surface (auth, payments, migrations, external contracts) is always Durable.
- **Prototype routing test:** offer a prototype once, only when a decision is "expensive to unravel AND neither talk nor a cheap sketch can settle it".

### Also seen
- **BMAD `bmad-spec`:** a domain-implication gap is an open question to flag, "never invent the answer". Examples: healthcare input silent on PHI, payments silent on PCI, control systems silent on fail-safe.
- **OpenSpec explore:** "explain why it matters and which decision it unlocks"; "Silence is not acceptance"; "Accepting… recommendations is not permission to write".

---

## 3. Reception

**Grill-me / grilling**
- Praise:
  - Most-installed planning skill (1.2M; 13M+ downloads across the repo per [YouTube](https://www.youtube.com/watch?v=8D8ewFBJfFM)).
  - Pocock: recommended answers "speed up the conversation significantly" because you can reply "yes" ([aihero](https://www.aihero.dev/my-grill-me-skill-has-gone-viral)).
  - Video titles: "/grill-me Skill: 10x Your Code with AI", "I Tried 'grill-me' Skill for Plan Mode. Wow.", "Matt Pocock's Claude Code Skills Beat Superpowers Now".
- Complaints and anti-patterns:
  - **Length.** One video is titled "Claude Code will grill you with 40+ questions before writing a single line of code" ([YouTube](https://www.youtube.com/watch?v=DygrTaHG4ak)). Sessions run "~45 minutes" ([aihero](https://www.aihero.dev/my-grill-me-skill-has-gone-viral)).
  - **One-at-a-time was irritating.** One user changed it to 1–3 questions per round using the native question UI, which "completely resolved the looping problem" ([tabnews](https://www.tabnews.com.br/marlonPassos/eu-melhorei-a-habilidade-grill-me-do-matt-pocock-em-3-vezes-e-ela-substituiu-meu-modo-de-planejamento)). This supports our existing rounds of ≤4 plus AskUserQuestion.
  - **Passive answering.** "Replying 'agreed, agreed, agreed'… you decided nothing, and the result looks more certain than it is" ([aihero anti-patterns](https://www.aihero.dev/skills-grill-me)). This points straight at our "Reply 'ok' to take all recommendations."
  - **Ungrillable questions.** Layout or feel questions can't be settled by talking: "the agent rephrases, you guess, and the scope grows". Prototype instead (same source).
  - **Oversized scope.** "two hundred questions usually means the work should be split first" (same source).
  - **No durable output.** Without a downstream artifact, "agent statelessness erases them" ([agentpatterns.ai](https://agentpatterns.ai/patterns/agent-design/grill-me-technique/)). Ours already records to a file.
  - **Confirmation, not discovery.** On constrained problems (fixed API or regulation), grilling "produces confirmation rather than discovery" (same source).
- Competitor claims. [Clarify](https://github.com/a-laughlin/agentic-resources/tree/main/skills/clarify) (HN [49939665](https://news.ycombinator.com/item?id=49939665)) claims "2-4x faster than grill-me" through:
  - an IBIS issue tree;
  - "answers differ in mechanism not degree";
  - a "do nothing" option on action questions;
  - automatic conflict detection;
  - pause and resume.

  The claim is unvalidated: the author admits there are no evals.

**Superpowers brainstorming / writing-plans**
- Praise: "Hard to believe a two-paragraph promptlet can improve Claude Code this much" (Eric Florenzano, via [billmill](https://notes.billmill.org/AI/claude/skills/brainstorm_skill.html)). Forcing a plan means "less time reviewing code" (r/ClaudeCode, via [mcp.directory](https://mcp.directory/blog/superpowers-skill-worth-it-2026)).
- Complaints:
  - **Token cost and bloat.** Top-voted Reddit criticism is "a bit bloated"; "a good way to waste a day of tokens" (same source). "Token consumption is heavy" ([zerofuturetech](https://zerofuturetech.substack.com/p/i-deep-tested-three-claude-code-harness)).
  - **Over-triggering.** It started brainstorming on a plain code-fix request ([classmethod](https://dev.classmethod.jp/en/articles/2026-03-17-superpowers-brainstorming/), [toppa](https://toppa.com/2026/pairing-with-ai-1-brainstorming/)).

**Spec-driven development (spec-kit, OpenSpec, BMAD)**
- HN "SDD: The Waterfall Strikes Back" (225 pts, 191 comments, [45935763](https://news.ycombinator.com/item?id=45935763)):
  - Specs are "mostly boilerplate, and a pain to maintain, and often not really read"; "done for legal reasons rather than engineering".
  - "SDD doesn't bring any value as I'm already using Plan mode".
  - The positive side: "small, individual, highly constrained specs"; "this sweet spot is TINY"; "20–30 minutes writing a good spec results in code ~90% close".
- HN "Does SDD still pay off with frontier models?" ([49834564](https://news.ycombinator.com/item?id=49834564), 2026-09):
  - "The big up-front PRD stopped paying off."
  - "Saying why than what."
  - "I'd sacrifice the writing step without sacrificing the reading & validating step."
- Spec-kit specifically: "branch-per-spec workflow that causes review overload"; artifact sprawl where you must work out "which file says what actually happened" ([particula](https://particula.tech/blog/spec-driven-development-tools-spec-kit-vs-kiro-vs-tessl), [dev.to](https://dev.to/alfredoperez/give-spec-kit-superpowers-1pp9)).
- These lean toward our spec as-is: one page, decisions linked, 2–6 slices.

**gstack office-hours**
- Praised as a "tough advisor" that asks whether to build at all ([zerofuturetech](https://zerofuturetech.substack.com/p/i-deep-tested-three-claude-code-harness)).
- Complaints:
  - "too many roles and commands for regular use";
  - an HN joke post, "Gstack to Be Renamed as Gslop" ([47599848](https://news.ycombinator.com/item?id=47599848));
  - telemetry concerns on HN [47355173](https://news.ycombinator.com/item?id=47355173).

---

## 4. Proposed edits (exact text, in priority order)

### GRILL

**G1. Guard against passive "ok"** (the largest evidence-backed gap)
- Sources: AI Hero anti-pattern "agreed, agreed, agreed"; ce settlement test ("no self-settling… never upgrades bare assent"); interview-me Step 5; superpowers "A default they never heard is one they couldn't reject".
- Replace: `Word each question so "yes" accepts the recommendation, and end the round with: "Reply 'ok' to take all recommendations, or answer by number."`
- With:
  > Word each question so "yes" accepts the recommendation. Mark with ⚠ any question that is expensive to reverse (stored data, public interfaces, money, security, irreversible ops); a blanket "ok" does not cover ⚠ questions — they need an explicit answer. End the round with: "Reply 'ok' to take all unmarked recommendations, or answer by number."
- Evidence it helps: it keeps the speed win Pocock credits to recommendations, while forcing a real decision exactly where AI Hero says passive agreement makes the plan "look more certain than it is".

**G2. Record provenance (chosen vs defaulted)**
- Sources: ce `user-directed`/`user-approved`; GSD "Claude's Discretion"; superpowers "Any choice you make goes in the design as your call, never as something they agreed to"; executing-plans `cost if wrong`.
- In **Record**, replace `one line each: decision, choice, reason.` with:
  > one line each: decision, choice, reason, and who settled it — `chosen` (the user picked or answered with the trade-off in view) or `default` (accepted recommendation, "ok", or "you decide"). Defaults are what later work may revisit first.
- Evidence it helps: downstream `/spec` and future sessions can tell firm decisions from soft ones. This is ce's stated reason for the protocol, which keeps settled decisions from being re-asked and lets unexamined ones be challenged once.

**G3. Assumptions from the code before questions**
- Sources: GSD assumptions mode ("~2-4 corrections vs ~15-20 questions"); interview-me HYPOTHESIS; brainstorming "A guess they can correct often beats a question".
- In **Facts are mine, decisions are theirs**, append:
  > When reading the code settles a likely answer, don't ask it — list it under "Assuming (from code):" at the top of the round, one line each with the file it rests on and what breaks if it's wrong. The user corrects only what's wrong.
- Evidence it helps: GSD's stated yield; it also directly answers the "40+ questions" and "~45 minutes" length complaints.

**G4. Ungrillable questions and scope too big: route out instead of grinding**
- Sources: AI Hero ("ungrillable → prototype", "two hundred questions → split", "too big for one session → wayfinder"); ce Rule 7 prototype test; superpowers "Spike to feel things out" and "several independent projects… one at a time".
- Add to **Size it first**:
  > - **Too big:** if it's more than ~15 real decisions or several independently shippable pieces, say so, propose a split, and grill one piece.
  > - **Can't be settled by talking** (look and feel, "will this API actually do X", performance): don't grind on it. Offer a throwaway spike that answers just that question, and park the dependent questions until it's back.
- Evidence it helps: these are the two failure modes AI Hero documents. Both currently produce long, low-yield sessions.

**G5. State what each answer changes**
- Sources: spec-kit "Why it matters" sentence; OpenSpec "which decision it unlocks"; GSD "If wrong: consequence".
- Change the fallback format line `→ Recommended: <answer> — <one-line why>` to:
  > `→ Recommended: <answer> — <one-line why>. Changes: <what this answer decides downstream>`
- Evidence it helps: it applies our own "drop questions where every option leads to the same outcome" rule visibly. A question whose Changes line can't be filled gets dropped. Cost: one line per question.

**G6. Flag contradictions immediately**
- Sources: domain-modeling "Cross-reference with code"; Clarify conflict detection; ce "research may contradict settled decisions only on evidence".
- Add to **Only ask the frontier**:
  > If an answer contradicts an earlier decision, the code, or a term as the code uses it, say so at once and ask which wins, before continuing.
- Evidence it helps: Clarify's core claim, and the glossary-challenge behaviour in grill-with-docs (1.05M installs).

**G7. Don't recommend more than the goal needs** (low cost)
- Source: ce Rule 9.
- Add after the AskUserQuestion paragraph:
  > Recommendations never add scope the user's goal doesn't need. Put costly-to-add-later options (stored data, shared interfaces, security) to the user as a plain choice without a recommendation.
- Evidence it helps: addresses the scope growth AI Hero describes, and our own "value is in the few decisions" thesis.

**G8. Premise check inside Holes first** (cheap)
- Source: gstack office-hours Phase 3.
- In **Holes first**, after "list the top 3–5 risks or unstated assumptions in the plan", insert:
  > — include whether doing nothing, or reusing code that already partly does this, would be enough —
- Evidence it helps: office-hours' most-praised behaviour is "asks whether you need to build it" ([zerofuturetech](https://zerofuturetech.substack.com/p/i-deep-tested-three-claude-code-harness)).

### SPEC

**S1. Builder check before handing over** (the strongest mechanism found)
- Source: superpowers `brainstorming/builder-check-prompt.md`.
- Add a new step 1 under **After writing**:
  > 1. If a subagent tool is available, have a fresh subagent read the spec as a builder who cannot ask the user anything, and list only the places where it would have to guess and a wrong guess would change what gets built, ranked. Fold answers already in the conversation or code into the spec; settle minor ones yourself and mark them "(my call)"; bring the rest to the user in one message. This is the only question round the check produces. Without a subagent, do this read yourself.
- Evidence it helps: it is the core quality gate of the most-starred skill repo (~297k). It is bounded to one round, which answers the "interrogation" complaint. Cost: one subagent read of a one-page file.

**S2. Wide refactors are not vertical slices**
- Source: mattpocock `to-tickets`.
- Under **Slices**, after the tracer-bullet sentence, add:
  > Exception: a wide mechanical change (rename or retype used across the codebase) can't land as a vertical slice. Sequence it expand → migrate in batches → contract, each batch green on its own. Put any prefactoring that makes the feature easy first.
- Evidence it helps: our current text ("never 'all the schema'…") would force an impossible slicing on refactors. to-tickets has 554k installs.

**S3. Slice size bound**
- Source: `to-tickets` ("sized to fit in a single fresh context window"); writing-plans task right-sizing.
- Append to the slice definition:
  > Each slice should fit one fresh session; if it wouldn't, split it.
- Evidence it helps: it links slices to `/handoff` and fresh-session work, and matches the HN preference for "TINY" specs.

**S4. Assumptions/defaults visible, and the gaps that matter flagged**
- Sources: spec-kit Assumptions section and "ambiguous adjectives"; BMAD domain-implication gaps; GSD Claude's Discretion.
- Change item 3 to:
  > 3. **Decisions** — link the decisions file if a grill produced one; otherwise one line each with the reason. Mark choices you made, not the user, as "(my call)".
- Add to item 6:
  > 6. **Open questions** — include any vague target ("fast", "robust") that a Done-when can't test, and any domain obligation the input is silent on (e.g. PII, payments, auth, migrations).
- Evidence it helps: it keeps the spec short (no new section) while preventing silent defaults, the most common SDD failure per the spec-kit taxonomy.

**S5. Uncovered failure modes**
- Source: writing-plans "Review Focus".
- Append to **Order so S1…**:
  > Then list up to 3 inputs or failure cases the outcome implies but no Done-when exercises; add each to the slice that owns it.
- Evidence it helps: writing-plans says the spec's "silence on an input is not permission for that input to break the program". Cost: three lines.

---

## 5. Considered and rejected

| Idea | Source | Why rejected |
|---|---|---|
| Strict one question per turn | interview-me, office-hours, ce, spec-kit, old grill-me | Users found it irritating and loop-prone ([tabnews](https://www.tabnews.com.br/marlonPassos/eu-melhorei-a-habilidade-grill-me-do-matt-pocock-em-3-vezes-e-ela-substituiu-meu-modo-de-planejamento)). Pocock himself moved `grilling` to frontier rounds. Ours already offers a "one at a time" switch. |
| Confidence % and "95% / predict next 3 answers" stop | interview-me | False precision and ceremony. Our stop ("no remaining question would change the outcome") is equivalent and cheaper. |
| Hard cap of 5 questions per session | spec-kit `/clarify` | Fits a clarify pass on an existing spec, but grill's purpose is to exhaust the decisions. G4's split rule handles runaway sessions instead. Spec already caps at one blocking question. |
| Re-asking on "whatever you think" | interview-me | Contradicts our "you decide" stop and adds friction. G2 records it as `default` instead, which keeps the information without the extra turn. |
| Inline GLOSSARY.md and ADR files | grill-with-docs / domain-modeling | Popular (1.05M installs), but it creates extra files on every run. G6 takes the high-value part (term and code contradiction). A repo-specific glossary could be honoured if one exists; not worth mandating. |
| Long user-story list; Commands / Code style / Boundaries sections | to-spec, addy spec-driven-development | Conflicts with the one-and-a-half-page limit and with HN's "TINY" sweet spot and "boilerplate nobody reads". Commands and style belong in CLAUDE.md. |
| No file paths in spec | to-spec | Our "Touches: best guess" is useful to a builder and already labelled as a guess. Paths going stale matters less for a short-lived spec. |
| Six YC forcing questions, founder signals, builder profile, telemetry | gstack office-hours | Product and startup specific. 1,359 lines. Bloat and telemetry complaints ("Gslop", "too many roles"). |
| Visual companion browser server | superpowers | Its author calls it "token-intensive"; heavy infrastructure. A spike (G4) covers "needs something to react to". |
| Append-only memlog with the spec derived from it | BMAD | Heavy machinery (scripts, uv). Our "append a dated section, never overwrite" gives the history cheaply. |
| Save to file after every answer | spec-kit `/clarify` | Real benefit (context loss), but grill deliberately records only after confirmation. Partial alternative: the existing "suggest a fresh session from the file" line. Revisit only if compaction-loss complaints appear. |
| Forced 2–3 approaches (minimal vs ideal) on every run | office-hours Phase 4 | Good when the approach itself is open, but ceremony otherwise. It's naturally one frontier question with options; not worth mandating. |
| Auto-trigger before any creative work ("MUST use") | superpowers brainstorming | The top complaint is over-triggering on plain fixes. Our ≤2-decision auto-trigger short-circuit is the right call. |
| Execution-method menu (subagent vs inline) after the plan | writing-plans | Out of scope for spec. We stop at "user picks a slice". |
| Issue-tracker map of decision tickets | wayfinder | Valuable for multi-week efforts (568k installs) but tracker-dependent and heavyweight. See section 6. |

---

## 6. Planning-type skills we lack

1. **`prototype` / spike (strongest evidence).**
   - Evidence:
     - mattpocock `prototype` has 840k installs (#9 of all practice skills);
     - AI Hero names "ungrillable questions" as a top grill-me failure;
     - superpowers has "Spike to feel things out";
     - ce routes to `ce-prototype`;
     - wayfinder has a `prototype` ticket type.
   - Minimal shape: answer ONE named design question with throwaway code on a scratch branch or dir, report what it showed, and never merge it ("keeping it is a new request").
   - G4 depends on it. Without the skill, G4's spike offer is still workable inline.
2. **Multi-session decision map (wayfinder-like). Medium evidence.**
   - Fills the gap where `/spec` stops (">6 slices: propose a split and stop") and `/handoff` covers only one session.
   - Wayfinder has 568k installs, and Pocock calls it "a more organized and foolproof grill-me".
   - Cost: tracker coupling and process weight. A cheap version would be a `docs/decisions/<topic>-map.md` holding Destination, Decided, Not yet specified and Out of scope, resolved one question per session.
   - Recommend only if users hit spec's split stop often.
3. **`to-questionnaire`. Weak evidence, niche.** It turns decisions only a third party can answer into an async questionnaire. Could be one line in grill ("if only someone else can answer, offer to write the questions for them").

Not missing:
- to-tickets: `/spec` already creates issues on request.
- implement-spec / executing-plans: covered by `tdd`, `prove-it` and `interrogate`. A ledger of `Ruling: … — cost if wrong` is worth considering for implementation skills, but is out of this cluster.
