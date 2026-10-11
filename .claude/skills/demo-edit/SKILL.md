---
name: demo-edit
description: Final stage of the demo-video chain. Renders each scene's take into its own clip with zooms, highlights, callouts, cursor, captions and edits (cuts, freezes, pauses), reviews still frames, stitches the clips into a versioned final MP4 with crossfades, captions and chapters, and takes the user's review notes back to the cheapest fix.
argument-hint: "[demo project folder]"
disable-model-invocation: true
---

# Demo edit

Post-production on the recorded takes. Clips are rebuilt only when their inputs change, so fixing one scene never redoes the rest.

Toolkit: `../demo-video/tools/` (relative to this skill's folder). Project folder: the argument, else `demo/`. Needs takes (run `/demo-record` first). Effects and edits: `../demo-video/reference/storyboard.md`.

## 1. Render clips
`RenderClip.ps1 -Dir <project>` renders every scene whose clip is missing or out of date (`-Scenes s03` for one, `-Force` to rebuild). It warns when a scene's storyboard changed since its take (re-record), when an effect's target was off-screen (skipped), and when a cut would cut speech (skipped).

## 2. Review every clip yourself
For each clip, extract stills at the moments that matter: the scene's start, each effect's middle (from the clip's `.json`, field `effects`), each click, and the end:
`Still.ps1 -Video "<project>\<clip path from manifest.json>" -At "1.0,3.4,6.2" -OutDir <scratch dir> -Sheet` and read `sheet.jpg`.

Check:
- Effects sit on the right thing (a highlight on a covered or moved element is wrong) and are readable.
- Captions match the narration and never cover what is being shown.
- The cursor is where the narration says; clicks land when the word is spoken.
- No dead air (the clip JSON lists auto-trims; look for long static stretches), no loading spinners or pop-ups on screen.
- App audio (if used) is present: the clip JSON `audio_tracks` count includes it.

Fix with the cheapest change: effects, edits (`cut`, `freeze`, `pause`) and brand settings only need a re-render. Narration, actions or phrase targets need `/demo-record` for that scene.

## 3. Stitch
`Stitch.ps1 -Dir <project>` joins the current clips in storyboard order with title and outro cards, 0.4 s crossfades, optional music, merged captions (`.srt`) and chapters, as a new numbered version in `final/`. It refuses if any scene lacks an up-to-date clip. It reads the result back and saves one still per scene in `final/<name>-vNNN-review/`. Check those stills. For a share-size copy: `Preview.ps1 -Video <final mp4> -Width 1280`.

## 4. Checkpoint 2: the user's review
Give the user the final video path (and the preview), length, chapters, and the review stills. Route each note to the cheapest layer:

| Note | Fix | Then |
|---|---|---|
| Wording, pronunciation, pace | storyboard narration or `voice.lexicon` | `/demo-script` check, `/demo-record` that scene, render, stitch |
| Wrong or missing step, UI changed | storyboard actions | rehearse, record that scene, render, stitch |
| Effect, emphasis, zoom | storyboard effects | render, stitch |
| Too slow, a wait, a glitch | `edits` (cut, freeze, pause) | render, stitch |
| Colours, fonts, cards, music, captions | `project.json` | render, stitch |

Each round makes a new version; earlier versions stay in `final/` and everything is logged in `log.jsonl`.
