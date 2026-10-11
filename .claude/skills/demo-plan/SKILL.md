---
name: demo-plan
description: First stage of the demo-video chain. Scouts a live web app through Windows UI Automation and screenshots, lists what it can really show (a feature coverage map with evidence), and agrees with the user which features the demo covers and in what order. Writes demo/plan.md.
argument-hint: "[demo project folder]"
disable-model-invocation: true
---

# Demo plan

Decide what the demo shows, based only on what the app really does on screen.

Toolkit: `../demo-video/tools/` (relative to this skill's folder). Project folder: the argument, else `demo/`. If `project.json` is missing, run the setup step of `/demo-video` first. Hard rules from `/demo-video` apply (no browser flags, built-ins only, warn before the mouse moves).

## 1. Gather what the app is for
From the user, the repo (README, routes, docs) and the app itself: who uses it, the pain it removes, the 3-4 real values under its features. Ask the user for the one moment that must be in the demo.

## 2. Scout the live app
Tell the user the browser is about to open and scroll by itself. Then:
`powershell -NoProfile -ExecutionPolicy Bypass -File "<tools>\Scout.ps1" -Url <app_url> -OutDir "<project>\scout" -Screens 6`
(use `-Attach "<window title*>"` for `profile: attach`). For each screen it saves a half-size screenshot (`screen-NN.png`) and the visible elements with their exact accessible names (`screen-NN.json`). Read the screenshots and the element lists. Explore deeper pages or opened panels the same way (navigate or click with the toolkit, then scout again); stop before anything outward-facing (sending, submitting, buying) and ask.

Note anything that affects recording: pop-ups and when they appear, loading delays, controls that need two clicks, content that changes between visits, things that make sound.

## 3. Coverage map
Write `<project>/plan.md`:

| Feature | Value to the viewer | Evidence (screen, element name) | Status |
|---|---|---|---|
| ... | ... | `screen-02`: Button "Add task" | FOUND / PARTIAL / NOT FOUND |

Rules:
- FOUND only if you saw it work on screen. Never plan a scene for a NOT FOUND feature; list it and ask the user (cut it, or they show you where it is).
- Note required state (login, sample data, a pop-up to dismiss) per feature.
- Mark steps that would send, submit, buy or delete anything; the demo uses test data or skips them.

## 4. Choose with the user
Propose the scene order (cold open, orientation, features by importance, close) and a target length from the setup answers, with seconds per scene. Ask the user to confirm or change it. If they asked for autonomous work, choose and say why.

Then continue with `/demo-script`.
