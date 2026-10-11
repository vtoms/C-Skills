# Attribution

The skills in `.claude/skills/` are original write-ups. Their structure and several ideas are adapted from two MIT-licensed projects:

- **mattpocock/skills** ("Skills For Real Engineers", https://github.com/mattpocock/skills), Copyright (c) Matt Pocock, MIT.
  It influenced `grill` (decision-tree rounds with a recommended answer per question), `diagnose` (feedback loop first), `tdd` (vertical slices, seams), `handoff`, and `plain` (from `wait-what`).
- **pstack** by Lauren Tan (https://github.com/cursor/plugins/tree/main/pstack, mirrored at https://github.com/backnotprop/pstack), Copyright (c) 2026 Lauren Tan, MIT.
  It influenced `prove-it` (from `principle-prove-it-works` and the evidence ladder), `blast-radius`, `interrogate` (lead-judgment buckets), `reflect` (from `reflect` and `principle-encode-lessons-in-structure`), and the root-cause rules in `diagnose` (from `principle-fix-root-causes`).

Both upstream licenses permit reuse with attribution, and this file provides it.

## Demo-video chain

The demo-video skills and toolkit are original code. Their design draws on the research catalogued in `docs/research/demo-video/features.md`; ideas (not text or code) were taken from:

- **Ultrademo** (Apache-2.0): two approval checkpoints, the evidence rule and coverage map, narration rules, voice-first timing, frame checks.
- **video-shotcraft** (Apache-2.0), **OpenScreen** (MIT), **Screenize** (Apache-2.0), **retake** (MIT), **screenstudio-alt-skill** (MIT), **demo-video-skill** (MIT): zoom, pan, highlight and easing parameters.
- **kanopi** (MIT), **iart** and **Afnanksalal** (MIT): narration pace rules, `[NEEDS:]` markers, scene-length formula.
- **edge-tts** (LGPL-3.0, not included or used): only the public facts of the Edge read-aloud protocol were used to write an independent client.

Unlicensed sources (ndemo, a record-demo-video gist and others) were read for ideas only; nothing was copied from them.