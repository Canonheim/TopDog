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
