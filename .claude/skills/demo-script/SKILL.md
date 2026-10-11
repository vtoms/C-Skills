---
name: demo-script
description: Second stage of the demo-video chain. Writes the narration and the JSON storyboard (each line tied to an on-screen action and effect), voices it with Aria to get real word timings, validates pace and timing, and stops for the user's approval of the script before anything is recorded.
argument-hint: "[demo project folder]"
disable-model-invocation: true
---

# Demo script

Writes the narration and storyboard, voices and checks them, and gets the user's approval.

**Toolkit:** `../demo-video/tools/` relative to this skill's folder (`<tools>` below). Run scripts as `powershell -NoProfile -ExecutionPolicy Bypass -File "<tools>\<Script>.ps1" -Dir "<project>" ...`. **Project folder:** the argument, else `demo/`. It needs `project.json` and `plan.md` (run `/demo-plan` first). Read `../demo-video/reference/narration.md` and `../demo-video/reference/storyboard.md` before writing.

**Hard rules** (they apply when this stage runs alone too):
- Never put real credentials or the user's personal data in `type` text; use invented test data.
- Steps that send, submit, buy or delete need the user's OK. Every rehearsal and recording repeats them for real.
- No browser debugging or automation flags; built-ins only.

## 1. Write the storyboard
Write `<project>/storyboard.json` from the plan: title, subtitle, outro, and one scene per beat.
- **Narration** follows the playbook:
  - benefit first, and say what is seen;
  - each line names an object, an action and a result;
  - exact labels in quotes;
  - no banned words and no dashes;
  - 2.2-2.7 words per second.
- **Targets** use element names from the scout output (`scout/screen-NN.json`) or a take's snapshots. Never invent names. Effects can also target a phrase on screen (`{ "text": "..." }`).
- **Off-camera setup** the viewer shouldn't watch (dismissing pop-ups, resetting data) goes in `pre`. Mark steps that may not happen as `optional`.
- **Timing:**
  - Tie each pointer action to the word it illustrates with `at_word`.
  - Tie each effect to the phrase that names its target with `at_word` and `until_word`.
  - Keep one dominant camera move per scene, and zoom on something small. A zoom can't go deeper than its target allows while the target stays in frame.
- **Talking apps** (`app_audio`): let the narration set up the moment, then stay silent while the app speaks. End the scene's actions with `wait_audio`, and time effects with `at_app_audio`.
- **Captions:** if they would cover the result being shown, set the scene's `caption_position` to `top`.
- **Pronunciation:**
  - A respelling for the whole project goes in `voice.lexicon`. Changing the lexicon later makes every take stale.
  - For one scene, respell the word in that scene's narration instead. The captions will show the respelling.

## 2. Voice and validate (repeat until clean)
1. **Voice:** `Record.ps1 -VoiceOnly`. This makes the narration with word timings; only changed phrases are re-voiced. It prints each scene's length, pace and voice.
   - Every scene must show the same voice. An "Aria failed" warning means the scene fell back to a Windows voice: run it again.
   - Run `-VoiceOnly` again after every narration edit.
2. **Validate:** `Test-Storyboard.ps1`. It prints errors, warnings and each scene's spoken word indexes.
   - The spoken words can differ from the written ones (a respelling can split a word), so re-check every `at_word` against the printed list.
   - A scene missing from that list hasn't been voiced yet.
3. **Fix:**
   - rewrite lines that are too fast or too slow;
   - move actions that can't land on their word;
   - remove dead air.

   Repeat until there are 0 errors and you can explain every remaining warning to the user.

## 3. Checkpoint 1: script approval
Show the user this table, and wait:

| Scene | Narration | On screen (actions, effects) | Seconds |
|---|---|---|---|

Also give them:
- the total length;
- anything flagged as outward-facing, and the test data it uses;
- any NOT FOUND features that were left out;
- the audio files in `<project>/audio/`, offered for listening.

Change and re-validate until they approve, then log it: `Note.ps1 -Kind approval -Text "Script approved"`. That records the exact storyboard version. Don't record before approval. If the user told you to work autonomously, log your reasoning with `Note.ps1 -Kind decision` instead.

**Next:** when run from `/demo-video`, read `../demo-record/SKILL.md` and continue. When run alone, stop and tell the user the next step is `/demo-record`.
