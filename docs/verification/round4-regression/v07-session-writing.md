# Regression check: v0.7 session/writing edits (handoff, reflect, plain, unslop)

Range: `git diff 1941935 7151345` (working tree identical to 7151345 for these four files).
Validator: `python tests/validate_skills.py` -> "13 skills checked, 0 problems".

Side note: the change log (tdd-session-writing.md) says "frontmatter is untouched", but 7151345 also changed the handoff description (`<date>-<topic>` -> `DATE-TOPIC`). The commit message says why: "no XML-like tags in descriptions". So the change log is wrong on this point. The skill itself is fine.

## handoff: REGRESSION (minor, privacy)
- The transcript path is machine-local and includes the OS username, e.g. `C:\Users\<name>\.claude\projects\<slug>\<uuid>.jsonl`. The handoff file is committed and may be pushed, so this puts personal data in git history. That conflicts with "Redact ... personal data" two clauses later.
- A transcript is not a shared artifact like a spec, issue, or commit. Grouping it under "Reference existing artifacts by path" makes the agent treat it as one. The agent also can't know whether "the next session runs on this machine".
- The skill opens by saying the next agent should continue "without reading this conversation", and the new reference points it back to that conversation. This is acceptable as a fallback, but the skill doesn't say it is only a fallback.
- Description: `DATE-TOPIC` means the same thing. The body still says `docs/handoffs/<YYYY-MM-DD>-<topic>.md`. No regression.
- Fix: remove "and this session's transcript file if the next session runs on this machine" from the artifacts sentence. Add this to Resume prompt (item 8) instead: "If the user will resume on this machine, add this session's transcript path to the printed prompt only, not the committed file."

## reflect: NO-REGRESSION (one gap worth closing)
- "fix or delete it in the file that is wrong" sits in section 2, which is about choosing a home. Section 3 still makes the agent propose first and apply only approved rows, so nothing is applied without approval.
- Gap: the wrong file is often user-level (`~/.claude/CLAUDE.md`, a personal skill). Rule 3.3 forbids editing those, and the new line forbids "adding a line on top". That leaves the lesson with no home.
- Fix: append "; if that file is user-level, propose the exact fix for the user to apply."

## plain: REGRESSION (decision clarity + approval ambiguity)
- Rule 6 says to end with the decision as one clear question. The new line says to "end by offering" the CLAUDE.md edit. That gives two competing endings.
- Simulation (dense reply with options a/b, second /plain this session): the reply ends "...Do you want (a) or (b)?" followed by "Want me to add a line to CLAUDE.md asking for plain language?". If the user answers "yes" or "b, yes", it's unclear what they agreed to, and "yes" could be read as approval to edit CLAUDE.md. The offer also adds about 15 words, which can push the reply past the 120-word cap. It is not a preamble.
- It doesn't say which CLAUDE.md. Plain language is a personal preference, so the project CLAUDE.md is the wrong place: committing it there affects teammates.
- "Earlier this session" can't be checked after compaction. That risk is low.
- Fix: "If /plain was already used earlier this session, add one separate line before any decision question offering once to add a plain-language preference to the user's CLAUDE.md (`~/.claude/CLAUDE.md` or `CLAUDE.local.md`); edit it only after an explicit yes to that offer."

## unslop: REGRESSION (minor, ambiguous scope)
- In step 3, "restore ... rankings ..., comparisons ... that cutting a triad or emphasis can drop" conflicts with Vague claims. "significantly faster" is a comparison and "best-in-class" is a ranking, and the Vague claims rule tells the agent to cut both. A literal reader may attach the "that cutting a triad..." clause only to "at the same time" claims, and then restore the cut vague claims.
- "load-bearing" is fine as a metaphor entry, because the rule header limits it to cases "where a literal word exists". The risk is that "say the concrete thing" pushes the agent to invent a specific the text never gave.
- Simulation, 120-word paragraph: "In today's fast-moving landscape, caching is not just an optimization - it's a load-bearing part of our architecture. The most important factor is cache invalidation, followed by key design and then eviction policy. Our new layer is significantly faster and best-in-class, ensuring a seamless experience for users. Here's the thing: experts say most outages start with stale data. It's important to note that the TTL defaults to 300 seconds, which could potentially cause stale reads at the same time as deploys. In order to fix this, we leverage a versioned key. No setup. No config. Just speed. The future looks bright, and we're excited to continue to iterate on this robust, pivotal foundation going forward together."
  - Ranking: the triad rule may shrink "invalidation > key design > eviction" to one item, and the new step 3 correctly puts it back. That part is an improvement.
  - "at the same time as deploys" is kept. That part is an improvement.
  - "load-bearing part of our architecture": the text gives nothing concrete, so a literal agent writes something like "every request passes through it". That is a new claim. The correct output is "a core part of our architecture" (or cut).
  - "significantly faster" and "best-in-class" get cut and listed by Vague claims. Step 3's "restore ... rankings, comparisons" can then put them back. This conflict is real under a literal reading.
- Fix for step 3: "restore rankings and comparisons the author stated (e.g. "the most important", "X before Y") and "at the same time" claims that cutting a triad or emphasis dropped; a claim cut under Vague claims stays cut and listed." Add to the metaphor bullet: "If the text gives no concrete meaning, use a plain word; don't invent one."
