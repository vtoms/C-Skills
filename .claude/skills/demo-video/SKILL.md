---
name: demo-video
description: Makes a narrated, captioned demo video of a web app on Windows, end to end. AI plans the features, writes the narration and storyboard, drives the real browser with the real cursor, records, edits and assembles the MP4; the user approves the script and reviews the cut. Uses only Windows built-ins and works with browsers started without debug flags. Runs the chain demo-plan, demo-script, demo-record, demo-edit.
argument-hint: "[app URL or demo project folder]"
disable-model-invocation: true
---

# Demo video

Turns a web app into a professional demo video. This skill runs the whole chain and holds the two human checkpoints; each stage is also its own skill, so the user can stop after any of them or redo just one.

| Stage | Skill | Output |
|---|---|---|
| 0. Setup | this skill | `demo/project.json` |
| 1. Plan | `/demo-plan` | `demo/plan.md` (feature coverage map) |
| 2. Script | `/demo-script` | `demo/storyboard.json`, narration audio, **checkpoint 1: script approval** |
| 3. Record | `/demo-record` | one take per scene |
| 4. Edit and assemble | `/demo-edit` | one clip per scene, `demo/final/<name>-vNNN.mp4`, **checkpoint 2: review the cut** |

## Hard rules
- **Built-ins only.** The toolkit uses Windows PowerShell 5.1, .NET, WinRT media, UI Automation, Win32 input, DXGI and WASAPI, plus Microsoft's Aria voice. Install nothing; no ffmpeg, Playwright, pip or npm.
- **No browser debug or automation flags, ever.** No DevTools protocol, no `--remote-debugging-port`, no WebDriver, no extensions. Pages are read through Windows UI Automation, so it works on any normally started Edge or Chrome, including one the user opened (`profile: attach`).
- **The real mouse and keyboard move during rehearsal and recording.** Tell the user before each run and ask them not to touch the PC until it finishes.
- **Never type real credentials.** If the app needs a login, use `profile: dedicated` and ask the user to sign in by hand in that browser window once.
- **Outward-facing steps need the user's OK:** sending messages, submitting forms, purchases, deletions. Use test data only; never enter the user's personal data.

## Toolkit
The scripts are in `tools/` next to this file; every demo-* skill uses them. Run each as
`powershell -NoProfile -ExecutionPolicy Bypass -File "<tools>\<Script>.ps1" -Dir "<project folder>"`.
Schema of `project.json` and `storyboard.json`: `reference/storyboard.md`. Narration rules: `reference/narration.md`.

## 0. Setup
1. Project folder: the argument if it is a folder, else `demo/` in the current repo (ask if unsure). If `project.json` exists, show `manifest.json` status (which scenes have takes and clips, and the latest final) and ask where to resume.
2. **Ask the setup questions every time**, all at once, and record the answers (and a one-line `setup_answers` summary) in `project.json`:
   - **Which screen to record?** List screens with `Import-Module "<tools>\DemoKit.psm1"; Get-DemoMonitors` and show index, size and primary.
   - **Full screen (F11)?** Hides tabs and the address bar.
   - **Browser zoom %?** (100 unless the UI is small or dense.)
   - Browser (Edge or Chrome) and profile: private (clean, default), dedicated (needs a login), or attach (use a window they opened).
   - Does the app make sound worth keeping (a talking agent, alerts)? Sets `app_audio`.
   - Audience, target length, and what viewers should do afterwards (call to action).
   - Voice: Aria (default) or a built-in Windows voice; brand colours if they have them.
   If the user has said to work autonomously, choose sensible defaults, say which, and record that in `setup_answers`.
3. Write `project.json`.

## 1-4. Run the stages
Follow each stage's skill in order (read its SKILL.md in the sibling folder: `../demo-plan/SKILL.md` and so on). Stop at both checkpoints and wait for the user:
- **Checkpoint 1 (after /demo-script):** the script table and the planned length. Nothing is recorded until the user approves.
- **Checkpoint 2 (after /demo-edit):** the review stills and the video. Route each note to the cheapest fix (see demo-edit).

## Finish
Report: final video path and length, captions and chapters files, a share-size copy if needed (`Preview.ps1`), and how to change one scene later (edit the storyboard, then `/demo-record` for that scene if its narration or actions changed, `/demo-edit`). Everything done is logged in `log.jsonl`; versions are kept in `final/`.
