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

## Where each note stands (11-12, end of the pass)

| # | Note | State | Commit |
|---|---|---|---|
| 1 | Breaking planks come back with a glitch | Fixed, seen in the game | `bc54ac8`, seen in `81f7130` |
| 2 | Water: Del Mar's shader and splashes | Done, seen in the game. Colour is Parker's call | `de35654` |
| 3 | The bucket: nothing sticks, collision wrong | Fixed, seen in the game | `bc54ac8`, seen in `81f7130` |
| 4 | The two hanging lines look like ropes | Third try in the game, Parker's to judge | `81f7130` |
| 5 | Wind streaks where there is no wind | Fixed, seen in the game | `bc54ac8`, seen in `81f7130` |
| 6 | The cart falls too slow; the track end | Both fixed, seen in the game. One new rule for Parker to know | `022e0d5` (cart), `bc54ac8` (track end) |
| 7 | Camera too pulled back, character too high | Fixed, seen in the game. First-try numbers; nine long jumps to decide | `65e26fc` |
| 8 | The dark plank by the big wheel | Fixed, seen in the game | `bc54ac8`, seen in `81f7130` |
| 9 | Rocks: more delay, bounce away off a board | Fixed, watched: 14 in a row left by the board | `7220cae` |
| 10 | Rocks: a slightly smaller hitbox | Kept at 0.60 (parked value) | `bc54ac8` |
| 11 | Rocks: half a second more after a double | Fixed, watched: the gaps as written | `7220cae` |

Nothing was blocked. Lint (88 scripts, 0 failed) and the `--peak` battery (0 fails) were
run after every commit's code. Nothing was merged, pushed or built. Nobody has PLAYED
any of this: every check is the probe standing the climber somewhere and making the
thing happen.

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


---

# SECOND BATCH: notes 12 to 57 (released by Parker 11-12 23:53)

Same rules, same probe. Groups are the Second Director's. Each group has its commit in
its heading once it lands.

## Calls waiting for Parker from this batch

(kept up as groups land; each is also in its note's entry)

- **Note 51:** inside the mountain the sun no longer casts shadows at all. That is what
  the black band was. If he misses the climber's own shadow on the back wall in the
  caves, it is one line (`shadow_opacity` in `_tick_peak`, `game/main.gd`).
- **Note 40:** six front layers were kept (list and pictures below). The storm ridge's
  six clouds are among them because the note left them undecided.
- **Note 52:** eight more slots were found on the mountain and NOT changed (list below).
- **Note 39:** the count was 39 patches, not 19. All 39 are out.
- **Note 21: the barrels' gaps are Parker's to choose.** Measured: about 1.3 m of
  water between two barrels is a plain stretch. The first try has eight gaps: four
  inside that, two a lunge (1.6, 1.7 m), two a swim (4.0, 4.4 m). `BARREL_GAPS` in
  `tools/peak/areas/a2.py` is the list.
- **Note 53:** the climb up the altar's east wall, now brushed by an arm every 2.3 s,
  was not tried by anything.
- **Note 20: the pace of a swing is the game's gravity.** A climber falls at 2.79 m/s2,
  and a rope that swings with it swings at that pace: 8 s there and back on a 5 m
  rope, 11 s on 9 m. The old rope fell at 9.8 and came back in 5 s, dragging the
  climber. If 8 s feels slow there is no rope number that shortens it; it is the
  climber's gravity or nothing.
- **Note 20: a swing now reaches two to three times as far**, on every rope, chain and
  vine. The table under group G lists each one. Moves laid out as "fling from a rope to
  the next thing" can now mostly be swung to and taken. Nothing in the course was moved.
- **Note 20: wind and a climber on a rope.** The winds push at 3 to 4.5 m/s2, harder
  than the climber's gravity. The old rope's weight held a climber near plumb in them
  (about 12 degrees off). On a light rope the wind carries the climber out to 50
  degrees and more: the balloon's ropes (10.8), the serac's rope (9.6), the prayer
  line (10.1). Whether that is the storm doing its job or too much is his call; the
  knob would be the winds, not the ropes.
- **Notes 28 and 43: the pad under Steam was not tried.** When Steam is running the
  game reads pads through Steam's own layer, from a layout the game writes. The right
  stick and the left trigger were not in that layout. They are now, written blind:
  there was no pad under Steam to try them on. If the right stick or the left trigger
  does nothing in a Steam run, that is where to look (`core/steam_input.gd`, groups 4
  and 5 in `_config`). With Steam off, and in the test, they work.
- **Notes 28 and 43: not on the Controls board.** Look and zoom can be rebound in the
  save file and follow the board's Reset, but the board itself has no rows for them:
  it is the UI kit's poster, laid out for six rows with six badges. Two more rows and
  two badges are a job for the UI creator.
- **Note 28: how far the look goes.** The page said "about three quarters of a screen"
  and also "your climber is still just in view on the opposite side". Those disagree:
  three quarters of a screen puts the climber off it. Built to the second: 85% of the
  way from the middle to the edge (`PEAK_LOOK_REACH`, `game/main.gd`).
- **Note 35: I cannot hear it.** The garden's bed was rebuilt from its recipe, not by
  ear. Dan (or Parker) has to say whether the static is gone. If it is still there,
  the next suspects are the garden's steady effects: `spore_puff` (its recipe ends "a
  little fizz") and the updraughts' wind loop.
- **Note 20: climbing a rope is slower than it was, on purpose.** 3 m hand over hand
  takes about 5.6 s; it took 2 s, and that speed was the launch he complained of.
  `rope_pull` in the F1 panel sets it.

## Group A: bugs you can see (notes 39, 40, 47, 48, 51, 52, 55)

### Note 48: the temple's pistons

- **State:** fixed, seen in the game.
- **Cause, confirmed in the game:** the note's reading was right. In, each piston's end
  lay exactly in the wall's face (`48_pistons_before.jpg`).
- **What changed (`tools/peak/areas/a5.py`):** each piston sits 0.33 m past the wall's
  face when it is in (`SOCK`); its travel is 0.33 longer so the tip reaches where it
  did. 2.4 m of rock was added behind the west wall so the longer run stays inside it.
- **A sliding piece that goes into a wall lets go of you at the wall's face.** This is
  now the game's rule for every `cycle` and `path` mover, with no authoring: a hand or
  foot on such a piece is let go the moment the point it holds is inside solid rock
  (`_wall_wipe` in `stages/peak/peak_things.gd`). So it also covers the temple's
  phantom blocks, which slide into their ramp. It does NOT apply to the door's three
  steps of 5.1 as the note thought: those slide under the next step into open air, not
  into rock (they still scrape you off against the step above, as designed).
- **You can see it coming:** half a second before a piston starts back, its socket
  puffs dust and trickles (`socket` on the mover; the sound is the Peak's
  `dust_trickle`, pitched up, chosen blind).
- **Sockets you can see:** a pale carved frame and the dark of the channel on the
  wall's cut face, one per piston. They are thin cards in front of the wall's rock
  only.
- **The walls reading as unholdable:** in the game they already draw as the dark wet
  slick (`48_pistons_before.jpg`); nothing changed there. If Parker's picture showed
  them pale, it was the lit edge of the wall, which is still there.
- **Watched:** a hand set on a piston's top 0.6 m out from the west wall was carried in
  and let go at x -371.93 (the face is -372.00), 4.04 s after the test began. A hand
  pressed to the wall at a sleeping socket, and between two sockets: holds nothing.
- **Pictures:** `48_pistons_before.jpg`, `48_piston_hand_on.jpg`,
  `48_piston_wiped.jpg`, `48_pistons_after.jpg` (sockets, and two dust puffs).
- **Not checked:** climbing all nine in time by play. Their timing was not touched.

### Note 47: the climber goes behind the great mask

- **State:** the climber is in front of the mask and the jaw now, seen in the game. The
  later half of the note (the carved features become the holds) needs the mask's
  outlines from the Building Maker: see `MODEL_REQUESTS.md`.
- **Cause, confirmed:** `47_mask_before.jpg`: the climber on the jaw is not in the
  picture at all, only its hand markers.
- **What changed:** the mask's deco from z -1.2 to z -2.9 (its front face is now 0.8 m
  behind the play plane); the jaw's model is set back 0.6 m (`model_at` takes a third
  number now), so its front lip is at the climber's depth and no nearer; the jaw's
  collision gained its chin (the model hangs 0.9 m under the lip and that part was
  air).
- **The sweep the note asked for** is `python tools/peak/checks.py fronts`: every
  model's front face against the climber's depth. Besides the mask it lists door
  frames (five `mine_frame`, meant: you walk through them), the champions (skins, at
  the play plane by design), the temple's two counterweight slabs and the cableway's
  eight gondolas (their models stand 0.3 m proud above what you stand on), the
  crystal cave's `crystal_shell_clear`, the garden's great cap and the summit bell.
  Only the mask was changed. The rest are for Parker when he reaches them.
- **Pictures:** `47_mask_before.jpg`, `47_mask_after.jpg`.

### Note 51: weird black spots

