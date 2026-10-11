---
name: demo-script
description: Second stage of the demo-video chain. Writes the narration and the JSON storyboard (each line tied to an on-screen action and effect), voices it with Aria to get real word timings, validates pace and timing, and stops for the user's approval of the script before anything is recorded.
argument-hint: "[demo project folder]"
disable-model-invocation: true
---

# Demo script

Narration and storyboard, voiced and checked, then approved by the user.

Toolkit: `../demo-video/tools/` (relative to this skill's folder). Project folder: the argument, else `demo/`. Needs `project.json` and `plan.md` (run `/demo-plan` first). Read `../demo-video/reference/narration.md` and `../demo-video/reference/storyboard.md` before writing.

## 1. Write the storyboard
Write `<project>/storyboard.json` from the plan: title, subtitle, outro, and one scene per beat.
- Narration follows the playbook: benefit first, say what is seen, object + action + result, exact labels in quotes, no banned words, no dashes, 2.2-2.7 words per second.
- Every target uses element names from the scout output (`scout/screen-NN.json`) or a take's snapshots. Never invent names.
- Put setup the viewer should not watch (dismissing pop-ups, resetting data) in `pre`, marking steps that may not happen as `optional`.
- Tie each pointer action to the word it illustrates with `at_word`; tie effects to the phrase that names their target (`at_word`, `until_word`). One dominant camera move per scene.
- For apps that talk (`app_audio`), let the narration set up the moment and then stay silent while the app speaks: end the scene's actions with `wait_audio`, and time effects with `at_app_audio`.
- Respell names the voice gets wrong in `project.json` `voice.lexicon`.

## 2. Voice and validate (repeat until clean)
1. `Record.ps1 -Dir <project> -VoiceOnly`: makes the narration with word timings (only changed phrases are re-voiced) and prints each scene's length and pace.
2. `Test-Storyboard.ps1 -Dir <project>`: prints errors, warnings and each scene's spoken word indexes. The spoken words can differ from the written ones (a respelling can split a word), so re-check every `at_word` against the printed list.
3. Fix: rewrite lines that are too fast or slow, move actions that cannot land on their word, remove dead air. Repeat until there are 0 errors and every remaining warning is one you can explain to the user.

## 3. Checkpoint 1: script approval
Show the user, and wait:

| Scene | Narration | On screen (actions, effects) | Seconds |
|---|---|---|---|

Also give the total length, anything flagged as outward-facing (and the test data used), any NOT FOUND features left out, and offer the audio files in `<project>/audio/` to listen to. Change and re-validate until they approve. Do not record before approval (unless the user told you to work autonomously; then record your reasoning in `plan.md`).

Then continue with `/demo-record`.
