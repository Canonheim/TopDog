# Designing one biome's areas: the brief

For whoever writes a `data/aN_areas.py` file. Read all of this first.

## What the job is

Top Dog's solo mode is a climb up one mountain, the Peak of DeGayo. It plays in a flat
plane seen from the side. Parker (the game's maker) played it and said it "looks way too
block out ish. Unfinished." His fix: split the mountain into its small places, over 100
of them, and design each one as "a little diorama basically. A full little 3d scene that
makes sense."

Every place has three layers, and they are "3 distinct areas":

- **Background:** what stands behind the climb. It must "naturally play into the play
  space correctly, like the ladder with it's rungs": the thing you hold is the near end
  of something real that carries on behind it.
- **Play space:** what you touch. It is 1.2 m either side of the climber.
- **Foreground:** what stands in front, "which should be very sparse". His model: "the
  arches in the mine, you pass through them but there is a background pole and a
  foreground pole."

And: "each area needs to thematically fit and the challenges should share a general
archectural style, reusing assets at times too. So the entire biome must be considered
first, then each area. And the transitions between biomes needs care to look correct."

**This is design only.** Nothing gets modelled until the whole mountain has been
playtested. You are writing the designs the model makers will build from later, and that
Parker will read and judge in the morning. He liked the worked example (El Derrumbe, in
`data/a1_areas.py`): match its depth and its plainness.

## Hard limits

- Write ONE file: `docs/peak/playtest/design/data/aN_areas.py` for your biome. Nothing else
  in the repository: not the course, not code, not the notes page, not `build.py`, not
  another biome's files, not the biome sheets.
- Do not run Godot or the game. Do not run any git command that changes anything (no add,
  commit, stash, checkout, reset). Do not download anything.
- Do not change the play. The challenge stays exactly as the course file has it, plus the
  changes Parker has already asked for in his notes (listed in your task). You dress it;
  you do not redesign it. If a design idea would need the play to change, put it in
  `"ask"` as a question, do not assume it.
- Do not put words in Parker's mouth. Refer to his notes by number ("note 26"). Do not
  quote him.
- Never name any other video game.

## Read these first

1. `docs/peak/playtest/design/data/aN_biome.py`: your biome's sheet. Its way of building,
   its looks table, its layers, its kit. **Every area you design is drawn from this
   sheet.** Also read the sheet of the biome before yours and the one after (for how you
   arrive and how you leave).
2. `docs/peak/playtest/design/data/a1_areas.py`: the worked example. Your file has the same
   shape.
3. The top of `docs/peak/playtest/design/build.py`: the data format, exactly.
4. `docs/peak/CHALLENGES.md`: your biome's challenges, one line each.
5. `tools/peak/areas/aN.py`: how your biome's course is written, with the author's
   comments on each challenge. `stages/peak/course/aN.json` is the result: the real
   numbers. `stages/peak/course/_meta.json` says what each `kind` of solid is.
6. `docs/peak/PEAK_DESIGN.md` sections 3, 4 and 7: the mountain's laws, its layout, its look.
7. In `docs/peak/playtest/PLAYTEST_NOTES.html`, the notes listed in your task. Each is a
   `<div class="note" id="nN">`: Parker's words, a picture in `shots/`, what is going on,
   the plan, and sometimes "After (from the thread)" with pictures in `after/`. Look at
   the pictures: they show what the place looks like in the game today.

## Coordinates

Metres. `x` is negative into the mountain (left on screen), `y` is height. `z` is depth:
the climber is at z 0, the play space is z -1.2 to 1.2, **background is z below -1.2**
(behind), **foreground is z above 1.2** (in front, towards the camera). The camera looks
along -z. The climber is 1.8 m tall and reaches 2.1 m. One screen with the close camera
is about 19.5 m wide and 11 m tall.

## How to work, area by area

1. **Look at the place.** Make a picture of the course as it is today:
   `python docs/peak/playtest/design/build.py --look aN x0 y0 x1 y1 OUT.png`
   then read the PNG. It has a 1 m grid with x and y labelled every 5 m, the solids in
   their colours, movers in dashed cyan, today's scenery as dashed grey boxes with model
   names, and each challenge's start as a white figure. Use `a3+a4` to see two biomes at
   once. The mountain's shared structure (the well, the east face) is always drawn.
   Put PNGs in your own scratch folder, never in the repository.
2. **Decide what the place is.** One paragraph: what was this, on the day it was built
   or grew, and what happened to it? It has to be a piece of the biome's story, built the
   biome's way. A challenge is not a set of platforms: it is a shaft, a pump room, a
   mushroom's underside. Find the real-world thing that would put those holds exactly
   there.
3. **Background.** For each thing you touch, ask what it is the near end of, and draw
   that behind it, at the real coordinates. Then the room's back wall, its light, and one
   or two things that say what the place was for. Usually 5 to 9 items.
4. **Play space.** Only what is drawn onto or added to things already there: a broken
   end, a carved band, a seam. Usually 1 to 4 items. Never a new thing to hold or stand on.
5. **Foreground.** 0 to 3 items. Thin posts and low lips, in front of solid rock or below
   the lowest floor. Never over open space the climber moves through or needs to read.
   If the area is better with no foreground, give it none.
6. **The explains table.** One row for each thing you touch: what it is in the scene,
   and what stands behind it. If you can't fill a row, the background is not doing its job.
7. **Pieces.** Every piece named with a size and a count, and in the last column either
   `kit: <piece from the biome sheet's kit>` or `new`. Reuse the kit hard. Truly new
   pieces that more than one of your areas uses go in a `KIT_MORE` list at the bottom of
   your file (same five columns as the sheet's kit; the builder adds them to the sheet).
8. **Notes.** Fold Parker's notes for that place into the design, and list them in
   `"notes"` with their numbers. The design shows the place as it will be AFTER his notes.
9. **Ask.** Only real decisions for Parker, at most two an area, each answerable in a word.
   Most areas should have none.

## Drawing the sketch

Every item has a `"draw"` list of shapes at real course coordinates. The side sketch is
the main picture: keep it honest and readable.

- Draw each background thing where it would really stand, at its real size.
- Background things are drawn UNDER today's course, so anything you draw inside solid
  rock is hidden. For a hole or room cut into rock that is solid today, set
  `"over": True` on the item.
- Use `"style"`: `solid` for big masses, `pale` for parts and planks, `dark` for holes and
  doorways, `line` for outlines and wheels, `mark` for dashed marks, `light` for lamps.
- A window is usually under 30 m wide. A long area may go to 45 m. A tall shaft can be as
  tall as it needs.
- Give every item a `"z"` pair. Give `"tag"` when the default spot (the middle of what it
  draws) would sit on top of something else.
- `"screen": [cx, cy]` draws one screen of the close camera. `"climber": [x, y]` draws a
  1.8 m figure standing at that point. `"cut_y"` is the height the from-above sketch is
  cut at: pick the height where the most layers show.

## Check your work

    python docs/peak/playtest/design/build.py aN --no-index --png YOUR_SCRATCH_DIR

It must print `warnings: 0`. Then **read every PNG** and look: are the background items
visible and where you meant? Does anything cover a hold? Is the foreground off the open
space? Do the number tags sit on their items? Fix and rebuild until each picture is one
you would show. The PNG is rougher than the real page (which is HTML in
`docs/peak/playtest/design/aN/`), but the positions are the same. The built HTML pages
in `design/aN/` are fine to leave: they are regenerated.

## How to write

Parker reads every word. Plain English, short full sentences, no jargon, no
abbreviations, no arrows, no symbols standing in for words. No em dashes: use a full
stop, a comma or a colon. Say what a thing is before what it is for. Sizes in metres.
Challenge names stay in Spanish as they are. Do not describe things as "epic" or
"stunning": say what is there.

## What to hand back

A short report: the areas you wrote (ids), any piece you added in `KIT_MORE`, every
question you put in an `"ask"`, and anything in the course that looked wrong to you (do
not fix it). Say plainly if any area is thinner than the rest or if you could not check
a picture.
