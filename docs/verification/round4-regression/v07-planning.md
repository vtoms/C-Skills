# v0.7 planning regression check (grill, spec) - diff 1941935..7151345

Validator: `python tests/validate_skills.py` -> 13 skills checked, 0 problems.
Words: grill 784 -> 846 (body ~751); spec 632 total.

## Verdict: NO-REGRESSION (4 optional tightening edits below; nothing must be reverted)

## (1) Contradiction checks
- **Stop "don't implement until the user asks" vs Stop/Record**: no conflict. Recording the decisions file isn't implementing, and Record still runs "after the user confirms". One rough edge: there's no longer a defined moment when the user gives permission. If the user says "ok, go" on the summary, the old text read that as permission, and the new text says confirming isn't permission, so Claude may refuse what the user meant as "build it". This is the intended direction (E4 evidence), but it causes friction. Edit A fixes it.
- **"Finish reading before asking" vs old "send a subagent while asking the rest"**: the old clause was replaced outright, so nothing contradicts. It only blocks on reading "that could change a question", so other lookups can still run in parallel. "A subagent's report is not the user's answer" fits with "Assuming (from code)" because a subagent's code facts still go there with a file cited. OK.
- **Session-wide Q numbering vs AskUserQuestion (max 4 per call)**: no conflict. Numbering applies across calls, and the 4-per-round cap already matches. The closing line ("answer by number") doesn't make sense inside AskUserQuestion, but that was already true before this change.
- **New a)/b) template vs "word each so 'yes' accepts the recommendation"**: the new layout makes this tension worse. "Postgres (a) or SQLite (b)?" can't be answered "yes". It's minor because the "→ Recommended" line resolves it. Edit B.
- **ADR "Proposed until the work ships" vs writing the decisions file**: the decisions file says `chosen` while the ADR says Proposed. In standard ADR usage (Nygard/MADR), Accepted means decided, so a Proposed ADR can invite re-asking, which goes against "later work cites this file instead of re-asking". It also ignores the repo's own ADR status convention. Edit C.
- **spec builder check vs "only question round"**: consistent, because uncovered decisions go into the same single message. One gap: "settle minor ones yourself (my call)" lets Claude quietly move an uncovered user decision to Out of scope. Edit D.
- **Unlogged change**: the spec description changed `docs/specs/<topic>.md` to `docs/specs/TOPIC.md`, probably for the validator. The body still says `<topic>`. Harmless, but it's not in edits/planning.md.

## (2) Length / redundancy (grill)
Key rules are still bold and in their own sections, and none are buried. These are cuttable redundancies, ~45 words:
- Stop: "⚠ questions still need an explicit answer, even after 'you decide'". This mostly repeats Asking ("blanket ok doesn't cover them... never record as default"). Move just "or 'you decide'" into the Asking sentence and cut it from Stop.
- Record: "Later work cites this file instead of re-asking." Spec already does this.
- Record: "If the session is long, suggest continuing in a fresh session..." Low value.
- Holes-first heading parenthetical repeats the Size-it bullet.

## (3) Simulations
- **6-decision plan, user answers "ok, go"**: Claude sizes it at ~6 decisions in 2 rounds and asks Q1-Q4. "ok" takes the unmarked recommendations and each ⚠ is re-asked alone, keeping its Q number. Round 2 asks Q5-Q6 (numbering holds). Stop lists the defaults and Record writes the file. "go" is ambiguous: Claude correctly doesn't implement on summary confirmation alone, but it has no instructed next prompt, so it may just stop or refuse. Edit A.
- **Subagent exploring code**: Claude now waits for the report before asking questions it could change. Code facts go under "Assuming (from code)" with a file. The subagent's opinions on choices are not recorded as `chosen`. Works, but the first round is slower (accepted trade-off).
- **spec, one decision no slice covers (e.g. "email receipt")**: the builder check now flags it, which is an improvement over the old text, which missed it silently. Risks: (a) Claude may file it under Out of scope as "(my call)", which drops a user decision (Edit D); (b) adding a slice could push the count past 6 after the spec is written, which hits the "too big, stop" rule. That's an edge case: offer the split in the same question round.

## Exact edits (optional)
A. grill Stop, append: "After recording, ask whether to implement or run `/spec`; 'go', 'build it' or 'implement' counts as asking."
B. grill Asking: "Word each as a plain-language question so \"yes\" accepts the recommendation" -> "Word each so \"yes\" accepts the recommended option".
C. grill Record: "status Proposed until the work ships" -> "status per the repo's ADR convention, else Accepted". If E5's evidence specifically wants Proposed, keep it but add "the decisions file is authoritative".
D. spec Builder check, append: "Cover an undelivered decision by adding it to a slice; move it to Out of scope only with the user's yes."