- **State:** fixed, seen in the game. The cause is NOT the one in the note.
- **Cause, confirmed:** the painted wall behind the east balcony was there all along
  (the room's back card covers it). The black band was the SUN's shadow. The sun
  stands front-right and shines on inside the mountain at a third of its strength, so
  the rock wall east of the balcony threw a hard shadow 5 m west and 7 m down onto the
  back wall. With the caves' low fill light a shadow there is pure black.
- **What changed:** `_tick_peak` in `game/main.gd` fades the sun's shadows out as you
  go inside (`shadow_opacity = 1 - inside`). Outside the mountain nothing changed. No
  card was moved.
- **The check the note asked for** is `python tools/peak/checks.py backs`: for every
  place a climber can be inside the mountain, is there a painted layer behind it. It
  reports none bare in any area.
- **The well:** it did have a layer, one flat near-black card, which is why it read as
  a piece missing. It now steps back into the depth (two ragged side layers, lighter
  near you) with a slot of black down the middle and far glints
  (`tools/peak/areas/st.py`).
- **Pictures:** `51_band_before.jpg`, `51_band_after.jpg`, `51_well_after.jpg`.
- **For Parker:** this also removes the climber's own cast shadow on the back wall in
  the caves. One line to bring back.

### Note 39: the small slick lip patches

- **State:** all removed, every area.
- **Count:** 39, not the note's 19 (a count by a different size): a2 3, a4 6, a5 6,
  a6 7, a7 7, a8 6, a10 4. Each was the "unease" patch of a rest ledge, named so in
  its area's file. Rest ledges keep any creak or gust they have. Nothing was added.
- **Checked:** every changed area regenerated with no error; the semantic diff shows
  only those 39 solids gone.

### Note 40: pieces in front of the screen

- **State:** done by the rule "nothing stands in front of where a climber can be".
- **Moved behind the climb (20):** the crystal cave's ten shards (`40_a3_before.jpg`,
  `40_a3_after.jpg`); the garden's 16 m stalk and the mound at its landing
  (`40_a4_before.jpg`, `40_a4_after.jpg`); the temple's broken arch; the chimney's
  soot under the hall roof (`40_moved_a6_soot.jpg`); the glacier's seven sheets of
  ice in front of its frozen climbers, which are now at their backs
  (`40_moved_a9_ice_at_his_back.jpg`).
- **Kept in front (15), and why:**
  1. Mine, the stalactite fringe under the east roof: its lowest point is 15 m above
     the nearest hold (`40_kept_a1_stalactites.jpg`).
  2. Mine, the strip along the bottom: below the Sump's floor
     (`40_kept_a1_under_the_sump.jpg`).
  3. Chimney, the floor's front lip: below the lowest floor
     (`40_kept_a6_floor_lip.jpg`).
  4. Glacier, three snow fringes: half a metre thick, lying on the rock's own front
     face; at most they cover a boot (`40_kept_a9_snow_fringe.jpg`).
  5. Storm ridge, six clouds across the towers' feet: the note left these undecided
     ("could be part of that area's difficulty"). They DO cross the climb
     (`40_kept_a10_clouds.jpg`). Parker's call when he gets there.
  6. Summit, two snow sheets: they lie over the dome's own rock
     (`40_kept_a11_snow.jpg`).
- **New in front, on purpose:** the 18 small socket cards of note 48, over wall rock.
- **Check:** `python tools/peak/checks.py fronts` lists every front layer and whether
  it crosses climbing space.

### Note 52: the insides of small pits

- **State:** the gallery's two slots are fixed, seen in the game. The rest are listed,
  not changed.
- **What changed:** each side of both slots is lined slick from the slot's foot to
  7 cm under the lip (four thin `wet` liners, `a5.py`). The 2.5 m under the floor was
  already slick; it was the floor slab's own half-metre end faces that held.
- **Watched:** a climber dropped into the west slot with every limb free to catch:
  nothing held, and it was 10.6 m down in the hall 3 s later. A hand laid on the
  floor's top at the lip: holds.
- **Pictures:** `52_slot_before.jpg`, `52_slot_after.jpg`, `52_slot_fell_through.jpg`.
- **Every other pit the check finds** (`python tools/peak/checks.py pits`: a slot up
  to 2 m wide between two holdable blocks whose floors are level, with 3 m of drop
  under it). Left for Parker:

  - a1: slot x -201.00..-200.40 (0.60 m wide), floors at y 14.20: sides holdable for 0.04 m and 0.40 m
  - a1: slot x -232.20..-231.80 (0.40 m wide), floors at y 52.30: sides holdable for 0.15 m and 0.40 m
  - a2: slot x -405.30..-404.00 (1.30 m wide), floors at y 153.00: sides holdable for 0.30 m and 0.30 m
  - a2: slot x -412.80..-411.50 (1.30 m wide), floors at y 153.00: sides holdable for 0.30 m and 0.30 m
  - a2: slot x -419.80..-418.50 (1.30 m wide), floors at y 153.00: sides holdable for 0.30 m and 0.30 m
  - a7: slot x -213.00..-211.60 (1.40 m wide), floors at y 672.00: sides holdable for 0.25 m and 0.25 m
  - a7: slot x -229.50..-228.90 (0.60 m wide), floors at y 663.00: sides holdable for 0.25 m and 0.25 m
  - a7: slot x -221.00..-220.40 (0.60 m wide), floors at y 663.00: sides holdable for 0.25 m and 0.25 m

  The three in a2 are the catwalk's gaps of note 24. The two in a1 are a crack beside
  the hoist's arm and one at the wheel's staging, both under half a metre.

### Note 55: the area banner's cool-down

- **State:** done, seen on the game's own HUD.
- **What changed (`ui3d/peak_hud.gd`, and one line in `game/main.gd`):** after a banner
  shows, none shows for `area_quiet_s` (15 s). Nothing asked for in that time is saved
  up; only where you are is remembered. When the quiet ends, if that is not the area
  last announced, its banner shows once. A banner also waits until the climber has
  hold of something (`holding`, set by main every frame).
- **Watched** (quiet set to 6 s for the test): the first banner showed at once; three
  more asked for across the line showed nothing; at 7 s the area settled in was
  announced; one asked for in mid fall waited and showed when the climber had a hold.
- **Picture:** `55_banner_after_quiet.jpg`.
- **Not run by me:** `tests/peak_hud_probe.gd` got five new checks for this, but that
  probe opens a full window on Parker's screen, so I ran the same steps in my own
  probe. Second Director: please run yours once.

## Group B: one lighting pass (notes 17, 27, 45)

A still can't show a flicker, so the probe learned to measure one (`flicker` in
`tests/peak_watch.gd`): it watches a patch of the picture for a few seconds and
reports how far its brightness strays (0 to 255, averaged over the patch). The runs
are `--watch=light:race`, `light:crystal`, `light2:race`, `light2:crystal`,
`light2:swim`.

### Note 27: the crystal cave's floor flickers

- **State:** fixed, measured. **It was suspect 1, the climber's own lamp.**
- **Reproduced:** the floor's top, 1.4 to 3.2 m west of the climber. Climber still:
  stray 0.00. Climber rocked 6 cm as if crawling, lamp on: 0.22 and 0.33 (two runs).
  The same with the lamp switched off: 0.00 and 0.00. The cave's three lanterns are
  steady and the sun's shadows made no difference. Suspect 2 (two surfaces in one
  place) and suspect 3 (the sheen) were not needed to explain it: with the lamp off
  nothing moved at all.
- **What changed (`frame` in `stages/peak/peak.gd`, constants at the top):** the lamp
  follows the climber smoothly (`LAMP_FOLLOW`), not frame by frame; it stands 4.2 m
  out toward the camera where it was 2.2 (`LAMP_OUT`), so floors and beds, which face
  up, catch little of it; range 12 (was 9), energy 1.0 (was 1.1); and it takes half
  its colour from the cave it is in, so it no longer paints yellow on lavender.
- **After:** crawling, lamp on: 0.01 and 0.04.
- **Pictures:** `27_floor_before.jpg` (the bright patch on the floor by the climber),
  `27_floor_after.jpg`; `17_lamp_in_the_mine.jpg` for how the new lamp looks in a
  warm cave.
- **This changes the look of every cave a little** (the climber's light is broader
  and softer). First-try numbers.

### Note 17: the light under the mill race pulses and flashes

- **State:** changed, but **I did not reproduce the pulsing itself**, so read this as
  "the likely causes are all gone", not "confirmed fixed".
- **What the three suspects measured, at the race, climber standing still on the
  pier, a patch on the bed under the water:**
  1. Lantern flicker: stray 0.01 with the lanterns flickering as played, 0.00 with
     them held steady. Not it, at this spot.
  2. The on/off snap at 34 m: real in the code, not seen here (nothing crossed the
     line while standing).
  3. The old water box lying in the bed's own plane: the box is gone from the branch
     (note 2 rebuilt the water), so I put one back for the test. With the camera
     drifting 5 cm it added nothing (stray 0.40 with it, 0.84 without).
- **What I think it was, from a picture and not a measurement:**
  `17_swimmer_before.jpg`. A climber floating in the race: the bed under and east of
  the swimmer carries a hard-edged bright yellow patch. That is the climber's own
  lamp again, 0.6 m over a body that bobs and drifts at 1.4 m a second, cut into a
  hard band on a flat bed 1.4 m below. It is the same thing as note 27 and was not on
  the note's list. My flicker patch did not catch it because the swimmer drifted out
  of the patch.
- **What changed:** the lamp, as under note 27 (`17_swimmer_after.jpg`: the patch on
  the bed is faint and soft). And the two lantern suspects were dealt with anyway,
  since both are real: a lantern now fades on and off over half a second
  (`LIGHT_FADE_S`), and its cast light swings 5 percent where it swung 28
  (`LIGHT_FLICKER`). And inside the mountain the sun casts no shadows (note 51), so
  the mill wheel's paddles no longer sweep hard shadows over the bed.
- **Not checked:** a person swimming the race.

### Note 45: the dark place at Los Ojos

- **State:** done, seen in the game. Numbers are first tries.
- **What changed:**
  - The box's strength: 0.42 where it was 0.85 (`A.dark` in `tools/peak/areas/a4.py`).
  - **A floor on darkness for the whole mountain:** no dark box counts for more than
    0.55 (`DARK_MAX` in `stages/peak/peak_zones.gd`). The cart tunnel at the start
    (0.8) is therefore 0.55 now. The glacier's (0.3) is untouched.
  - **It fades in space:** the dark deepens over the last 7 m outside a box
    (`DARK_FADE_M`), where it used to switch on whole at 2 m.
  - **It fades in time:** any change is eased (`DARK_EASE`).
  - **The puffballs light it:** each of the nine "eyes" in the box casts a pale pool
    of light, which goes out when it bursts and comes back when it grows back.
- **Watched:** by the boxes, coming from the east: 0.00 at 8 m out, 0.02 at 6 m, 0.17
  at 4 m, 0.34 at 2 m, 0.42 at the edge. Warped into the middle from outside, the
  darkness on screen went 0.00, 0.29 (0.5 s), 0.38 (1 s), 0.41, 0.42 (2 s).
- **Pictures:** `45_dark_after_game_camera.jpg`, `45_dark_after_whole.jpg`. No
  "before" of mine; Parker's own is `shots/45_too_dark.jpg`.
