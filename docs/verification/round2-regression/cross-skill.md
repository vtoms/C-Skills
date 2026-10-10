# Cross-skill check: 11 skills in .claude/skills

Validator: `python3 tests/validate_skills.py` reports "11 skills checked, 0 problems".
Auto skills (5): blast-radius, diagnose, grill, prove-it, tdd. Manual-only skills (6): handoff, interrogate, plain, reflect, spec, unslop.

## 1. Cross-references
| # | Where | Issue | Suggested edit |
|---|---|---|---|
| R1 | tdd:25 -> prove-it | The target exists. The backticked `prove-it` reads like a tool or command name. | "verify the feature through its real entry point with the prove-it skill (evidence level 4+)" |
| R2 | grill:51 -> spec:3,28 | spec expects "a grill's decisions file" but never says where grill puts it (an ADR dir or `docs/decisions/<topic>.md`). grill never mentions /spec, so its "fresh session" hint leads nowhere. | grill:51 append: "Then suggest `/spec <path>` to turn it into slices." spec:14: "Use the argument if given, else the newest file in the ADR/decisions location or `docs/decisions/`, else this conversation." |
| R3 | handoff:20 | "only skills that exist here" is ambiguous: here could mean the repo, the built-ins or the session. | "only skills in `.claude/skills/` or built-ins (/code-review, /security-review, /simplify), by `/name`, with one line on why" |
| R4 | handoff:16 -> grill | "link decision files" doesn't say where they live. | "link decision files (`docs/decisions/` or the repo's ADR dir) and specs (`docs/specs/`)" |
| R5 | interrogate:35 vs blast-radius | The Blast radius lens re-implements the blast-radius skill and uses a different verdict scale (block/ship vs SAFE/BREAKING). Its Security lens doesn't mention /security-review. | Lens text: "Blast radius - apply the blast-radius skill's checklist (steps 2-5)". |
| R6 | spec:51 | Says "the spec's pushed path", but spec only offers to commit. Nothing covers pushing. | "offer to commit it; ask before pushing" |

## 2. Conflicting rules
- **C1 Evidence vocabulary (high).** prove-it uses a 5-level ascending ladder (Asserted/Cited/Reasoned/Executed/Observed live). blast-radius:26 uses a different 4-step descending ladder ("observed running > test passed > read the code > inferred"). blast-radius also uses UNVERIFIED/UNPROVEN, interrogate uses Verified/Unverified, and diagnose has no scale. A reader can't map "test passed" to a level 4. Edit blast-radius:26 to: "State the proof's level on the prove-it ladder (1 Asserted ... 5 Observed live)."
- **C2 Committing generated docs.** handoff commits its file without asking on a non-default branch and asks before pushing. spec writes its file, leaves it uncommitted and offers to commit. grill says nothing, so its decisions file is silently lost in an ephemeral env. Edit grill:51 to add: "Say the file is uncommitted and offer to commit it (ask before pushing)."
- **C3 Overwrite and naming.** grill and spec say "never overwrite" but not what to do instead. handoff's dated name has no overwrite rule, so a same-day handoff on the same topic clobbers the earlier one. Shared rule: "never overwrite; if the path exists, append `-2`".
- **C4 "Slice" means two things.** In tdd a slice is one behaviour/test (minutes). In spec it is an independently mergeable PR. Edit tdd:3,15 to say "one behaviour at a time" and drop "vertical slices" from the description, or say "inner slices".
- **C5 Production guard missing in diagnose.** prove-it:34 and blast-radius:26 forbid production. diagnose covers "only in CI or prod" bugs and suggests "script against a running server" and replaying payloads without that guard. Add to diagnose:18: "Repro and instrument locally or on staging; ask before touching production, shared data, or anything that sends, charges, migrates or deploys."
- **C6 Done criteria duplicated.** diagnose "Done means" overlaps prove-it but never mentions it. tdd defers to prove-it. Add "Report with the prove-it evidence level" to diagnose:29.
- **C7 Sizing.** The sizing rules are reasonable and don't conflict. interrogate's "trivial diff" isn't defined. blast-radius's private/boundary split and interrogate's <50-lines/boundary split agree.

## 3. Routing among auto skills (boundary prompts)
| Prompt | Fires | Problem |
|---|---|---|
| "Is this PR safe to merge?" | blast-radius (/code-review possible) | ok |
| "Poke holes in my plan to rename the `user_id` column" | grill AND blast-radius ("before changing persisted interfaces", argument "described change") | **overlap** |
| "Check that my fix for the flaky test really works" | prove-it AND diagnose ("flaky failures") | **overlap** |
| "Export lost rows after the lib upgrade; is the upgrade safe to keep?" | diagnose AND blast-radius ("dependency upgrades") | **overlap** |
| "Fix this bug test-first" | tdd ("asks for TDD") vs diagnose (regression test before fix); tdd excludes "debugging failing tests" but not "fixing a bug" | **overlap** |
| "Write a cron parser with TDD" | tdd | ok |
| "Add tests for this existing function" | none (tdd excludes it) | none fires; acceptable |
| "Review my diff for bugs" | none of the auto skills (blast-radius and grill exclude it) -> built-in /code-review | ok |

Fixes:
- grill desc: add "Not for ... impact analysis of a concrete code change (blast-radius)."
- blast-radius desc: "Not for bug-hunting reviews, debugging, or challenging a plan with no code (grill)."
- prove-it desc: "...Not for finding the cause of a failure (diagnose)."
- tdd desc: "Not for fixing a reported bug (diagnose) ...".

## 4. Safety
- handoff:28 commits without asking on a non-default branch. The user invokes it and the description discloses it, but it is the only skill that commits unprompted. Consider "Offer to commit only the handoff file".
- diagnose: missing production guard (C5). `git bisect run` checks out other commits with possibly uncommitted work present. Add: "bisect in a `git worktree`, never with uncommitted changes."
- reflect:36 limits edits to CLAUDE.md and `.claude/skills/`, yet its homes (tests, lint rules, hooks, scripts) live elsewhere, so an approved hook would mean touching settings.json. Change to: "Touch only files named in rows the user approved."
- tdd: confirms before installing (good). prove-it: asks before deploy/push/prod (good). interrogate: no edits, untrusted forks not run (good). No skill merges or deploys.

## 5. Style
- Voice is mixed. prove-it ("I said so", "If I've done"), tdd ("teach me"), blast-radius's report ("what I checked") and grill ("Facts are mine", "I'll also") use first person. The rest are imperative. prove-it mixes both in one list. Pick imperative and rewrite: prove-it:19 "Asserted - claimed without a check", prove-it:31 "after the same manual check twice", tdd:13 "as slices reveal more", blast-radius:34 "what was checked".
- Dashes mix " - " and em dashes: grill and interrogate use em dashes in their templates, everyone else uses hyphens.
- The skills use arrows (diagnose:16, reflect:27-30) and "**Label:**" lists, which unslop's own rules flag as over-compression and decorative formatting. That is cosmetic and acceptable, but inconsistent with unslop.
- Verdict scales: blast-radius SAFE/SAFE IF/BREAKING vs interrogate block/ship after fixes/ship. Consider one shared scale.
