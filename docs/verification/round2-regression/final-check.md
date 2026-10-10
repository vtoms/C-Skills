# Final check: diff 7d2699c..HEAD (.claude/skills, 11 files)

Validator: `11 skills checked, 0 problems` (rc=0). Frontmatter valid in all changed files.

## Commands tested (git 2.43, scratch repos rnr/rc/rd/rh)
- interrogate base block: remote with origin/main only -> base resolves, `git diff "$base"` shows committed+unstaged, ls-files lists untracked. No remote -> base='' silently (stderr suppressed), then `git diff ""` prints `fatal: ambiguous argument ''`. Prose says "if no base resolves ... stop", so behaviour is acceptable but noisy. (minor)
- diagnose `git grep -nE --untracked "\[DBG-[0-9a-f]{4}\]" -- ':(top)' ':(top,exclude).claude'`: finds tracked + untracked tags, skips .gitignored and .claude/, works from subdirectory (whole repo, ../ paths), rc=1 when clean. Lowercase hex only (tag spec says "4 hex"). (minor)
- handoff `git add <f> && git commit -m .. -- <f>`: commits only the handoff; pre-staged `a`, `o2` stay staged. Without the `git add`, pathspec on new file fails, which the skill already covers.

## Diagnose order
Gate -> safety -> 1..4 -> 5 regression test (red on old) -> 6 fix -> Done. Sensible; "apply the fix (step 6)" forward ref is clear.

## Near-miss trigger check (changed auto descriptions)
- diagnose: "KeyError trace at parser.py:42, fix it" (excluded: obvious trace) ; "why does useEffect run twice?" (excluded: question) ; "that didn't work, button still blue" (may trigger via "first fix did not work" - mild over-trigger risk, acceptable).
- grill: "what am I missing in this PR?" (excluded: reviewing code) ; "is this rename safe to merge?" (excluded: blast-radius) ; "challenge my query's perf" (borderline, acceptable).
- prove-it: "why is the deploy failing?" (excluded: diagnose) ; "plan the rollout" (excluded) ; "fix typo in README" (excluded).
- tdd: "add tests for existing util" (excluded) ; "fix this bug with a test" (excluded: diagnose) ; "refactor parser" (excluded).

## Contradictions
None blocking. blast-radius ladder matches prove-it 1-5. grill -> `/spec <path>` matches spec Source. 

## Optional nits
1. spec/SKILL.md:14 "If neither contains decisions" -> "If none of these contains decisions" (now three sources).
2. interrogate: add `[ -n "$base" ] || echo "no merge base"` before `git diff "$base"`.
3. diagnose Done grep: `[0-9a-fA-F]{4}` to tolerate uppercase tags.
