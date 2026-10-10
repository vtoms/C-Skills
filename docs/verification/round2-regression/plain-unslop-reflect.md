# Regression check: plain, unslop, reflect (OLD 31d6e7e vs NEW working tree)

## plain — REGRESSION (minor)
### Regressions / contradictions
1. Generic-jargon rule lost. OLD L13 "Define any term the user didn't use first, or replace it." NEW only glosses *project names* (step 4); non-project jargon (ACCESS EXCLUSIVE, statement_timeout, TOCTOU, 409) is covered only by the vague "everyday words".
2. "Not my invented labels" lost. Round-1 fix 3 asked to keep "Replace your own invented labels"; NEW dropped it, so invented labels from the previous reply now persist.
3. Step 5 "Keep every number, file path..." misfires against (i) the opening "If the user named a part, re-explain only that part" (every number of the *whole* original?), and (ii) the 120-word cap. Hand test: output came out at 124 words, longer than the 117-word original. Round-1 explicitly judged dropping jargon numbers (jitter 50ms/2s, v1beta2) acceptable; NEW forbids it.
Kept: one-sentence context opener, "end with one clear question", no-preamble, 120-word guideline.
### Fix verification
- Fix 1 (voice "your previous reply"): fixed ("The previous assistant reply").
- Fix 2 (keep numbers/paths/labels/order; arguments): fixed, but over-broad (see 3).
- Fix 3 (keep project names + gloss; GLOSSARY if present): partially (invented-label clause dropped).
### Frontmatter: OK (description is a menu label, argument-hint present, manual).

### Hand test (b)
Input (117 words):
The deploy failed because the migration in `db/migrations/0042_add_index.sql` takes an ACCESS EXCLUSIVE lock on `orders`, which has 38M rows, so the 300s statement_timeout in the pgbouncer transaction pool kills it mid-build and Alembic leaves the revision marked dirty. Options: (a) rewrite it as CREATE INDEX CONCURRENTLY, which needs the migration split out of the transactional block and a manual `alembic stamp` afterwards; (b) raise statement_timeout to 1800s for the migration role only, which works but blocks writes to orders for ~20 minutes; (c) run it off-hours via the maintenance runbook, which delays the release by 2 days. I'd go with (a) since it avoids downtime entirely and the split is a ~10-line change. Should I prepare (a)?

Output applying NEW literally (124 words):
The deploy failed while adding a database index; here is why and how to fix it. The change in `db/migrations/0042_add_index.sql` locks the `orders` table (38M rows) while it builds. That runs past the 300s time limit, so the database stops it halfway, and Alembic, our migration tool, marks the step as broken.
(a) Build the index without locking the table. The step moves into its own file and needs one manual "mark as done" command. About 10 lines.
(b) Raise the limit to 1800s for migrations only. It works, but nobody can write to orders for about 20 minutes.
(c) Run it after hours using the maintenance guide. That delays the release by 2 days.
I suggest (a): no downtime.
Should I prepare (a)?

Checks: order a/b/c kept, labels kept, path kept, all numbers (38M, 300s, 1800s, ~20 min, 2 days, ~10 lines) kept, recommendation kept, ends with one question. Length 124 > 120 and > original: the "keep every number" + "gloss" rules push length up; "don't just compress" plus a 120 cap is now nearly unsatisfiable for dense replies.

## unslop — REGRESSION (minor)
### Regressions
1. OLD step 4 "Reply with the revised text (or edit the file) ... No commentary beyond that." NEW step 4 drops both "reply with the revised text" (for pasted/last-reply input, output form is now implicit) and "No commentary beyond that" (commentary now allowed).
2. Listing ambiguity: fake-depth cuts ("ensuring a smooth rollout") and "In summary" closers delete claims/restatements; NEW says "list each cut claim" — unclear whether these count. Not a regression vs OLD (OLD cut silently), but the new rule is fuzzy.
Kept: "If the text is already clean, say so and change nothing." No contradictions found between "Never change facts" and Vague-claims (exception now explicit).
### Fix verification
- Fix 1 (protected set + allowed cuts listed): fixed.
- Fix 2 (default input, diff for files, skip generated/licence/CHANGELOG): fixed.
- Fix 3 (headings that are anchors / product names): fixed (though "is a link anchor" is hard to know; minor).
### Frontmatter: OK.

### Hand test (a)
Input (140 words):
Great question! In order to deploy the service, it's important to note that you should run `make deploy-prod` from the repo root. This robust command seamlessly handles migrations, ensuring a smooth rollout for the whole team. As the on-call guide puts it, "Never deploy on a Friday without a robust rollback plan." Our pipeline is significantly faster than competitors' pipelines and is widely regarded as best-in-class across the industry. The last release took 14 minutes end to end, including the 3 smoke tests. Full documentation for every step lives at https://example.com/docs/deploy#rollback and should be your north star. To roll back a bad release, run:

```bash
make rollback  # leverage the robust snapshot
```

In summary, deploying is easy and rolling back is easy. The future looks bright! I hope this helps, and let me know if you have any questions.

Output:
To deploy the service, run `make deploy-prod` from the repo root. This command handles migrations. As the on-call guide puts it, "Never deploy on a Friday without a robust rollback plan." The last release took 14 minutes end to end, including the 3 smoke tests. Full documentation for every step lives at https://example.com/docs/deploy#rollback. To roll back a bad release, run:

```bash
make rollback  # leverage the robust snapshot
```

14 changes; most common: chatbot residue and inflated words/filler.
Cut claims:
- "Our pipeline is significantly faster than competitors' pipelines and is widely regarded as best-in-class across the industry." (no number or source in the text; 14 minutes is not a comparison)
- "ensuring a smooth rollout for the whole team" (unsupported; listed because unclear whether fake-depth cuts count)
- "In summary, deploying is easy and rolling back is easy." (pure restatement)

Byte-identity check (python substring test): inline `make deploy-prod`, the quote (which contains "robust"), URL with #rollback anchor, "14 minutes", "3 smoke tests", and the whole fenced block (with "leverage the robust" comment) all present unchanged: True for all.
Clean-text test: input "Run `make test` before pushing. The suite takes about 3 minutes." -> "Already clean; no changes." Text unchanged. Pass.

## reflect — REGRESSION
### Regressions / contradictions
1. Step 3.3 "Touch only the project CLAUDE.md and `.claude/skills/` unless the user asks otherwise" contradicts step 2, whose two strongest homes (test/type/lint rule; script/hook in .claude/settings.json) live outside those paths, and step 3.4 ("for each test, hook, or lint rule added"). Round-1 asked only to exclude *user-level* files; the fix over-narrowed it.
2. Routing is now worse for the round-1 case: "Costly or repeated process mistakes -> script or hook". Since step 1 keeps only candidates likely to recur, nearly every process lesson qualifies as "repeated", so a one-line convention (`uv run pytest`) is sent to a hook — the opposite of round-1 fix 1 ("A one-line convention belongs in CLAUDE.md, not a hook; hook only for mistakes repeated despite a written rule"). Overlaps with "One-line conventions -> CLAUDE.md"; no tie-break.
3. OLD "Prefer the home that makes the mistake impossible over one that merely warns" lost; now only "strongest home whose cost fits" in the heading. Acceptable.
Kept: approval gate, smooth-session stop, table, no-contradiction rule, no duplicate skill edits.
### Fix verification
- Fix 1 (proportional routing): partially / worse (see 2).
- Fix 2 (prove guard, stop on no approval, scope): proof + stop fixed; scope over-narrowed (see 1).
- Fix 3 (recurrence criterion, compaction note, description overclaim): fixed.
### Frontmatter: OK.

### Hand test (c)
Invented session: (1) repeated — agent edited generated `src/api/schema.ts` three times, overwritten by `npm run codegen`; user corrected twice. (2) one-off — typo in commit message. (3) one-off — forgot to cd into `web/` once before `npm test`.
Step 1: keep (1); drop (2) as typo; drop (3) as one-time slip.
Step 2: (1) is a repeated process mistake -> "script or hook" (PreToolUse hook blocking edits to src/api/schema.ts in .claude/settings.json); it is also a "one-line convention" -> CLAUDE.md. Both rules match; literal reading picks the hook.
Step 3: table proposed:
| lesson | home | edit |
| generated schema.ts is overwritten by codegen | hook (alt: CLAUDE.md) | PreToolUse matcher Edit|Write on src/api/schema.ts -> block "edit src/api/openapi.yaml then npm run codegen"; alt `+ src/api/schema.ts is generated: edit openapi.yaml and run npm run codegen.` |
Nothing applied before approval (pass). But on approval of the hook row, 3.3 forbids touching .claude/settings.json "unless the user asks" — is approval "asking"? Ambiguous; contradiction surfaces in practice.

## Suggested edits
- reflect 3.3: replace with "3. Edit only files in this project (never `~/.claude` or other user-level files) unless the user asks. Keep each edit minimal, ..."
- reflect step 2 hook bullet: "**Process mistakes that recurred despite a written rule, or are costly** → a script or hook. Otherwise a one-line convention goes in CLAUDE.md first."
- unslop step 4: "4. Reply with the revised text (for a file, the diff), then one line: ... then the list of cut claims, if any. No other commentary."
- plain step 3: append "Define or replace any other term the user didn't use first."
- plain step 4: append "Drop labels you invented in the previous reply."
- plain step 5: "Keep every file path, option label (a/b/c), and recommendation, in the same order, and every number the user needs to decide; drop incidental ones. Add no new claims."