- **Not checked:** a puffball bursting and its light going out, by eye (the code path
  is two lines beside the ball's own hide and show).

## Group C: tells for holds that let go on a timer (notes 23 and 56)

- **State:** done for the hot holds of both areas, seen in the game. The cold version
  for the ice holds is written and switched off.
- **One system, in `stages/peak/peak_things.gd`** (`TELLS`, `_tick_tell`, `_burn_hand`),
  for every hold of the `timed` kind. It needs nothing from the area files, so all 20
  hot holds (11 joints in 2.9, 9 nubs in 6.2) have it:
  - **At rest it looks hot:** its colour pulses between its own orange and a bright
    yellow, and it breathes a wisp of steam every second or two, sometimes a spark.
  - **While you hold it you watch the time run out:** it brightens toward white, the
    hand on it smokes thicker and faster, and in the last half second the hold
    shudders and spits sparks (with the sizzle it already had).
  - **When it lets go:** a burst of steam and two of sparks, the hand is flicked off,
    and the hand wears a red mark and smokes for the 0.8 s it can't hold anything.
  - No glowing materials: the heat is the house shader's own tint, driven per hold.
    The particles are `PeakZones.burst`, one table of kinds for the whole mountain.
- **The ice holds:** `TELLS.cold` (frost for steam, a pale blue mark for red) is there
  and `TELL_COLD` is false. Areas 8 and 9 are untouched, as asked.
- **The chimney's red on red (note 56):** the furnace face is burnt black along the
  line of the holds (one card behind them, `tools/peak/areas/a6.py`), so the hot
  holds burn against dark.
- **Watched:** a hand laid on the first hot joint of 2.9 and left: let go at 1.51 s
  (the joint's time is 1.5), heat 0.45 at 0.68 s and 0.87 at 1.30 s, the hand marked
  afterwards. The first hot nub of 6.2: let go at 1.21 s (1.2).
- **Pictures:** `23_hot_before.jpg`, `23_hot_at_rest.jpg`, `23_hot_half_way.jpg`,
  `23_hot_last_moments.jpg`, `23_hot_lets_go.jpg`, `23_hot_hand_after.jpg`, and the
  same six for `56_`.
- **Not done, and why:**
  - The cool joints of 2.9 were not recoloured: in the game the cool joint is already
    a teal valve wheel, plainly unlike the orange ones (`23_hot_before.jpg`). The
    three level pipes between are still red.
  - The three cool nubs of 6.2 are still pale rock. With every hot one pulsing and
    steaming they are the only calm things on the wall.
  - The warning plate (a hand and a flame) needs a model: `MODEL_REQUESTS.md`.
- **First-try numbers:** every size and rate in `TELLS` and `_tick_tell`.
- **Not checked:** "someone who has never been told the rule can say what happened
  after being dropped once". That is a test for a person.

## Group D: La Cortina (notes 13, 14, 15)

### Note 13: the wet holds, and the drip that wets them

- **State:** done, watched in the game. The later text of the note was followed: the
  holds stay wet in turn and do NOT slide in and out. The 7 wet holds of Las Aguas
  Negras are untouched.
- **What changed (`tools/peak/areas/a1.py`, the 1.11 block):**
  - **A drip you can watch.** A fat drip of water runs down each of the two columns,
    from the lip to under the bottom row, at 1 m a second, one every 7 m
    (`DRIP_SPEED`, `DRIP_GAP`). `A.drips(...)` draws it; `Area.drip_phase(...)` sets
    each hold's wet clock to it, so a hold turns wet exactly as a drip reaches it.
  - **Dry for longer.** Wet 2 s, dry 5 s (was wet 2.6, dry 3.4). The two columns are
    half a turn apart.
  - **Wet looks wet, not gone.** A soaked hold is a shiny blue-grey (a fourth kind of
    slick, "water", in `stages/peak/peak.gd`; a hold asks for it with
    `"look": "water"`), throws a splash of drops when the drip lands, drips while it
    is wet, and its colour comes back over half a second as it dries. A drip's sound
    plays when a hold near you goes wet.
  - **Five holds never get wet**, in pale bone: rows 2, 5, 8, 11 and 14, swapping
    sides (west, east, west, east, west).
- **Watched for 15 s, every wet hold of the wall (23):** each was wet between 5.0 and
  6.3 s of the 15 (2 in every 7 is 4.3); 50 times a hold turned wet, and the nearest
  drip was then at most 1 cm from it; a row had both its holds wet at 0 of 1,802
  moments looked at.
- **Pictures:** `13_cortina_before.jpg`, `13_cortina_whole.jpg` (the two columns with
  their drips), `13_cortina_close_0.jpg`, `_1`, `_2` (the bottom rows, 1.3 s apart: a
  drip passing).
- **Carried-over asks, assumed kept as the note says:** dry for longer, and some
  always-dry holds in another colour. Both are in.
- **First-try numbers:** 1 m/s, 7 m, 2 s wet, which five rows.
- **Not checked:** climbing it by play; the sound.

### Note 14: a rope from the top, to half way

- **State:** done, seen in the game. Settled reading "b": one long rope from the lip.
- **What changed:** an iron bracket out of the dry shaft's east wall under the lip, and
  an 8 m rope from it (`cuerda_cortina`), a hand east of the east column of holds.
- **Measured in the game:** its top is at (-232.42, 89.15), 0.69 m from the lip's
  corner; its tail at (-232.42, 81.65), by rows 7 and 8, and the nearest hold is
  1.18 m from the tail (a reach is 1.9). A climber hung from its lower end for 3 s
  stayed on it.
- **Picture:** `14_rope_hanging.jpg`; it is the thin line right of the east column in
  `13_cortina_whole.jpg`.
- **Why the east side:** on the west the rope would hang 3.5 m from the lip, across
  the shaft. Here its top is beside the lip.
- **As the note says, this makes the upper half much easier.** Shorten `8.0` in the
  rope's line to start it higher.
- **Not checked:** climbing the rope and stepping off onto the lip by play. (Rope
  physics is note 20.)

### Note 15: the life ring at the foot of the wet slab

- **State:** done, counted in the game.
- **What changed:** Del Mar's life ring (`float_lifesaver`, the kit's own) is propped
  on a block at the foot of the awning, facing up and east. It is a bounce pad that
  throws a body at the same velocity however it arrives (`throw` on `A.bounce`, new):
  1.9 m/s east and 8.6 up (`RING_THROW` in `a1.py`). It squashes and springs by Del
  Mar's floats' own recipe when it throws someone, and boings with Del Mar's sound.
  A bounce pad can now carry a model (`model=` on `A.bounce`).
- **Counted (the probe drops a climber, limbs free to catch, and waits to see where
  it holds on):**
  - Off the balcony's edge, 10 times: 7 slid to the ring and all 7 landed on the
    balcony; 3 caught the balcony's own edge as they went and never fell.
  - From the first row of La Cortina, 5 times: 5 of 5 on the balcony.
  - From the second row, 5: 2 reached the ring; 1 landed on the balcony and 1 ended
    hanging from its edge; 3 caught a hold of the wall at once.
  - From the third row, 5: all 5 caught a hold of the wall at once (the test starts
    them beside the always-dry hold of that row).
  - So of 14 that reached the ring, 13 landed on the balcony and 1 hung from its
    edge. None was lost to the fall. In an earlier run of 10, one ring throw ended
    holding a hold of La Cortina on the way up; that is a save, not a miss, but it
    does happen.
  - From the bounce to holding on again: 3.5 s on average.
- **Pictures:** `15_slab_before.jpg`, `15_ring_squashed.jpg`, `15_ring_thrown.jpg`,
  `15_ring_landed.jpg`.
- **First-try number:** the throw.
- **Not checked:** a fall from the upper rows, which lands harder and further out;
  whether a body that slides off the slab's SIDE can miss the ring.

## Group E: breakables, one look and one rule (notes 16, 24, 31, 53)

### The measurement first: how fast a climber crosses a floor

- `--watch=gait` in the probe: a scripted crawl along the temple's gallery floor (12 m
  of level stone), one limb at a time picked up, aimed ahead and planted, as a player
  does. Five rhythms:

  | rhythm | metres a second | chest over the floor |
  |---|---|---|
  | hands then feet, 0.20 s a limb | 0.64 | 0.25 m |
  | hands then feet, 0.14 s a limb | 0.65 | 0.43 m |
  | hand, foot, hand, foot, 0.16 s | 0.63 | 0.35 m |
  | hands then feet, long reach, 0.18 s | 0.90 | 0.51 m |
  | hand, foot, hand, foot, long reach, 0.12 s | 1.11 | 0.75 m |

- So **a brisk crawl is about 1.1 m/s, and a low one 0.65 to 0.9**. A crawl IS
  crouched: the chest rides a quarter to three quarters of a metre up. A crawling
  body is about 1.6 m from leading hand to trailing foot, so it is wholly off a piece
  (L + 1.6) / speed after first touching it: 3.3 s for a 2.1 m piece at the brisk
  pace, 3.5 s for a 1.52 m piece at 0.9.
- This is a script, not a person. A person who lunges will be faster.

### The shared look and rule

- **Rule:** the game's existing breaking hold (it gives way `t` seconds after the
  first hand or foot is on it, falls in pieces, comes back in its own place 8 s
  later). Two new kinds carry it: `rusty` (iron rusted through) and `crazed` (a
  cracked crystal plate), beside `brittle` (stone) and `rotten` (wood).
- **Look, drawn by the game on every `brittle`, `rusty` and `crazed` piece** (`_crack`
  in `stages/peak/peak.gd`): at rest it is cracked through in the ink of its material
  and has a corner gone. Once touched a second, denser set of cracks appears, it
  shudders harder as its time runs out, and it sheds dust (glitter for crystal). It
  goes with a burst (sparks and a clang for iron).
- This is a code-drawn look on plain shapes, not modelled damage. Cracked pieces for
  the four materials are asked for in `MODEL_REQUESTS.md`.
- Rotten planks keep the kit's own rotten look. Icicles and snow bridges are as they
  were (areas Parker has not played).

### Note 16: the first pipe's two dark sections

