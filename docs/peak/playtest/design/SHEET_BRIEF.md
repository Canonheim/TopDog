# Writing one biome's sheet: the brief

For whoever writes a `data/aN_biome.py` file. The areas of a biome are designed from its
sheet (`BRIEF.md` is the brief for that second step), so the sheet comes first: Parker,
"the entire biome must be considered first, then each area. And the transitions between
biomes needs care to look correct."

## What a sheet is

One Python file holding one dict, `BIOME`, with exactly these keys, in this order:
`name, line, story, built, light, looks, layers, kit, arrive, leave, motifs, notes`.
Read `data/a6_biome.py`, `data/a3_biome.py` and `data/a0_biome.py` and match their shape,
their depth and their plainness. A sheet is about 70 to 90 lines.

- `story`: three short paragraphs. What this part of the mountain is, who built or left
  what in it, and what happened. It must follow from the biomes below it.
- `built`: its way of building, as rules a model maker can follow: the materials, the
  joinery, what is never used here.
- `light`: where the light comes from and what colour it is.
- `looks`: the table that tells a player what a thing does by how it looks. Always the
  rows "You can hold it", "You can't", "It is scenery", and one row for each thing this
  biome does (it blows, it is cold, it breaks, it moves, it strikes...).
- `layers`: what the background, the play space and the foreground hold in this biome.
- `kit`: every piece the biome's areas will be built from: name, size, where it is used,
  layer, and whether it is "in the kit: <name>" (see `docs/peak/PARTS.md` and
  `docs/peak/PROPS_USED.md` for what exists) or "new". Reuse hard.
- `arrive`, `leave`: the joins with the biome below and above, in two or three sentences
  each. Read the neighbours' sheets where they exist.
- `motifs`: the mountain's running threads as they show here: the pug, the ones who tried
  (frozen or fallen climbers), the town's bunting following you up, the frog.
- `notes`: Parker's playtest notes for this biome, one line each, by number.

## The laws the sheet must keep

1. The twelve mountain-wide rules: the `RULES` list in `build.py`. Read them all.
2. Parker's two standing rules (2026-11-13): he gave "complete authority to arrange and
   even move geometry in play space a bit"; and "If it is in the play space you should
   generally be able to hold it. That is more telling than the color". So scenery stands
   behind or in front of the play space (1.2 m either side of the climber) and is duller.
3. Far backgrounds are ONE flat painted cut-out card standing well back, and open ground
   is a designed painted slab with real things standing on it: both are written out in
   `BRIEF.md` ("Far backgrounds", "Open ground"). Above 430 m the mountain already has its
   far layers, made that way: a painted valley 7 km wide below (fields in bands along a
   river and a road, farms, trees, and the tiny town the climb started from), two painted
   mountain ranges behind it, and rows of painted cloud banks at 932 m that you climb up
   through near the top. Pictures: `docs/peak/playtest/far/7_5_close_trial.jpg`,
   `7_10_pulled_back_trial.jpg`, `8_8_pulled_back_trial.jpg`, `summit_after3.jpg`. Those
   are given. The sheet says what stands between the climb and them.
4. A second playtest (notes 76 on) made one more law for everything that moves or acts:
   **what is drawn is what can be touched** (notes 76, 77: a wheel and a gondola whose
   solid parts were bigger than their models), and **a thing that comes is seen coming**
   (notes 86, 88, 93: ice that falls or returns grows into view first).
5. Wind is drawn loudly (note 89): long wavy lines in the air, and things in the world
   that stream the way it blows, flags first. Parker liked both of those.
6. One frog is hidden in every biome, in a small warm lit place (note 60).
7. No glowing materials. Heat, cold and light are shown by colour, sparks, steam and
   frost. No reference to any other video game, ever.

## Walls and masses

