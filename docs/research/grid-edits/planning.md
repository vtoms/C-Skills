# Planning cluster edits (grill, spec, spike)

Word counts (body): grill 466 -> 647 (+181; baseline = f4a2e2d^, note HEAD f81d100 WIP already contained my first-pass grill edit), spec 389 -> 533 (+144), spike new 250. Validator: 13 skills checked, 0 problems.

## grill
- Size it first: "Too big" (>~15 decisions / several shippable pieces -> split, grill one) and "Can't be settled by talking" -> `/spike`, park dependents. Source: planning.md G4 (AI Hero "two hundred questions -> split", "ungrillable -> prototype"; ce prototype routing test); left-behind prototype SKIP note suggests a one-line route.
- Facts section: "Assuming (from code):" lines with the file each rests on, user corrects. Source: planning.md G3 (GSD assumptions mode, "~2-4 corrections vs ~15-20 questions"; length complaints "40+ questions", "~45 min").
- New "Terms and claims" section (overloaded terms; claims vs code with file:line; glossary only if one exists, never start one). Source: left-behind Top-6 #1 (grill-with-docs #2 retained, 1.05M installs); planning.md G6 (contradiction with code). Dropped the "edge scenarios" bullet (budget; vocabulary-theater complaints #1071).
- Asking: ⚠ on hard-to-reverse questions (stored data, public interfaces, money, security); blanket "ok" covers only unmarked. Source: planning.md G1 (AI Hero "agreed, agreed, agreed"; ce no self-settling; superpowers "a default they never heard").
- Record: `chosen` vs `default` tag; ADR only if hard to reverse + surprising + real trade-off. Source: planning.md G2 (ce user-directed/approved; GSD Claude's Discretion); left-behind #1 ADR filter.
- Kept regression fixes R1-R4 (round2 grill-spec.md) intact: Holes-first override, append-not-overwrite, "Later work cites...", "(or where the user prefers)".

## spec
- Slices: expand -> migrate in batches -> contract exception, /blast-radius before contract when external consumers/persisted data. Source: planning.md S2; left-behind Top-6 #6 (to-tickets, 554k installs; "never horizontal" gives wrong advice for renames).
- After writing step 1: builder check by fresh subagent (or self), consequential guesses only, fold/(my call)/one question round. Source: planning.md S1 (superpowers builder-check-prompt.md).
- Kept regression fixes S1-S3 (overwrite-with-ask, source fallback wording, single slice ok).

## spike (new, manual)
- Source: planning.md section 6 #1 (mattpocock prototype 840k installs; AI Hero "ungrillable"; superpowers "Spike"; ce-prototype). Named `spike` because `prototype` is reserved/built-in (left-behind #1019; validator RESERVED). Branch clutter (#1020) addressed: scratch location/worktree, delete by default, keeping = new request.

## Rejected / deferred
- Map mode (wayfinder fold, left-behind #4): skipped. Even tracker-free it costs ~130 words, pushing grill well past the +180 budget; evidence is medium/niche (4 HN users) with heavy defect traffic (#1180 re-floating decisions, ids, jargon, unsaved state) and reported scope creep; planning.md says "recommend only if users hit spec's split stop often". The decisions file + "suggest a fresh session from that file" + new split rule cover the common case.
- G5 "Changes:" line per question: budget; partly covered by existing "drop questions where every option leads to same outcome".
- G7 no-recommendation for costly options: conflicts with G1 (we keep the recommendation but require explicit answer via ⚠); one mechanism is enough.
- G8 premise check in Holes first: not in required list; budget.
- spec S3 (slice fits one session), S4 (my-call marks / vague targets / domain gaps), S5 (uncovered failure modes): budget; builder check partially covers S4 via "(my call)".
- Codemod "do first by hand then script" line (left-behind #6): budget; implementation detail beyond spec.
- Edge-scenario bullet and glossary inline updates as mandate (grill-with-docs): vocabulary-theater complaints (#1071, #1235); glossary only if one exists.
- to-questionnaire line: weak evidence.
