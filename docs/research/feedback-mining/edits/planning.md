# Planning-skill edits (grill, spec) - change log

Source: cskills-run/analysis/planning.md (E1-E7). Rule: apply if >=2 independent reports. All 7 qualified; all applied, several tightened vs the proposal.
Word deltas (body only): grill 689 -> 751 (+62, budget ~80); spec 555 -> 577 (+22, budget ~35). Frontmatter untouched.
Validator: `python tests/validate_skills.py` -> 13 skills checked, 0 problems.

| Edit | Evidence | Result |
|---|---|---|
| E1 grill "Facts are mine": don't ask what user/issue already said; finish reading/subagents that could change a question before asking; subagent report is not the user's answer (replaces "send a subagent while asking the rest of the frontier") | mp#948, #1104, #1245, #802 (+toverux, benshields), #1106, #1145 | Applied, shortened ("source issue", "a subagent's report") |
| E2 grill Asking: template `Q<n>`, options on own lines a)/b); number across session, never restart at Q1; "plain-language question" replaces statement-style wording | mp#834, #933, #1057, #789, #1154, #1249, #962, #994 | Applied as proposed |
| E3 grill AskUserQuestion: put needed background inside the question (tool hides the chat); plain-text opt-out | mp#850, sp#114, mp#986, gs#1208, gs#879; opt-out mp#149, #168, sp#388 | Applied, shortened ("Otherwise, or if the user prefers plain text:") |
| E4 grill Stop: gate is "until the user asks for it"; confirming the summary is not permission | mp#1068, #975, #134, #240, #570, #729; sp#1030; gs#287, #66; ce#514 | Applied as proposed |
| E5 grill Record: spell out ADR; status Proposed until the work ships | mp#299, #822, #830 | Applied as proposed |
| E6 spec builder check: also flag decisions/Outcome items no slice delivers and Out of scope doesn't exclude | mp#341, #310, #924, #959, #689; sp#602 | Applied as proposed |
| E7 spec issues: inline the slice text and the decisions it depends on | mp#1078, #959, #341 | Applied as proposed |

Safety rules preserved: ask before pushing, never overwrite files, ⚠ questions need explicit answers / never `default`, no implementation until the user explicitly asks (strengthened by E4).

Note: `git diff --stat` also shows uncommitted changes in blast-radius, diagnose, interrogate, prove-it, review-feedback, tdd - not made by this run (presumably a parallel edit pass); left untouched.
