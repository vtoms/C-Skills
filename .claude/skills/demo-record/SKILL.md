---
name: demo-record
description: Third stage of the demo-video chain. Rehearses the approved storyboard at real pace on the live app, fixes broken steps, then records each scene as its own take with the real cursor, screen capture and (optionally) the app's own sound. Re-records only stale or named scenes.
argument-hint: "[demo project folder] [scene ids to re-record]"
disable-model-invocation: true
---

# Demo record

Rehearse, then record one take per scene. Takes are kept; the manifest points each scene at its newest take.

Toolkit: `../demo-video/tools/` (relative to this skill's folder). Project folder: the first argument, else `demo/`. Needs an approved `storyboard.json` (run `/demo-script` first). Run each script as `powershell -NoProfile -ExecutionPolicy Bypass -File "<tools>\Record.ps1" -Dir "<project>" ...` with a timeout of at least the video length plus several minutes.

## Before each run
Tell the user: the browser will open on the chosen screen and the mouse and keyboard will move by themselves; please don't touch the PC until the run finishes; close notification pop-ups and anything that makes sound if `app_audio` is on. For `profile: dedicated`, make sure they have signed in to that browser window by hand; for `attach`, that the app's window is open.

## 1. Rehearse
`Record.ps1 -Dir <project> -Rehearse`. This drives every scene at real pace without capturing video. It still listens to system audio, so `wait_audio` works.
- A failed step stops the run and names the scene and target. Find the right element with `Scout.ps1 -Attach "<title*>" -OutDir <project>\scout-fix -Screens 1 -KeepOpen` (or rehearse with `-KeepBrowser` and scout the window it leaves open), fix the storyboard, rehearse again.
- Warnings like "landed 0.6s off its word" mean the step before it runs long: move the action to a later word or speed up the earlier step.
- Optional steps report "skipped": fine when the thing (a pop-up) did not appear.
Repeat until a full rehearsal passes.

## 2. Record
`Record.ps1 -Dir <project>` records every scene whose take is missing or stale (its narration, voice, steps or phrase targets changed). Use `-Scenes s02,s05` for specific scenes or `-All` for everything. When a later scene is recorded alone, the earlier scenes are replayed quickly off-camera first, so the app is in the right state.

Each take folder holds the frames, cursor and audio logs, page snapshots after every step, and `take.json` with the exact scene and settings used. A failed scene stops the run; scenes recorded before it are kept.

## 3. Check
- Read the run output: every scene recorded, no step landing more than about 0.4 s off its word.
- If something visibly went wrong (a pop-up mid-scene, a slow load), re-record just that scene with `-Scenes`.

Then continue with `/demo-edit`.
