# Peak playtest fixes, notes 1 to 11: work log

Kept by the session "Peak playtest fixes, notes 1 to 11" for the Second Director, who
owns `PLAYTEST_NOTES.html`. Branch `luchador-ui`. Pictures are in `after/`, named by
note. Every picture is the real game (`game/main.tscn`) driven by `tests/peak_watch.gd`
in a 1280 x 720 window; nothing here was played by hand.

How to take any of these pictures again (one Godot at a time; point `APPDATA` at a
scratch folder first, or the game goes full screen with Parker's own display setting):

```bash
Godot_console.exe --path . --audio-driver Dummy res://tests/peak_watch.tscn -- --no-steam --out=DIR --watch=cam:1.4:1.6
```

## Calls waiting for Parker

1. **Camera numbers (note 7).** First try: at most 11 m of view (`PEAK_CAM_HALF_MAX`
   5.5) and at most 1 m aimed below the climber (`PEAK_CAM_DOWN_MAX` 1.0), both at the
   top of `_peak_camera` in `game/main.gd`.
2. **Nine long jumps now land out of frame (note 7).** With the cap, 9 of the course's
   68 written flings have their landing outside the view while you stand at the launch
   hold: 3.5 Agujas (two), 7.8 Viento a Favor, 9.6 Tobogán Helado, 10.6 Gendarmes
   (two), 11.2 La Corona (two), 11.4 El Último Salto. They are 7 to 20 m across. The
   camera still steps back by itself once you fly faster than 5 m/s. Keep the cap
   strict, or let those zones keep a wider view (a flag on the zone, an hour's work)?
3. **Water colour (note 2), the Second Director's call, now with pictures.** Built
   tinted per cave. `WATER_TINTED` in `stages/peak/peak_zones.gd` is the one line:
   `false` gives Del Mar's own bright blue everywhere.
4. **The cart and the chain (note 6).** New rule: while the loose cart is in the air,
   a climber who also holds something else (the chain) keeps that and loses the cart.
   Is that the wanted outcome of catching the chain? (See note 6 below.)
5. **Chains past the track end (note 6), the Second Director's call, unchanged:** not
   moved. The first chain hangs 1.0 m from the end of the now-solid boards.
6. **The lift's hoistway (note 4):** Parker's eye on `04_lift_try3_hoistway_whole.jpg`.

## Note 7: camera far too pulled back, character too high

- **State:** fixed, seen in the game. First-try numbers, Parker's to change.
- **Commit:** see `git log` for "The Peak's camera stays close".
- **What changed:** `_peak_camera` in `game/main.gd`. One rule over all 111 zones: a
  zone's half height is capped at `PEAK_CAM_HALF_MAX` (5.5 m, so 11 m of view) and its
  aim below the climber at `PEAK_CAM_DOWN_MAX` (1.0 m). A zone that is cut down keeps
  its lean in proportion (a lean of 10 m written for a 28 m view would put the climber
  off an 11 m one). No zone (half 4.2) and the step back while falling or flying are
  untouched. No zone in the course was edited.
- **How many zones it touches:** 101 of 111 asked for more than 11 m; 60 aimed more
  than 1 m below the climber.
- **Pictures** (same spot, before and after):
  `07_camera_before_1_4.jpg` / `07_camera_after_1_4.jpg` (the rope, view 18 m to 11 m,
  climber 3.3 m above the middle to 0.6 m),
  `07_camera_before_1_6.jpg` / `07_camera_after_1_6.jpg` (the banded wall, 16 m to 11 m),
  `07_camera_before_1_8.jpg` / `07_camera_after_1_8.jpg` (Las Vigas, 26 m to 11 m,
  climber 6.0 m above the middle to 0.6 m),
  `07_camera_before_4_7.jpg` / `07_camera_after_4_7.jpg` (mushroom garden, 22 m to 11 m),
  `07_camera_before_9_3.jpg` / `07_camera_after_9_3.jpg` (glacier, 19 m to 11 m).
- **Checked:** the five spots above, standing still. The probe prints the view's height
  and where the climber sits in it.
- **Not checked:** the camera in motion (a fall, a fling, the cart ride) by eye; the
  other 106 zones one by one.

## Note 1: breaking planks come back with a glitch

- **State:** fixed (the parked fix in `bc54ac8`), now seen in the game.
- **What it is:** `_tick_holds` in `stages/peak/peak_things.gd`: a returning breaking
  hold grows from its own middle.
- **Pictures:** `01_plank_broken.jpg` (the second rotten plank of 1.3 gone),
  `01_plank_return_0.jpg` (42 ms into its return, 0.42 of its size, in its own gap),
  `01_plank_return_1.jpg` (113 ms, 0.86), `01_plank_back.jpg`.
- **Checked:** the probe measured the plank's drawn middle on every frame of the
  return: never more than 0.044 m from its place (before the fix it began about 170 m
  away). The same code runs every breaking hold.
- **Not checked:** an icicle, a snow bridge or the summit's brittle rock by eye (same
  code path, not pictured).

## Note 3: the mine's bucket

- **State:** fixed (parked fix in `bc54ac8`), now seen in the game.
- **Pictures:** `03_bucket_solid_outline.jpg` (the collision drawn in cyan over the
  bucket: floor on its base, walls to its rim), `03_bucket_hand_holds.jpg` (a hand
  holding the LOWER half of its wall, the half that had no collision, and riding down
  with it), `03_bucket_riding_in.jpg` (standing in it, both feet stuck, riding).
- **Checked:** drawn bucket 0.00 to 1.33 m up from its own zero (1.04 is the rim, the
  rest is the bail), -0.64 to 0.63 across; solid 0.00 to 1.04 up, -0.60 to 0.60 across.
  A hand laid on the lower wall stuck at once and stayed stuck over 4 m of travel.
  Standing in it, both feet stuck and the climber rode 4 m with it, joints closed.
  The counterweight (the thing you ride up) was measured too: model and collision
  agree exactly (0.00 to 1.20 up, 0.80 each side).
- **Not checked:** reaching the bucket by play from the counterweight or the deck
  (the probe sets the climber on it).

## Note 4: the two hanging lines in the mine

- **State:** third try in the game. Parker's to judge from the picture.
- **Try 1 (the Second Director's, parked): three stacked `station_scaffold` models.**
  Thrown out. `04_lift_try1_scaffold_whole.jpg`: a bright orange cross-braced tower,
  26 m tall, in the colour of every timber you hold in this mine. It reads as a
  climbing frame, which is the note's own complaint moved sideways. It also stood on
  nothing, over the 34 m gap.
- **Try 2: a dark gallows frame alone (post, arm, gusset) on the station deck.**
  Thrown out. `04_lift_try2_gallows_only_floating.jpg`: nothing reads as a rope, but
  the bucket and the counterweight float alone in the dark with nothing behind them.
- **Try 3 (in the game now): the hoistway painted on the cardboard behind the climb.**
  `04_lift_try3_hoistway_whole.jpg`, `04_lift_try3_hoistway_from_catwalk.jpg`; it is
  also behind the bucket in `03_bucket_riding_in.jpg`. Two flat cards in the back
  wall's own grey (`HOIST_TONE` in `tools/peak/areas/a1.py`, one place to change it):
  a gallows on the station deck holding the pulley, and hung from its arm the old
  back boards, 4.4 m wide, that the bucket and counterweight run in front of, ragged
  at the bottom. Why this one: in this mine bright orange in the play plane means
  "hold me" and dark flat cardboard means "behind you". It is broad, so it is not a
  line; it has no rungs or lattice, so it is not a ladder.
- **My doubt:** it is quiet, a dark grey shape on a darker wall. If Parker wants the
  lift's "track" to be seen more, lighten `HOIST_TONE` (it takes a "#RRGGBB").
- **Checked:** pictures only. Nothing in it has collision (cards never do).

## Note 5: wind streaks where there is no wind

- **State:** fixed (parked fix in `bc54ac8`), now seen in the game.
- **Pictures:** `05_wind_a1.jpg` (the waterfall: the streaks are inside the fall's
  column and nowhere else; they are faint against the falling water),
  `05_wind_a1_where_the_stray_band_was.jpg` (the banded wall under the cart ledge,
  31 to 38 m up, where Parker met the band: no streaks),
  `05_wind_a4.jpg` (the first updraught of 4.3 in the mushroom garden: upright
  streaks rising inside the column over the climber).
- **Checked:** the probe read both emitters: born in a box the zone's own size and
  place (6.0 x 112.0 m at the fall; 4.6 x 7.7 m in a4), not turned, flying along the
  wind.
- **Seen, not part of this note:** an updraught gets few streaks (the 4.6 x 7.7 m one
  has 8), so it is still easy to miss. Say if they should be denser.

## Note 6, the track end: collision on the boards

- **State:** the track end is fixed (parked fix in `bc54ac8`), seen in the game. The
  cart itself is further down this log.
- **Picture:** `06_track_end_close.jpg` (the climber held on the last boards, 1.1 m
  past where the collision used to stop).
- **Checked:** stood at x -212.7 (it was air west of -211.6): both feet stuck.
- **Waiting for Parker (the Second Director's call, unchanged):** the first chain now
  hangs 1.0 m from the boards' end. The chains were not moved.

## Note 8: the dark plank by the big wheel

- **State:** fixed (parked fix in `bc54ac8`), seen in the game.
- **Pictures:** `08_staging_close.jpg` (one run of planks under the wheel),
  `08_staging_west_end.jpg` (standing on what was the dark plank: held).
- **Checked:** both feet stuck on the west end at x -236.6. The west end darkens a
  little in the pictures: that is the lantern's light falling off, not another piece.

## Notes 9, 10, 11: the cave-in's rocks (challenge 1.10)

- **State:** all three fixed and watched in the game.
- **Note 11, the rhythm.** The two sources follow one written loop. In
  `tools/peak/areas/a1.py`: `ROCK_GAPS = [4.6, 0.4, 5.5, 2.2, 3.8, 3.8, 2.2, 5.0, 0.4,
  5.1, 3.0, 3.0]` (39 s, 12 rocks) and `ROCK_ORDER = "ABAABABAABAB"`, which is which
  source makes each drop, read off today's two timers so every rock still falls from
  its own source. `Area.rhythm` turns the two into each source's times;
  `spawner(times=..., loop=...)` in `peaklib.py` and `_drops` in
  `stages/peak/peak_things.gd` are what learned to follow a list. The parked periods
  5.0 and 6.6 are gone.
  **Watched:** 46 s of it. The gaps the probe measured between rocks appearing:
  5.5 2.2 3.8 3.8 2.2 5.0 0.4 5.1 3.0 3.0 4.6 0.4, the written list (it joined the
  loop part way round). Two checks were added to the `--peak` battery for the
  list-following itself.
- **Note 9, no vanishing.** A snapped catwalk board, propped on a heap of rubble, lies
  at the fallen beam's foot (`A.board(...)` in `a1.py`, kit models `plank` and
  `rubble_pile`, no new models). A rock that touches it is thrown up and back, 2.3 m
  behind the climb, shrinking as it goes; from that moment it has no collision and can
  knock nobody out; it drops behind the gallery's own floor and is removed there, out
  of sight. The board is solid grip wood and dips when a rock lands on it.
  **Watched:** 14 rocks in a row (a whole loop and two more) left by the board; every
  one was last seen below the floor's top, 2.3 m behind the climb. None rolled past
  the board onto the gallery (furthest west any loose rock got: x -223.4, the board).
  Stood on the board: it holds.
  **The net, not seen to fire:** a rock that somehow never reaches the board (12 s, or
  lying still 1.5 s) breaks into chunks where it lies, as a breaking plank does. It
  never blinks out.
- **Note 10, the hitbox.** Kept at 0.60 m (the parked value). The rock is 0.42 m in
  radius, so a knock-out now needs the rock's surface within 0.18 m of the middle of
  your head, chest or hips: it has to be on you. I did not find it looking wrong.
- **Also fixed on the way:** on the first tick after a load every rock source dropped
  one at once (an unwritten double if you resumed in the gallery). A source now takes
  its place in the rhythm silently.
- **Pictures:** `09_board_idle.jpg`, `09_rock_thrown_0.jpg`, `09_rock_thrown_1.jpg`,
  `09_rock_thrown_2.jpg` (the two rocks of a double going up and back; in the last
  one passes behind the lantern), `09_board_stood_on.jpg`.
- **First-try numbers:** the throw (1.4 m/s west, 5.2 up, 3.3 back) and how small the
  rock gets (0.6 of its size at the back).
- **Not checked:** a knock-out by a rock (nothing was changed there but the parked
  reach); the sound of the board (a thwack and a creak, chosen blind from the Peak's
  own sounds).

## Note 6, the cart: it falls for real (challenge 1.7)

- **State:** fixed and watched in the game, three ways. Feel numbers are first tries.
- **What changed:** `cart1`'s road in `tools/peak/areas/a1.py` is now only the rails
  and the first dip off their end (`TRACK`, four points). 9.2 m along it
  (`CART_LOOSE`: x -215.6, a cart's length past the end of the boards) the mover is
  let loose: `_let_loose` in `stages/peak/peak_things.gd` makes a 140 kg rigid body
  where the cart stands, with the speed (4.7 m/s west, 1.7 down) and the lean it had,
  and moves the drawn cart onto it. It falls at a rock's gravity (5.4 m/s2). Any
  `once` path mover can do this with `"loose"` in its motion. `cart0`, the ride in
  from the station, has no `loose` and is untouched. The two chains were not moved.
- **Watched, empty** (the climber steps off as it starts): rolls 0.70 s after you
  stand in it, is let loose 3.08 s later, tips nose down and tumbles, hits the Sump
  5.3 s after that going 21.7 m/s (it took about 15 s before), sinks, and lies on the
  Sump's floor at x -235, about 5 m east of the fall. 12.6 s after it was let loose
  it is back on the rails, drawn and solid.
- **Watched, ridden** (both feet stuck in it): the feet's welds are made again on
  the loose body the moment it is let loose (THE LATE TRANSFORM LAW: the body is
  pushed to the physics server first). The climber stayed on it all the way down,
  tumbling with it; joints never opened more than 0.012 m; ended in the Sump on the
  sunk cart, feet still stuck (lift them to float up).
- **Watched, a hand on the chain** (the probe put a hand on the first chain's tail
  as the cart went under it): the feet let go of the cart and the climber stayed on
  the chain; the cart fell alone. **This is a new rule and Parker should know it:**
  while the loose cart is in the air, a climber who also holds something else keeps
  that and loses the cart. Without it a 22 kg climber on a chain held the 140 kg cart
  up by the feet for good (seen in the first test run). Before today the opposite
  happened: the cart was unstoppable and tore your hand off the chain.
- **Other things it does:** bangs when it hits something hard (the cart's crash
  sound, louder the harder); in water it slows, sinks and stops tumbling; it passes
  through ropes and chains rather than hanging up on them.
- **Pictures:** `06_cart_empty_0.jpg` (on the rails), `06_cart_empty_1.jpg` (0.35 s
  after it was let loose, tipping off the end), `06_cart_empty_2.jpg` (tumbling),
  `06_cart_empty_3.jpg` (sinking in the Sump), `06_cart_empty_4.jpg` (at rest),
  `06_cart_empty_home_again.jpg`, `06_cart_ridden_2.jpg` (the rider going down with
  it, the game's own camera), `06_cart_ridden_4.jpg` (rider and cart on the Sump's
  floor).
- **First-try numbers:** where it is let loose (9.2 m), its mass (140 kg), its
  gravity (0.55 of the engine's, `LOOSE_G`), the nose-down turn it starts with
  (0.9 rad/s), its bounce (0.3).
- **Not done, on purpose:** the speed on the rails is still 5 m/s. The notes page
  suggests trying 7 to 8; that is the Second Director's idea, not Parker's words, so
  it waits for him.
- **Not checked:** a real player catching the chain by play; the splash when it hits
  the water is the old sound only until note 2 lands (below).

## Note 2: water uses Del Mar's shader and splashes

- **State:** done and seen in the game: splashes, surface, front, tint. One call for
  Parker (the colour).
- **Splashes.** They are Del Mar's own, thrown by Del Mar's own class: every pool has
  a `DelMarSea` node (`stages/delmar/delmar_sea.gd`, not edited) and
  `PeakZones.splash_at` calls its `splash`: the fan of pale blobs, two rings stamped
  on the surface, the splash sound (the small sound for small things).
  - Going in: sized by how fast you hit it (0.75 to 1.5 of Del Mar's climber splash).
  - Coming out: a smaller one (0.5) where you left the water.
  - Other things: a rock of a rock fall, the chunks of a broken plank, a loose barrel
    or boulder (`_tick_wettings` in `peak_things.gd`), and the cart let loose (1.6).
    Small ones in one pool are thinned to one every 0.22 s, so a plank's two dozen
    chunks do not throw two dozen splashes.
  - One difference from Del Mar, on purpose: Del Mar's blobs are lit by the scene, and
    in a cave's lamp light their shaded side went smoke grey (first run). The Peak's
    wear a copy of the same blob with a pale shade (`_pale` in `peak_zones.gd`).
- **Surface.** The top of each pool is a sheet dressed by `DelMarSea.dress`, so it is
  Del Mar's shader (`sea_surface_fast.gdshader`) with its foam circles, the ripple
  rings a splash stamps in, and the ink replayed. Seen from the side it is a strip:
  a line when the camera is level with the water, about half a metre of foam when
  the camera is 3 m above it.
- **Front.** New small shader `stages/peak/peak_water_front.gdshader`: a clean tint
  that deepens downward, a waterline that is never a ruled line, a paler band under
  it. A river's waterline ripples run with its current.
- **Flecks kept** on every river and race, as before.
- **Eddies** (three still patches laid over the river of 2.8): they were a second
  see-through box, which is why they showed darker. They are now a darker patch of
  the front only, so they still read, and their top is the river's own.
- **A waterfall's foot** churns the pool it lands in (Del Mar's spray and rings),
  while you are within 40 m. The Sump's is the only one today.
- **Tint, one place:** `WATER_TINTED` and `water_colors` in `peak_zones.gd`. Tinted is
  Del Mar's two blues pulled toward each area's own dark card colour.
- **Frame rate, Las Aguas Negras with all 13 on** (the real game in the probe's
  1280 x 720 window, vsync off, 5 s each, on Parker's PC while it was in use):

  | standing at | before | after, run 1 | after, run 2 |
  |---|---|---|---|
  | 1.3 (the mine, the Sump in the area) | 342 | 333 | 319 |
  | 2.3 (the race) | 263 | 230 | 264 |
  | 2.8 (the river and its eddies) | 278 | 275 | 280 |
  | 2.10 (the small pool) | 310 | 288 | 292 |

  Frames a second. The two "after" runs differ from each other as much as from
  "before", so the cost is inside this machine's noise; the worst single reading is
  12 percent down at 2.3. Not measured at 4K or full screen.
- **Pictures:** `02_before_sump.jpg`, `02_before_river.jpg` (yesterday's water),
  `02_water_sump.jpg`, `02_water_race.jpg`, `02_water_river.jpg`,
  `02_water_pool.jpg`, `02_water_lake.jpg`, `02_splash_in_0.jpg`,
  `02_splash_in_1.jpg` (0.12 s and 0.32 s after hitting the Sump from 6 m),
  `02_splash_out_0.jpg` (leaving), `02_splash_cart.jpg` (the cart going in),
  `02_splash_chunks.jpg` (a chunk going in).
- **Checked:** the five kinds of water in pictures; a climber in and out; the cart;
  three chunks dropped together threw one splash (the thinning).
- **Not checked:** the swim itself by play (the forces were not touched, and the
  battery's swim checks pass); a2's water with a climber in it; the look at 4K.
- **For whoever opens the editor next:** `stages/peak/peak_water_front.gdshader` and
  `tests/peak_watch.gd` have no `.uid` files yet (nothing here ran the editor); the
  editor will write them.
