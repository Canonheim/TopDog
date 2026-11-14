# The fix run that starts the night of 2026-11-13

For the fix thread. Parker has finished playtesting the whole mountain and has answered
every open call. Asked what may start overnight, he picked "Docs, models and fixes". So the
hold on fixes is lifted, for what is listed here.

Everything is on `luchador-ui`, as before: commit by path, never push, one Godot at a time
through the gate with a timeout, before and after pictures into `docs/peak/playtest/after/`,
your record in `WORK_LOG.md`. You never edit `PLAYTEST_NOTES.html`: report to the Second
Director, who updates it. Each note is `<div class="note" id="nN">` on that page: Parker's
words, the cause, the plan, and "Settled" lines with his later answers. His exact answers
are also in `docs/peak/playtest/design/ANSWERS.md` (three rounds). Both playtests were on
an old build, so check the branch before you fix: a few things are already done.

## Who owns what tonight

- **You:** the game's code, and the course's area files `tools/peak/areas/aN.py` (and the
  JSON they generate).
- **The modelling run (the Second Director and the maker threads):** new models, and each
  biome's SCENERY, which will live in its own file `tools/peak/areas/aN_dress.py` with one
  function `dress(A)`, called from `aN.py` exactly as `a0_station.py` is from `a0.py`. If
  you are in an area file and that call is not there yet, do not add scenery yourself.
- Where a fix needs a model that does not exist, build the play with a plain stand-in in
  the right colour and say so; the model follows. Do not make models.
- The climber's own code (`climber/`) is the Top Dog session's. Notes 90 and 101 touch it:
  leave 101 (the ending ceremony) alone; for 90 see below.

## Order of work

Report after each group. Groups 1 and 2 first; after that, bottom of the mountain upward.

### Group 1: rules of play, mountain-wide (code)

1. **A crunch knocks you out** (notes 49, 78). When the head, chest or hips are pinned
   between a moving piece and anything solid (or two moving pieces) with no room left,
   knock out, with the stars and the sound. "Head or body only": a trapped hand or foot
   slips free. One rule for gears, sheaves, pistons, counterweights.
2. **Held between two moving things** (note 83): when both things move, the grip that lets
   go is on the thing with FEWER of your limbs; if a tie, the lower one. All limbs on the
   losing thing let go together. When one thing is still, the moving thing wins, as now.
3. **Cold shows on the hand** (note 84): the button mark on a limb that holds timed ice
   shivers, harder as the 2 seconds run out, until the hand lets go. `TELL_COLD` frost can
   stay off.
4. **Sharp tips are blunt as solids** (note 90): an icicle, needle or spike is drawn sharp
   but its solid ends blunt (cut the last 0.15 m or so off the collision), so a point can
   not wedge between a hand and its forearm. Test: a hand dragged across a point.
5. **What can be touched is drawn**, the plain cases that need no new model:
   - the summit's six ring ropes (note 98): a bounce line with look "rope" and no model is
     drawn as a thick band along its line, with a cushion at each end, squashing when it
     throws; the real rope model replaces it later;
   - the bull wheel at 7.10 (note 76): draw the model at the solid wheel's 7.6 m
     (`model_scale`), until the re-made model lands;
   - every gondola's step and rack (note 77): a plain iron bar stand-in on each, exactly
     along the solid part.
6. **Ice that comes is seen coming, ice that goes shatters** (notes 86, 88, 91, 93):
   - a falling icicle grows at its source during a few seconds before it drops, and breaks
     into harmless pieces on the first solid thing it lands on (nothing is left lying;
     nothing blinks out). Check a knocked-out climber on the lower crevasse's floor can
     always get up and away;
   - the snow slabs of 9.8 show in a hole at the top of the chute, creep out during the
     warning, slide, and are thrown into the background by a kicker at the rope's foot (the
     mine's board, in ice). No slab reaches the climb below;
   - the serac of 9.5 does not stop at 75 degrees: it falls through level into the pit and
     shatters there, taking whoever is on it; the next one grows up in its place over a few
     seconds and can be touched only at full height.
7. **Wind is drawn loudly** (note 89; he likes "the flag and wavy wind idea"): long wavy
   lines with an inked edge that fill the wind's whole box and move at its speed, and
   streamers and flags inside it that stream its way and hang slack between gusts. The
   lines stop where the wind stops (note 70).
8. **Lightning says what it is** (note 95): sparks crawl up the mast's metal during the
   hum, a drawn bolt hits the tip, the metal stays lit for the strike, and the button mark
   on a limb touching metal buzzes during the hum. No glowing materials.

### Group 2: small numbers and the HUD

- Note 55: the banner's quiet time is 40 seconds (`area_quiet_s`).
- Note 7: at the nine long jumps, a tool tip at the bottom right: "Hold [key bind] to widen
  the camera", naming the player's own bind. No automatic widening.
- Note 28: the Controls board gets a Next page button, and the two camera controls get
  rows on the second page. No rework of the board.
- Note 85: the big icicles of 9.2 hold 1.5 seconds (first try).
- Note 63: every vent about 10 per cent stronger. Note 61: half as many rings in the
  updraught shaft. Note 49: the gears turn twice as fast.

### Group 3 onward: the course, by biome, from the bottom

Take each note's plan and its Settled lines. Where a design page exists for the place
(`docs/peak/playtest/design/aN/`), it shows the place as it should be after the change.

- **a0:** 73 the cart really hops the broken rail, with dust as it lands.
- **a1:** 103 the cart room reworked (WAIT for the redone design page of 1.7 and 1.8: the
  Second Director will tell you when it is in). It replaces note 6's chain.
- **a2:** 25 the dam's lift goes straight up a shaft and always sinks when you stop
  winding.
- **a3:** 26 truly slanted crystal shafts, the six flings re-laid; 34 the ring spikes;
  74 La Columna's collars, as drawn on its design page ("Yes, build that").
- **a5:** 52 all eight more pits lined so their insides cannot be held; 54 both altars
  count, and F farts on the keyboard.
- **a6:** 58 the dynamite rung; 62 the high red block, shown either way.
- **a7:** 70 the tail wind's box out to the fang's face.
- **a8:** 79 El Cable out (its five stretches, frayed end and clamp plate): one long jump
  from the gondola's rack to pylon 2's landing; 80 the four chairs' hanger rods are not
  solid (the gondolas' hangers STAY solid); 81 El Pilón's brace and rung out; 82 the zip
  line runs all the way to the maintenance deck. (77: the station roofs become real: WAIT
  for the redone design pages of 8.1 and 8.11.)
- **a9:** 86, 88, 91, 93 as in group 1; the lower crevasse's small moves in 9.3 as its
  design page lists them.
- **a10:** 92 the six flat grey cloud cards in front of the climb come out; 96 the weather
  balloon has one rope, hung from the middle of the basket.
- **a11:** 99 the breaking plank at El Último Salto goes and the iron ring moves up 1.9 m
  to the height of the corner post's top, still 3.7 m west of it; 100 the bell rope rings
  the bell, and the bell and its clapper swing. (102, the secret west of the peak: WAIT for
  its redone design page.)

Not for you tonight: anything that is only a new model (frogs, huts, signs, the tea
places, the statues' broken arms, the staples, cracked breakables); note 101.

## For every fix

Say what you measured, show a before and an after, list what you could not try, and name
any number that is a first guess for Parker to change. Nothing has to be perfect tonight:
a working first version of each, honestly reported, is the goal.
