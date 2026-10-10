# Round 1: live activation (v0.3)

**What was run:** 28 held-out prompts written by an independent agent that never saw the skills. Each ran once in a real headless `claude -p` session from the repo root (tools limited to Skill, Read, Grep and Glob; 3 turns max). The harness (`tests/live/activation.py`) records whether the session actually called the Skill tool.

| Skill | Loaded on its prompts |
|---|---|
| blast-radius | 4/4 |
| tdd | 3/3 |
| grill | 3/4 |
| diagnose | 2/4 |
| prove-it | 2/4 |
| none of ours on the 9 should-not-fire prompts | 9/9 (built-ins such as `code-review` and `security-review` loaded where they fit) |

**Overall:** 23/28 correct. Precision is 1.0; the gap is recall.

## What the misses had in common

| Skill | Missed prompt |
|---|---|
| diagnose | Data discrepancy ("~3% fewer rows on some days") |
| diagnose | Device-only crash that can't be reproduced locally |
| prove-it | "Confirm it's actually serving the new headers" |
| prove-it | "Confirm on staging…" (checks against a running or deployed system) |
| grill | "What am I missing? Push back" |

The v0.4 descriptions name these cases explicitly.

## Caveats

- These prompts now informed the descriptions, so the regression round uses a **new** held-out set.
- Each prompt ran once, so the per-skill numbers are noisy.
- The narrow tool set may make Claude answer directly ("I can't reach staging") instead of loading a skill.