**Walls and rock are painted, not built of blocks (Parker, 2026-11-13).** He asked: "is there
a plan to make the walls and things look better? instead of so blocky". Until then every
mass you climb was one of the course's straight boxes dressed in a 2 m square panel repeated
in a grid, flat-fronted, with square corners. A first try that built each bed of rock as its
own block still read as stacked blocks: in this art style every step of shape gets an ink
line, so a bed built as a block is a brick. The second try was painted, and of it he said:
"I judge it as looking pretty darn good... I like the painted look".

The worked example is the split tower top of the wind cliffs (challenges 7.9 and 7.10):
`walls_example_before.jpg` (the game today) and `walls_example_after.png` (the kit's
`ex_riscos_tower_top`; its source is `Top Dog Kit\sourceuild_ex_riscos_tower_top.py`).

How a wall or a mass is made:

- **The face is paint.** A few large planes. The material's layers (beds of chalk, courses
  of brick, bands in ice, the grain of a rock) are flush colour regions on those planes, in
  three or four tones, long and uneven, with rain streaks or stains painted down across
  them. No ink inside a face, and no step of shape for each layer.
- **A few big breaks are real shape,** and only those get ink: one overhang with a painted
  shadow under it, one deep recess or opened joint, one ledge with something on it, one
  leaning slab or fallen block. They sit inside the game's frame, not below it.
- **The outline is designed.** Away from the holds and the tops you stand on, the edge may
  move up to 0.8 m: it leans, tapers, is notched where a piece has gone, and has no long
  ruled level or upright edge. The holds, the standing tops and the faces of any gap you
  climb stay exactly where the course has them.
- **Holds belong to the wall.** A hold is a bed, a course or a band of the same wall, painted
  running on across its face, and standing proud only where it is held.
- **The body carries on behind:** in place of a flat card, the mass's own body 1.5 to 3 m
  back as one big form in two or three slanted planes, duller and cooler, its layers painted
  as thin lines that carry on from the wall's, with an uneven skyline.
- **No tiling.** One piece made for its place. Repeating panels are for small filler only.
- Each biome's sheet says what this means for its own material, in its `built` list and in
  a kit line for its walls and masses.

## Read these

- `docs/peak/CHALLENGES.md`: your biome's challenges, one line each.
- `tools/peak/areas/aN.py`: the course's own file, with the author's comments. Its header
  says what the place is and how the route runs.
- `docs/peak/PEAK_DESIGN.md` sections 3, 4 and 7.
- `docs/peak/playtest/PLAYTEST_NOTES.html`: the notes named in your task. Each is a
  `<div class="note" id="nN">`: Parker's words, a picture in `shots/`, what is going on,
  a plan. Look at the pictures. Both playtests were on an old build, so a few things in
  the pictures are already changed; where that is so the note says it.
- `docs/peak/playtest/design/ANSWERS.md`: what Parker has already decided, in his words.
- To see the course: `python docs/peak/playtest/design/build.py --look aN x0 y0 x1 y1 OUT.png`
  then read the PNG (put it in a scratch folder outside the repository).

## Hard limits

- Write ONE file: `docs/peak/playtest/design/data/aN_biome.py`. Nothing else in the
  repository.
- Do not run Godot or the game (Parker is playing on this machine). No git command that
  changes anything. No downloads.
- When you run the builder, ALWAYS pass `--no-index` (without it the builder rewrites the
  notes page, which someone else is editing):
  `python docs/peak/playtest/design/build.py aN --no-index`. It must print `warnings: 0`.
- Design only. Nothing is modelled or changed in the game from this.
- Do not put words in Parker's mouth. Quote him only where your task or the notes page
  gives his exact words; otherwise refer to notes by number.
- How to write: plain English, short full sentences, no jargon, no abbreviations, no
  arrows or symbols standing in for words, no em dashes. Sizes in metres. Challenge names
  stay in Spanish. Say what is there; never "epic" or "stunning".

## What to hand back

A short report, under 300 words: the biome in two sentences; the pieces you marked "new";
anything you had to decide that Parker might see differently (as plain questions, each
answerable in a word); and anything in the course that looked wrong (do not fix it).
