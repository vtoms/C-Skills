# v0.7-rc regression: validator + cross-skill consistency

Range: 1941935..7151345, worktree cskills-local. Repo not modified; probes removed (`git status --porcelain` empty, 0 `zz-probe-*` dirs, `~/.claude/skills/zz-probe-shadow` removed - Test-Path False). Probe scripts: `probe.py`, `rx.py`, `wc.py` in this folder.

Baseline: `python tests/validate_skills.py` -> 13 skills checked, 0 problems. No `$<digit>` in any current body.

## Verdict
Validator: PASS WITH FIXES (2 real false negatives, 1 regression vs old check). Cross-skill: PASS, no hard conflicts; 3 minor tensions.

## (1) Validator probes (42 probe skills, one run)

| Probe | Result | Correct? |
|---|---|---|
| desc `a < b > c` | pass | yes |
| desc `x<y` | pass | yes |
| desc `x<y and z>w` | FAIL `<y and z>` | acceptable (looks like a tag) |
| desc `<https://example.com>` autolink | FAIL | acceptable (API sees a tag) |
| desc `<example>` | FAIL | yes |
| desc `a -> b`, `c <= d` | pass | yes |
| when_to_use `<example>` | pass | minor gap (field is Claude Code-only; low priority) |
| body `$0`, `$1`, `$19`, `$1.50`, `$1` in fenced block | FAIL | yes (substitution ignores fences) |
| body `\$1`, `$ARGUMENTS[1]`, `${1}` | pass | yes |
| body `$20` | pass | unclear; conservative flag preferable |
| body `=SUM($B$6)` | **pass** | **FALSE NEGATIVE** - the exact anthropics/skills#1779 case cited in mechanics.md; `(?<![\\$\w])` lookbehind skips `$6` after `B` |
| body `a$1`, `$$1` | **pass** | **FALSE NEGATIVE** (same lookbehind) |
| `disable-model-invocation: true` | pass | yes |
| `: True` | FAIL | strict (YAML 1.2 accepts it) - fine, message says "literally" |
| `: "true"` | FAIL | strict, fine |
| `: yes` | FAIL | yes |
| `: yes # manual` | **pass** | **FALSE NEGATIVE** - `\S+\s*$` doesn't match with a trailing comment; PyYAML reads yes as True so no fallback catches it |
| `user-invocable:` (empty) | **pass** | **REGRESSION** - old `fm[key] not in BOOL_VALUES` flagged it; new regex needs `\S+` |
| `user-invocable: true # x` | pass (unchecked) | ok by luck |
| folder with `skill.md` only | FAIL "no file named exactly SKILL.md" | yes (Windows, case-insensitive FS) |
| personal `~/.claude/skills/zz-probe-shadow` | WARN, exit 0 | yes |

Side note: `\s*` in RAW_BOOL_RE can cross a newline (`user-invocable:\n  false` matched as `false`) - harmless now but fragile.

### Exact fixes (tests/validate_skills.py)

```python
ARG_TOKEN_RE = re.compile(r"(?<!\\)\$(\d+)")
RAW_BOOL_RE = re.compile(r"^(disable-model-invocation|user-invocable):[ \t]*([^\s#]*)[ \t]*(?:#[^\n]*)?\r?$", re.M)
```
Verified with rx.py: `$B$6`, `a$1`, `$$1`, `$20`, `$1.50`, `$0` flagged; `\$1`, `${1}`, `$ARGUMENTS`, `$(git x)` not; `yes # manual` -> 'yes', empty -> '' (both now FAIL), `true # x` -> 'true'. Current 13 skills stay clean (no `$<digit>` anywhere). Matches mechanics.md's own proposal `(?<!\\)\$\d`.

Optional: also run TAG_RE over `fm.get("when_to_use", "")`.

Question for the author: RESERVED now contains `synced`, which is not a Claude Code built-in I can identify; it is a folder in this user's personal `~/.claude/skills/`. If that is its source, drop it (it is a personal-copy clash, which the new WARN already covers).

## (2) Cross-skill consistency

- Commit/push: grill/spec offer to commit, ask before push; handoff commits only its file, asks before push; review-feedback never commits/pushes unless asked; diagnose commits only if asked; spike never commits. Consistent.
- CLAUDE.md edits: new plain line ("offer once ... edit only if they agree") agrees with reflect's approve-then-apply. plain doesn't mention reflect's ~200-line cap - minor.
- Evidence vocabulary: blast-radius 1-5 ladder still "same as prove-it"; diagnose/tdd defer to prove-it levels. Unchanged and consistent.
- "Prove it could fail": prove-it's new "when it passes, confirm it could have failed (red on old code)" matches tdd red, review-feedback "run on the unfixed code and see it fail", diagnose "fails on old code". Consistent. tdd's new stub rule (return the named bug's wrong result) doesn't conflict.
- grill ADR `status Proposed until the work ships` vs spec: spec reads the decisions file, not ADRs, so no conflict - but no skill ever moves an ADR to Accepted (orphan state). Fix (optional): spec "After writing" or handoff: "if a grill ADR exists for this work, note it stays Proposed until the shipping PR."
- interrogate buckets vs review-feedback: review-feedback "act on Act on" and new "Beyond the change -> user follow-up" can collide when an interrogate Act-on item is new hardening. Fix: in review-feedback step 2 add "(interrogate's Act on items already passed this filter)", or in step 1 "act on 'Act on' unless it is beyond the change".
- Wording clash: unslop now lists "load-bearing" as a metaphor to cut, while blast-radius uses "load-bearing fact" as its key term (steps 3 and 6). Not a rule conflict; either drop "load-bearing" from unslop's list or rename blast-radius's term to "the fact safety rests on".
- grill internal: "Do not implement until the user asks for it - ... confirming the summary is not permission" + Record "after the user confirms" - consistent; spec "until the user picks a slice" - consistent.

## Body word counts (after frontmatter)

| skill | 1941935 | 7151345 | delta |
|---|---|---|---|
| blast-radius | 488 | 519 | +31 |
| diagnose | 651 | 687 | +36 |
| grill | 689 | 751 | +62 |
| handoff | 416 | 429 | +13 |
| interrogate | 848 | 848 | +0 |
| plain | 196 | 228 | +32 |
| prove-it | 627 | 657 | +30 |
| reflect | 489 | 528 | +39 |
| review-feedback | 455 | 515 | +60 |
| spec | 555 | 577 | +22 |
| spike | 262 | 262 | +0 |
| tdd | 509 | 551 | +42 |
| unslop | 521 | 542 | +21 |
| **total** | 6706 | 7094 | +388 (+5.8%) |