- **State:** done, seen in the game.
- **What changed:** the two 1.5 m grease stretches of challenge 2.1 are `rusty`
  (`tools/peak/areas/a2.py`): a hand holds, and 1.0 s later the section snaps and
  falls to the river.
- **Watched:** a hand on the first section was let go at 1.01 s; the section was back
  7.8 s after it broke. The chain past the second section is untouched.
- **Pictures:** `16_pipe_before.jpg`, `16_pipe_at_rest.jpg`, `16_pipe_touched.jpg`,
  `16_pipe_breaks.jpg`.
- **Not checked:** the 1.5 m lunge across a missing section (it is the lunge the
  challenge already had).

### Note 24: the catwalk before the dam

- **State:** done, crossed in the game by the scripted crawl.
- **What changed (`a2.py`):** of 34 m, 22.2 m now breaks, in eleven pieces of 1.85 to
  2.2 m. Solid: a 2 m landing at each end and two 2 m rest plates. The three 1.3 m
  gaps are where they were. Each piece gives way `FLOOR_T` = 3.4 s after first touch.
- **The delay is from the measurement above**, not the holds' 1.2 s (at which no
  crawl could have crossed a single piece).
- **Watched:** the crawl made each stretch: the two pieces from the west landing in
  4.2 s (1.04 m/s), the two before the first rest plate in 2.7 s, and the long run of
  five pieces, 10.5 m, in 12.1 s (0.88 m/s). Standing still on a piece: in the river
  4.4 s after first holding it.
- **The crawl could not cross the 1.3 m gaps** (it does not lunge). Those gaps were
  there before and were not changed.
- **Pictures:** `24_catwalk_before.jpg`, `24_catwalk_at_rest.jpg`,
  `24_catwalk_close.jpg` (the red landing against two breaking pieces),
  `24_catwalk_crawled.jpg`.

### Note 31: the prism's shelves

- **State:** done, seen in the game.
- **What changed (`a3.py`):** the eight shelves are `crazed` crystal plates, pale
  with purple cracks, not tan blocks. 1.3 s where it was 0.8, for these eight only.
- **The scale, in order:** each shelf plays its own note, `crystal_chime_01` at the
  bottom to `_08` at the top. It used to pick one of the eight at random.
- **Watched:** the first shelf let go at 1.32 s. The probe read the eight shelves'
  notes bottom to top: 1 to 8.
- **Pictures:** `31_shelves_before.jpg`, `31_shelves_at_rest.jpg`,
  `31_shelf_touched.jpg` (cracks spread, glitter falling), `31_shelf_breaks.jpg`.
- **Not checked:** the sound of the scale. I can't hear it.
- **Not done:** shards in place of boxes for the falling pieces (the pieces are the
  game's usual chunks, in the shelf's colour, with a burst of glitter).

### Note 53: the altar's beam and cross

- **State:** done, crossed in the game by the scripted crawl.
- **What changed (`a5.py`):** the beam is six pieces of cracked stone, 1.52 m each,
  each giving way `BEAM_T` = 3.5 s after first touch. The cross turns at 6.4 rpm.
- **Watched:** the cross turned 77.1 degrees in 2 s: 6.43 rpm, an arm every 2.33 s.
  Three crawls from the threshold to the far end, the cross turning: the brisk one
  crossed in 8.2 s, the low one in 10.2 s, the lowest in 13.3 s. None was knocked
  out, the brisk one included (chest 0.75 m up, the arm's tip 0.5 m over the beam's
  middle): the knock-out reads the middle of the head, chest and hips, and a crawl's
  are under the arm.
- **So the delay is not the hard part here; standing up is.** If Parker wants the
  beam itself to press harder, `BEAM_T` is the number.
- **Pictures:** `53_beam_before.jpg`, `53_beam_at_rest.jpg`,
  `53_beam_after_a_crawl.jpg`.
- **Not checked, and it matters:** the climb up the east wall after the beam. An arm
  now brushes that wall every 2.3 s where it was every 9.4. Nothing tried it.

## Group F: things that leave properly (note 21, the pool's barrels)

- **State:** done, watched in the game. The gaps are a first try for Parker to set.
- **What changed (`tools/peak/areas/a2.py`, the 2.7 block; `stages/peak/peak_things.gd`):**
  - **Eight barrels where there were 13**, on a written rhythm: `BARREL_GAPS`, the
    metres from each barrel's middle to the next, round a 30.8 m loop.
  - **They come out of a cove.** The kit's own `brick_arch` (the aqueduct's arch,
    drawn at 4.6 m) stands in the back wall at the waterline just east of the west
    bank, black inside. A barrel floats forward out of the dark over its first 2.4 m
    of drift and can't be touched until it is in the climb's plane (`emerge` on the
    mover). No new model was needed.
  - **They go over the lip for real.** 0.85 m past the end of the water the barrel on
    the line is replaced by a loose 60 kg body with its look (`loose` on a `wrap`
    mover: note 6's hand-over, made general in `_let_stray`). It tips over the lip,
    falls the 24 m down the cascade, splashes into the river, sinks, and shrinks away
    five seconds later if nobody is holding it. Hands and feet on it go with it.
  - The barrel on the line carries on unseen and comes out of the cove again.
- **The measurement asked for: how wide a gap can a climber stretch?** The probe set
  two barrels a chosen distance apart, stood a climber at the west end of the east
  one and had it aim a hand at the next barrel's near corner for a second at a time,
  the body leaning out after it. The hand got 1.52 and 1.59 m past the rear foot at
  most. Take off about 0.1 m for the foot's place on its barrel and 0.15 m for the
  hand's on the next: **about 1.3 m of water is a plain stretch.** (The old barrels
  had 0.8 m between them.) The script never took the far barrel, even at 1.2 m: it
  cannot lunge, and it overbalanced. So this is "how far a hand goes", not "how far a
  player gets". A lunge goes further; I can't put a number on it.
- **The first-try gaps, as water between barrels:** 1.2, 1.6, 1.1, 4.0, 1.3, 1.7, 1.1,
  4.4 m. Four are a stretch, two a lunge, two a swim against the pool's 1 m/s (the
  swims in this area were designed for 1.0 to 1.6). Because the barrels all drift at
  one speed a gap never closes while you wait.
- **Watched:** 8 barrels, 7 on the pool at the moment looked at. Five in a row came
  out of the cove into the climb's plane, all at x -310.8. Five in a row went over
  the lip and hit the river 3.2 s later at x -285.2. A climber stood on one near the
  lip: its feet were on the loose barrel the moment it went loose, and 4.3 s later it
  was down in the river at (-283.3, 92.9) with all four limbs on the barrel.
- **Pictures:** `21_cove.jpg`, `21_cove_coming_out.jpg`, `21_pool_whole.jpg`,
  `21_over_the_lip.jpg`, `21_riding_it_over.jpg`. No "before" of mine; Parker's is
  `shots/21_barrels.jpg`.
- **First-try numbers:** the gaps; the drift (unchanged, 0.55 m/s); where it is let
  loose; its mass, push and tip.
- **Not checked:** hopping the barrels by play; the swim across a long gap.

## Group G: the ropes swing with you (note 20)

- **State:** done on the bench and watched in the game; nothing played by a person.
- **Parker 11-12:** "we need to fix the rope physics. Make it so you can swing back and
  forth on them better. Right now they like launch you up weird but you can't get a
  good swing on them".

### The bench first

`tests/peak_rope_bench.tscn` (headless; the header of `tests/peak_rope_bench.gd` says how
to run it). It hangs two ropes of its own in open sky, built by the game's own rope
builder, so nothing is near to hit: a 5 m rope and a 9 m chain. It also uses the mine's
real rope. A climber is hung by one hand near the foot and put through six scripts.
The pump is the battery's own: a leg thrown the way the body is going. One push is one
swing to one side.

**Before (the committed ropes: 3.6 kg a half metre, a chain 6.6; full gravity, 9.8;
brakes 0.25 and 1.2; the hand welded):**

| | 5 m rope | 9 m chain | the mine's rope |
|---|---|---|---|
| The rope weighs | 36 kg | 119 kg | 36 kg |
| How far out each push took it (degrees) | 0 1 1 1 18 29 39 48 48 47 48 49 | 0 0 0 0 0 0 0 0 0 0 0 1 | 0 0 1 1 17 16 16 16 9 10 7 13 |
| The fifth push reached | 18 | 0 | 17 |
| Widest in 24 s of pumping | 51 | 20 | 49 |
| There and back | 4.8 s | 3.8 s | 5.0 s |
| A leg held to one side, 8 s: off plumb at most | 27 | 11 | 25 |
| Free hand held straight up 3 s: the GRIPPING hand was carried up | 1.93 m | 1.76 m | 1.89 m |
| ...the body's middle got above its own grip by | 1.13 m | 1.15 m | 1.13 m |
| ...fastest upward | 3.6 m/s | 3.6 m/s | 3.7 m/s |
| Hand over hand, 3 m up | 2.1 s | 1.7 s | 3.4 s |
| One push from a still hang, then let go | leaves at 2.3 m/s, nearly straight up | | |

The gripping hand carried 1.9 m up is the "launch you up weird": a rope cannot push, so
a hand on a rope that rises was thrown. The first four pushes doing nothing is "you
can't get a good swing".

**After:**

| | 5 m rope | 9 m chain | the mine's rope |
|---|---|---|---|
| The rope weighs | 3 kg | 9 kg | 3 kg |
| How far out each push took it (degrees) | 22 40 52 60 62 61 | 17 32 38 41 43 | 22 39 49 51 56 60 |
| The fifth push reached | 62 | 43 | 56 |
| First past 60 degrees | 15.6 s in (the fourth push) | not in 24 s | 6th push |
| There and back | 8.0 s | 10.9 s | 8.0 s |
| A leg held to one side, 8 s: off plumb at most | 26 | 28 | 27 |
| Free hand held straight up 3 s: the gripping hand was carried up | 0.08 m | 0.12 m | 0.05 m |
| ...the body's middle got above its own grip by | 0.32 m | 0.34 m | 0.34 m |
| ...fastest upward | 1.1 m/s | 1.2 m/s | 1.2 m/s |
| Hand over hand, 3 m up | 5.6 s | 5.7 s | 6.0 s |
| Let go at the bottom after 24 s of pumping | 4.2 m/s | (4.2 m/s on an earlier run) | 4.4 m/s |
| One push from a still hang, then let go | leaves at 0.9 m/s | | |

