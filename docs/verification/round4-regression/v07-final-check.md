# v0.7 final regression check (diff 7151345..HEAD, .claude/skills + tests)

Verdict: CLEAN. No blocking issues. There are 3 optional minor edits.

`python tests/validate_skills.py` reported 13 skills checked, 0 problems. All probes were deleted, and `git status --porcelain` is empty.

## Per hunk

- **grill, Stop.** The new line "go/build it/implement counts as asking" is consistent with "Do not implement until the user asks". It names explicit requests, while "ok" and confirming the summary still don't count. It does not permit commit or push. One weakness: the text doesn't tie "go" to the post-record question, so a "go" said during the rounds could be read as permission to implement. Optional edit: `"go", "build it", or "implement" counts as asking` -> `"go", "build it", or "implement" in reply to that question counts as asking`.
- **grill, Record (ADR Accepted).** This is consistent. Every ⚠ decision is answered explicitly and is never `default`, so marking the ADR Accepted reflects confirmed choices. The repo's own status convention still wins. Spec reads the decisions location, not the ADR folder, so nothing conflicts there. Dropping "Later work cites this file" loses nothing, because spec's Source still reads that file.
- **grill, "yes accepts the recommended option".** This is clearer and has no conflict.
- **handoff.** The transcript path now goes only in the printed prompt and never in the committed file. This is a safety improvement.
- **interrogate, Act on/Consider.** The categories are now separable. Act on means a realistic trigger or irreversible harm, and irreversible harm outranks rarity. Consider means rare and recoverable, or the cost/benefit is the user's call. One small overlap remains: an item that is irreversible but whose cost/benefit is the user's call fits both. That is acceptable. The temp diff file now sits outside the repo and is deleted afterwards, which is safer.
- **review-feedback.** "Act on" items bypass only the beyond-the-change rule. That is consistent: interrogate's brief already excludes issues the diff neither introduces nor exposes, and "default to fixing" agrees with this. Act-on items still go through the other diversions (doesn't hold, needs a decision). The new `follow-up` verdict is added to both the reply list and the table. The commit/push prohibition at the top is unchanged.
- **plain.** The offer sits before the closing question, so the ending still has one decision question. It edits a file only after an explicit yes, and the 120-word cap has an escape for content that truly needs more. Minor: if the offer is phrased as a question, the reply ends with two questions. Optional edit: `add one separate line before the closing question offering, once,` -> `add one separate statement (not a question) before the closing question offering, once,`.
- **prove-it, tdd, spec, reflect.** These are consistent. tdd's Done now matches its Red step's "passes immediately" path. spec still has a single question round. reflect proposes fixes to user-level files instead of editing them, which is safer.
- **unslop.** Removing "load-bearing" is now consistent with blast-radius ("load-bearing fact"), so unslop would no longer rewrite that term of art.

## Safety

No hunk allows committing, pushing, editing CLAUDE.md, or writing files without explicit approval. Several hunks tighten safety: handoff, interrogate, reflect and plain.

## Validator probes (temporary zz-probe-*, deleted)

ARG_TOKEN_RE:
- Correctly not flagged: `$` alone, `US$`, `$ 5`, `$x`, `$ARGUMENTS`, `\$1`.
- Correctly flagged: `$0`, `$19`, `=SUM($B$6)` (as $6), `$100`, `` `echo $1` ``.
- `\\$1` (escaped backslash followed by $1) is not flagged. It is unclear whether Claude Code substitutes here, and it is very unlikely in practice.

RAW_BOOL_RE:
- Correctly flagged: empty value, empty value with spaces, `yes # c`, `"true"`, `True` (conservative).
- Correctly passed: `true # c`, `false   # trailing`, `false`.
- False negative: `user-invocable: true#c` passes. YAML reads `true#c` as the string "true#c", because a comment needs whitespace before `#`. Optional edit at tests/validate_skills.py:44:
  `r"^(disable-model-invocation|user-invocable):[ \t]*(\S*?)[ \t]*(?:[ \t]#[^\n]*)?\r?$"`
  This drops `[^\s#]*` and requires whitespace before `#`.
