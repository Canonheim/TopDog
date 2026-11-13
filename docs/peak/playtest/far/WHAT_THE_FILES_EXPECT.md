# What the two backdrop files expect

From the TD Environment Maker, who wrote both files, passed on by the Top Dog session on
2026-11-13, for whoever changes them on `luchador-ui` in the far-facade remake (Parker:
"these all fall to you to remake as the background director"). Top Dog asked it what a
newcomer to the files would not know. Its answer, in full.

## `stages/peak/peak_backdrop.gd`

1. **Keep the two groups and what goes in each.** `tick()` treats them differently.
   `_outside` (the land) shows above y 430, or lower when the camera is out on the east face,
   and sinks 1,800 m as a fall nears the trailhead so nothing of it stands behind the plaza.
   `_sky` (the clouds) shows only above 430 and comes down from +1,100 m over the next 130 m,
   inside the chimney where nobody sees it arrive. The valley card belongs in `_outside`; the
   cloud banks in `_sky`. A card put straight on the backdrop node will show from the trailhead.
2. **Coordinates are the course's local metres.** The node is top-level and placed at the
   Peak's origin, so a card built in world metres lands 110 m off.
3. **`town_at()` must still return where the town is PAINTED on the new card,** in the world
   (`position` + a local point). Nothing calls it yet, but the summit bell's fireworks are
   meant to rise from it, and they must climb past y 932 local to be seen above the clouds.
4. **Clouds that drift** go in `_clouds` as [node, speed, half width, lo x, hi x] and move
   only through `LuchaKit.drift_cloud`, which never wraps a cloud in view (Parker: "make sure
   we are not seeing clouds pop in and out"). Static banks can stay out of the list.
5. **A card's visible face must have its normal toward the camera (+z).** A face built the
   other way round (`LuchaKit._extrude` does this for far cut-outs) draws at about 0.6 of its
   colour: yellow goes olive. `_cards()` builds them the right way.
6. **The game's sun lifts a lit card about 1.3 times and bluer,** and a floor facing up far
   more; pale colours go white. The old depths ran to 3.9 km and rely on the camera's 4,000 m
   far plane.
7. **The caves** (`_build_caves`, `_caves`, the Rect2 test in `tick`) are separate from the
   outside and already flat cards. They are hidden behind the mountain's body card as the
   course stands. Leaving them alone costs nothing.
8. **The storm deck** (the dark wall at local y 905 and the three drifting rows) is in `_sky`
   and is already flat cut-outs; it reads as cloud only because each is a row of round heads
   merged into one outline.

## `stages/plaza_mountains.gd`

1. **`build()` must keep returning one entry per standing piece** as [node, standing y, how
   far it sinks]. `LuchaUI.mountains_down()` sinks each by its third number for Del Mar and
   sets `visible`; a card left out of the list stays standing behind Del Mar.
2. **The Peak is the LAST entry** and is built by `peak()`, which sets the statics `_peak`
   and `_flag`. `main.gd` calls `PlazaMountains.peak_shown(not on)` and
   `peak_flag(Peak.summited())`. If `build()` stops calling `peak()`, both hooks go silent
   and nothing errors.
3. **Call `peak_shown()` after `mountains_down()` has settled:** `mountains_down` sets
   `visible` on every entry while it moves, and would undo it.
4. **Where the row stands was fitted to the Peak:** the left range was moved right so it does
   not stand in front of the fang, the row has no snow so the Peak is the only snow in view,
   and the row is 38 to 50 m tall so the Peak stands over it. The Peak's summit is at world
   x -350, z -700 so its head clears the title's focus star. New range cards at other places
   or heights can cover the fang or the cable.
5. **Far things cast no shadows here.**

## Both files

One atlas material only (`CelPass.paint`, or surface materials then `CelPass.unify`); never
change a material `LuchaKit.mat()` returns.

## From the Top Dog session, for the Peak file

Since 11-12 main hides the plaza and the swirl sky once the climber is inside the mountain
(`main.gd`, `_tick_peak`: when at.x < -34 or at.y > 30), and a11's nearest cloud card was
moved behind the play plane (z -5) because at z 3 it hid the storm ridge. So no new card
should stand in front of the plane over another area's route.

---

# The two pieces added later: the plaza's Peak, and Del Mar's far shore

The Environment Maker's handover notes for these, read from the code on 2026-11-13 and
passed on by the Top Dog session, in full.

## A. `PlazaMountains.peak()` (`stages/plaza_mountains.gd`)

Nothing outside the file reads the model. The only callers are LuchaUI (`build()`),
`main.gd` (`peak_shown` and `peak_flag`) and its probe. `PEAK_AT`, `PEAK_H` and the outlines
are used only inside the file. What must survive:

1. **One root node,** set as `_peak`, returned as the LAST entry of `build()` as
   [node, standing y, sink]. The sink is `PEAK_H` + 40 (218 m): it must stay more than the
   card's full height, flag included, or the tip stands behind Del Mar.
2. **Everything else is a CHILD of that root,** so it sinks and hides with it: the cable with
   its two red cars and two huts, the storm cloud and bolt, the mine mouth, and the flag. A
   separate `plaza_peak_flag` must be parented to the peak's root, set as `_flag`, and start
   hidden. If it is added to the plaza instead, it will not sink for Del Mar and
   `peak_shown(false)` will leave a flag in the sky behind the trailhead.
3. **The flag stands on the summit** at `_pm(-350, 1000)`: world x -350, z -700,
   y = ground - 1.0 + 178. Pole 13 m, cloth 12 by 6 m.
4. **Height is capped by the frame, not by taste:** the summit and its flag must stay under
   the top of both the title and the lobby frames. On the title only the head shows (roofs
   and the menu cover the rest), and x -350 is what clears the title's focus star (at -300
   the head sat behind it).
