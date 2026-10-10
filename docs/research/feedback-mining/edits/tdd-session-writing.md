# Change log: tdd + session/writing skills

Worktree: C:\Users\visha\C-Skills\.claude\worktrees\cskills-local (not committed). Only skill bodies were changed; frontmatter is untouched. CRLF line endings are preserved.
Sources: analysis/tdd.md and analysis/session-writing.md. The applied script is edits2/apply_edits.py.
Validation: `python tests/validate_skills.py` reported 13 skills checked, 0 problems.

| Skill | Edit | Words added (budget) | Evidence (2 or more independent reports) |
|---|---|---|---|
| tdd | E1: the stub returns the wrong result of the named bug (e.g. the input unchanged) | | obra/superpowers#2092, #2452; mattpocock/skills#1210 |
| tdd | E2: the behaviour list ends with the edges the spec implies (empty, each limit and the values either side, invalid input) | | mattpocock/skills#1074, #590; obra/superpowers#489 |
| tdd | E3: the report quotes the red assertion failure for each behaviour (7 words, within the 15-word limit) | tdd total +42 (45) | obra/superpowers#994 (plus lucasburkholder); HN 45281161 |
| reflect | New candidate type: instructions that misled the agent because they were stale or contradicted another file | | mattpocock/skills#822, #827; EveryInc/compound-engineering-plugin#1265; garrytan/gstack#1844 |
| reflect | Section 2: fix or delete stale or contradicting text in the file that is wrong instead of adding a line on top | reflect total +39 (40) | same as above |
| plain | Rule 3: short, complete sentences (no arrows, dropped articles, or fragments) | | mattpocock/skills#1071, #1128; blader/humanizer#146 |
| plain | If /plain was already used this session, offer once to add a plain-language line to CLAUDE.md and edit only if the user agrees. The 120-word cap is kept. | plain total +32 (35) | mattpocock/skills#1071, #881, #1128 |
| unslop | Added "load-bearing" to the metaphor list | | HN 48916865 (several commenters) |
| unslop | The final pass also restores rankings, comparisons and "at the same time" claims | unslop total +21 (25) | blader/humanizer#212, #187 |
| handoff | Reference this session's transcript file if the next session runs on this machine | handoff +13 (20) | mattpocock/skills#235 (ehsanjso's measurement); HN 46662213; HN 47097741 |

## Handoff: why it was applied
Cluster H6 lists three independent reports, so it clears the 2-report bar. The analysis rated it "optional, lower confidence" because the agent has to look up the transcript path. Only the path is carried, never the content. A quick test that the agent finds the file reliably is still worth doing.

## Safety rules (unchanged)
The skills still require the following:
- handoff commits only its own file and asks before pushing.
- reflect applies only the edits the user approves.
- unslop never changes protected spans or frontmatter.
- plain's new CLAUDE.md step is an offer only.

## Note
The worktree already had uncommitted edits that this task did not make, in blast-radius, diagnose, grill, interrogate, prove-it, review-feedback and spec. They were left untouched.
