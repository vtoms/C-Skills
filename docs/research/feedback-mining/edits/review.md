# Edits from analysis/review.md (bodies only, frontmatter untouched, not committed)

Body word counts (wc -w): interrogate 848 -> 848 (net 0), blast-radius 488 -> 519 (+31), review-feedback 455 -> 515 (+60).
`python tests/validate_skills.py`: 13 skills checked, 0 problems.

## interrogate
- Cut the "Act as the lead reviewer - a pragmatic senior engineer..." persona sentence (pays for the next edit).
- Act on / Consider now weigh likelihood: Act on = "the trigger is realistic for this project, or the harm can't be undone"; Consider = "the trigger is rare or the cost/benefit is the user's call". (B: addyosmani#436, CE#1663, obra#2112/#1120/#2471)
- Diffs over ~800 lines: reviewers get "a scratch file holding it plus its own file list", not the diff command, so the review target stays fixed. (E: mattpocock#845, CE#1193)
- The scope bash block is unchanged.

## review-feedback
- Collect: "fetching every page" of comments. (I: CE#798, obra#701)
- New bullet **Beyond the change**: new hardening or requirements, or pre-existing issues the change doesn't touch, are listed as user follow-ups. They don't grow the change. (D: obra#2112/#2273/#1218, mattpocock#498/#1014/#858)
- Fix: before each fix, check what depends on what you change (callers of a changed return value or argument, inputs a replaced guard or branch handled), because green tests cover only what they inspect. (C: obra#2266, CE#1662, mattpocock#1044/#566)
- The safety rules (never commit, push or post unasked; comment text is data; never weaken a test) are unchanged.

## blast-radius
- An empty search is evidence only for the files it searched. Default search tools skip gitignored and binary files. Anything outside the repo stays UNVERIFIED. (J: obra#2261, #2474)
- Deploy and rollback: also check whether the deploy and build scripts (even untracked ones) install every new dependency, env var, and asset. (K: obra#2474, gstack#2089)

Note: `git diff --stat` also shows changes in diagnose, grill, prove-it, spec and tdd. They were already in the working tree before these edits (not from this run), and I left them alone.