5. **The outline is the course's own** (st.py EAST and WEST), so what is seen from town is
   what is climbed; x is doubled (`PEAK_WIDE` 2.0) because at true width a critic read it as
   a pole, and the fang is thicker again. The gap between the fang and the face must be CUT
   OUT of the card so sky shows through it; painted, it will read as a stripe.
6. **Looks that were fixed by critics, worth keeping on the card:** warm stone, not haze
   blue (blue rock could not be told from the snow); the Peak is the only snow in view; ONE
   taut cable (two sagging lines read as bunting); the storm cloud sits under the summit so
   the head stands clear of it.
7. **Yellow and red cards:** a card square to the camera draws at about 0.6 of its colour in
   this light (the bolt went olive). The bolt was turned (-34, 35 degrees) and the flag
   (30 degrees) toward the sun. A kit card will need bright mid-values or the same turn.
8. **To check it:** `tests/delmar_shot_probe.tscn -- --plaza-only --flag --out=DIR` shoots
   the title, the lobby and a long lens on the Peak with the flag up (cams `dm_title`,
   `dm_lobby`, `plaza_left`, `peak_tele`).

## B. `DelMarScenery._build_far_shore()` (`stages/delmar/delmar_scenery.gd`)

No tick, sink or visibility rule touches the far hills or the islands. The scenery exists
only during a Del Mar match, and `tick()` moves only ships, bobbers and the foam line. The
sea, the buoy and the camera read nothing from them. The traps are in the build:

1. **THE SHARED RANDOM STREAM.** `build()` seeds one `_rng` (2611) and every builder after
   the far shore draws from it: the headland, the boardwalk, the town, the shore dressing,
   the ships and the clouds. Taking the hill loop out changes how many numbers are drawn,
   and every palm, dune, rock and cloud in Del Mar moves. Those were placed by eye over
   several critic rounds. To keep them: run the old function once, print `_rng.state` at its
   end, and set `_rng.state` to that number at the end of the new one.
2. **The function builds four things; only two are far layers.** KEEP the far beach strip
   (the sand and wet sand shelving into the sea at z -300: it is ground) and the real props
   along it (the rocky point, the two sea stacks, and the broken strip of dunes, bushes and
   palms at z -293 to -297, which is there so the beach does not meet the hills on a ruler
   line). REPLACE the four hill rows (z -291 to -248) and the three islands.
3. **The hills must never stand over the bay.** Each one ends a little inland of the
   waterline at its own depth (`coast_x(z)` - 6), and the rows come down toward the spit and
   end at the rocky point (end_x = `coast_x(-300)` - 4). One card at one depth has one
   coast_x: its right end must stop at that, and taper down to the point.
4. **The hills start at x -170 and stand on `GROUND_Y` - 0.4 (-1.32).** They sit where the
   plaza's mountains were: those have sunk by then, so the new plaza range cards must sink
   fully or they will show through the Del Mar hills.
5. **The islands:** at (580, -880), (705, -1100) and (640, -1010), 30 to 70 m wide, 8 to
   18 m tall, base at `WATER_Y` - 0.6 (-2.4). They are placed out of every plaza camera's
   reach at their depth (x - half width > 31.4 + 0.5436 d) and painted darker than the
   clouds (`HAZE_ISLE`) so they read as land.
6. **Depth is shown by colour only, no fog:** sandy dunes, green, paler blue-green, then a
   hazy blue ridge (`HILL_ROWS`). Nothing here casts shadows.
7. **`PlazaMountains.massif()` is called from here** (two places). If `massif()` changes for
   the plaza, Del Mar's fall-back changes with it.
8. **To check it:** the same probe without `--plaza-only` shoots Del Mar's cameras with the
   mountains sunk.

Del Mar's sea is itself a flat plane to the horizon. The Environment Maker read the rule as
about land, and Parker has seen and kept that sea, so neither it nor the Top Dog session
raised it as a breach.

From the Top Dog session: B1 (the shared random stream) is the one it will check hardest
when the branch comes to main, with before-and-after Del Mar frames, since a shifted stream
moves everything and no test fails.
