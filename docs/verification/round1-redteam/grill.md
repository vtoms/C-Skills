# Red-team review: .claude/skills/grill/SKILL.md

## A. IDENTIFICATION (frontmatter, lines 1-5)

Current description (L3), about 370 chars: third person, front-loads "Interviews the user about a plan, feature, or design", says what and when, and has an exclusion clause. Its quoted triggers are "grill me", "stress-test this plan" and "poke holes in this". There is one broad clause: "wants to align before building something non-trivial".

### A1. Should trigger (none reuse the quoted phrases)

| # | Prompt | Correct decision under the current description? |
|---|---|---|
| 1 | "Before I start on the billing rewrite, interview me until we both agree on the design." | Yes. "Interviews the user ... design" matches. |
| 2 | "Play devil's advocate on my plan to split the monolith into three services." | Likely. "plan" plus a request for a challenge is close to stress-test. "devil's advocate" is not named, so it could go to plain chat instead. |
| 3 | "What am I missing in this caching design? Ask me whatever you need." | Likely. It matches "align before building" and "design". |
| 4 | "Challenge every assumption in PLAN.md before we write any code." | Likely. "plan" and "before building" both match. |
| 5 | "I want to add multi-tenancy. Don't build yet. Let's hash out the open questions first." | Yes. It matches "align before building something non-trivial". |
| 6 | "Quiz me on the requirements for the export feature until nothing is ambiguous." | Probably. "feature" and "until every open decision is settled" match, but "quiz" and "requirements" are not named. |
| 7 | "Help me make all the design decisions for the new auth flow, one question at a time." | Probably. The body's "one at a time" mode helps, but the body is not visible when the decision is made. Only "design" and "decisions" are lexical hits. |
| 8 | "Here's my RFC. Tear it apart before I send it to the team." | Uncertain. "Tear it apart" is close to "poke holes", but an RFC is a document, and the model may instead do a one-shot written critique. |
| 9 | "/grill rollout plan for the v2 API" | Yes, by explicit invocation. |
| 10 | "Ask me clarifying questions about this feature until you're confident, then write down what we agreed." | Yes. It closely matches "interviews ... records the decisions in a file". |

### A2. Near-misses (should NOT trigger)

| # | Prompt | Better served by | Would the current description decide correctly? |
|---|---|---|---|
| 1 | "Poke holes in this PR." | code-review | **At risk.** It reuses the quoted trigger "poke holes in this" word for word. The description scopes to "plan, feature, or design", but the exact phrase match pulls toward grill. |
| 2 | "Stress-test this function with edge-case inputs." | tdd or plain testing | **At risk.** "stress-test" is a quoted trigger. In code, it usually means load or fuzz testing. |
| 3 | "Is this migration safe to merge? What could it break?" | blast-radius | Mostly correct, because blast-radius names those phrases. |
| 4 | "The checkout test is flaky; figure out why." | diagnose | Correct. |
| 5 | "Write a spec for the notifications feature." | docs or spec writing | Uncertain. "feature" plus "non-trivial" may pull grill, and the user wanted a document, not an interview. |
| 6 | "Plan out the steps to implement OAuth and then do it." | planning or plan mode | **At risk.** "Align before building something non-trivial" matches nearly every sizable build request. The user wants action, and grill will interrogate them. |
| 7 | "Rename `fooBar` to `foo_bar` everywhere." | direct edit | Correct, through "Not for one-line fixes". |
| 8 | "Should I use Postgres or SQLite for a 10-user internal tool?" | a direct answer | Correct-ish, through "questions with an obvious answer". |
| 9 | "Review my architecture doc and leave comments." | docs or comment review | At risk. It is a "design" and could be read as an implicit poke-holes request. The user wants written comments, not rounds of questions. |
| 10 | "Grill these sausages: what temperature?" or "grill the junior candidate's take-home" | none, or code review | Mostly correct. The context differs, though the literal "grill" could misfire on the second. |

