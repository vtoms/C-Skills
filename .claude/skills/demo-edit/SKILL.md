---
name: demo-edit
description: Final stage of the demo-video chain. Renders each scene's take into its own clip with zooms, highlights, callouts, cursor, captions and edits (cuts, freezes, pauses), reviews still frames, stitches the clips into a versioned final MP4 with crossfades, captions and chapters, and takes the user's review notes back to the cheapest fix.
argument-hint: "[demo project folder]"
disable-model-invocation: true
---

# Demo edit

Post-production on the recorded takes. A clip is rebuilt only when its inputs change, so fixing one scene never redoes the rest.

**Toolkit:** `../demo-video/tools/` relative to this skill's folder (`<tools>` below). Run scripts as `powershell -NoProfile -ExecutionPolicy Bypass -File "<tools>\<Script>.ps1" -Dir "<project>" ...`. Rendering takes about 2-5 s of work per second of video, so run it in the background or with the longest timeout.

**Project folder:** the argument, else `demo/`. It needs takes (run `/demo-record` first). Effects and edits are documented in `../demo-video/reference/storyboard.md`.

## 1. Render clips
`RenderClip.ps1` renders every scene whose clip is missing or out of date. Use `-Scenes s03` for one scene, or `-Force` to rebuild. Read its warnings:

| Warning | Meaning | Fix |
|---|---|---|
| "storyboard changed since this take" | the clip still uses the old take | `/demo-record` that scene |
| effect target "not found" or "off-screen" | the effect was skipped | take a name from the take's snapshots in `takes/<scene>/<take>/take.json`, give a `rect`, or move the effect to when the target is visible |
| zoom "can only reach 1.0x" | the target is too big to zoom | zoom on something smaller |
| click "outside the zoomed view" | the zoom crops the action | end the zoom earlier, or zoom on an area that includes the click |
| cut "overlaps narration" | the cut was skipped | move it to where nobody is speaking |

## 2. Review every clip yourself
Each clip has a JSON file next to it (the path is in `manifest.json`), with times already on the clip's own timeline:
- `effects[].clip_mid`
- `clicks`
- `captions[].start`

Take stills at those times, plus 0.5 s from each end:
`Still.ps1 -Video "<project>\<clip>" -At "0.5,3.4,6.2" -OutDir <scratch dir> -Sheet`, then read `sheet.jpg`.

Check:
- **Effects** sit on the right thing (a highlight on a covered or moved element is wrong) and are readable.
- **Captions** match the narration and don't cover what is being shown. If they do, set the scene's `caption_position`.
- **The cursor** is where the narration says, and clicks land as the word is spoken.
- **No dead air,** loading spinners or pop-ups on screen. The clip JSON lists automatic trims.
- **No personal data** on screen: emails, account names, tokens. Any value the narration speaks is readable.
- **App audio,** if used, was recorded: the take's `take.json` has `app_audio`. Listen to the clip.

Fix with the cheapest change. Effects, edits (`cut`, `freeze`, `pause`) and brand settings only need a re-render. Narration, steps or phrase targets need `/demo-record` for that scene.

## 3. Stitch
`Stitch.ps1` first brings every clip up to date (it runs RenderClip). Then it joins the clips in storyboard order with:
- title and outro cards;
- 0.4 s crossfades;
- optional music;
- merged captions (`.srt`) and chapters.

The result is a new numbered version in `final/`. Stitch refuses if a scene has no take, or if its take is stale. It reads the result back and saves one still per scene in `final/<name>-vNNN-review/`: check them. For a share-size copy, run `Preview.ps1 -Video <final mp4> -Width 1280`.

## 4. Checkpoint 2: the user's review
Give the user:
- the final video's path (and the preview);
- its length and chapters;
- the review stills.

Log each note with `Note.ps1 -Kind review -Scene <id> -Text "..."`, then route it to the cheapest layer:

| Note | Fix | Then |
|---|---|---|
| Wording or pace in one scene | that scene's narration (respell a word there for a one-scene pronunciation fix) | `-VoiceOnly` and `Test-Storyboard`, `/demo-record` that scene, Stitch |
| Pronunciation everywhere | `voice.lexicon` (makes every take stale) | `/demo-record` all scenes, Stitch |
| Wrong or missing step, UI changed | storyboard actions | rehearse, record that scene and any after it that depend on it, Stitch |
| Effect, emphasis, zoom, caption position | storyboard effects or `caption_position` | Stitch |
| Too slow, a wait, a glitch | `edits` (cut, freeze, pause) | Stitch |
| Colours, fonts, cards, music, captions on/off | `project.json` | Stitch |

Each round makes a new version. Earlier versions stay in `final/`, and everything is logged in `log.jsonl`.