The page's own test for "better" was: from hanging still, four or five pumps to about
60 degrees each side; nothing throws you upward unless you swung there. On the 5 m rope
the fourth push reaches 60. On the 9 m chain five pushes reach 43 degrees, which is
5.6 m to each side.

The bench's numbers move a few degrees from run to run (a thrown leg is not tidy).

### What changed

- **`stages/peak/peak_things.gd`** (`ROPE_MASS`, `_build_rope`, `tick`):
  - **You are the weight.** A half-metre piece of rope or vine weighs 0.3 kg (it was
    3.6 and 3.0), of chain or cable 0.5 (6.6 and 6.0), of banner line 0.25 (2.7). The
    miner's rope is 3 kg under a 22 kg climber.
  - **One gravity.** Every piece falls at the climber's own gravity, read from the Feel
    table, and follows it if the F1 panel changes it.
  - **The brakes are off.** 0.03 and 0.15, from 0.25 and 1.2: enough that a rope left
    alone comes to rest.
  - A weight on a rope's end (the chandeliers, the bell, the drawbridge's) falls at the
    same gravity.
  - **A plank bridge is exactly as it was** (the garden's `puente`): you stand on it.
- **`climber/climber.gd`**, and only for a grip on a Peak rope (the arena and the tower
  never see any of it):
  - **A hand on a rope pivots** (`attach`): held on the rope's own line, free to turn.
    On rock it is still the weld.
  - **The pump** (`_pump`): hanging only from things that hang, steering a limb to one
    side pushes the whole body that way along the swing, at a sixth of its weight (Feel
    `rope_pump`, 0.16). In time with the swing it builds; held one way it cannot carry
    you. It replaces, on ropes only, the turn about a single grip, which spun the body
    round its hand.
  - **No launch** (`_tick_joints`). Hanging by ropes only, the limb you steer pulls at
    2.4 body-weights of the climber's own gravity (Feel `rope_pull`; on rock it is 3.1
    at full gravity, about four and a half times as much), and the pull is paid by the
    climber's own gripping hands, not the rope. An upward pull lifts the body only
    while its middle is below its highest grip, and eases off above 0.8 m/s. So a hand
    reaching up pulls you up to your grip, as a pull-up does, and no further.
