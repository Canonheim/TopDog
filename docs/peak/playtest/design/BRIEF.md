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

## Far backgrounds

**Far backgrounds are flat facade pieces (Parker, 2026-11-13).** What stands far behind a
scene (far hills, a far town, a far range, the far wall of a cavern) is ONE flat cut-out card
standing well back. It is not modelled terrain, and it is never an empty plane running to a
ruled horizon. Parker, on the station's dry hills: "I like how you made the background back
there a flat facade piece, that was good. You did a good job coloring it too to make it look
nice", and then: "that is now the correct way to do far backgrounds".

How to make one (the worked example is the kit's `stn_far_hills`: `Top Dog Kit\source\stn_b_ground.py`
and `stn_far_hills_design.py`; it stands 95 m behind the climb, 160 m wide, 6 to 14 m tall):

- **One card with a hand-cut outline,** in the kit's cardboard cut-out language: a thick card
  whose cut edge shows kraft, a dark stripe, kraft, with braces behind.
- **A painted face of flush colour regions on one plane.** Two or three rows of forms. The
  back row is hazed toward the colour of the sky and the far mountains. The front row is in
  the place's own colours, each form with a shade flank. A third colour runs in drifts along
  the foot.
- **A few bold silhouettes cut into the ridge** (cactus and scrub at the station; whatever
  belongs to the place elsewhere), big enough that the ink line can't swallow them: a trunk
  1 m across at 95 m.
- **Mid-value colours.** The game's light lifts every lit face a long way; a pale card goes
  to white.
- **Far enough back that it barely slides** as the camera moves. In front of it: the ground
  and the real props. Behind it: the sky and the far ranges.

When a design has something far behind it, design it as one such card: say how wide and tall it is, how far back it stands, its rows and colours, and what is cut into its ridge.

## Open ground

**The ground is designed, not a flat plane (Parker, 2026-11-13).** Open ground is never one
flat colour running to the horizon. Parker, of the station's first ground: "a massive flat tan
plane". Of the ground that replaced it: "your ground work was also very good, make sure that
info on how you did it is written down". This is how it was done; the worked example is the
kit's `stn_yard_floor` (`Top Dog Kit\source\build_stn_yard_floor.py` and
`stn_yard_floor_design.py`) with the props that stand on it (`stn_b_ground.py`).

It is two things together: one painted slab, and things standing on it.

**1. The slab: one flat model, all paint, no height.**
- **One slab, 2 cm thick,** laid over whatever ground is there. Nothing on it has height, so
  the climber walks through all of it. Every mark is a flush colour region on ONE plane, cut
  in a design step (shapely), so no ink is drawn between its colours.
- **It runs off every edge of the screen,** at the close camera and at the pulled-back one.
  The first try was 52 m by 9 m and its front edge showed as a hard inked line across the
  lower third of the screen. The one that worked is 96 m by 122 m: 32 m toward the camera and
  90 m back. If any edge of the ground can come into frame, it is too small.
- **No more than about 4 m of one flat colour anywhere on screen.** That was the brief's test.
- **It is laid out as a real place, in bands from the camera back:**
  - *Foreground* (in front of the road): a second rutted track, then flat stones and tufts
    about every 4 m in rows, thinning toward the camera. Bold and sparse.
  - *The road* (under the climb): a paler worn band about 5 m wide, a darker verge either
    side, wheel ruts, worn patches along it.
  - *The yard* (between the road and what is built behind): trodden earth, cart tracks that
    go where carts went (from the gate to the dock's end), soft patches.
  - *Paving where people built:* a cobbled street through the gate and down the alley, its
    stones drawn bigger the further back they are, and a forecourt apron in front of the gate.
  - *Open country:* a yellower ground, patches of two earth tones and two scrub olives, and
    one wandering line to lead the eye away (a dry stream bed of pale sand between darker
    banks). The darker olive patches are where bushes and cactus are then stood.
  - *Far:* two or three long calm bands, each paler than the last, toward the horizon.
- **Detail is sized by distance:** bold at 1 m = 80 pixels near the camera, broad shapes only
  far away.
- **Mid-value earth, a step darker and warmer than the pale plaza ground,** so the bone-white
  climber reads against it.
- **Its origin is a line that means something** (here the middle of the yard wall's foot), and
  it did not move when the slab was made bigger, so nothing placed on it had to move.

**2. What stands on it.** Real models on the darker patches, well behind the climb: two
saguaros, prickly pear, yucca, rock clusters, dry grass tufts, a dead tree. A few, big, and
mid-value. Thin plants (grass, the yucca's leaves) are flat cut-outs facing the camera: as
separate blades each took its own ink line and the plant went black.

**3. Then the horizon:** a flat facade card far behind (the rule above), so the ground ends
against painted hills, not against the sky.

**Two traps we hit:**
- *The camera sits at about the climber's chest height.* So anything standing in FRONT of the
  road covers the climber up to its own height, wherever the climber stands behind it. In
  front of the road: only things under 0.3 m, or tufts 6 m and more toward the camera. Tall
  foreground pieces go where nobody stands behind them (in front of a raised deck, past a wall).
- *A deco's `size` must be the size its model is made at.* The game rescales a landed model
  that is more than a quarter off the size the course gives it.

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
  three or four tones: long, uneven, wavy lines and bands that run the length of the face.
  No ink inside a face, and no step of shape for each layer.
- **No random triangles (Parker, on the worked example: "it does not need these random
  triangles ... just the painted lines look lovely").** Nothing painted tapers to a point:
  no rain streak that narrows down the face, no stain shaped like a wedge, no hold band
  that thins away across the wall. Lines and bands only.
- **A few big breaks are real shape,** and only those get ink: an overhang with a painted
  shadow under it, a ledge with something on it, a leaning slab or fallen block. They sit
  inside the game's frame, not below it. **No dark slot or recess cut into a face**
  (Parker, of the example's opened joint: "Get rid of this part too so it all looks painted
  like that").
- **Little outcrops, with plants.** Parker: "I also love the little foreground out
  croppings, feel free to put little plants like the painted plants in the foreground of
  the Station had." So a wall keeps a few small outcrops standing out of it, and they carry
  life: plants made for that biome, each one flat painted card (its parts flush colours on
  one plane, so only its outline is inked), in the style of the station's foreground
  plants. Of those plants he said: "you will want to make new ones for various biomes, but
  that is the style I mean. You don't have to re use the old one." Each biome's sheet says
  what grows on its walls.
- **The outline is designed.** Away from the holds and the tops you stand on, the edge may
  move up to 0.8 m: it leans, tapers, is notched where a piece has gone, and has no long
  ruled level or upright edge. The holds, the standing tops and the faces of any gap you
  climb stay exactly where the course has them.
- **Holds belong to the wall.** A hold is a bed, a course or a band of the same wall, in
  the hold's own pale colour, standing proud where it is held. It is a plain block or band
  with square ends: it does not trail off across the face as a wedge.
- **The body carries on behind:** in place of a flat card, the mass's own body 1.5 to 3 m
  back as one big form in two or three slanted planes, duller and cooler, its layers painted
  as thin lines that carry on from the wall's, with an uneven skyline.
- **No tiling.** One piece made for its place. Repeating panels are for small filler only.
- Each biome's sheet says what this means for its own material, in its `built` list and in
  a kit line for its walls and masses.

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
