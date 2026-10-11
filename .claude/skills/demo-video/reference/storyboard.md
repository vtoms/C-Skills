# Demo project reference

A demo project is one folder (default `demo/` in the app's repo, or any folder the user names). All paths in its logs are relative to it.

```
demo/
  project.json      setup answers and settings (you write it from the setup questions)
  storyboard.json   scenes: narration, actions, effects, edits (you write it; the user approves it)
  plan.md           feature coverage map (demo-plan)
  log.jsonl         append-only record of every voice, rehearsal, take, clip render and stitch (tools write it)
  manifest.json     current take and clip of each scene, and every final version (tools write it)
  audio/            narration audio, cached by content hash
  takes/<scene>/<take-id>/   frames, cursor and audio logs, page snapshots, take.json (exact inputs used)
  clips/<scene>/    one MP4 + JSON (+ first/last frame) per render of a take
  final/            <name>-v001.mp4, .srt, .chapters.txt, .json (which clips went in), -review/ stills
```

Never edit `log.jsonl`, `manifest.json` or anything under `takes/` by hand. Old takes and clips are kept so any version can be traced and rebuilt.

## project.json

| Key | Meaning |
|---|---|
| `app_url` | Start page. |
| `browser` | `msedge` (default) or `chrome`. |
| `profile` | `private` (default: throwaway InPrivate window, clean state), `dedicated` (persistent profile in `demo/.browser-profile`: the user signs in there by hand once), `attach` (drive a window the user already opened; needs `window_title`). |
| `window_title` | Title pattern of the app's window, e.g. `"Acme*"`. |
| `monitor` | Screen index from `Get-DemoMonitors` (setup question). |
| `fullscreen` | `true` = press F11 (hides tabs and address bar) (setup question). |
| `zoom` | Browser zoom %, snapped to the browser's steps 25-300 (setup question). |
| `setup_answers` | One line recording how the setup questions were answered. |
| `fps` | Capture rate, default 15 (DXGI handles up to about 28 at 2560x1600). |
| `app_audio` | `true` when the app makes sound worth keeping (talking agents, alerts): system audio is recorded. |
| `app_audio_volume` | Optional fixed gain for that sound; default levels it to the narration. |
| `voice` | `{ "engine": "aria"|"builtin", "name": "en-US-AriaNeural", "rate": "+0%", "pitch": "+0Hz", "volume": "+0%", "lexicon": { "SaaS": "sass" } }`. Edge's voice service honours only rate, pitch and volume; the lexicon respells words before speaking. |
| `captions` | Burn captions in (default true). An `.srt` is always written. |
| `title_card` | Opening card from the storyboard title (default true). |
| `brand` | `{ "accent": "#RRGGBB", "background_from": "#RRGGBB", "background_to": "#RRGGBB", "font": "Segoe UI" }`. |
| `music` | Optional `{ "file": "music.mp3", "volume": 0.12 }` (a file the user supplies and has rights to). |
| `output` | `{ "width": 1920, "name": "acme-demo" }`. |
| `replay_earlier` | Default true: when re-recording a later scene alone, earlier scenes are replayed off-camera first to rebuild the app's state. |

## storyboard.json

```json
{ "title": "...", "subtitle": "...", "outro": { "title": "...", "subtitle": "..." },
  "scenes": [ { "id": "s01", "title": "...", "narration": "...", "voice": { "pitch": "+2Hz" },
                "pre": [ ...actions run before the scene, cut from the video... ],
                "actions": [ ... ], "effects": [ ... ], "edits": [ ... ], "auto_trim": true } ] }
```

- `id`: letters, digits, `-`, `_` (it names files). Scene order is the video order.
- `narration`: what the voice says. `[pause 400ms]` inserts a real pause (the phrases are voiced separately). Word indexes (`at_word`) count the words **as spoken**: run `Test-Storyboard.ps1` after `Record.ps1 -VoiceOnly` to print them (a lexicon respelling can split one word into two).
- Changing `narration`, `voice`, `pre`, `actions` or a phrase target makes the scene's take stale (re-record that scene). Changing other effects, edits or brand settings only needs a re-render.

### Targets (how an element is found, through Windows UI Automation)

`{ "type": "Button", "name": "Save", "id": "save-btn", "index": 0, "within": { ...target... }, "pick": "top-right" }`

- `type`: Button, Hyperlink, Edit, ComboBox, CheckBox, RadioButton, MenuItem, TabItem, ListItem, Text, Group, Image, Document, List...
- `name`: the accessible name exactly, or a wildcard pattern (`"Order *"`). Take names from `Scout.ps1` output or a take's snapshots, never guess.
- `within`: search inside another element (for example a chat window); `pick`: first, last, top-left, top-right, bottom-left, bottom-right among matches (for unnamed icons such as a close button).
- Effects can also target a phrase on screen: `{ "text": "Grows your business" }` (measured during the take).

### Actions

| `do` | Fields | Notes |
|---|---|---|
| `click`, `double_click`, `right_click`, `hover` | `target` | Real cursor glides (0.7 s, eased) and lands on time. |
| `type` | `target`, `text`, `cps` (default 18), `clear` | Clicks the field, then types with Unicode key events. |
| `key` | `keys` e.g. `"Ctrl+K"`, `"Enter"` | |
| `scroll` | `notches` (+ down), optional `target` to scroll over | |
| `navigate` | `url` | Ctrl+L, type, Enter. |
| `wait` | `ms`, or `for` (a target to appear) + `timeout_ms` | |
| `wait_audio` | `start_timeout_ms`, `quiet_ms`, `timeout_ms`, `expect_seconds` | Needs `app_audio`. Waits for the app to start making sound, then for `quiet_ms` of silence. |

Timing: `at_word` (index into the spoken words) or `at` (seconds from the narration start). Pointer actions are scheduled so the click lands on that word. Untimed actions follow the previous one. Any action can be `"optional": true` (skipped if its target never appears, e.g. a pop-up that may not show). Add `"note"` to explain unusual steps.

### Effects (drawn in post-production, timed to words)

`{ "type": "zoom|highlight|spotlight|marker|underline|callout", "target": {...} | "rect": {x,y,w,h}, "at_word": 3, "until_word": 8, "scale": 1.4, "at_app_audio": true }`

| Effect | Use | Defaults |
|---|---|---|
| `zoom` | Push in on a region while it's discussed; chained zooms under 1.5 s apart pan instead | eases in 0.75 s landing on the cue, holds, out 0.9 s; scale 1.25-1.5 (hard cap 2.0, never past the captured pixels) |
| `highlight` | Outline a control being named | 0.2 s in, until the phrase ends + 0.3 s |
| `spotlight` | Dim everything else (about 50%) | at most one per scene; not with a zoom deeper than 1.3 |
| `underline` / `marker` | Draw under / sweep a highlighter across a phrase | for short labels |
| `callout` | Magnified balloon of a small region, placed beside it with a leader line | 1.6-2.0x; at most twice per video |

`at_app_audio: true` times the effect to the app's own speech (for chat agents) instead of words. Every effect ends before the scene's last 0.5 s. Targets off-screen at that moment are skipped with a warning.

### Edits (post-production, in seconds from the narration start; no re-recording needed)

- `{ "cut": [from, to] }`: remove picture and sound (refused where narration or the app's speech is playing). Cuts are crossfaded.
- `{ "freeze": [from, to] }`: hold the frame at `from` while the narration keeps playing (hide a spinner or flicker).
- `{ "pause": 1.2, "at_word": 7 }`: insert a still frame and silence; narration resumes after.
- `"auto_trim": false`: keep idle silent stretches (by default stretches over 1.5 s with no motion, speech or action are cut to 0.6 s).