- **`data/feel.gd`:** two new numbers in the F1 panel, `rope_pull` and `rope_pump`.
- **What keeps the old complaint from coming back** ("a climber hauling a light rope
  anywhere and nearly flying", the reason the ropes were tripled on 11-12): the bench's
  HAUL and LEAN rows. A hand held up moves the gripping hand 0.08 m, where the heavy
  rope let it go 1.9 m. A leg held to one side for 8 s swings the body out to 26
  degrees at most, the same as before.

### Every rope, chain and vine on the mountain, old against new

`-- --survey` on the same bench: a climber on the foot of each one, where it really
hangs, pumped for 20 s by the same script. "Reach" is how far east / west of the rope's
own top the gripping hand got. A rope in a shaft or beside a wall stops where the wall
is, before and after.

| Area | Rope | What | Reach before (east / west) | Reach now | There and back | Its move |
|---|---|---|---|---|---|---|
| a1 | cuerda_minero | rope 5.0 m | 2.9 / 3.4 m | 3.6 / 3.9 m | 4.7 s to 6.5 s | 1.4 La Cuerda del Minero: the rope over the 5.1 m gap |
| a1 | cadena_a | chain 9.0 m | 1.6 / 1.5 m | 4.9 / 5.2 m | 5.6 s to 10.9 s | 1.8 Las Vigas: the chain you climb to the first beam |
| a1 | cadena_b | chain 9.0 m | 1.9 / 1.9 m | 4.8 / 5.6 m | 5.7 s to 10.7 s | 1.8 Las Vigas: the second chain beside it |
| a1 | cuerda_cortina | rope 8.0 m | 1.8 / 0.9 m | 1.8 / 1.2 m | 2.8 s to 1.8 s | 1.11 La Cortina: the new rope down the wet slab (note 14). It lies against the slab |
| a2 | last_chance | chain 2.5 m | 1.5 / 1.6 m | 1.7 / 1.6 m | 3.3 s to 5.4 s | 2.4: the one mercy over the river |
| a2 | cadena1 | chain 7.0 m | 2.1 / 2.3 m | 4.6 / 4.6 m | 5.2 s to 9.4 s | 2.6 Cadenas: chain to chain over the fast water |
| a2 | cadena2 | chain 7.5 m | 1.9 / 1.7 m | 4.8 / 4.9 m | 2.2 s to 9.6 s | 2.6 Cadenas |
| a2 | cadena3 | chain 6.5 m | 2.4 / 2.5 m | 4.4 / 4.4 m | 4.9 s to 7.5 s | 2.6 Cadenas |
| a2 | flume_out | chain 1.5 m | 0.8 / 0.8 m | 0.8 / 0.7 m | 1.8 s to 5.2 s | 2.8: the way out of the flume, taken with a raised arm |
| a2 | cuerda_niebla | rope 14.0 m | 1.2 / 1.3 m | 5.8 / 4.6 m | 2.8 s to - | 2.10: the long rope up through the mist |
| a3 | chand1 | chain 9.0 m, weighted | 1.7 / 2.1 m | 2.6 / 3.1 m | 7.3 s to - | 3.3 Candelabros: a chandelier on a chain |
| a3 | chand2 | chain 9.0 m, weighted | 2.1 / 2.2 m | 3.5 / 0.8 m | 8.6 s to - | 3.3 Candelabros |
| a3 | chand3 | chain 9.0 m, weighted | 1.6 / 1.7 m | 2.2 / 2.4 m | 3.4 s to - | 3.3 Candelabros |
| a4 | root_in0 | vine 12.0 m | 1.8 / 1.5 m | 5.8 / 6.8 m | 3.3 s to - | the garden's entry: the roots that catch the throw from the crystal cave |
| a4 | root_in1 | vine 12.0 m | 2.1 / 2.2 m | 5.8 / 6.7 m | 7.8 s to - | the garden's entry |
| a4 | root_in2 | vine 12.0 m | 2.2 / 2.1 m | 5.8 / 6.7 m | 3.8 s to - | the garden's entry |
| a4 | liana0 | vine 9.5 m | 2.6 / 2.2 m | 5.2 / 5.7 m | 6.2 s to 11.4 s | 4.2 Lianas: four vines 5 m apart |
| a4 | liana1 | vine 9.5 m | 2.5 / 2.9 m | 5.2 / 5.8 m | 5.9 s to 11.4 s | 4.2 Lianas |
| a4 | liana2 | vine 9.5 m | 2.8 / 2.6 m | 5.2 / 5.7 m | 6.3 s to 11.4 s | 4.2 Lianas |
| a4 | liana3 | vine 9.5 m | 2.7 / 2.9 m | 5.2 / 5.7 m | 5.9 s to 11.4 s | 4.2 Lianas |
| a4 | lift0 | vine 10.0 m | 2.5 / 2.0 m | 5.6 / 5.6 m | 4.8 s to - | 4.3 El Ascensor de Esporas: the vines at the top of the spore lift |
| a4 | lift1 | vine 10.0 m | 2.5 / 2.5 m | 5.5 / 6.2 m | 6.7 s to - | 4.3 |
| a4 | lift2 | vine 10.0 m | 2.3 / 2.3 m | 5.8 / 6.5 m | 6.8 s to - | 4.3 |
| a4 | rebote | vine 10.0 m | 1.3 / 2.0 m | 3.0 / 4.8 m | 4.6 s to 9.3 s | 4.4: the vine before the bounce wall |
| a4 | ojo_v0 | vine 2.5 m | 0.0 / 3.7 m | 1.1 / 2.8 m | - to 4.5 s | 4.9 Los Ojos: the way up off the root shelf |
| a4 | ojo_ra | vine 3.5 m | 1.7 / 1.1 m | 4.4 / 17.4 m | 2.2 s to - | 4.9 Los Ojos: the root over eye A **(it lost its grip in the new run: see below)** |
| a4 | ojo_ca0 | vine 7.5 m | 2.0 / 0.9 m | 3.5 / 1.2 m | 2.0 s to 6.7 s | 4.9 Los Ojos: the catch in the dome |
| a4 | ojo_ca1 | vine 7.5 m | 2.5 / 0.4 m | 3.5 / 0.7 m | 3.0 s to 4.7 s | 4.9 Los Ojos |
| a4 | ojo_rb | vine 3.5 m | 1.4 / 1.7 m | 1.0 / 10.5 m | 4.0 s to - | 4.9 Los Ojos: the root over eye B |
| a4 | ojo_cb0 | vine 11.5 m | 2.5 / 2.2 m | 3.6 / 3.9 m | 3.3 s to 8.4 s | 4.9 Los Ojos: over the sill's end |
| a4 | ojo_cb1 | vine 11.5 m | 2.2 / 2.3 m | 4.0 / 2.9 m | 8.2 s to 8.3 s | 4.9 Los Ojos |
| a5 | banner_chain_1 | chain 12.0 m | 1.2 / 1.2 m | 6.6 / 5.4 m | 3.1 s to - | the temple's door: the chains that catch the throw from the garden |
| a5 | banner_chain_2 | chain 12.0 m | 1.3 / 1.7 m | 6.6 / 5.4 m | 2.9 s to - | the temple's door |
| a5 | gallery_chain | chain 12.5 m | 0.5 / 2.2 m | 0.7 / 2.8 m | 1.7 s to 6.2 s | 5.6: the chain up the 3.8 m shaft to the gallery (the shaft's walls stop any swing) |
| a5 | serpent_tail | chain 4.5 m | 1.6 / 1.4 m | 2.8 / 1.9 m | 3.2 s to 5.8 s | 5.8: the serpent's tail |
| a6 | c61 | chain 5.0 m | 2.0 / 2.4 m | 3.6 / 3.8 m | 4.7 s to 7.8 s | 6.1: the chain from the mask's nose ring that catches the column's throw |
| a6 | c63 | chain 7.0 m | 1.6 / 2.2 m | 4.4 / 4.3 m | 2.5 s to - | 6.3: the chain |
| a6 | c65 | chain 6.0 m | 2.4 / 2.4 m | 3.5 / 5.5 m | 4.7 s to - | 6.5 Escoria: the way off the last raft **(it lost its grip in the new run: see below)** |
| a6 | c66_1 | chain 4.5 m | 3.0 / 2.9 m | 3.3 / 3.7 m | 3.7 s to 5.1 s | 6.6: a chain on a moving hammer |
| a6 | c66_2 | chain 4.5 m | 11.7 / 2.3 m | 3.4 / 3.3 m | 4.4 s to 12.4 s | 6.6 |
| a6 | c66_3 | chain 4.5 m | 5.3 / 0.5 m | 3.7 / 3.8 m | - to 5.8 s | 6.6 |
| a7 | bridge_w | rope 5.5 m, weighted | 5.1 / 5.1 m | 1.0 / 6.6 m | 4.4 s to - | 7.4: the drawbridge's west rope, with its weight |
| a7 | bridge_e | rope 5.5 m, weighted | 1.5 / 5.1 m | 1.6 / 5.0 m | 2.0 s to 2.8 s | 7.4: the east rope |
| a9 | rope96 | rope 16.0 m | 1.1 / 2.1 m | 2.0 / 5.5 m | 2.6 s to - | 9.6: the 16 m rope down the serac, in the gusts |
| a9 | rope98 | rope 5.5 m | 1.5 / 2.0 m | 3.2 / 2.3 m | 3.9 s to 6.0 s | 9.8 Ventisca: the dead man's rope out of the chute |
| a10 | filo_line | banner 4.5 m | 3.3 / 2.6 m | 3.8 / 2.8 m | 5.2 s to 5.6 s | 10.1 El Filo: the torn prayer line under the Alero, in the wind |
| a10 | banda1 | banner 8.5 m, strung | sags 0.27 m under a climber | sags 0.33 m | - | 10.3: a prayer line strung between two points |
| a10 | banda2 | banner 9.1 m, strung | sags 0.26 m under a climber | sags 0.43 m | - | 10.3 |
| a10 | banda3 | banner 12.2 m, strung | sags 0.34 m under a climber | sags 0.53 m | - | 10.3 |
| a10 | papalote1_cola | banner 6.0 m | 3.7 / 4.5 m | 4.5 / 5.3 m | 4.5 s to 4.3 s | 10.6: a kite's tail (the kite moves) |
| a10 | papalote2_cola | banner 6.0 m | 4.4 / 5.2 m | 4.9 / 5.3 m | 4.4 s to 4.2 s | 10.6 |
| a10 | papalote3_cola | banner 6.0 m | 5.1 / 4.8 m | 4.0 / 5.3 m | 4.3 s to 2.6 s | 10.6 |
| a10 | globo_a | rope 12.0 m | 4.5 / 1.9 m | 9.7 / 1.1 m | 3.8 s to - | 10.8: the balloon's rope, in a 4 m/s2 wind |
| a10 | globo_b | rope 12.0 m | 4.8 / 1.8 m | 9.7 / 2.0 m | 3.8 s to - | 10.8 |
| a11 | bell_rope | rope 10.0 m, weighted | 6.7 / 4.3 m | 12.9 / 11.5 m | - to 2.6 s | 11.4: the bell's rope (the bell swings it) |

**What changed, move by move:**

- **1.4, the miner's rope:** 2.9 / 3.4 m becomes 3.6 / 3.9 m. Watched in the game: five
  pushes take it to 59 degrees, and let go at the bottom it lands on the far dock.
  Before, a swing there took a long fight.
- **1.8 and 2.6, chain to chain:** a chain's reach goes from about 2 m to nearly 5 m.
  The chains of 2.6 hang 4 to 6.4 m apart, so the next chain can now be swung to and
  taken by hand, where it was a fling. Easier. Not moved.
- **1.11, La Cortina's rope (note 14):** unchanged in reach (1.8 / 1.2 m): it lies
  against the slab. It is climbed, and climbing is the slower hand over hand above.
- **2.10, the 13.6 m rope:** 1.2 m of reach becomes 5.8 m. It was a rope you could only
  climb; now it swings.
- **3.3, the chandeliers:** 2 m becomes about 3 m. They are 6 m apart and each weighs
  more than the chain, so they changed least. The east one hit something on its west
  side in the new run (0.8 m).
- **The garden's entry roots and the temple's door chains** (they catch a throw from
  the area below): they hang lighter, so a body that hits one carries it along more.
  The catch itself was not tried.
- **4.2, the lianas:** 2.6 m becomes 5.2 to 5.8 m, with the vines 5 m apart: vine to
  vine by hand. Easier.
- **4.3, the spore lift's vines:** the updraught there is 3.7 m/s2 up, more than the
  climber's gravity. On a light vine a climber in the draught is carried up with the
  vine slack. Not tried by play.
- **4.9, Los Ojos:** the two short roots over the eyes now swing far enough to touch a
  puffball, and it throws you: in the new run the climber on `ojo_ra` was thrown 17 m
  and lost the rope, and on `ojo_rb` 10 m. Before, a swing there never reached the
  eyes. The eyes are that challenge's way across, so this may be right; it is new.
- **6.5, the chain off the last raft:** the climber lost its grip at the west end of a
  5.5 m swing (it was 2.4 m). Something there took it off: not looked into.
- **6.6, the hammers' chains, 10.6, the kites' tails, 11.4, the bell's rope, 7.4, the
  drawbridge's ropes:** these are thrown about by what they hang from, before and
  after. Their numbers say only that.
- **9.6, 10.1, 10.8, ropes in the wind:** see the call above. The balloon's ropes hang
  9.7 m downwind at the gust's height, where they hung 4.5 to 4.8 m.
- **10.3, the prayer lines:** strung lines sag 0.1 to 0.2 m more under a climber.
- **Flings off a rope:** the area files give a speed for each ("5 m/s off a rope", "4.6
  m/s from a dead hang"). One push from a still hang gave 2.3 m/s before, nearly
  straight up, and gives 0.9 m/s now. The speed comes from the swing now: 4.2 to 4.4
  m/s at the bottom after five or six pushes on a 5 m rope, more on a longer one.

- **Pictures:** `20_rope_hanging_still.jpg`, `20_rope_push_2.jpg`, `20_rope_push_4.jpg`,
  `20_rope_push_5.jpg` (the mine's rope, 1.4). No "before" picture: a still does not
  show a swing; the tables do.
- **Checked:** lint; the `--peak` battery; and, because the climber is shared with the
  arena, `--swing --grab --climb --feel --neutral --peakride`: all clean.
- **First-try numbers:** the rope's weights; `rope_pull` 2.4; `rope_pump` 0.16; the
  lift's limits (0.35 m below the grip, 0.8 to 1.3 m/s).
- **Not checked:** any of it by play. No designed move was replayed end to end: the
  script can swing and climb, it cannot fling and catch.

## Note 22: the water's full overhaul

- **State:** done on every stretch and fall, watched in the game. Nothing played by a
  person. It is a first try at a look: Parker's eye decides.
- **Parker 11-12:** "water will need a full visual overhaul, it is in weird cubes and it
  doesn't pour off things or look like water".
- **The sample stretch** is the mill race of 2.2 and 2.3: `22_mill_race.jpg`,
  `22_race_close.jpg`, `22_wheel.jpg`, `22_channel_over_the_lip.jpg`,
  `22_channel_fall_lands.jpg`, `22_race_over_the_lip.jpg`. Before: `22_before_race.jpg`.
- **Rolled out in the same change** (the drawing is general; nothing is per-stretch):
  all 14 stretches and the falls. `22_flume.jpg` (before: `22_before_flume.jpg`),
  `22_step.jpg`, `22_cascade.jpg` (before: `22_before_cascade.jpg`),
  `22_cascade_foot.jpg`, `22_river_lip.jpg`, `22_pool_210.jpg`, `22_chica.jpg`,
  `22_dam_leak.jpg`, `22_lake.jpg`, `22_sump.jpg`, `22_climber_drips.jpg`.

### What changed (`stages/peak/peak_zones.gd`, two new shaders)

- **The look is separate from the rules.** A water rule (a box with its own current) is
  never drawn. Rules that touch at one surface are drawn as ONE body, from their
  joined outline (`_build_bodies`, `_body_vis`): the flume, the tail pool and the three
  still patches behind the pillars are one piece of water. No seam, no darker box
  where a still patch lies over a river. The 14 rules make 9 bodies.
- **A waterline that moves.** A travelling ripple cuts the body's top edge
  (`stages/peak/peak_water_body.gdshader`); it runs with the current.
- **A body with depth.** The cave's two blues, lighter at the surface, darker down; the
  climber and the bed show through it as before, with no box edges.
- **Current you can read.** Long soft streaks slide with the flow, longer and stronger
  where it is faster. Each point of the body carries its own speed, so the river's
  quick end and its still patches are one surface. In a still patch the streaks fade
  out and slow turning arcs take their place. **The square specks are gone.**
- **Foam where water meets something:** at a body's ends, and at every pile or pillar
  that stands through the waterline (found from the rock itself).
- **Water that pours** (`_fall_vis`, `stages/peak/peak_water_fall.gdshader`). A fall is a
  ribbon along the water's own path. At a lip the pool's WHOLE depth turns over: the
  ribbon's top is the waterline and its bottom is the bed's corner, so the pool has no
  end wall; its end is the fall. It thins as it speeds up, as falling water does. It
  starts in the pool's own colour, breaks white from its outer edge, runs in streaks
  that stretch as they fall, and turns white where it lands. At its foot: foam on the
  pool's waterline, Del Mar's spray and rings, and a mist. On a floor it spatters.
  The old fall was a pale slab as wide as its whole shaft.
- **Three falls that were missing are drawn** (`tools/peak/areas/a2.py`): the mill
  channel's drain into the race, the race's drain onto the lip ledge, and the flume's
  one-metre spill into El Charco del Pozo. Those pools ended in mid air before.
- **The river's fall into the mine is one line** through both areas (a2 draws it to
  y 84, a1 the rest, on the same x and thickness).
- **Things shed water.** The mill wheel's paddles drop water on their way up
  (`_find_sheds`). A climber just out of the water drips for a second and a half.
  Drops are round.
- **Kept:** note 2's splashes, rings and sounds; the cave tints; `WATER_TINTED`.
- **Gone:** `stages/peak/peak_water_front.gdshader` (note 2's front), the foam flecks.

### Frame rate (the probe's `fps` scene, 5 s each, uncapped, off-screen)

| Standing at | Before | After |
|---|---|---|
| 1.3 (the mine, over the Sump) | 130 | 171 |
| 2.3 (the mill race) | 107 | 140 |
| 2.8 (the flume) | 116 | 136 |
| 2.10 (the upper pool) | 110 | 128 |

It went up: one mesh a body where there was a box, a plane and a particle cloud a rule,
and a ribbon where there was a slab and up to 140 particles a fall.

### Honest limits

- **The flume's one-metre spill reads as a thick curl** (`22_step.jpg`): the whole depth
  of the flume turning over a drop shorter than it is deep. A first try.
- **The wheel does not reach the water.** Its paddles end 0.6 m above the race, in the
  model and in the collision. The drops are there; the lifting is not.
- **Barrels, chains and the cart do not drip** when they come up. Only the wheel and
  the climber do.
- **"Thin spills where a channel overflows an edge"** (the page's plan): none added.
  There is nowhere in the data that says a channel overflows.
- **Foam against the barrels:** none. They move; the foam is found once, from the rock.
- **The top of each body** is still Del Mar's flat surface, seen at a slant: it does
  not rise and fall with the front's ripple (3 cm).
- `after/02_water_*.jpg` show note 2's surface, which this replaces. The `02_splash_*`
  pictures still hold.
- **Not checked:** by play; the swims' feel (no rule changed); how it reads in motion
  to a person. Stills cannot show the streaks sliding.
- **First-try numbers:** the streaks' strength (`streak`, 0.7) and the ripple's height
  (`wave_m`, 0.03) in the body shader; `FALL_G` 7.0, the pull the falls are drawn under.

## Notes 28 and 43: the camera's own controls (solo climb only)

- **State:** done; the pad half watched in the game through a test pad. The keyboard
  half (Alt and the mouse, Shift) is built and was NOT exercised: a test cannot move
  the real mouse. Nothing played by a person.
- **Parker 11-12, note 28:** "make the right stick let you control the camera a bit line
  in Hallow Knight where you can look around with it and it returns to normal when you
  let go of it. Make it holding alt and useing the mouse on mouse and keyboard".
- **Note 43:** "make holding L on controller zoom the camera out and make it holding
  shift on keyboard and mouse"; which L: "left trigger".

### What it does (`game/main.gd`, `_peak_camera`)

- **Look around.** The right stick slides the view, further the harder it is pushed,
  up to 85% of the way to the screen's edge, so the climber is still in view on the
  far side. Let go and it glides back. A stick that drifts a little does nothing (the
  left stick's own dead zone).
- **On the keyboard, hold Alt** and move the mouse: the same slide, the same limits.
  While Alt is down the mouse aims no limb (a limb being held keeps its pose), and it
  stays that way until the view has glided back. The pointer is put back where it was
  when Alt went down, so the limb is not thrown when aiming picks up again.
- **Hold to zoom out:** the left trigger, counted as held from about half way
  (`trigger_press`, 0.45, the number the other triggers use), or Shift. The camera
  pulls back to the frame the spot's author drew for it, the one note 7 stopped the
  close camera from using; where nobody drew one, to twice the view. Let go and it
  comes back. The climber plays on as normal.
- **Together:** zoomed out, the look still slides the view, in proportion.
- **The follow camera is untouched.** It is kept in its own place and the look and the
  zoom are laid over it, so neither is slowed by the follow's easing.
- **Solo climb only:** this is the Peak's camera. The party modes do not run it.

### Measured (the probe's `look` scene, at 1.4, a test pad)

| | |
|---|---|
| The close view | 5.5 m half-height |
| That spot's own frame | 9.0 m half-height, aimed 4 m down |
| Zoom held 0.33 s | 8.97 m: there |
| Zoom let go 0.33 s | 5.53 m: back |
| Right stick full east | the view slides 7.5 m in 0.25 s, 8.3 m in all |
| Full down | 4.2 m in 0.25 s, 4.7 m in all |
| 0.25 s after letting go | 0.2 to 0.4 m from home |
| Stick pushed 60% | 4.05 m: about half of the full look |
| A drifting stick (15%) | nothing |

### The inputs (`core/players.gd`, `core/steam_input.gd`)

- Two new binds, held: `look` (Alt; a pad needs none, its right stick looks) and
  `zoom` (Shift; the left trigger). They are in the same table as the limbs: saved,
  swapped if a key is bound over, and put back by Reset. A save file from before
  keeps its binds and gains these two at their defaults.
- **Steam's layout** (the game writes its own): one new stick action on the right
  stick, one new button on the left trigger (its soft pull and its full pull both).
  See the call above: written without a pad under Steam to try it on.

### What this closes

- **Note 7's open call, the nine long jumps that land out of frame:** the close camera
  stays strict everywhere. To see a landing, hold the left trigger (or Shift), or look
  that way.

- **Pictures:** `28_43_normal.jpg`, `43_zoomed_out.jpg`, `28_looking_east.jpg`,
  `28_looking_down.jpg`, `28_43_zoomed_looking_east.jpg` (all at 1.4).
- **Checked:** lint; `--peak`; `--input --devices --hotswap --inputreconnect
  --personalcamera --feel`: all clean.
- **First-try numbers:** the look's reach (0.85) and its two easings; the zoom's
  easing; the mouse travel that is a full look (35% of the window's height).
- **Not checked:** Alt and the mouse, and Shift, by hand; a real pad; a pad under
  Steam; aiming a limb with the mouse while zoomed (the pointer's place on the wall
  moves as the view widens, as it does whenever the camera moves).

## Note 35: the garden's static

- **State:** changed from the recipe and the numbers. **Not heard by me: I cannot hear
  the game.** Dan or Parker has to judge it.
- **Parker 11-12:** "the garden green place has weird static noise".

### Was it the fizz? What the recipe says

The garden's background bed is `audio/sfx/peak/amb_a4.wav`, made by `amb_a4` in
`tools/peak/make_peak_sfx.py`. As it was, it had three layers:

1. **"room":** noise from 85 to 450 Hz, plus half as much noise from 300 to 2,500 Hz.
2. **"fizz":** random clicks (500 to 1,400 a second) rung through three sharp filters
   at 2,600, 3,600 and 4,800 Hz, with noise from 2,500 to 6,500 Hz under them.
3. Six plops (each with a small noise burst) and three insect chirrs, in a short room.

So yes: layer 2 is made the way you would make radio static on purpose. But layer 1 is
noise too, up to 2,500 Hz, and by the script's own loudness guide it was the louder of
the two (A-weighted, as they sat in the bed: room -23.1 dB, fizz -29.4 dB, the plops
and chirrs -38.9 dB). The whole bed was noise with a few events on top. Taking the
fizz out alone would have left a "shh". **Both noise layers are gone above 900 Hz.**

### What the new bed is

A soft damp garden, built to the plan on the page:

1. **Room:** noise from 85 to 420 Hz only. A low tone.
2. **A slow breath of air:** noise from 220 to 900 Hz, swelling and fading slowly.
3. **A soft pad in the climb's key,** as the crystal cave has its glass: D3, A3, D4,
   F#4, A4 as plain sines, each breathing on its own slow swell.
4. **Four slow drips** (new), **the six plops** (without their noise burst), and **the
   three insect chirrs**, a little under half as loud as they were (0.10 from 0.18).
   A slightly longer room on them.

| | Before | After |
|---|---|---|
| Share of the bed's power above 2 kHz | 4.34% | 0.03% |
| Share between 2.5 and 6.5 kHz (the fizz's band) | 3.08% | 0.02% |
| Share above 900 Hz | 8.16% | 0.84% |
| Loudness guide (A-weighted; every bed is the same plain level, -16 dB) | -22.1 dB | -24.3 dB |

What is left above 900 Hz is the drips, the plops' tops and the chirrs (3.5 to 4.1 kHz
tones, pulsed 47 to 64 times a second: three of them in 12 s, 0.4 to 0.7 s each). If a
buzz is still heard, the chirrs are the first thing to take out.

### Its level

- The beds are all mastered to one level and trimmed per area in
  `stages/peak/peak_audio.gd` (`AREA_DB`). The garden's trim was 0.0, against -1.0 for
  the mine, -2.0 for the black waters and -2.5 for the crystal cave. **It is -2.0 now.**
- An honest note on "the loudest": by the loudness guide the old garden bed, as
  played, was level with the crystal cave and the black waters (-22.1 against -22.0
  and -22.5), and about 5 dB over the mine and the temple. It stood out for what it
  was, not for how loud. As played now it is -26.3: 4.2 dB under where it was, between
  the crystal cave before it (-22.0) and the temple after it (-27.5).

- **Files:** `tools/peak/make_peak_sfx.py` (the recipe and its one-line description),
  `audio/sfx/peak/amb_a4.wav` (rebuilt; the full script was run, and no other sound
  changed by a byte), `docs/peak/SFX.md` (its row, written by the script),
  `stages/peak/peak_audio.gd` (the trim).
- **The game picks the new file up when Godot next imports** (opening the editor, or a
  build). No import was run in this folder.
- **Checked:** the loop's seam (the script's own test: passes); lint; `--peak`.
- **Not checked:** by ear, any of it.

## Note 72: the station's lever starts the cart

- **State:** done, watched in the game and in the battery, with the Kit's two models.
  Nothing played by a person.
- **Parker 11-13:** "make it so you have to pull the lever to start the cart, regardless
  of if you are in the cart. If you pull the lever it goes. It controls like the chair
  whaere you are hlding the activated limb".
- **What changed:**
  - **The cart no longer starts when boarded** (`tools/peak/areas/a0.py`: `cart0`'s
    trigger is `"lever"`). Standing in it for any length of time does nothing.
  - **A lever is a new kind of thing in the course** (`A.lever` in
    `tools/peak/peaklib.py`; `_build_lever` and `_tick_levers` in
    `stages/peak/peak_things.gd`). It is taken as the arena's chair is: by the limb
    whose button is DOWN, when that hand or foot comes within 0.3 m of its grip (its top
    0.4 m), and kept while the button is held. While held it follows the hand round its
    pivot, between its two notches.
  - **Drawn all the way** (0.7 m at its top) it drops into its second notch with
    `lever_clunk` (a sound the game already had) and the cart goes, whether or not
    anyone is in it. **Let go short of that** and it springs back.
  - It stays in its second notch while the cart is away and goes back to its first,
    with a quieter clunk, when the cart is home.
  - **The cart comes home by its old rule,** unchanged: 25 s after it stops, once the
    climber is 22 m from it (or 75 s after, if nobody is on it).
  - It stands 0.65 m in FRONT of the climb, just in front of the near rail (the
    Director's change, 11-13: behind the cart it was half hidden), and is never solid:
    nothing sticks to it.
  - **The chock.** The base model carries the rod and the chock as its own object
    (`stn_lever_rod`). As the lever is drawn over, the rod draws the chock 0.42 m east,
    out from under the cart's near wheel; it goes back with the lever.
  - The old `brake_lever` deco is gone.
- **Where it is:** pivot at (-7.6, 2.2) on the deck; the arm 1.7 m; at rest 11.9 degrees
  west of upright (its top at (-7.95, 3.86)), pulled 11.9 degrees east ((-7.25, 3.86)):
  the notches the arm's model was made to.
  The brief's pulled height of 3.75 does not fit a 1.7 m arm turned about that pivot;
  the angles are what the game uses.
- **The models:** `stn_lever_base` (origin at the pivot) and `stn_lever_arm` (straight
  up from the pivot; the game turns it), synced from the Kit and imported
  (`kit/models/`). If either is ever missing, a dark block and an iron bar with a red
  grip stand in. A thicker arm, re-landed with the same origin and length, needs only
  a sync and an import.
- **Watched** (the probe's `lever` scene): 3 s standing in the cart, it did not move.
  The right hand, its button held, took the handle; drawn east it was thrown in 0.28 s
  and the cart rolled. The cart was home 42.8 s after the pull and the lever back in
  its first notch. From the deck, with nobody in the cart, the left hand threw it in
  0.8 s and the cart left without the climber.
- **The battery** (`--peakride`, rewritten for this): in the cart and it stays; a held
  hand takes the grip; half way and let go, it springs back; all the way, the cart
  rolls; the ride to the buffer; the lever stays over while the cart is away; home
  again, and the lever back. All pass.
- **Pictures:** `72_lever_at_rest.jpg`, `72_lever_hand_on_it.jpg`,
  `72_lever_half_way.jpg`, `72_lever_pulled.jpg`, `72_cart_going.jpg`,
  `72_pulled_from_the_deck.jpg`.
- **First-try numbers:** how near a hand must come (0.3 m), how far it may stray
  before it is let go (0.8 m), how fast it springs back.
- **Not checked:** by play. Nothing tells the player the lever is there or that the
  cart now needs it; at rest most of it is behind the cart's east end, with the grip
  showing above.
- **Note 73's hop is not part of this.**

## The far layers as flat facade cards (not a playtest note)

- **State:** the game's side is in, drawn with plain code cards until the kit's models are
  synced. Watched in the game by frame. Nothing played by a person.
- **Parker 11-13:** "that is now the correct way to do far backgrounds" (flat painted cut-out
  cards; `docs/peak/PEAK_DESIGN.md` section 7). Three far layers broke it: the valley's
  floor, the sea of cloud's floor, and the plaza's modelled ranges.
- **The valley** (`stages/peak/peak_backdrop.gd`): the flat floor of fields, the river and
  road lying on it and the hill cards are gone. In their place ONE upright card stands
  2,350 m back (`peak_valley_panorama`; a code card of the same measure until it lands): its
  origin line, where the painted fields meet the feet of the painted hills, is at y 215
  (`HORIZON_Y`). Measured in a frame from El Balcon (y 580): that line is half way between
  the middle and the foot of the picture, so the valley is the bottom quarter.
  - The two cardboard ranges stand on that line: their heights are squashed to 0.8 and lifted
    215 m; the giants keep their own height (1,080 to 1,260 m). Their cards run on 900 m
    below the line, hidden behind the valley's card: a card that much farther back shows its
    foot HIGHER than the valley's line when seen from above, and sky would show under it.
  - The tiny town (`town_far`) stands 12 m in front of the card, 150 m east of its middle,
    34 m under the line, at 6.4x (it was 9x at 3.3 km: the same size on screen).
    `town_at()` returns that spot. **Nothing in the game calls `town_at()`:** there are no
    fireworks in the code yet, so there was nothing to check from the summit. For whoever
    writes them: from the summit they must rise past about y 960 at the town's depth to
    clear the banks in front of it.
- **The sea of cloud:** the white floor is gone. Behind each of the seven rows of kit clouds
  stands a continuous row of banks (`peak_cloud_bank_a` and `_b` by turns; code cards until
  they land), their origin line at y 932.
  - **Size:** a row's banks are scaled by its depth / 3,100 (the far row at the made size),
    as the clouds are, but never under 0.3. The floor of 0.3 is needed: from the summit, 68 m
    above the sea, a row's body must hang about 70 m to cover the gap down to the top of the
    row in front. Scaled purely by depth, the near rows would hang 18 to 46 m and the valley
    would show between them.
  - Each row's banks stand just behind its farthest cloud (the last row at 3,600 m, in
    front of both ranges), and its clouds are kept in front of them. The clouds drift as
    before; the banks stand still.
- **Each layer has its own seed now,** so a kit model landing in place of a stand-in does
  not reshuffle the ranges or the clouds. The ranges and clouds are therefore not the same
  shapes as before this change.
- **The plaza's ranges** (`stages/plaza_mountains.gd`): each of the four is the kit's
  painted card (`plaza_range_a` to `_d`) if it has landed, on the massif's own spot and
  ground, square to the camera, and sinks for Del Mar by the same number. Otherwise the
  massif, as before. The Peak's model and Del Mar's own hills are untouched. Tried with a
  card that has landed (`stn_far_hills`, through the probe's new `--cards=`): it stands,
  faces the camera and sinks.
- **What the frames show** (`docs/peak/playtest/far/`, before and after pairs; the `clear_`
  ones are from open air 290 m east of the route, where no area's own cards are in the way):
  - **From the cliffs the sky is mostly gone.** The far banks are 300 m tall, so from y 580
    the rows close into a striped ceiling from a little above the middle of the picture to
    its top; open sky is one band between the far range and the first row. The sun and the
    giants are behind the banks from there. Before, it was separate clouds on open sky.
  - **From the summit** it is rows of white banks and clouds with nothing of the valley
    between or under them, and a giant's snow tip standing out.
  - **At the storm ridge** (y 933) the camera is inside the layer: the valley's hills and the
    town show along the foot of the picture under the storm's clouds. It was so before too
    (the old floor showed there).
  - **In the game's own views the areas' own cards hide most of this:** the cableway's
    orange mountains, the storm's wall and the summit's pale back card cover nearly all of
    the far layers at 8.4, 10.5, 11.1 and 11.4. Only the cliffs see them widely.
- **In the engine:** no trouble found. The valley's stand-in is colour regions 4 cm apart on
  one plane: no ink between them and no flicker at 2.35 km (the ink asks for a step of
  about a fifth of a pixel's width there, 12 cm at 4K). Banks side by side in one plane
  show no joint. Every row's top and underside takes the ink, as cut-outs should.
- **Not changed, and worth knowing:** the two cardboard ranges still have ink lines inside
  them (their shade and snow cards stand 2 and 4 m proud of the body, as they always did).
  The ranges are 7,400 m wide: on a 32:9 screen their ends would show (they did before).
- **Checks:** lint; `--peak`; the party game's `--ring --bell --plazafloor --delmar --tower
  --scramble`: all clean. The plaza and Del Mar by frame: unchanged, as no range card had
  been synced when they were taken.
- **Probes:** `tests/peak_watch.tscn` has a `far:TAG:7.1:7.5...` scene (each start, close and
  pulled back). `tests/delmar_shot_probe.tscn` now keeps a small window off every screen
  (the first run of it here opened a maximised window on Parker's screen for about 15 s),
  and takes `--jpg` and `--cards=`.

## To do: every note of 12 to 57 not done yet

Kept here so nothing is lost (Parker 11-13). The page has the same list.

**In hand:** nothing. Notes 20, 21, 22, 28, 43 and 35 are done (each has its entry above).

**Parked until Parker says** (his design job comes first):

- 12: a dark chimney in the cave-in's roof for the rocks to fall from.
- 18: the rings fixed to the wall, six chains out.
- 19: the gate's pistons (needs a model).
- 25: the dam as one inclined elevator with its winch on board.
- 26, 30, 33: the crystal cave's pieces in the pale purple cluster look (needs models;
  the white "you can hold this" finish may be possible in code).
- 29: the geode at 3 rpm.
- 32: the crystal bonsai (needs a model).
- 34: the ring's spikes pop in and out with a shake.
- 36: the bounce caps squash and spring.
- 37: the bouncy caps spotted (needs a model); the scenery mushrooms pushed back 6 to 10 m.
- 38: the spore updraught drawn as a real column with a source at its foot.
- 41: the mushroom hut and the frog (need models).
- 42: the giant mushroom (needs a model).
- 44: two warts, and the lunges checked.
- 46: the great cap (needs a model).
- 49: the gears, options 1 to 3.
- 50: only the middle censer stays.
- 54: the achievements list, "Pay Your Respects" first.
- 57: the great bellows works its gust; the three small ones breathe.
- The model requests still to be written into `MODEL_REQUESTS.md`: 19, 26/30/33, 32,
  37, 41, 42, 46, and the four cracked pieces of group E.
