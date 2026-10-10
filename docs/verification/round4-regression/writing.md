# Regression check: unslop, plain (OLD d228028 vs NEW working tree)

## unslop - NO-REGRESSION (3 minor misfire risks)
### Regressions / contradictions
- None lost: Never-change list, cut-claim listing, step 4 output form incl. "No other commentary" (round-2 fix), "already clean -> change nothing", frontmatter all identical.
- Dash policy vs protected spans: no contradiction. Never-change already says "even if they contain the patterns below", so a dash inside a quote or code block stays. Test confirms.
- "Act on clusters, not one weak signal" vs pattern list: consistent; the parenthetical scopes "weak" to a lone dash or hedge, so a lone "I hope this helps" is still cut. Fits the already-clean rule.
- Misfire 1: "reveal colon" can be read as covering colons that introduce code, lists or quotes ("To apply it, add this step:"). Suggested: "...or a reveal colon ("The fix: a cache"), not a colon before code, a list, or a quote."
- Misfire 2: Staged emphasis "State the claim once" drops the "not X" half, which can be content ("not a memory leak"), and nothing says to list it. Suggested: append "If the 'not X' half is a fact, keep it as a plain clause."
- Misfire 3: "several em dashes per paragraph" is vague (is 2 several?). Acceptable; optional "(three or more)".
### Intended edits: all 6 landed as described in the change log. YAML unchanged and valid.

### Hand test (a) input
````
Great question! In order to speed up the build, it's important to note that you should run `npm ci --prefer-offline` before every CI job — this robust approach seamlessly leverages the local cache, ensuring consistent installs. It's not a caching trick, it's a reliability fix. Here's the thing: the cache already sits on every runner, so there is no extra setup. As the npm docs put it, "npm ci can only install entire projects at a time." Teams that adopt this see significantly faster pipelines, and experts agree it is best-in-class. Our own build dropped from 312 seconds to 140 seconds after the change — a 55% cut. The full reference lives at https://docs.npmjs.com/cli/v10/commands/npm-ci. To apply it, add this step:

```yaml
- run: npm ci --prefer-offline  # robust — seamless cache
```

I hope this helps!
````

### Output (applying NEW literally)
````
To speed up the build, run `npm ci --prefer-offline` before every CI job. It is a reliability fix that uses the local cache, so installs stay consistent. The cache is already on every runner, so it needs no extra setup. As the npm docs put it, "npm ci can only install entire projects at a time." Our own build dropped from 312 seconds to 140 seconds after the change — a 55% cut. The full reference lives at https://docs.npmjs.com/cli/v10/commands/npm-ci. To apply it, add this step:

```yaml
- run: npm ci --prefer-offline  # robust — seamless cache
```

9 changes; most common: chatbot residue/filler and fake depth/staged emphasis.
Cut claims:
- "Teams that adopt this see significantly faster pipelines, and experts agree it is best-in-class." (no source or number for the comparison; 312->140 is our own build)
- "not a caching trick" (negated half of the staged contrast; listed by choice, rule does not require it)
````
Checks (python): inline `npm ci --prefer-offline`, quote, URL, 312 seconds, 140 seconds, 55%, whole fenced block (incl. its em dash and "robust", "seamless") all byte-identical: True. Prose em dashes 2 -> 1 (limited, not banned; code dash untouched). Words 136 -> 97. No new formula: no closers, no threes, sentence lengths vary. "add this step:" colon kept (judgement; see misfire 1).

### Hand test (b) clean text
Input: "Run `make test` before pushing. The suite takes about 3 minutes — longer on Windows, where the file watcher is slower."
Output: "Already clean; no changes." Text unchanged (lone dash = single weak signal, cluster rule correctly holds). Pass.

## plain - NO-REGRESSION
### Regressions / contradictions
- Round-2 items are present in NEW (generic jargon "Define or replace any other term", "Drop labels invented", "every number the user needs to decide"). Nothing lost; frontmatter unchanged.
- Minor tension: "Keep what was verified apart from what wasn't" + "in the same order": if the reply interleaved them, separating needs reordering; if it never marked them, the model may infer verified status (a new claim). Suggested: "If the reply says what was verified, keep that split."
- Length pressure (pre-existing): first natural pass came out 134 words (= input); a tight pass fits in 111. The new clause adds ~10-15 words to output.
### Intended edit: landed (caveat that changes the decision; verified vs unverified).

### Hand test input (134 words)
````
The nightly export in `jobs/export_orders.py` drops rows because the cursor paginates on `updated_at`, and when more than 1,000 rows share one timestamp the page boundary skips the overflow. I confirmed this locally: with 1,200 rows sharing a timestamp, exactly 200 went missing. I have not checked whether production has collisions that large, though the logs suggest weekly bulk imports might. Options: (a) paginate on `(updated_at, id)` as a compound key, a ~15-line change; (b) raise the page size to 10,000, a quick fix that only moves the limit; (c) switch to a full snapshot export, simplest but it triples runtime to ~45 minutes. I'd go with (a), but note (a) needs a new index on `(updated_at, id)`, and building it locks the orders table unless it is built concurrently. Want me to do (a)?
````

### Output, first pass (134 words)
````
The nightly export is losing rows; here is why, and three ways to fix it. The export (`jobs/export_orders.py`) reads orders page by page, sorted by `updated_at` (last-change time). When more than 1,000 rows share one time, the extras are skipped.
Checked: I reproduced it locally. With 1,200 rows sharing a time, 200 went missing.
Not checked: whether production gets that many at once. Logs hint weekly bulk imports might.
(a) Sort by `(updated_at, id)`, time plus row ID. About 15 lines.
(b) Raise the page size to 10,000. Quick, but only moves the limit.
(c) Export everything each night. Simplest, but runtime triples to about 45 minutes.
I suggest (a). Catch: (a) needs a new index, and building it locks the orders table unless built concurrently (the slower, non-blocking way).
Should I do (a)?
````

### Output, tight pass (111 words)
````
The nightly export loses rows; here is why and three fixes. `jobs/export_orders.py` reads rows in pages sorted by `updated_at` (last-change time). When over 1,000 rows share one time, the extras are skipped.
Checked: locally, 1,200 rows with one time lost 200.
Not checked: whether production gets that many; logs hint weekly bulk imports might.
(a) Sort by `(updated_at, id)`. About 15 lines.
(b) Raise the page size to 10,000. Quick, but only moves the limit.
(c) Export everything. Simplest, but runtime triples to about 45 minutes.
I suggest (a). Catch: it needs a new index, which locks the orders table while it builds unless built concurrently (non-blocking).
Should I do (a)?
````

Checks: context opener first; order cause -> verified -> unverified -> (a)(b)(c) -> recommendation -> caveat -> question, same as input; labels a/b/c kept; path `jobs/export_orders.py` kept; code names `updated_at`, `(updated_at, id)` kept and glossed; numbers 1,000 / 1,200 / 200 / ~15 / 10,000 / ~45 kept; decision-changing caveat (index locks table unless concurrent) kept; verified and unverified on separate labelled lines; ends with one question; tight pass under 120.

## Verdicts
- unslop: NO-REGRESSION (optional edits: reveal-colon exemption; keep factual "not X" half).
- plain: NO-REGRESSION (optional edit: "If the reply says what was verified, keep that split.").
