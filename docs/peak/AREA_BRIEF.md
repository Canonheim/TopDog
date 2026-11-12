# Brief for an area author (the Peak of DeGayo)

You are building one area of Top Dog's solo climb: its geometry, its challenges, its
fall design and its look, as course data. Parker (the game's owner) asked for a rage
climb of at least 100 distinct challenges, in depth, where falls cost real progress. He
is away tonight; nobody can play your area before morning. Your area has to be right on
paper: geometry that a 1.8 m physics climber can actually climb, catch and fall through.

## Read first, in this order

1. `docs/peak/PEAK_DESIGN.md`: the whole design. §2 (what the climber can do), §3 (the
   laws), §5 (the falls) and §7 (the look) bind you.
2. `docs/peak/CHALLENGES.md`: your area's table is your job list. Build every one.
3. `docs/peak/AUTHORING.md`: how to write the file, the hard rules, the doors, motions,
   zones. The softlock rule (no flat slick) and the sealing rule are the two that
   authors most often break.
4. `tools/peak/peaklib.py` (the library; read the docstrings) and
   `tools/peak/areas/a0.py` (the worked example).

## Your job

- Write `tools/peak/areas/<your id>.py`. Nothing else: no other file, no Godot, no git.
- Build the whole area: the room or the face, every challenge in order from your entry
  to your exit, rest ledges between them, the catches that give each miss its cost,
  camera zones over every fling, lights, back cards and props that tell the story.
- Make each challenge a real, distinct, hand-shaped piece of climbing, not a row of
  boxes. Vary the rhythm: a hard move, a breath, a harder one.
- Work challenge by challenge: build, run, draw its window
  (`python tools/peak/preview.py <id> --challenge N.M`), LOOK at the picture, fix.
  Check clearances with numbers, not by eye alone: launch circles (2.3 m), reaches
  (1.9 m max, 1.2 m comfortable), fling speeds (`peaklib.fling_speed`), landing sizes.
- Finish with the whole-area picture and, inside the mountain, `--leak` at 0 cells.
- Difficulty is the point. D4 and D5 challenges should make an expert sweat: small
  landings, moving targets, long flights. But every one must be possible.

## What the game does with your data (so you design to it)

- Solids are extruded cardboard: grip kinds are pale and matte, slick kinds near
  black with pale drips. Kinds `hot`, `ice`, `rotten`, `brittle` have their own
  colours. The player reads the wall by colour alone, so be consistent.
- Movers are solid bodies that carry whatever grips or stands on them.
- Ropes are real physics chains: they swing when a climber moves on them.
- A climber that falls onto grip sticks to it by hands or feet if they touch.
- Camera: 4.2 m half-height unless your `cam` zone says otherwise.

## Your final message

Follow "Your report" at the end of AUTHORING.md. Be exact about anything unfinished or
doubtful: an honest "7.6 may be impossible because..." is worth more than a clean claim.
