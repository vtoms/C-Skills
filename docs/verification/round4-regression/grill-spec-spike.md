# Regression check: grill, spec, spike (OLD d228028 vs NEW working tree)

## grill

### YAML / frontmatter
Unchanged (name, description, argument-hint), auto mode. Valid.

### Regressions / new problems
- **G-R1. ADR rule contradicts where decisions are recorded (new).** Record says to write the decisions "to the repo's existing ADR/decisions location if there is one". The next sentence says "Suggest an ADR only for decisions hard to reverse, surprising, and a real trade-off." In a repo with `docs/adr/`, the first sentence puts every decision into the ADR folder and the second says most of them don't deserve an ADR. An agent will either make an ADR per decision (the bloat the filter was meant to stop) or not know where the rest go.
  Edit: `write the decisions to the repo's existing decisions location if there is one, else docs/decisions/<topic>.md (or where the user prefers) ... Propose a separate ADR, in the repo's ADR location if it has one, only for decisions that are hard to reverse, surprising, and a real trade-off.`
- **G-R2. The ⚠ rule says what "ok" doesn't do, but not what happens next.** "a blanket 'ok' doesn't cover them" leaves the ⚠ question in limbo. The agent might take it as a default anyway, because Stop or "you decide" lists defaults and Record allows a `default` via "ok". Or it might leave it unrecorded.
  Edit: append `; re-ask each unanswered ⚠ question on its own before moving on, and never record one as default.`
- G-minor. Parked `/spike` questions have no place in the record. Optional edit to Record: `List parked questions as open, naming the spike that settles them.`
- G-minor. "add resolved terms there" (to the glossary) has no timing. It could be written mid-interview, before the summary is confirmed. Optional: `...add resolved terms there when recording.`
- Length is 466 to 647 words. That is acceptable, because the new sections are short bullets and no rule is buried.
- R1 to R4 from round 2 are all intact: the Holes-first override, append instead of overwrite, "Later work cites...", and "(or where the user prefers)".

### Intended edits landed?
Too big / spike route: yes. Assuming (from code): yes. Terms and claims: yes. ⚠ marking and the ok wording: yes, apart from the gap in G-R2. chosen/default tags: yes. ADR filter: landed, but conflicts with the location rule (G-R1).

### Simulations
- **Normal:** "/grill per-tenant rate limiting for our Express API".
  1. Sizing says "~6 decisions, 2 rounds".
  2. The agent reads the middleware and lists "Assuming (from code): Redis client already in src/cache.ts".
  3. Round 1 asks Q1 ⚠ "key limits by tenant id stored in a new tenants.rate_limit column?", Q2 window algorithm, and Q3 429 body format. It ends with "Reply 'ok' to take all unmarked...".
  4. Result: PASS.
- **Edge:** the user answers "ok" to that round.
  1. Q2 and Q3 are taken and tagged `default`. Q1 ⚠ is not covered, and nothing tells the agent to re-ask it.
  2. A likely outcome is that the next round re-plans the frontier and Q1 drifts. Or the user says "enough", Stop lists defaults, and Q1 is silently recorded as `default`.
  3. The rule exists to prevent exactly that.
  4. Result: PARTIAL (G-R2). With the edit, the agent re-asks Q1 alone and the result is PASS.
  5. In the same repo with a `docs/adr/` folder, Record writes all 6 decisions as ADRs (G-R1).

Verdict: **REGRESSION (minor)**: G-R1, G-R2.

## spec

### YAML
Unchanged, manual, valid.

### Regressions / new problems
- **S-R1. Migrate batches collide with the 6-slice cap.** A wide rename across many packages produces "migrate moves callers in batches (per package or directory)". If each batch is a slice (each is "green on its own", like a slice), a 15-package rename gives 17 slices. That triggers "Would need more than 6 slices: say the scope is too big, propose a split, and stop", which is wrong for a mechanical rename.
  Edit: `...migrate moves callers in batches (per package or directory), each green on its own, listed as PR batches inside one migrate slice; ...`
- **S-R2. Persisted-data renames lack dual-write/backfill.** "Expand adds the new form beside the old" is not enough for a column rename. Without dual-write and backfill, migrated readers see empty data.
  Edit: `Expand adds the new form beside the old (for stored data: new column, dual-write, backfill);`
- S-minor. "run `/blast-radius` before the contract slice": spec "writes only the spec file", so it is unclear whether the agent runs blast-radius now or at implementation time. Edit: `make the contract slice's Done when include a /blast-radius pass.`
- S-minor. The slice template heading "<user-visible capability>" and "Delivers:" fit expand and contract slices badly. Agents will improvise, which is acceptable.
- S-minor. A pure internal symbol rename done with tooling often fits one PR. "Size it" runs first, so this is acceptable, but "one edit breaks every caller, so slice them" overstates the need. Optional: `when it can't land in one PR`.
- Builder check: ceremony is moderate (one subagent pass). It is bounded by "only the question round" and consequential guesses only. Acceptable. Unclear: whether to wait for the user's answers before steps 2 to 5. Minor.
- S1 to S3 from round 2 are intact.

### Intended edits landed?
Expand/migrate/contract: yes (with S-R1 and S-R2). Builder check: yes.

### Simulations
- **Normal:** "/spec docs/decisions/auth.md".
  1. The agent reads the file and writes 4 vertical slices.
  2. The builder-check subagent flags "session lifetime unspecified". The conversation has 24h, so the agent folds it in.
  3. The agent shows the slices and offers to commit.
  4. Result: PASS.
- **Edge:** "/spec rename `userId` to `accountId` everywhere". The symbol is in 14 packages plus the `users.user_id` column read by an analytics job.
  1. Size: more than one PR, so the exception applies.
  2. S1 expand adds `account_id` and an alias type.
  3. Migrate in per-package batches gives S2 to S15, which is over 6, so "scope too big, split, stop" misfires (S-R1).
  4. If the agent instead groups the batches, the column has no backfill or dual-write (S-R2).
  5. Blast-radius: the agent may run it now even though the skill is meant to write only the spec (S-minor).
  6. Result: PARTIAL.

Verdict: **REGRESSION (minor)**: S-R1, S-R2.

## spike (new)

### YAML
Valid. Manual (disable-model-invocation: true), so grill's "offer `/spike`" correctly means the user types it. The name avoids the reserved `prototype`. The description is a fine menu label.

### Problems
- Cross-skill mismatch: grill routes "look and feel" to /spike, but spike requires a question "answerable yes/no or by a measurement". A UI-feel spike has no allowed signal.
  Edit: `answerable yes/no, by a measurement, or by the user picking between variants`.
- Minor: deleting a worktree spike should also remove the worktree and its throwaway branch. Optional: `Delete the scratch files (and any spike worktree and branch) once the user agrees.`
- Minor: for several questions, "ask which comes first" could recommend an order (riskiest first). Optional.
- "~30 minutes" can't be measured by the agent, but "or three attempts" is workable. Length is about 250 words, which is lean.

### Simulations
- **Normal:** "/spike can better-sqlite3 load in our Electron 30 build?"
  1. Frame: the signal is that `require` succeeds in the main process. The box is 3 attempts.
  2. Work happens in a temp dir with the real Electron version. The agent records the command and output.
  3. Report: Code: delete.
  4. Result: PASS.
- **Edge:** "/spike does FTS5 handle 1M docs under 50ms, does it work in Electron, and is it faster than sql.js?"
  1. The argument holds three questions, so the agent asks which comes first and builds nothing yet.
  2. Result: PASS. It could be better with a recommended order.

Verdict: **NO-REGRESSION** (one recommended cross-skill wording fix).