### A3. Summary of identification quality
- Recall: good for explicit interview or alignment wording. It is weaker for "devil's advocate", "challenge my assumptions", "what am I missing", "quiz me on requirements" and "tear apart my RFC".
- Precision: the two quoted phrases "poke holes in this" and "stress-test this plan" also match code-review and testing requests. The clause "wants to align before building something non-trivial" is broad enough to fire on ordinary feature requests (A2 #6). This is the main precision risk.

### A4. Invocation mode
Auto, which is the default, is right. Users ask for this behaviour in natural language, and its value is preventing premature implementation. Manual-only would lose that. To reduce over-firing, the "non-trivial" clause should require the user to signal that they want to discuss or decide first. A big task alone should not be enough.

### A5. Proposed frontmatter
```yaml
---
name: grill
description: Interviews the user about a plan, feature, or design in short rounds of high-impact questions (each with a recommended answer) until every open decision is settled, then records the decisions in a file. Use when the user says "grill me", asks to be challenged or quizzed on a plan, wants its gaps found, or wants to settle decisions before building. Not for reviewing code or PRs, debugging, testing, one-line fixes, or questions with an obvious answer.
argument-hint: "[plan, file, or topic to grill]"
---
```
(About 460 chars.) Justification: the new wording keeps the strongest literal trigger. It drops the code-ambiguous "stress-test" and "poke holes in this" in favour of plan-scoped wording. It narrows "align before building" to cases where the user wants to settle decisions. It adds exclusions for code review, debugging and testing, the neighbouring skills that collide. It also says how the skill works ("each with a recommended answer"), which helps the model choose it over a one-shot critique.

## B. FUNCTIONING (body)

1. **The sizing rule overrides an explicit user request (L13-15).** "≤2 decisions: don't grill." If the user typed "grill me" or /grill, refusing to grill goes against the explicit instruction. The rule should apply only to auto-triggering.
2. **"proceed" conflicts with the stop gate (L15 vs L43).** L15 says "State assumptions and proceed". L43 says "Do not implement until the user confirms the summary". On the ≤2 path, an agent reading literally will start implementing without confirmation. This also skips the persistence step at L47.
3. **Sizing happens before fact-finding (L13 vs L27).** "Before asking anything, estimate how many decisions". But L27 says to look facts up. The estimate made before reading the code is often wrong, because many apparent "decisions" are facts the existing code already settles. Order should be: read the plan and code briefly, then size.
4. **Everything is framed around code (L13, L23, L43).** "decisions actually change the code", "every option leads to the same code", "no question left would change the code". The description promises plans and designs, including non-code ones such as rollout plans, migrations, RFCs and process. For those, a literal reading counts 0 decisions, so the skill does not grill and proceeds (see C2).
5. **Description and body mismatch: "stress-test" and "poke holes".** The description advertises adversarial critique. The body only elicits decisions (open choices). It has no step for finding risks, failure modes, unstated assumptions or contradictions in the user's plan. A user who asked to have holes poked gets a preference survey.
6. **"Yes" acceptance conflicts with the question format (L31 vs L39).** AskUserQuestion presents labelled options, so there is no "yes". In the markdown format, a round has up to 4 questions. If the user replies "yes", it is unclear whether that accepts one recommendation or all of them. The skill needs an explicit batch-accept convention ("reply 'ok' to accept all recommendations").
7. **Stop conditions are missing for the user side.** Nothing covers the user saying "you decide", "enough", "just build it", or not knowing the answer. There is also no round cap. L43 stops only when questions run out.
8. **Persistence order is ambiguous (L43 vs L47).** It is unclear whether the file is written before or after the user confirms the summary. "Persist, then reset" comes after "Stop", but nothing says "after confirmation". The agent may write unconfirmed decisions.
9. **Unsafe or presumptuous file write (L47).** `docs/decisions/<topic>.md` is created in the user's repo by default, with no check for an existing convention (docs/adr/, ADR numbering, an existing PLAN.md). There is no rule against overwriting an existing file with the same topic, and `<topic>` slugging is undefined. Checking for an existing convention is the kind of fact L27 says to look up, but L47 does not say to.
10. **Undefined reference (L47).** "(or via `handoff`)": no such skill or tool is defined, and the agent may try to invoke something that does not exist.
11. **Subagent concurrency (L27).** "send a subagent while asking the rest of the frontier". This is doable only if the subagent runs in the background before the blocking AskUserQuestion call, and the skill does not say so. Results that come back mid-round may invalidate questions already asked. There is no instruction to retract or adjust those questions.
12. **AskUserQuestion availability (L31).** Correctly hedged with "when available". The tool also caps options at 2-4 per question and adds an "Other" option automatically, and the skill does not mention either. The fallback works.
13. **The frontier rule is over-strict (L21).** "If any plausible answer to Q1 would change or remove Q2, Q2 waits". Read literally, almost every pair of design questions is weakly dependent. This degrades to one question per round, which conflicts with "rounds of at most 4". The rule should say "materially change".
14. **No input-resolution step.** argument-hint takes a plan or topic. The body never says to read a referenced plan file, to use $ARGUMENTS, or to ask for the plan when none is given. When invoked bare (/grill) with nothing in context, the behaviour is undefined.
15. **Voice inconsistency.** "Facts are mine", "I can look up" and "the defaults I'm taking" use first person from the agent's view. This is readable, but it mixes with the second-person imperatives used elsewhere. Minor.
16. **Ceremony.** The one-line size estimate shown to the user (L13) is fine and cheap. Bold "Q1 —" headers are fine. No major waste.

## C. Simulations

### C1. Where it should shine: "grill me on adding per-tenant rate limiting to our Express API"
- Size: "~5 real decisions; 2 rounds." OK. It reads the middleware dir in parallel, which is good per L27.
- Round 1 through AskUserQuestion: storage (Redis, Recommended / in-memory), key (tenant id, Recommended / API key), and over-limit behaviour (429 + Retry-After, Recommended / queue). Algorithm (token bucket vs sliding window) waits under L21 because the storage answer affects it. Good.
- Round 2: limits config source. Low-stakes items go in "Unless you object...". Good.
- Breaks:
  - (a) If the user types "yes" in the markdown fallback, it is ambiguous (B6).
  - (b) After the summary, it is unclear whether to write docs/decisions/rate-limiting.md now or after confirmation (B8).
  - (c) The repo already has docs/adr/0007-*.md, so the skill creates a parallel, inconsistent location (B9).
  - (d) It may mention a `handoff` that does not exist (B10).
- Otherwise the skill performs well here.

### C2. Edge case: "Poke holes in my plan to upgrade prod Postgres 12 to 16 this Saturday with pg_upgrade --link"
- Size: the decisions that "change the code" number 0, so L15 says "don't grill. State assumptions and proceed". A literal agent states assumptions and proceeds, which could mean starting to help run the upgrade. That is unsafe.
- Even if it grills, the body generates *decisions* ("Which maintenance window?") rather than *holes*: --link makes rollback impossible once the new cluster starts, extension versions such as PostGIS must be compatible, replicas need rebuilding, and planner stats need ANALYZE afterwards. Those are what the user asked for. B4 and B5 explain why.
- Stop at L43, "no question would change the code", is meaningless here, so the stop is undefined.
- It writes docs/decisions/postgres-upgrade.md into an app repo where it may not belong.
- Verdict for C2: the skill fails on its own advertised trigger.

Also, for a small topic: "grill me on whether to name this flag --dry-run or --check" has ≤2 decisions, so the skill refuses to grill the user who explicitly asked for it (B1).

## D. Verdict: PASS-WITH-FIXES

The core loop is strong: frontier ordering, recommendations, looking facts up instead of asking, and confirming before implementing. But the ≤2-decision branch and the code-only framing produce wrong or unsafe behaviour, and "stress-test" and "poke holes" promise a critique the body never performs.

### Top 3 fixes (ranked)

1. **L15, fix the shortcut path.** Replace:
   `- **≤2 decisions:** don't grill. State assumptions and proceed, or ask the one question that matters.`
   with:
   `- **≤2 decisions (auto-triggered only):** don't grill. Ask the one question that matters, or state your assumptions and wait for a go-ahead. If the user explicitly asked to be grilled, grill anyway.`
   Also in L13, L23 and L43, replace "change the code" / "same code" with "change the outcome (code, plan, or rollout)". On L13, add "after a quick read of the plan and relevant code" before "estimate".

2. **Add a critique step after "Size it first" to match the description.**
   `## Holes first (when asked to stress-test or poke holes)\nBefore the decision rounds, list the top 3–5 risks, failure modes, or unstated assumptions in the plan, each with severity and a suggested mitigation. Turn any that need the user's choice into frontier questions.`

3. **Replace the stop and persist rules at L39-47 so there is a defined end.**
   - L39: `Word each question so "yes" accepts the recommendation.` becomes `End each round with: "Reply 'ok' to take all recommendations, or answer by number."`
   - Add to Stop: `Also stop when the user says "you decide" or "enough"; take the recommended answers and list them.`
   - L47: `After the user confirms the summary, write the decisions to the repo's existing decision/ADR location if one exists, else docs/decisions/<kebab-topic>.md (or where the user prefers); never overwrite an existing file, append instead. One line each — decision, choice, reason.` Delete "(or via `handoff`)".
