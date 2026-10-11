# Narration playbook

How the narration of a software demo is written. Apply while writing, then self-check every scene. Sources and evidence: `docs/research/demo-video/features.md` in the C-Skills repo.

## Structure
1. **Cold open (5-10 s, over the title card or first scene):** product, who it is for, the pain it removes.
2. **Orient before acting:** one beat naming where we are before the first click.
3. **Each feature scene answers the opening pain** and shows the outcome, not just the control.
4. **Time goes to state changes, not navigation.** Opening plus close is about 15% of the runtime; the most important feature gets the most time.
5. **Value close:** end on the strongest proof frame, one-line recap, the user's own call to action.

## Line rules
1. **Benefit before feature:** "Find any invoice in seconds", not "Search functionality".
2. **Say what is seen:** every claim and every spoken value is visible in that scene; say the result after the action lands, never before.
3. **Object + action + visible result** in each step line. Test: read it with the screen covered; if a newcomer would ask "what? where? what happened?", rewrite.
4. **Intent, then the control:** "Let's add a task: I'll type it and press "Add task"."
5. **Name controls by their exact on-screen label** in quotes, with a noun ("the "Status" column").
6. **Don't read the screen aloud:** add why it matters or what happens next; paraphrase long typed text.
7. **One idea per sentence;** if a scene needs "and" to join two actions, it may be two scenes.
8. **Present tense, active voice,** "let's" / "you" address. Vary sentence length and connectors; never the same connector twice in a row.
9. **Concrete over vague:** "in three seconds", not "quickly".

## Never
- Openers like "Welcome to", "This is a demo of", "In this video we will".
- Hype: revolutionary, seamless, leverage, unlock, powerful, amazing, super easy, game-changing, cutting-edge, effortless.
- Feature lists without context; tidy three-part lists in every scene; template bookends.
- Mentioning the tool, AI, or how the video was made.
- The word "pause", emojis, em or en dashes (they read badly aloud and in captions). Use `[pause 400ms]` for a real pause.

## Pace
| Item | Rule |
|---|---|
| Speaking rate | 2.2-2.7 words/s (2.0 for technical lines); rewrite above 3.1 |
| Scene length | about words / 2.3 + 0.4 s; 3-4 s holds 8-12 words, 7-8 s holds 22-30 |
| Budgets | 30 s about 69 words, 60 s about 138, 90 s about 207 |
| Core feature | 7-12 s; small tweak 2-4 s |
| Pause before a reveal | 300-600 ms, at most twice per scene |
| On-screen text | at most 7 words |

## Self-check per scene
- [ ] Pace in range (Test-Storyboard reports it from the real audio).
- [ ] Object, action and visible result named; passes the covered-screen test.
- [ ] Every claim is visible in the scene; results follow the action.
- [ ] Labels quoted exactly as the element map shows them.
- [ ] Adds why or what's next instead of reading the screen.
- [ ] No banned words, dashes, emojis or "pause".
- [ ] Hard words respelled in `voice.lexicon` (check by listening to the audio file).

## Self-check for the whole script
- [ ] Cold open, orientation, feature scenes, value close and call to action all present.
- [ ] Most time on the most important feature; total within the agreed length.
- [ ] Every NOT FOUND item in the coverage map was cut with the user's agreement, never faked.
