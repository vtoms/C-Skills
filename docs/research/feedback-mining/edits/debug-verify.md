# debug-verify edits (applied, uncommitted)

Worktree: C:\Users\visha\C-Skills\.claude\worktrees\cskills-local. Bodies only; frontmatter untouched.

1. prove-it, Rules (cluster A, 6+ reports): "When a check fails, suspect the check..." became "Suspect the check before the system - when it fails, confirm I'm observing the right thing; when it passes or finds nothing, confirm it could have failed (red on the old code or a known-bad input, and any edit or probe I made actually landed)." The "never weaken/skip/delete" clause and the hand-off to diagnose are kept.
   Evidence: obra/superpowers#2186, #2286, #2092, #2452, #2008; mattpocock/skills#955.
2. diagnose, Done means (cluster B, 3 reports): after "the cause isn't confirmed." added "If the user's own failing records, logs, or payload are readable, check the mechanism explains them - a repro on inputs you built proves the path exists, not that it is the one the user hit."
   Evidence: obra/superpowers#2449, #1955 (item 2); mattpocock/skills#1149.
3. prove-it, Report template (cluster H, 2 reports): `<actual output>` became `<actual output, secrets redacted>`.
   Evidence: obra/superpowers#2375 and #2460; mattpocock/skills#674.

Kept unchanged: fresh evidence, never weakening a check, prod/write safety, and the git grep DBG cleanup command.

Checks: `python tests/validate_skills.py` reported 13 skills checked, 0 problems. `git diff --stat` shows 2 files changed, 3 insertions(+), 3 deletions(-).
