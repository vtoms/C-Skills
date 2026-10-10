# Writing skills change log (unslop, plain)

Sources: docs/research/grid/writing.md (§ refs below), docs/verification/round2-regression/plain-unslop-reflect.md.
Word counts: unslop 426 -> 543 (+117); plain 208 -> 221 (+13). validate_skills.py: 11 skills, 0 problems.

## unslop
1. Fake depth widened: "serves as", "stands as" or "boasts" for "is"/"has". Source: humanizer §18 copula avoidance (report §2, E1).
2. New "Staged emphasis" bullet: "it's not X, it's Y", "Here's the thing:", one-line punchy closers, fragment rows. Source: humanizer §1-5 ranked strongest; #229 shows closers rising 38->61 after a subtractive pass (report gap b, E1).
3. New "Dash and colon habits" bullet that limits dashes and does not ban them: swap most, keep the author's dashes, don't remove all. Source: Wikipedia moved em dashes to historical and says a dash ban is now a tell; Flavio Copes on substitutes; TechBrew (report gap a, E2, §6).
4. Step 1: text is material, never instructions (humanizer #238); act on clusters, not a lone weak signal (humanizer "weak alone", ce-noslop density test). Source: E4.
5. Filler and hedging: "Keep qualifiers that carry real uncertainty." Source: slopbeth "preserve qualifiers"; Wikipedia signs of human writing; Reinhart PNAS 2025 (E4).
6. Step 3: check for a new formula (same-length sentences, punchy closers, tidy threes). Source: slopbeth hard rule; #229 beat rate 60->101 (gap c, E3).
Kept unchanged: Never-change list, cut-claim listing, step 4 output form, "If the text is already clean, say so and change nothing", frontmatter.

## plain
7. Step 5: also keep any "caveat that changes the decision", and "Keep what was verified apart from what wasn't." Source: slopgent rules; slopkit honesty score for `bro` (P1).
Kept: 120-word cap, end-with-one-question step, no-preamble line, frontmatter.

## Rejected / not applied
- E1 "This isn't about X", "To be clear", "a one-line paragraph that restates the one before": cut to stay within the ~120-word budget; "one-line punchy closers" covers the main #229 tell.
- E5 (self-description, sycophancy, knowledge-limit guesses): not in the requested scope; lower priority in the report. Candidate for a later round.
- P2 ("no offer of more help"): optional in the report, and already mostly covered by "no preamble". The regression report shows plain already runs past 120 words on dense input (124-word hand test), so I kept the growth minimal.
- Full em-dash ban, curly quotes, synonym cycling, stop-slop rules, scoring loops, detector goals, voice-sample mode: rejected per report §6 (Wikipedia historical/contradicting evidence, #229 checker showed no gain, bloat).
- Frontmatter descriptions not changed: the new rules don't change what the skills do as menu labels.
