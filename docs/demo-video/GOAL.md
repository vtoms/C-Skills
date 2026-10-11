# Goal: demo-video skill chain

**Goal.** Build a chain of skills that turns a web app into a professional, narrated demo video. AI does most of the work: it finds features, writes the narration, drives the app, and edits and assembles the video. A human steps in at a few checkpoints. The chain is built and tested until it works, autonomously.

Status key: ✅ built and tested · 🔧 in progress · ⏳ not started

## Requirements (as stated by the user)

### A. Scope and workflow
| # | Requirement | Status |
|---|---|---|
| A1 | **Full pipeline:** find the app's features → choose → write the narration and storyboard (each line tied to a screen, region and action) → rehearse → record → voice → captions, cursor and zoom → final MP4 | 🔧 |
| A2 | Each stage is its own skill, chained together; the user can stop after any stage | ⏳ |
| A3 | Ultrademo-level polish ("absolutely professional looking"), using all the research gathered | 🔧 |
| A4 | AI drives the narration and the video creation, with human input where it's needed (for example, approving the script and reviewing the cut) | 🔧 |
| A5 | Work autonomously: log the goal, stick to it, and keep building and testing the skills until they're finished | 🔧 |

### B. Target and driving
| # | Requirement | Status |
|---|---|---|
| B1 | Web apps in any browser, including ones started without a debug flag (so no Playwright or CDP); the real Windows cursor and keyboard are driven | ✅ |
| B2 | Elements are found through Windows UI Automation; no fragile pixel coordinates in scripts | ✅ |
| B3 | Playwright is dropped; built-in Windows features only (user's choice) | ✅ |
| B4 | **Hard restriction: no browser debugging or special launch flags, ever.** No Chrome DevTools Protocol, no `--remote-debugging-port`, no `--force-renderer-accessibility` or other automation switches, no Playwright, Selenium or WebDriver, no browser extensions. The user's machines run browsers without debug flags, so the skills must work on a normally launched Edge or Chrome window, including one the user opened themselves. Page content is reached only through Windows UI Automation: the page window is asked for its accessibility root, as Narrator does. | ✅ |

### C. Built-in only
| # | Requirement | Status |
|---|---|---|
| C1 | **No external libraries.** Use Windows built-in features: PowerShell 5.1, .NET Framework, WinRT, UI Automation, Win32, `System.Drawing`, DXGI, and the Windows media engine (MediaComposition) in place of ffmpeg | ✅ |
| C2 | **Voice:** Microsoft's Aria (en-US-AriaNeural) through the Edge read-aloud service, reached with a built-in client ("if it's from Microsoft, use it"); the built-in Windows voices are the fallback | ✅ |

### D. Per-project setup questions (asked every time and saved in `demo/project.json`)
| # | Requirement | Status |
|---|---|---|
| D1 | Which monitor to record (Windows can target a single screen) | ✅ (tooling) / ⏳ (skill question) |
| D2 | Whether to use F11 full screen | ✅ / ⏳ |
| D3 | The browser zoom % | ✅ / ⏳ |

### E. Narration
| # | Requirement | Status |
|---|---|---|
| E1 | Narration written the way professional software demos are; research this if the Perplexity material doesn't already cover it | 🔧 (research agent) |
| E2 | Narration is tied to on-screen action: actions land on their spoken word | ✅ |

### F. Post-production effects
| # | Requirement | Status |
|---|---|---|
| F1 | While a phrase is narrated, highlight that part of the screen or text for emphasis | 🔧 |
| F2 | "Ballooning": a magnified callout that pops out, plus zoom in → hold → zoom or pan out, then back to normal and on to the next point | 🔧 |
| F3 | Smooth, not jagged: eased motion, crossfades, no abrupt frame changes | 🔧 |

### G. Clip-based production
| # | Requirement | Status |
|---|---|---|
| G1 | Use Windows' media features to create clips | ✅ |
| G2 | Within a clip, hold a frame (pause) to stretch it so it lines up with the audio when needed | 🔧 |
| G3 | Within a clip, cut parts out so the audio matches, guided by how the whole video looks and flows | 🔧 |
| G4 | Make small clips separately, then stitch them together once everything is ready | 🔧 |
| G5 | Redo or update one small piece without re-producing the whole video | 🔧 |

### H. Traceability
| # | Requirement | Status |
|---|---|---|
| H1 | Every project logs everything it did, completely | 🔧 |
| H2 | Changes are traceable and reproducible | 🔧 |
| H3 | Earlier work can be referenced to recreate an updated version of one small clip in the bigger video | 🔧 |

### I. Quality process (this repo's standard)
| # | Requirement | Status |
|---|---|---|
| I1 | Research → build → test on a real app → independent adversarial checks → fix → independent regression check after every fix, until clean | ⏳ |
| I2 | Skill frontmatter (YAML) optimised so the skills are identified and work properly | ⏳ |
| I3 | Reuse existing work where it exists (reference points, not reinventing the wheel); forum searches can come later | 🔧 |

## Decisions taken

| Topic | Decision | Why |
|---|---|---|
| Driving | UI Automation finds elements; Win32 `SendInput` moves the real cursor with eased glides; clicks are timed to land on their spoken word | Works with any browser; no debug flag needed |
| Recording | DXGI Desktop Duplication (GDI as fallback), on a separate process, at 15–30 fps on the chosen monitor, with the cursor drawn in | GDI took about 100 ms a frame on a full-screen browser |
| Voice first | Narration is synthesised before recording; its word timings schedule the actions; each scene lasts max(narration + 0.7 s, last action + 0.4 s) | Removes drift (from Ultrademo and the record-demo-video gist) |
| Effects | Burned into frames with `System.Drawing`: zoom and pan crop, spotlight, highlight, marker, callout balloon, click ripple, captions | MediaComposition has no effects layer; we own every frame |
| Clips | One take and one clip per scene, each with content hashes; the final video is stitched from clips with crossfades | Requirements G4 and G5 |
| Traceability | Append-only `demo/log.jsonl`, `demo/manifest.json`, and per-take `take.json` holding copies of the scene and settings used | Requirements H1–H3 |
| Storyboard format | JSON | PowerShell has no built-in YAML parser |
| Invocation | All skills manual (`/name`) | They move the real mouse and record the screen |

Research behind these decisions is in `docs/research/demo-video/`.
