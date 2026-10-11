# Demo-video skill chain: feature catalogue

Date: 2026-10-12. Purpose: list every feature that makes an AI-produced web-app demo video look professional, say where each one was seen, and judge whether it can be built with **Windows built-ins only**: PowerShell 5.1, .NET Framework, WinRT (`Windows.Media.Editing.MediaComposition`, `Windows.Media.SpeechSynthesis`, `Windows.Media.Transcoding`), UI Automation, Win32 `SendInput`, `System.Drawing` and DXGI desktop duplication, plus Microsoft's Aria voice through the Edge read-aloud websocket (word timings available). No ffmpeg, no Playwright, no pip or npm packages.

How to read it:
- **Source(s)** names only repos where the feature was actually seen, in source or docs. "(proposed)" means no source had it and it is our own suggestion.
- **Feasible** is our judgement for the built-in stack. Items marked "verify" still need a spike.
- Licences decide reuse. MIT and Apache-2.0 sources may be adapted with attribution. AGPL and unlicensed sources are **learn only**: everything taken from them below is paraphrased.

Method: three earlier source-read reports (clones in `%TEMP%\cskills-run\demo-research\clones`, read only), the Perplexity report the user pasted, and a new round of `gh search repos` / `gh api` reads on 2026-10-12. Some GitHub searches hit the rate limit, so the "further repos" sweep is not exhaustive.

## Sources

| Short name | Repo | Licence | Stars (Oct 2026) | What it contributes |
|---|---|---|---|---|
| Ultrademo | [new-xp/ultrademo](https://github.com/new-xp/ultrademo) | Apache-2.0 (Remotion dependency has its own commercial licence) | 32 | Two approval gates, coverage map, narration style guide, timing formula, synthetic cursor, karaoke captions, live redaction, vertical/GIF/stems outputs, frame verification |
| ndemo | [splitbrain/ndemo](https://github.com/splitbrain/ndemo) | **None (learn only)** | 13 | Narration/intent/actions/done segment schema, accessibility-tree targets, per-segment rehearsal, fixtures for repeatable state, title card |
| kanopi | [kanopi/screencast-skills](https://github.com/kanopi/screencast-skills) | MIT | 2 | Storyboard with scene types, `[NEEDS:]` blockers, approval gate with evals, TTS-safe narration rules, dead-air lessons |
| Afnanksalal | [Afnanksalal/product-demo-video-skill](https://github.com/Afnanksalal/product-demo-video-skill) | MIT | 0 | Coverage table, truth-status per scene, words-per-second validator, zoom/transition/caption/music finishing rules, contact sheet, distribution variants |
| AnastasiyaW | [AnastasiyaW/codex-claude-code-config](https://github.com/AnastasiyaW/codex-claude-code-config) `skills/video-production/*` | MIT | 154 | "So what?" value ladder, kill-word list, script-evaluator rubric, audio levels, caption standards, aspect-ratio exports |
| shotcraft | [Vincentwei1021/video-shotcraft](https://github.com/Vincentwei1021/video-shotcraft) | Apache-2.0 | 11,287 | Feature-to-shot table with required page state, element bounding boxes for camera targets, shot cards (crash zoom, spotlight, marker underline) with durations, independent reviewer |
| iart | [iart-ai/explainer-video-skills](https://github.com/iart-ai/explainer-video-skills) | MIT | 34 | Voice-first word budgets, `seconds = words/2.3 + 0.4`, transition anchored to a word, caption limits |
| ajanaku1 | [ajanaku1/demo-video-skill](https://github.com/ajanaku1/demo-video-skill) | MIT | 3 | Five-act story arc, voiceover do/don't list, word-timed reveals, music bed with ducking and fades |
| alirezarezvani | [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) `engineering/demo-video` | MIT | 28,015 | Story templates, "and means two scenes", words-per-duration fill table |
| ECC | [affaan-m/ECC](https://github.com/affaan-m/ECC) `skills/ui-demo` | MIT | 277,079 | DOM field map, rehearse-before-record gate, typing speed per character |
| Kminer | [Kminer2053/demo-video-skill](https://github.com/Kminer2053/demo-video-skill) | MIT | 22 | Scene table with zoom point and speed-up window, PoC scene, 3x3 montage QA |
| op7418 | [op7418/guizang-product-video-skill](https://github.com/op7418/guizang-product-video-skill) | **AGPL-3.0 (learn only)** | 770 | Feature-evidence table, object + action + result copy test, music ducking levels |
| gist | [mainguyen1701 record-demo-video](https://gist.github.com/mainguyen1701/8623caf578c9711d6f6572012a63ccca) | **None (learn only)** | n/a | Voice first, then measured durations drive recording waits, real timestamps logged |
| Leihyn | [Leihyn/claude-demo-video-skill](https://github.com/Leihyn/claude-demo-video-skill) | **None (learn only)** | 2 | "Add what the visuals can't show" narration rule, real-output proof labels |
| jezweb | [jezweb/claude-skills](https://github.com/jezweb/claude-skills) `product-showcase` | MIT | 1,058 | Feature-to-benefit rewriting examples |
| suraj | [surajshetty3416/demo-video-skill](https://github.com/surajshetty3416/demo-video-skill) (new find) | MIT | 5 | Deterministic frame capture, compositor-side camera with EMA easing, zoom caps, keycaps, typing per frame, fixture seeding and cleanup, speed regions with eased ramps |
| screenstudio-alt | [connerkward/screenstudio-alt-skill](https://github.com/connerkward/screenstudio-alt-skill) (new find) | MIT | 10 | Idle speed-up, auto-zoom on click clusters, smootherstep easing, two-keyframe pans, keystroke chips, vertical follow, callout non-overlap rules, video-model critique |
| retake | [tonhaoln/retake](https://github.com/tonhaoln/retake) (new find) | MIT | 9 | Auto zooms from clicks with lead-in / hold / speed controls, motion blur, click sounds, crop to 16:9 / 4:3 / 1:1 / 9:16 |
| OpenScreen | [siddharthvaddem/openscreen](https://github.com/siddharthvaddem/openscreen) (new find) | MIT | 39,926 | Zoom depth presets, zoom transition windows, chained pans, dwell-based zoom suggestions, cursor smoothing and motion blur, mosaic blur regions, annotations |
| Screenize | [syi0808/screenize](https://github.com/syi0808/screenize) (new find) | Apache-2.0 | 616 | Spring-damper camera constants, dead-zone camera targeting, max zoom |
| Playwright | microsoft/playwright 1.59-1.64 release notes | Apache-2.0 | n/a | `showActions` cursor/highlight, `showChapter` title card. Reference only, since Playwright is excluded |
| Perplexity | User-pasted Perplexity report (transcript, 2026-10-11) | n/a | n/a | Scene schema (feature, narration, start screen, screen region, actions, visible proof, duration), selection criteria, planner outputs (persona/value mapping, prerequisites, fallback state) |

Repos named by Perplexity but not mined further (low value or no access): wetlink/demo-video-skill, obeskay/skillcast, teniolona/claude-code-skills, manalkaff/remotion-prompts, AlemTuzlak/skills, Avatechdir/video-walkthrough-skill (MIT, per-step subtitles and click highlighting, not read in depth), isaaclins/demo-video-skill (licence NOASSERTION, not read). CapSoftware/Cap (23k stars) has a non-standard licence and was not read.

Does the Perplexity report cover narration craft? Only partly. It gives the scene record (feature, narration, start screen, screen region, actions, visible proof, duration) and says a planner should output persona and business-value mapping, the narration script, the expected visible result, timing and transitions. It has **no** writing rules (structure, pace, person, banned words). Those come from the repos above; see the Narration playbook.

---

## Feature table by stage

### 1. Plan

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| One-batch intake | Ask all missing facts at once: URL, login method, what to show, fixture policy, output. Skip anything already known | suraj, Ultrademo (two question rounds), shotcraft (agent pre-fills, asks 1-3 questions) | High | Yes. Prompt-only, answers saved to `demo/project.json` |
| Per-project capture setup | Choose the monitor, F11 on or off, and the browser zoom %. Saved once and reused by every take | GOAL.md (user requirement) | High | Yes. `System.Windows.Forms.Screen`, `SendInput` F11 and Ctrl+/-, stored in JSON |
| Feature discovery from the live app | Walk navigation and pages, learn the app's own labels, take screenshots | Ultrademo, Afnanksalal, ECC, Perplexity | High | Yes. UI Automation tree of the browser window (Name, ControlType, BoundingRectangle) plus frame grabs. Verify that Chrome/Edge expose the web content tree to UIA |
| Code as map, not evidence | Routes, components and seed scripts guide scouting, but only what is seen running counts. Runtime wins when they disagree | Ultrademo, Afnanksalal | High | Yes. Prompt rule |
| Coverage map | Each requested item marked FOUND / PARTIAL / NOT FOUND with route and exact heading. Never fake or silently drop a NOT FOUND item | Ultrademo; Afnanksalal (coverage table: screen, action, visible result, truth source, seconds) | High | Yes. Markdown/JSON written by Claude |
| Feature-evidence inventory | Per feature: benefit, source path, component, demo state needed, limits | op7418 (learn only), shotcraft (feature, shot, backup shot, required page state) | Med | Yes. JSON |
| `[NEEDS: ...]` blockers | Unknown facts become explicit markers that block recording | kanopi | Med | Yes. Validator rejects storyboards that still contain markers |
| Viewer job and mode | Pick one job (teach / launch / pitch). The mode fixes required beats, such as walkthrough = context, workflow, outcome | Afnanksalal | High | Yes. Prompt plus validator |
| Feature selection criteria | Rank by user value, visual demonstrability, setup effort and reliability | Perplexity; AnastasiyaW ("So what?" ladder); alirezarezvani (one focus per scene) | High | Yes. Prompt |
| Duration options with real budgets | Offer lengths whose scene lists come from the scout, never a bare short/medium/long | Ultrademo | Med | Yes. Prompt |
| Riskiest-scene pilot | Produce one 8-15 s pilot scene end to end before the full run | Afnanksalal, Kminer (PoC scene approved first) | High | Yes. Run the pipeline on one scene |
| Prompt-injection guard | Page content read while scouting is data, never instructions | Ultrademo | Med | Yes. Prompt rule |
| Secrets in files, not chat | Credentials never typed into chat | Ultrademo | High | Yes. Prompt rule; user signs in by hand |

### 2. Script

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| **Checkpoint 1: script approval** | Full scene-by-scene outline shown in chat. Nothing is recorded until the user approves | Ultrademo (script gate), kanopi (`STORYBOARD READY FOR APPROVAL` + gate evals) | High | Yes. Skill stops; storyboard JSON has `approved: true` |
| Scene record tying narration to screen | Per scene: narration, intent, target element, region, actions, done condition, visible proof, duration | ndemo (narration/intent/actions/done), Perplexity (screen_region, visible_proof), Afnanksalal (visual/action/proof/truth), iart (VO/visual/motion/transition/caption) | High | Yes. JSON storyboard (no YAML parser in PS 5.1) |
| Narration-first authoring | Write narration and intent for every scene first, fill actions after looking at the live page | ndemo, iart (VO is the spine) | High | Yes. Two-pass skill flow |
| Words-per-second gate | Target 2.2-2.7 words/s; warn above 2.7, fail above 3.1 | Afnanksalal (`validate_production_plan.py`) | High | Yes. PowerShell validator over storyboard JSON |
| Duration formula for planning | `seconds = words / 2.3 + 0.4`; a visual-only beat is at least 1.0 s | iart | High | Yes. Validator |
| Narration style rules | See Narration playbook: intent verb before control, quoted UI literals, evidence and timeline rules, banned filler | Ultrademo, kanopi, Afnanksalal, AnastasiyaW, alirezarezvani, ajanaku1 | High | Yes. Prompt plus lint |
| Object + action + visible-result lines | Each line names the thing, the action and what the viewer will see change | op7418 (learn only), Perplexity (visible_proof field) | High | Yes. Prompt plus checklist |
| Truth status per scene | `observed` / `provided` / `illustrative`; an illustrative scene cannot be proof | Afnanksalal | Med | Yes. Validator |
| Claim ledger | Claim, source, approved wording, scene, risk note | Afnanksalal | Low | Yes. JSON |
| Script critique pass | Score on six dimensions and look for named flat patterns (feature parade, generic superlatives, uniform energy) | AnastasiyaW | Med | Yes. Separate Claude pass |
| Transition anchored to a word | The storyboard says which word a cut or zoom lands on | iart, ajanaku1 (element appears when a keyword is spoken) | High | Yes. Aria WordBoundary gives word offsets |

### 3. Rehearse

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Accessibility-tree targets | Targets by role + name instead of CSS selectors | ndemo, Afnanksalal (role/name locators) | High | Yes. UIA `FindFirst` with ControlType + Name conditions. Verify depth and speed inside browser content |
| Field map per page | Dump visible interactive elements before scripting | ECC | Med | Yes. UIA tree walk filtered to Button/Edit/ComboBox/Hyperlink |
| Per-segment rehearsal | Run one segment, re-read the page, then author the next | ndemo, ECC (rehearse gate exits non-zero on a missing element) | High | Yes. Rehearse skill runs one scene with no recording |
| Done conditions | Every page-changing action waits for a condition (element visible, text present, URL) | ndemo, Ultrademo ("never a fixed pause for a variable event") | High | Yes. UIA polling for element/property; window title for URL. Verify |
| Hidden duplicate targets | Apps render hidden copies of buttons; choose the visible one | Ultrademo, tooling report | Med | Yes. UIA `IsOffscreen` + non-empty BoundingRectangle |
| Login handling | User signs in once by hand; skill pauses for it; profiles used one run at a time | Ultrademo (`npm run login` persistent profile), tooling report, suraj (test account or saved session) | High | Yes. Real browser keeps the session; skill pauses at a checkpoint and confirms the logged-in landmark via UIA |
| State reset between takes | A reset recipe runs before every take so each take starts identical | Ultrademo (`reset.mjs`), ndemo (fixtures copied back, idempotent setup steps), suraj (create fixture in `try`, delete in `finally`) | High | Partial. App-specific: the skill writes a PowerShell reset step (API call via `Invoke-RestMethod`, file copy, or UI steps). Needs the user's approval for data changes |
| Deterministic seeded data | Demo runs on known seed records, never on data the user cares about | suraj, ndemo, Ultrademo (seed scripts mined from code) | High | Partial. Same as reset; seed via app API or UI script |
| Persistent driving session | Browser stays open between rehearsal calls | ndemo (daemon) | Med | Yes. Real browser window is already persistent; skill reattaches by window handle |

### 4. Record

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Voice-first timing | Synthesise narration first, measure each line, and hold the scene until the audio ends | gist (learn only), Ultrademo, ajanaku1, tooling report | High | Yes. Aria duration from MP3 bytes; drive waits from it (GOAL decision) |
| Timing formula | Scene = max(audio + 0.7 s, clip / rate + 0.4 s), clip sped up at most 1.3x | Ultrademo; ajanaku1 (audio + 0.5 s); kanopi (~1 s lead and tail) | High | Yes. Arithmetic in the assembler |
| Deterministic frame capture | Capture frames at a fixed grid so playback is smooth regardless of capture speed | suraj (one step per frame), ndemo (hold last frame, force constant frame rate) | High | Yes. `System.Drawing` CopyFromScreen (15 fps proven) or DXGI duplication for higher rates; timestamps logged per frame |
| DPI-aware full-resolution capture | Capture physical pixels, not logical | GOAL.md pending item; suraj ("zoom headroom = capture resolution") | High | Yes. `SetProcessDpiAwarenessContext(-4)` already in DemoKit |
| Per-scene clips and retakes | Each scene recorded separately; a failed scene is re-shot alone | ndemo (per segment), Ultrademo (fix at the cheapest layer, re-run triage) | High | Yes. One frame folder per scene id |
| Cut spinner waits | Mark wait windows and cut or speed them | Ultrademo (`skipWhile`), Kminer (6-9x speed-up window), suraj (speed regions with 0.6 s eased ramps), screenstudio-alt (idle speed-up) | High | Yes. Drop or thin frames in the marked window; ramp the rate at both ends |
| Cursor event track | Log every move and click with time and position for the renderer | Ultrademo, suraj, screenstudio-alt, OpenScreen | High | Yes. Driver logs `{t,type,x,y}` as it calls `SendInput` |
| Eased real cursor motion | Mouse travels on an eased path, 350-900 ms scaled by distance | Ultrademo; retake (`mouse move` eases); Playwright 1.64 | High | Yes. `Win32Input.Glide` (smoothstep) |
| Typing realism | Type character by character at a readable pace; paraphrase long strings in narration | Ultrademo (60 ms per char), ECC (25-40 ms per char), suraj (one char every few frames) | Med | Yes. `TypeText` Unicode SendInput with small random jitter (proposed) |
| Park the cursor | Move the cursor to neutral ground after a scene so no tooltip is frozen on screen | tooling report (from Ultrademo) | Med | Yes. Glide to a safe point before the scene ends |
| Honest failure | Never replace a failed capture with a mock or placeholder; report deltas against the approved script | Ultrademo | High | Yes. Prompt rule plus run log |

### 5. Voice

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Neural voice with word timings | Natural voice plus per-word offsets for captions and cues | Ultrademo (ElevenLabs), ajanaku1 (edge-tts VTT), tooling report | High | Yes. Aria via raw websocket (working); built-in `SpeechSynthesizer` with word boundaries as fallback |
| TTS cache | Hash of engine, voice, settings and text; only changed lines are re-synthesised | Ultrademo, ndemo | High | Yes. SHA-256 via .NET; `.sig` file beside the MP3 |
| Pronunciation fixes | Respell words the voice mangles ("claude dot A I"); keep pronunciation notes | kanopi, Afnanksalal | High | Partial. Respelling always works. SSML `<sub>`, `<phoneme>` and `<break>` work with the built-in `SpeechSynthesizer` (SSML input). Support on the Edge read-aloud endpoint is unverified: test each tag |
| Rate control without distortion | Never speed narration more than about 6%; rewrite instead | Afnanksalal | Med | Yes. SSML `prosody rate` limited to plus or minus 6% by the validator |
| Consistent voice across segments | Same voice, settings and sample rate for every line | Afnanksalal | Med | Yes. One voice config in `project.json` |
| Voice fallback | Use the built-in voices if the Aria endpoint returns 403 | GOAL.md, tooling report (endpoint breaks when its token rotates) | High | Yes. Already in `Speak.ps1` |

### 6. Visual polish

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Synthetic smooth cursor | Draw the cursor at render time from the event track, so it stays sharp at any zoom and can be smoothed | Ultrademo, suraj, screenstudio-alt, OpenScreen (smoothing 0.67, motion blur 0.35), Screenize (spring cursor) | High | Yes. CopyFromScreen excludes the cursor; draw an arrow bitmap at the logged position (hotspot aligned) |
| Click effects | Ripple or pulse ring at each click | Ultrademo (ripple over 14 frames), suraj (pulse ring), OpenScreen (click bounce), retake | High | Yes. `System.Drawing` ellipse with fading alpha |
| Click sound | Recorded click sound on each click | screenstudio-alt (CC0 sample), retake | Low | Partial. Needs a licensed sample file; mix as a short `BackgroundAudioTrack` with `Delay` |
| Zoom / push-in | Ease into a region, hold, ease back out | Ultrademo (Ken Burns 1.0 to 1.35), suraj, screenstudio-alt, retake, OpenScreen, Screenize, Afnanksalal, Kminer (planned zoom point) | High | Yes. Crop and scale source frames with `HighQualityBicubic` (GOAL decision). See Emphasis effects spec |
| Highlight / spotlight / underline | Box, marker sweep or dimmed surroundings on a region while it is named | shotcraft (spotlight, marker underline cards), Playwright (element highlight), explainer (focus + dim the rest) | High | Yes. Draw over frames; target rect from UIA BoundingRectangle |
| Magnifier balloon | Magnified bubble of a small region popping out over the frame | None found (proposed) | Med | Yes. Clip path + DrawImage of the scaled region |
| Keystroke overlays | Keycap chips for shortcuts and keys the viewer can't otherwise see | suraj (keycaps about 1 s), screenstudio-alt (chips), Ultrademo (`inject` keycap HUD), OpenScreen | Med | Yes. The driver knows every chord it sends; draw keycaps with `System.Drawing` |
| Captions burned in | Bottom captions, one or two lines | Ultrademo (themes outline/pill/bar), AnastasiyaW (standards), iart, Afnanksalal | High | Yes. PNG overlays via `MediaOverlay` (spiked), or drawn into frames |
| Word-highlight (karaoke) captions | Current word highlighted as it is spoken | Ultrademo (dim/pill/wipe modes; needs word timings) | Med | Yes. Aria word offsets; redraw the caption per word |
| Quoted UI literals tinted | Words in double quotes shown in a literal colour, quotes stripped | Ultrademo | Low | Yes. Caption renderer rule |
| Caption overlap avoidance | Captions and callouts never cover the target; one callout at a time with a gap | screenstudio-alt (gap about 0.3 s, at least 1 s visible), Afnanksalal (safe areas 6% bottom, 5% sides) | High | Yes. Rect intersection between caption box and UIA target rect; move caption to top if they overlap |
| Title and outro cards | Intro card with product and agenda; outro with value line and URL | Ultrademo (narrated slides, 0.75 s lead-in), ndemo (title card), Playwright (`showChapter`) | High | Yes. `MediaClip.CreateFromColor` plus PNG overlay, or a rendered PNG clip |
| Brand colours and fonts | Accent colour, caption theme, font from the brand kit | Ultrademo (`brand` hex), suraj (background gradient), Afnanksalal (visual system: one accent, two fonts) | Med | Yes. `project.json` brand block; `PrivateFontCollection` loads a brand TTF file |
| Framed-window look | Gradient background, padding, rounded corners, shadow around the app | suraj, retake, OpenScreen | Med | Yes. `GraphicsPath` rounded rect, `LinearGradientBrush`, soft shadow by layered alpha |
| Crop browser chrome | Hide tabs and address bar; keep edges clean | Afnanksalal (never half a navbar), retake (crop) | High | Yes. F11 at capture, or fixed crop rect |
| Privacy redaction | Blur or pixelate sensitive values on every frame | Ultrademo (live DOM blur + frame check for secrets), OpenScreen (mosaic blur regions), tooling report | High | Partial. Pixelate rects from UIA elements whose Name/Value matches patterns (email, key, token) or user-listed regions. Elements without UIA exposure need manual rects |
| Motion blur | Blur during fast camera or cursor moves | OpenScreen, retake, screenstudio-alt | Low | Partial. Average sub-frames; costly |

### 7. Assembly

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Scene clips + narration track | Concatenate scenes; place each narration file at its scene start | All pipelines | High | Yes. `MediaComposition` clips + `BackgroundAudioTrack` with `Delay` (spiked) |
| Transitions | Hard cuts inside a workflow; 150-350 ms dissolve or dip only between sections; fade from and to black at start and end | Afnanksalal, Ultrademo (12-frame fades top and tail, hard cuts between scenes), ajanaku1 (0.5 s crossfade) | High | Yes. No built-in transitions in MediaComposition: blend frames with `System.Drawing` (alpha) before encoding |
| Music bed with ducking | Licensed music under narration, ducked 12-20 dB under speech, 2 s fade-in, 3 s fade-out | Afnanksalal (side-chain duck: attack 20 ms, release 320 ms; provenance note), ajanaku1 (15% under VO, 40% between scenes), AnastasiyaW (music -32 to -24 dB under VO; VO -12 to -10 dB), op7418 (learn only) | Med | Partial. Simple version: split the music into several `BackgroundAudioTrack`s with trims and per-segment `Volume` (stepped ducking). Smooth version: decode to PCM with `MediaTranscoder`, apply a gain envelope from the word timings in C#, write one WAV. Verify |
| Loudness normalisation | Even narration level across lines | AnastasiyaW (loudnorm -16 LUFS), Afnanksalal | Med | Partial. RMS/peak gain in C# on PCM; true LUFS needs a K-weighting filter (doable in C#) |
| Chapters | Section markers for long videos | Afnanksalal (dip or dissolve separates chapters), Playwright (`showChapter` card) | Med | Partial. MediaComposition writes no MP4 chapter atoms: deliver a timestamp list (YouTube description format) plus chapter title cards (proposed) |
| Multiple aspect ratios | 16:9 master plus 9:16 and 1:1 variants that follow the action | Ultrademo (`--vertical` crop anchored on mean click X, GIF), screenstudio-alt (vertical follows the action), Afnanksalal (recompose dense UI, don't shrink), AnastasiyaW, retake | Med | Yes. Re-crop frames per aspect; `MediaEncodingProfile` with custom width and height |
| Stems export | Clean video, narration file and SRT for editors | Ultrademo (`--stems`) | Low | Yes. Render without overlays; copy audio; write SRT |
| Archive previous renders | Keep the last cut for before/after comparison | Ultrademo | Low | Yes. Move to `out/archive/` |
| Encode settings | H.264, constant frame rate, AAC 48 kHz, 30 fps | Afnanksalal | Med | Yes. `MediaEncodingProfile.CreateMp4(HD1080p)` |

### 8. Review & QA

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| **Checkpoint 2: review the cut** | First render gets scene-level review; each note fixed at the cheapest layer (text edit = re-voice + re-render; UI change = re-shoot) | Ultrademo (review gate), ndemo (feedback-to-action table) | High | Yes. Skill stops; fix routing table in the skill |
| Look at frames | Extract a frame at each scene's midpoint and actually inspect it | Ultrademo, tooling report | High | Yes. `MediaComposition.GetThumbnailAsync` on the rendered file, then Claude reads the PNGs |
| Contact sheet | Grid of sampled frames to judge pacing and framing at a glance | Afnanksalal (`make_contact_sheet.py`), Kminer (3x3 montage), shotcraft | Med | Yes. `System.Drawing` grid |
| Blank / loading frame check | Flag frames that are blank, spinners or error pages | Ultrademo (right content), ECC, tooling report (`freezedetect`) | High | Yes. Pixel variance and frame-difference metrics with `LockBits` |
| Dead-air and pacing check | Flag frozen video, silence gaps, scenes where speech runs long past the action | tooling report (freezedetect), kanopi (252 s of frozen video from `networkidle`), ajanaku1 (no dead air), screenstudio-alt (idle detection) | High | Yes. Frame diff for frozen spans, word-timing gaps for silence |
| Cursor visibility check | Cursor visible where an action happens; not parked on a tooltip | Ultrademo (park cursor) | Med | Yes. The cursor is drawn by us; check its rect lies inside the frame and the zoom window |
| Caption overlap check | Caption box does not cover the named target or another callout | screenstudio-alt | Med | Yes. Rect intersection per frame |
| Data legibility | Any value named in narration is readable in frame at 1080p | Ultrademo | High | Partial. Check the zoomed target's text height in output pixels (UIA rect x zoom); Claude confirms visually |
| Secrets check | No visible secrets in sampled frames | Ultrademo | High | Partial. Claude inspects frames; pattern check on UIA Names |
| Independent reviewer | A clean-context reviewer critiques the cut before delivery | shotcraft, screenstudio-alt (sends the MP4 to a video model) | Med | Partial. A fresh Claude subagent can review frames and contact sheets; it cannot watch motion |
| Keycap claim check | After a shortcut keycap, confirm the app actually reacted | suraj | Low | Yes. Frame diff after the keypress |

### 9. Delivery

| Feature | What it does | Source(s) | Value | Feasible with built-ins? |
|---|---|---|---|---|
| Captions sidecar (SRT) | SRT built from word timings, not character counts | Ultrademo, ndemo (char-proportional, avoid), tooling report | High | Yes. Write SRT from Aria word offsets |
| Thumbnail / poster frame | Representative frame with title | Afnanksalal (poster frame or thumbnail in the delivery list), shotcraft (poster extraction) | Med | Yes. `GetThumbnailAsync` + `System.Drawing` title overlay |
| Delivery summary | Paths, duration, deltas against the approved script, known limitations | Ultrademo, Afnanksalal (validation output, limitations) | Med | Yes |
| Reproducibility kit | Keep raw frames, plan, caption timings, music provenance until accepted | Afnanksalal | Med | Yes. Project folder layout |
| No tool watermark | Never mention the tool or "AI" in the user's video unless asked | Ultrademo | High | Yes. Prompt rule plus lint for "AI", "Claude", tool name in narration |

---

## Narration playbook

Rules an AI can apply while writing and then self-check. Each rule names its source. Learn-only sources are paraphrased.

### A. Structure

1. **Cold open (5-10 s, over the title card).** Product name, who it's for and the pain it removes, then a one-line agenda ("I'll show you X, then Y"). (Ultrademo)
2. **Orient, then act.** Before the first click, one beat naming where we are ("this is the dashboard; invoices live in the sidebar"). (Ultrademo)
3. **Feature walk-through as answers to the opening pain.** Each feature scene shows the outcome, not just the control. (ajanaku1: hook, problem, turn, journey, resolution; alirezarezvani: hook, problem, magic moment, proof, invite)
4. **Time goes to state changes, not navigation.** Opening and closing together take about 15 s of a 5-minute video; the rest is split by importance, and the most important moment gets the most time. (Afnanksalal; AnastasiyaW)
5. **Runtime shares for short pieces:** problem about 20%, solution about 15%, how about 45% (1-3 steps), payoff about 20%. (iart)
6. **Value close on the outro.** End on the strongest proof frame, recap in one line, then the user's own tagline and call to action. Never the tool's name. (Ultrademo)
7. **Mode fixes required beats.** Walkthrough must have context, workflow and outcome scenes. (Afnanksalal)

### B. Line rules

1. **Benefit before feature.** "Find any invoice in seconds", not "Search functionality". Ask "so what?" until you reach the real value; most products have 3-4 real values under many features. (jezweb; AnastasiyaW; Kminer: a caption is one value sentence, not a feature name)
2. **Say what is seen.** Every claim in a scene is visible in that scene. Results come after the action lands, never before. A value spoken aloud (price, count, status) must be readable on screen. (Ultrademo evidence, timeline and legibility rules)
3. **Object + action + visible result.** Each step line names the thing, what we do to it, and what changes. Self-test: cover the screen and read the line to someone new; if they would ask "what? where? what happened?", rewrite. (op7418, learn only)
4. **Intent verb, then the control.** "Let's create a new company: I'll click the button called "New Company"." Not "First, a new company" and not a bare label. (Ultrademo)
5. **Name UI elements by their exact label, in double quotes, with a signpost noun** ("the "Status" column", "the button called "Save""). Quote only on-screen literals. (Ultrademo)
6. **Don't read the UI aloud.** Add what the picture can't say (why it matters, what happens next); paraphrase long typed text ("we give it a short description"); captions should not repeat visible headings word for word. (Leihyn, learn only; Ultrademo; Afnanksalal)
7. **One idea per sentence.** If a scene needs "and", it is probably two scenes. Every narration line maps to one visual intent. (kanopi; alirezarezvani; iart)
8. **Person and tense.** Default: first person plural or singular with second-person address ("let's", "you'll see"), active voice. Tutorials may use second-person imperative ("Open Settings, then click Billing"). Present tense throughout (our rule; sources use it in their examples). (Ultrademo voices; kanopi; ajanaku1 "use you and your", avoid passive)
9. **Vary sentence length; rotate connectors** ("now let's", "next", "here's where") about once per scene, never the same one twice in a row. One genuine opinion or reaction per video. (Ultrademo)
10. **Concrete over vague.** "In three seconds", not "quickly"; real nouns and verbs. (ajanaku1; Afnanksalal)

### C. Banned filler and AI tells

- Openers: "Welcome to...", "This is a demo of...", "In this video we will...". (ajanaku1)
- Hype words: revolutionary, seamless, leverage, unlock, powerful, amazing, super easy, game-changing, cutting-edge, effortless. (AnastasiyaW kill list; kanopi; Afnanksalal example) Extend per brand.
- Tidy three-part parallel lists, template bookends, the same connector every scene. (Ultrademo)
- Feature lists without context ("we also support X, Y and Z"). (ajanaku1)
- Any mention of the tool, AI or how the video was made. (Ultrademo)
- Writing "pause" in the text. (kanopi; pauses are produced by timing or SSML instead)
- For TTS: no emojis; avoid em/en dashes (they read badly in TTS and captions); spell out what the voice mangles. (kanopi) Note the conflict: ajanaku1 recommends dashes and ellipses for pacing. We use an SSML `<break>` instead.

### D. Pace and length

| Item | Rule | Source |
|---|---|---|
| Speaking rate | 2.2-2.7 words/s; warn above 2.7, rewrite above 3.1 | Afnanksalal |
| Technical lines | about 2.0 words/s | iart |
| Scene seconds | words / 2.3 + 0.4 | iart |
| Word budgets | 30 s about 69 words, 60 s about 138, 90 s about 207 | iart |
| Fill per scene | 3-4 s: 8-12 words; 5-6 s: 15-22 words; 7-8 s: 22-30 words (70-80% fill) | alirezarezvani |
| Feature scene | 12-16 s per feature in a story-led video | ajanaku1 |
| Core vs small change | core capability 7-12 s, small tweak 2-4 s | op7418 (learn only) |
| On-screen text | at most 7 words; reading speed about 2.5 words/s | AnastasiyaW |
| Pause before a reveal | 0.3-0.6 s `<break>` before the payoff word, at most once or twice per scene | (proposed; supports Ultrademo's "payoff after the action lands") |
| Lead and tail | about 0.5-1.0 s silence before and after each scene's line | kanopi (~1 s), Ultrademo (+0.7 s hold), ajanaku1 (+0.5 s) |
| Speed change | never more than about 6% faster or slower | Afnanksalal |

### E. Scene-script template (JSON storyboard)

```json
{
  "id": "s04-filter-high-risk",
  "beat": "workflow",
  "feature": "Risk filter",
  "value": "Reviewers start with the riskiest exceptions",
  "truth": "observed",
  "startScreen": "Exception worklist",
  "target": { "controlType": "Button", "name": "High risk" },
  "region": "Risk column and first three rows",
  "intent": "filter to high-risk exceptions",
  "actions": [
    { "type": "click", "target": { "controlType": "Button", "name": "High risk" },
      "done": { "visible": { "controlType": "Text", "name": "3 results" } } }
  ],
  "narration": "Let's cut the list down to what matters. I'll click \"High risk\", and the three riskiest exceptions jump to the top.",
  "cues": [
    { "word": "High", "effect": "highlight", "target": "button" },
    { "word": "three", "effect": "zoom", "region": "first three rows", "scale": 1.4 }
  ],
  "visibleProof": "Filtered list showing three highlighted rows",
  "caption": "Filter to high-risk exceptions",
  "estSeconds": 9.5
}
```

### F. Self-check (run per scene, then for the whole script)

Per scene:
- [ ] Words/s within 2.2-2.7 for the estimated duration; never above 3.1.
- [ ] Line names an object, an action and a visible result; passes the cover-the-screen test.
- [ ] Every claim and every spoken value is in `visibleProof` and will be legible.
- [ ] Results are spoken after the action, not before.
- [ ] UI labels quoted exactly as UIA reports them.
- [ ] Not reading the screen aloud; adds why or what's next.
- [ ] One idea; no "and" joining two actions that deserve two scenes.
- [ ] No banned words, no dashes, no emojis, no "pause".
- [ ] Hard-to-say terms respelled or given an SSML fix.
- [ ] Each cue word exists in the narration exactly once.

Whole script:
- [ ] Cold open, orientation beat, feature scenes, value close and call to action all present.
- [ ] Required beats for the chosen mode present.
- [ ] Connectors varied; sentence lengths varied; one opinion or reaction present.
- [ ] Total duration within the agreed budget; most time on the most important feature.
- [ ] No mention of the tool, Claude or AI.
- [ ] Every NOT FOUND item in the coverage map is either cut with the user's agreement or flagged, never faked.

---

## Emphasis effects spec

Every captured frame is post-processed with `System.Drawing`, so all effects below are frame compositing: compute a camera (centre x, centre y, scale) and an overlay list for each output frame, then `DrawImage(source, destRect, srcRect)` with `InterpolationMode.HighQualityBicubic`, then draw overlays mapped through the same camera transform. Targets come from UIA `BoundingRectangle` captured during recording (per-frame or per-scene), which plays the role shotcraft's `layout.json` bounding boxes play.

### What the sources do

| Source | Effect | Timing / parameters seen |
|---|---|---|
| Ultrademo | Ken Burns push-in on stills toward a focus point | 1.0 to 1.35 (default) between 18% and 62% of the scene, ease in-out cubic; cursor travels 12-42% of the scene; click ripple at 50% over 14 frames. No zoom on clips |
| suraj | Whole-window camera push-in, eased by EMA | Hold zoom about 1.5-1.9x on a working region, cap 1.75 (`fit_zoom hi`); EMA 0.11 (zoom) / 0.13 (pan) per frame at 60 fps; let the camera settle about 20 frames before the action; one zoom per shot; end with zoom out to 1.0 and a linger; camera decoupled from cursor |
| screenstudio-alt | Auto-zoom on click clusters, two-keyframe pans | Smootherstep ease-in-out by default (Smooth / Snappy / Linear options); spring renderer with tunable frequency and damping; callouts at least 1 s, about 0.3 s apart, never overlapping, placed clear of the target, leading or coinciding with the moment |
| retake | Auto zooms from clicks | Lead-in, hold and speed sliders; motion blur on camera moves |
| OpenScreen (MIT) | Zoom regions with spring smoothing, chained pans | Depth presets 1.25 / 1.5 / 1.8 / 2.2 / 3.5 / 5.0; zoom-out transition about 1.0 s, zoom-in window 1.5x that (about 1.5 s) starting 0.5 s before the region; regions closer than 1.5 s are joined by a 1.0 s pan instead of out-and-in; auto suggestions from cursor dwell of 450-2600 ms, spaced at least 1.8 s |
| Screenize (Apache-2.0) | Spring-damper camera | Position spring damping 0.90, response 0.35 s; zoom spring damping 0.90, response 0.55 s; max zoom 2.8; dead zone 75% of the view (60% while typing) |
| Afnanksalal | Interface zoom and pan rules | Normal emphasis 1.08-1.25x; deeper only for one clear target with a safe exit; ease in and out; hold until the result is understood; establish the full screen before the first deep crop; let the action finish before moving away; never leave half a navbar in frame; one dominant move per scene |
| shotcraft (Apache-2.0) | Crash zoom, spotlight, marker underline | Crash zoom: 6-11 frame move, hold at least 30 frames wide before and 45 frames on the close-up after. Marker underline: starts 4-8 frames after the text settles, drawn left to right in 8-12 frames, hugging the text baseline. Spotlight card: page darkened to about 6-14% brightness outside the light (promo style) |
| explainer (iart) | Focus + context | Highlight the active element and dim the rest; reveal in order |
| Playwright 1.64 | Element highlight while acting | Built-in highlight box and action title (reference only) |
| none found | Magnifier balloon | No repo seen implements a magnified call-out bubble; parameters below are proposed |

### Spec for our renderer

All times are anchored to Aria word offsets. `cueStart` = start of the cue word; `phraseEnd` = end of the last word of the phrase the effect belongs to.

| Effect | In | Hold | Out | Parameters | Rules |
|---|---|---|---|---|---|
| **Push-in zoom** | Start 0.6 s before `cueStart`, 0.6-0.9 s long, so the zoom lands as the word is spoken | Until `phraseEnd + 0.4 s`, minimum 1.5 s | 0.8-1.0 s back to 1.0 | Default scale 1.25-1.5; dense text up to 1.8; **hard cap 2.0** and never past the capture's pixel headroom (source crop must be at least output size) | Establish wide before the first zoom of a scene; target stays in a stable area of the frame; no camera moves during a drag or typing; return to 1.0 before the scene ends unless the next scene starts on the same region |
| **Pan between regions** | Replaces out-then-in when the next zoom target starts within 1.5 s | n/a | 0.8-1.0 s move | Same scale on both ends, or scale change at most 0.25 during the pan | Never pan and change scale by more than 0.25 at once; pan distance at most about 60% of frame width per second (proposed, motion comfort) |
| **Highlight box** | Draw-on 0.2-0.25 s at `cueStart` | Until `phraseEnd + 0.3 s`, minimum 1.0 s | Fade 0.2 s | 3-4 px stroke in brand accent, corner radius 6-8 px, 6-10 px padding around the UIA rect (proposed) | One highlight at a time; never cover the target's text |
| **Marker underline** | Starts at `cueStart`, drawn left to right over 0.27-0.4 s (8-12 frames at 30 fps) | Until `phraseEnd + 0.3 s` | Fade 0.2 s | 4-6 px brand colour at 70-85% opacity, 2-3 px under the text baseline | For a single word or short label only |
| **Spotlight (dim the rest)** | Fade the dim in over 0.3 s, starting 0.2 s before `cueStart` | Until `phraseEnd + 0.4 s`, minimum 1.2 s | Fade 0.3 s | Black overlay 40-55% opacity outside a rounded rect (radius 10-12 px, 12-16 px padding), 12-24 px feathered edge (proposed; walkthroughs need context, so much lighter than shotcraft's promo darkness) | At most one spotlight per scene; do not combine with a zoom deeper than 1.3 |
| **Magnifier balloon** | Pop in over 0.2 s (scale 0.85 to 1.0, overshoot at most 5%) at `cueStart` | Until `phraseEnd + 0.4 s`, minimum 1.5 s | Pop out 0.15 s | Magnification 1.6-2.0x of a small region (at most about 25% of frame width); rounded or circular bubble with 2 px border and soft shadow; optional thin leader line to the source; placed so it covers neither the source region nor the caption (all proposed) | Use for small text in an otherwise useful wide shot, instead of a deep zoom; not more than twice per video |
| **Return to normal view** | n/a | n/a | Every effect ends before the next scene's first cue; the scene's last 0.5 s is at scale 1.0 with no overlays (proposed) | | Prevents carried-over zoom when scenes are re-shot separately |

Easing and motion comfort:
- **Easing:** smootherstep (`6t^5 - 15t^4 + 10t^3`) or ease-in-out cubic for keyframed moves. Both are deterministic, so preview equals render. A critically damped spring (damping 0.9-1.0, response 0.35 s for position, 0.55 s for zoom, as in Screenize) is the alternative if moves are chained. No overshoot on UI zooms; overshoot (crash zoom) only for promo cuts.
- **Spacing:** at least 1.8 s between the end of one zoom and the start of the next unless it is a chained pan (OpenScreen's suggestion spacing).
- **Budget:** one dominant move per scene (Afnanksalal). No constant drift or "floating" (Afnanksalal's generic-AI-video list).
- **Sharpness:** capture at physical resolution and zoom from those pixels; never upscale past the source (suraj).
- **Cursor:** drawn after the camera transform at a constant on-screen size, so it does not balloon with the zoom.
- **Captions:** drawn in output space after the camera, never zoomed; they move to the top band if they would overlap a highlight, spotlight or balloon.

---

## Recommended build list

Ranked by value for a professional result and by fit with the built-in stack.

1. **Two human checkpoints:** script approval before any recording, cut review before delivery, with the fix-at-the-cheapest-layer routing table. (Ultrademo, kanopi)
2. **Coverage map + evidence rule:** scout the live app through UIA and frames; FOUND / PARTIAL / NOT FOUND; never fake. (Ultrademo, Afnanksalal)
3. **JSON storyboard schema with a validator:** narration, intent, UIA target, region, actions, done condition, visible proof, cue words; validator checks words/s (2.2-2.7, fail above 3.1), banned words, `[NEEDS:]` markers and cue words. (ndemo idea, Afnanksalal, iart, kanopi)
4. **Narration playbook as a prompt plus lint pass** (sections A-F above). (Ultrademo, kanopi, AnastasiyaW, op7418 idea)
5. **Voice-first timing with Aria word offsets and a TTS cache;** scene = max(audio + 0.7 s, action + 0.4 s). (Ultrademo, gist idea)
6. **Per-scene rehearsal and recording with done conditions,** so a single scene can be re-shot. (ndemo idea, ECC)
7. **State reset and seeded fixtures before every take,** plus a login checkpoint where the user signs in by hand. (Ultrademo, ndemo idea, suraj)
8. **Synthetic cursor from the event track,** with eased travel and click ripples. (Ultrademo, suraj, OpenScreen)
9. **Word-cued emphasis renderer:** push-in zoom, highlight box and spotlight first, using the spec above; pans and the magnifier balloon second. (suraj, OpenScreen, Screenize, shotcraft, Afnanksalal)
10. **Burned-in captions plus SRT from word timings,** with safe areas and overlap avoidance. (Ultrademo, AnastasiyaW, screenstudio-alt)
11. **Frame QA:** midpoint frames, contact sheet, blank/loading and frozen-frame detection, dead-air gaps, caption overlap, legibility of named values. (Ultrademo, Afnanksalal, tooling report)
12. **Spinner and wait compression** with eased speed ramps. (Ultrademo, Kminer, suraj)
13. **Title and outro cards in brand colours,** plus fades from and to black and short dissolves only between sections. (Ultrademo, ndemo, Afnanksalal)
14. **Privacy redaction:** pixelate UIA-matched sensitive fields and user-listed regions on every frame, with a secrets check on sampled frames. (Ultrademo, OpenScreen)
15. **Music bed with stepped ducking** (user-supplied licensed track; 12-20 dB under speech, 2 s in, 3 s out), upgraded to a smooth PCM gain envelope once a spike proves `MediaTranscoder` decoding. (Afnanksalal, ajanaku1, AnastasiyaW)

Next tier: keystroke keycaps, typing jitter, thumbnail, chapter list + chapter cards, 9:16 and 1:1 re-crops that follow the action, stems export, framed-window look, karaoke captions, loudness normalisation.

Skip or defer: motion blur, click sounds (asset licensing), video-model critique (no built-in video model; a fresh Claude reviewer on frames is the substitute).

Open risks to spike first: UIA visibility of web content in Chrome/Edge (targets, done conditions, redaction all depend on it); SSML tag support on the Aria endpoint; frame-to-video throughput for long videos (thousands of image clips in MediaComposition; `MediaStreamSource` with `MediaTranscoder` is the built-in alternative to test); PCM decoding of MP3 for ducking.
