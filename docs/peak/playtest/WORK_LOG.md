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

- **State:** done, with the kit's thirteen models in (see "The kit's models in" below).
  Watched in the game by frame. Nothing played by a person. What follows first is the
  stand-in stage, as it was written.
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

### The kit's models in, and two more layers (the plaza's Peak, Del Mar's far shore)

- **Synced and imported** (`python tools/sync_kit.py`, one import), all thirteen measured
  against what was asked: `peak_valley_panorama`, `peak_cloud_bank_a` and `_b`,
  `plaza_range_a` to `_d`, `plaza_peak`, `plaza_peak_flag`, `delmar_far_hills`,
  `delmar_far_isle_a` to `_c`. The code takes each by name; the code cards and modelled
  pieces stay as fall-backs.
- **The plaza's Peak** (`PlazaMountains.peak()`): the `plaza_peak` card stands where the
  half cone stood, square to the camera, with `plaza_peak_flag` on its summit as its child.
  `peak_flag()` and `peak_shown()` work as before; it is still the last entry of `build()`
  and sinks 218 m for Del Mar (the card and flag are 191 m).
  - **Nothing on the modelled Peak moved.** The cable cars, the storm and the bolt were
    still pieces: no code animated them. So nothing is lost to the flat card.
- **Del Mar's far shore** (`DelMarScenery._build_far_shore()`): the `delmar_far_hills` card
  stands in place of the four rows of dunes and hills, at (32.1, ground - 0.4, -298): the
  middle of the old run, on its ground, 2 m in front of the land's end so the whole strip
  of scrub and palms (z -297 to -293) stays in front of it. The three isles' cards stand at
  the isles' places. The beach, the rocky point, the sea stacks and the strip are untouched.
  - **The shared random stream is kept:** the hills' and isles' draws are still made when
    the cards stand in their places. A new battery, `--delmarfar`, builds the far shore both
    ways and compares the stream's state after it: the same number. Frame against frame,
    nothing in the start, wide and far views changed outside the band the hills are in.
- **What the frames show with the real models:**
  - **The banks' feet are ruled lines.** Each bank's body ends in a straight edge 230 m
    under its line. From the summit nobody sees it. From the cliffs every row draws one
    straight inked line across the whole sky, seven of them stacked
    (`clear_780_pulled_back_after.jpg`, `clear_580_close_after.jpg`). My stand-ins had round
    bellies there. This wants a cut underside on the models; code cannot hide it.
  - No joint shows between banks side by side, and no ink between any card's colours.
  - The valley's card: the town stands on its calm patch and the road meets it.
  - The plaza: the four range cards stand where the massifs stood and do not cover the
    fang or the cable; the Peak's head and flag are under the top of the title and lobby
    frames.
  - Del Mar: the hills' card comes down to the rocky point and nothing of it stands over
    the bay. Its painted palms are dark shapes 10 to 20 m tall on the ridge, beside the
    scene's own bright green palms in front: a matter of looks, for the Director.
  - From the probe's aerial camera (not a play view) the hills' card reads as a flat fence
    at the back of the sand.
- **Checks:** lint; `--peak`; `--ring --bell --plazafloor --delmar --delmarfar --tower
  --scramble`: all clean.
- **Frames:** `docs/peak/playtest/far/`: `*_before.jpg` and `*_after.jpg` pair up (the
  earlier `*_after_standin.jpg` are the code cards). The plaza's `before` frames show the
  window's "click to regain controls" line in a corner: the probe hides it now.

### Round two: the banks with scalloped undersides, and the two far ranges as painted cards

- **State:** done, by frame. Nothing played by a person.
- **Synced and imported:** `peak_cloud_bank_a` and `_b` re-landed (179 m tall: 69 above the
  line, 110 below, the underside scalloped), and `peak_far_range_near` and `_far` (7,400 m
  wide, running 900 m below their foot line; crests to 400 m, and to 1,002 m at the far
  card's giants).
- **The ranges:** each card stands on the horizon line (y 215) at its `_range()` depth
  (3,620 and 3,880 m), at its made size. `_range()` stays as the fall-back. The cards are
  not squashed as the code's ranges were: the far card's giants need their height to stand
  out of the sea of cloud (their tops are at y 1,217; the last bank's top is at 1,001).
- **The banks, re-sized for the shorter body:** never under 0.55 now (it was 0.3 with the
  230 m body), which gives 61 m of body on the five near rows, 78 and 110 on the two far
  ones. Worked out row by row for a camera 35 to 85 m above the sea: from 75 m up (the
  summit's top) every row covers the one behind with 9 m to spare; no row was added and no
  spacing closed. Under the nearest row, low in the frame at the summit's foot, the storm's
  deck is in front.
- **The rows are staggered:** each row stands 5 to 9 m higher or lower than the last
  (`BANK_STEP`), so the undersides of the five equal rows are at five heights and do not
  fall into one line when the camera is level with them.
- **What the frames show:**
  - **From the cliffs** (`clear_580_close_after2.jpg`, `7_5_close_after2.jpg`): rows of
    cloud with scalloped undersides and open sky between them and under them; the sun shows;
    the painted ranges stand on the valley's hills, the far one snow-capped.
  - **From the summit** (`clear_1000_close_after2.jpg`, `clear_967_pulled_back_after2.jpg`):
    rows of white banks and clouds, nothing of the valley between them, a giant's tip
    standing out. At 967 pulled back, one corner at the very foot of the frame shows a
    sliver of valley past the end of the storm's deck (the open-air view is 290 m east of
    the route; over the route the deck is under the frame's middle).
  - **At the glacier and the storm ridge in play** (`9_9_pulled_back_after2.jpg`,
    `10_1_pulled_back_after2.jpg`): the banks are a band of three or four stacked rows about
    an eighth of the picture tall, with the ranges and the valley under it. Not a white-out.
  - **In open air at glacier height** (`clear_832_close_after2.jpg`, no area in the way):
    the upper two fifths of the picture IS white: the camera looks up into the undersides
    of all seven rows. The game never has that view today, because the glacier's own ice
    and the storm's own clouds fill that part of the screen.
  - **Seen from underneath, the cards' thickness shows:** a kraft-brown line along the
    scallops' points on the nearest rows, and small notches where two banks' undersides
    meet at different heights (same frame). From above, the near banks' top edges show
    kraft too. That is the cards' cut edge, as made.
- **Checks:** lint and `--peak` clean.
- **Frames:** `*_after2.jpg` in `docs/peak/playtest/far/`; each pairs with its `*_after.jpg`
  (the first banks and the code's ranges).

### TRIAL: three areas without their own stand-in far views (three commits, each can go back alone)

- **State:** in, for the Second Director to judge by frame. Lint and `--peak` clean after
  each. Nothing played by a person.
- **Why:** the areas' own flat "far" cards stood 14 to 60 m behind the climb and hid the
  Peak's real far layers. The orange slabs at the cableway and the blue ones at El Balcon
  were these, not the backdrop's ranges.
- **El Teleferico** (`tools/peak/areas/a8.py`, commit `a6ef221`): out went the three cards of
  far range (z -30, -22, -14), the `town_tiny` standing on the nearest, and the `sun_low`.
  The "clouds" effect along the foot stays: it is mist in the void itself. Light and
  palette untouched.
  - **Seen:** the painted valley with the town on its patch, the painted ranges under the
    area's gold sky, and the rows of cloud. **The rows fill the upper two fifths of the
    picture at 8.4** (y 703: the camera looks up into all seven undersides), with gold sky
    in one gap between them. The pylons, wheels, cars and pennants read against it.
- **Los Riscos** (`tools/peak/areas/a7.py`, commit `13375fb`): out went the two cards of far
  range (z -30 and z -18) and the area's second `town_far` (z -60). The "clouds" effect
  stays. The cliff's own cards (tower, arch, fin, horn, needles, the west back at z -2.5)
  are untouched.
  - **Seen:** at 7.1 the ranges, the rows of cloud and the sun stand behind the balcony;
    pulled back, the valley and town are under it. Flags, signs and holds read as before.
- **La Cumbre** (`tools/peak/areas/a11.py`, commit `7ba244d`): out went the one pale sky card
  (z -40). Nothing else.
  - **Seen:** the summit stands over the real sea of cloud under a gold sky, with a
    giant's tip standing out and the storm's deck dark at the foot.
  - **There are two suns now.** The area's own pale disc behind the bell (a card at z -36,
    22 m across) was drawn pale on the pale card; without the card it is a great white
    disc, and the backdrop's yellow sun is in the same picture to its east
    (`11_5_close_trial.jpg`, `11_4_close_trial.jpg`). One of them should go.
  - No hold, ring or plank was lost against the new sky in the four starts shot.
  - **Settled (the Second Director, 11-13): all three trials stand, and the pale disc is
    out too,** so the backdrop's yellow sun is the only sun. The disc was a card, not a
    light (the bell's own light is untouched). The bell rope, which 11.4's leap ends on,
    used to hang in front of the disc: it now reads against the gold sky and the clouds by
    its ink, no worse than before (`11_5_close_trial2.jpg`, `11_4_pulled_back_trial2.jpg`).
- **Each area's JSON** was regenerated from its file; the difference in each is only the
  entries named (plus empty `levers` and `boards` lists the generator now writes).
- **Frames:** `docs/peak/playtest/far/`: `8_*`, `7_*`, `11_*` and `10_9_*` as `*_trial.jpg`,
  against the same views as `*_after2.jpg`. `7_10_*_trial_a8.jpg` is the low station with
  only the cableway's cards out.

## The fix run of 11-13, group 1: the mountain's rules of play

The brief: `docs/peak/playtest/FIX_RUN_1113.md`. All eight items are in, each a first
working version. Measured headless (`--peakrules`, new) and by frame in the real game
(`tests/peak_watch.tscn`, scenes `g1ice`, `g1serac`, `g1slab`, `g1wind`, `g1bolt`,
`g1drawn`, `g1cold`). The "before" frames are the same scenes with the old files swapped
in. Nothing played by a person.

1. **A crunch knocks you out (notes 49, 78).** `_tick_crunch` in `peak_things.gd`. Each
   tick a small ball inside the head, the chest and the hips (62% of the part's own size)
   is checked against the world. If one ball is touched by a moving piece and by anything
   else solid, or by two moving pieces, for 0.08 s, you are knocked out (stars, bonk) and
   drop. A piece is "moving" above 0.15 m/s or 0.15 rad/s, so gears, sheaves, pistons and
   counterweights are all covered by one rule. Hands and feet are not checked.
   - Measured (`--peakrules`): chest squeezed between a moving jaw and a wall: out after
     0.07 s. The same squeeze with the jaw still: nothing. The jaw closing on a hand
     only: nothing.
   - **Not tried on the real gears of 5.4 or the sheave of 8.4.** The geometry of those
     pinches was not reproduced by script.
   - First guesses: the ball's size (62%), the 0.08 s.
2. **Held between two moving things (note 83).** In `_tick_strain`. When a grip has to
   break and two or more of the held things move, the thing with fewer of your limbs loses
   and all your limbs on it let go together; on a tie the lower held point loses. With one
   thing still, the moving thing wins as before.
   - **Found on the way:** the old rule never fired for two things moving apart at the
     same speed (it compared speeds, which were equal), which is the counterweights' case.
     It now compares the grips' velocities. A thing counts as moving by its own speed (a
     mover's speed and turn), not by the hand on it, because the hands lag behind.
   - Measured: two limbs rising, one sinking: the one lets go. Hand on one thing, foot on
     another, either way round: the foot (the lower) lets go. One thing still: its grip
     lets go.
3. **Cold shows on the hand (note 84).** `_frame_glyphs`. The button mark on a limb holding
   timed ice shivers from 6 mm to 5 cm as its 2 s run out, then 8 mm while that hand cannot
   grip again (0.6 s). Measured on 9.1: up to 0.011 m in the first half second, up to
   0.048 m near the end. `TELL_COLD` is still off. The open call ("whether the mark keeps
   a slight shiver while the hand cannot grip") is answered yes, slightly: a first guess.
4. **Sharp tips are blunt as solids (note 90).** `Peak.blunt()`, used by every solid's
   collision (`_add_shapes`). Any corner sharper than 40 degrees is cut back along both its
   edges until its end is 8 cm across, at least 15 cm back from the point and never more
   than 30% of the corner's shorter edge. What is drawn stays sharp. Measured: a 14
   degree spike 1.2 m long ends 0.079 m across, 0.32 m short of its point.
   - **Not tried:** a hand dragged across a real icicle in the game (the test the brief
     names). The geometry is proven; the wrist is not.
   - First guesses: 40 degrees, 8 cm, 30%. It changes every sharp solid on the mountain
     (icicles, needles, crystal points, rock wedges). The Peak battery still passes.
5. **What can be touched is drawn.**
   - Note 98: a bounce line with look "rope" and no model is drawn as a band 0.2 m thick
     along its line with a dark padded cushion at each end, red, cream and jade in turn,
     squashing when it throws you. The summit's six ropes now show (`98_ring_ropes_*`).
   - Note 76: the bull wheel is drawn at `model_scale` 1.52 (7.6 m, the solid's size);
     `A.mover` gained `model_scale` (`76_bull_wheel_*`).
   - Note 77: every gondola draws its west step and east rack as plain iron bars exactly
     along their solids (`A.mover(..., drawn=[...])`), until the model has them
     (`77_gondola_rails_*`).
6. **Ice that comes is seen coming; ice that goes shatters (notes 86, 88, 91, 93).**
   - Icicles: each grows at its source over its last 2.6 s (from 8% of its length),
     shivers in the last 0.4 s, then drops, and shatters into pieces that touch nothing
     but the world on the first solid thing it lands on. On the floor of 9.2 over 14 s:
     before, 6 icicles lay there at once; after, at most 2 counted as still, both in the
     instant of landing. A knocked-out climber left lying under the four sources for 20 s:
     before, knocked out again 1 to 4 times; after, never, 18.4 s awake.
   - The serac of 9.5 keeps today's curve through level (85 degrees at 5.3 s, 105 at
     5.9 s), shatters at 108 degrees (6.0 s) and drops whoever is on it into the pit; a new
     one grows out of the ice 3 s later over 3 s and is solid only at full height. Watched:
     the climber left on it ended in the pit at 812 m (`88_serac_*`).
   - The slabs of 9.8 sit in a dark mouth at their source and creep out of it through
     their 1.3 s warning, then slide. A lip of ice (`A.board(..., kind="ice")`, a plain
     stand-in) at the rope's foot throws every slab into the cave behind the climb. Over
     22 s: 4 thrown, none past the rope's foot.
   - **Found on the way:** on this branch the slabs stopped against the new lip without
     being thrown, because a board meets a falling thing by its middle and a slab is a
     3 m box: they now meet it by half the slab's length.
7. **Wind is drawn loudly (notes 89, 70).** `stages/peak/peak_wind.gdshader`: one quad over
   each wind's whole box, long wavy white lines with an inked edge, travelling along the
   wind at 3 + 1.6 x its push m/s, showing at full strength while it blows and faintly in
   its warning. They fade out over the box's last 0.7 m, so you see where the wind stops.
   The old thin particle dashes are gone. Every streamer pole inside a wind's box flies a
   streamer (a chain of six painted pieces) that streams the wind's way while it blows and
   hangs slack between gusts. Only area 7 has such poles today; the glacier and the storm
   ridge have the lines only.
8. **Lightning says what it is (note 95).** Through the hum, sparks climb the mast's metal
   from its foot to its tip, faster and thicker toward the strike; a drawn yellow bolt
   hits the tip (the metal's own highest point, not the strike's sound point 30 m above
   it); the metal is tinted pale for the strike's 0.4 s (the house tint, no glow); the
   button mark of a limb on the metal buzzes through the hum. In a still frame the lit
   metal's tint is hard to see.

- **Checks:** lint; `--peak`; `--peakride`; `--peakrules` (9 of 9); `--swing --grab
  --climb`. All clean.
- **Pictures** (`docs/peak/playtest/after/`): `84_cold_hand_*`, `86_icicle_*`, `86_floor_*`,
  `88_serac_*`, `91_*`, `93_*`, `89_wind_*`, `95_hum_*`, `95_strike_*`, `98_ring_ropes_*`,
  `76_bull_wheel_*`, `77_gondola_rails_*`, each `_before` and `_after`.
- **Stand-ins waiting for models:** the ice lip of 9.8, the slab mouth (a dark disc), the
  gondola rails, the ring ropes' bands and cushions, the bull wheel's re-made model.

## The fix run of 11-13, group 2: small numbers and the HUD

- **Note 55:** the area banner's quiet time is 40 s (`area_quiet_s` in `ui3d/peak_hud.gd`).
  Not watched for the full 40 s.
- **Note 7, the long jumps' tool tip:** standing within 3 m of the launch of one of the nine
  long jumps, a paper card slides in at the bottom right: "Hold [bind] to widen the
  camera", naming the player's own zoom bind (the keyboard's when they play on keys, the
  pad's on a pad: "Shift" and "LT" by default). It slides out when they move off. No
  automatic widening. The nine are found from the course's own flings, in the six
  challenges they were counted in (3.5, 7.8, 9.6, 10.6, 11.2, 11.4), whose landing lies
  outside the close view from the launch (`Peak.long_jump_near`): 10.6 three, 3.5 two,
  11.2, 11.4, 7.8, 9.6. Seen at 7.8 and 11.4 (`7_tool_tip_at_*`), and not at 11.1.
  - **Note:** the HUD's code builds the card; main.gd decides when. Not seen on a pad or
    under Steam Input (the pad's bind name is the Controls board's own, "LT").
  - First guess: the 3 m from the launch.
- **Note 28, the Controls board's Next page:** a NEXT PAGE belt beside BACK turns to a
  second page with the two camera controls' rows (LOOK AROUND (HOLD), ZOOM OUT (HOLD)),
  each with its three keycaps, rebindable like the others; on page two the belt reads
  FIRST PAGE. The pad-check bubble moved 0.45 m east to make room. The camera rows' badge
  is a plain gold block: the kit has no eye or camera icon (a model request).
  (`28_controls_page_1_*`, `28_controls_page_2_*`). Rebinding a camera row was not tried.
- **Note 85:** the big icicles of 9.2 hold 1.5 s (the `icicle` kind's crumble time, was 0.7;
  only 9.2 uses the kind). A first try.
- **Note 63:** every vent x 1.1: the first 5.01 to 5.51 m/s, the twins 5.0 to 5.5 and 4.0 to
  4.4, the three stacked 4.54 to 4.99. Landings not tried again.
- **Note 61:** the updraught shaft's seven rings are four: on the wall the ring under the
  gust band (541.6) and the ring over it (547.3), across the head the first and the last
  (2.5 m apart). The worry in the note (no time to cross the band with the middle ring
  gone) does not hold by the shaft's own numbers: from a standstill on the 541.6 ring the
  climber is in the band from 1.8 s to 3.3 s, so letting go anywhere from 1.8 s before the
  gust ends to 0.2 s after clears it within the 3.5 s lull. Not tried with a climber. The
  route's legs are recorded as `drift` moves (the check read a 2.7 m drift as a reach).
  (`61_shaft_rings_*`)
- **Note 49:** the four gears turn at 5 rpm (a turn in 12 s). The reaches between gears
  at the new speed were not measured again by play.
- **Checks:** lint; `--peak`; `--peakrules`; `--input`; `--settings`. All clean.

## The fix run of 11-13, group 3: the course by biome (a0 and a2)

- **Note 73, the cart hops the broken rail (a0).** The cart's path has a `hop` at the crest
  (x -90): there it leaves the rails at its own speed along them and flies under g 8.9 m/s2
  (the design page's "real throw") until its floor is back on the track, then runs on from
  there. On landing: dust off both wheels, the cart's crash, and a jolt of the camera
  (`peak.cam_kick`, read in main.gd's Peak camera; there was no camera shake before).
  The rail decos of the broken stretch (x -94 to -90) are left out; its bent stub and the
  doubled sleepers are the dress's.
  - Watched (`g3hop`): the floor rose at most 0.98 m over the track and came down at x -98.4.
    A rider holding the cart's end stayed with it (never more than 1.09 m from it) and still
    held on. `--peakride` passes (the cart reaches its buffer and comes home).
  - First guess for Parker: g 8.9. With it the rider is lighter than the cart in the air
    (the climber's own gravity is 2.79); one who is not holding floats up a little.
  - `73_cart_in_the_air_*`, `73_cart_landing_dust_*` (the before frame shows the cart on
    the unbroken track).
- **Note 25, the dam's one lift (a2).** As the design page draws it: a gallery 7.8 m long
  and 2.6 m tall through the dam's foot from the apron, a shaft 2.6 m wide straight up
  inside the dam to the hall's roof, its east wall closed from the third step up, and one
  cage (deck 2 m wide, top bar 2.2 m up, both held) with its winch 1.5 m over the deck. The
  five lifts and five cranks are gone; the spillway's steps stay, bare.
  - The winch is a new kind of thing (`A.winch_lift`, `_tick_winches`): its handle is taken
    as the lever's is, by the limb whose button is held, near the handle; while it is held
    the crank follows the hand round its hub, and every bit it turns (either way) winds
    the cage up, 0.6 m a turn (about 25 turns). Stop and it sinks at 0.3 m/s, always. The
    pawl clicks each quarter turn.
  - Watched (`g3lift`): the hand took the handle at once; winding a turn every 1.4 s the
    deck rose from 152.2 to 156.9 in 6 s, 165.1 in 16 s and the crest's 167.0 by 22 s, the
    climber riding it; 3 s after letting go it had sunk 0.9 m.
  - Stand-ins: the cage is its deck and top bar only, the winch a hub, an arm and a red
    grip. The gallery's arch, the shaft's rails and rack, the lanterns: the dress's.
  - Not tried: stepping off onto the crest at the top, a real pad's circling stick.
  - First guesses: 0.6 m a turn, 0.3 m/s sinking.
  - `25_the_dam_*`, `25_winding_*`, `25_winding_higher_*`.
- **Checks:** lint; `--peak`; `--peakride`; `--peakrules`. All clean.

## The fix run of 11-13, group 3: the crystal cave (a3)

- **Notes 74 and 34, La Columna's collars (3.9).** The three turning rings are gone. As the
  design page draws it, three collars (the dress's: nothing of them is in the play space)
  carry pairs of spikes across the front of the column on slants: up and west from beside
  the lower shelf, up and east, up and west, each 6 m across and 3.8 m up in 10 s, each
  starting 1 m above the last one's end. A spike's tip slides out of the back over its first
  0.35 m, crosses, and slides back in over its last 0.35 m (`emerge` gained `back`); it can
  be held only while it is out. Four pairs a collar, 12.7 s apart (a turn in 50.8 s); the
  two of a pair 1.3 m apart. Each collar starts 8 s after the one below, so its first spike
  is out 1 m above you 2 s before yours goes in (the page said 1.5 s).
  - **Note 34 inside it:** each spike shakes for 0.5 s and goes in for 1.5 s of every 4.5,
    under your hand or not (it lets go of you: `blink` on a wrap path). The two of a pair
    take turns. Their phases were worked out so that a crossing's leading spike is never
    in during its first 2 s or its last 2 s.
  - Worked out (the game's own rule, off line): at each corner the leading spike near its
    end and the next collar's leading spike just out are both there for 1.43 s; a pair is
    never both in for more than a moment (0.18 s, at the slide-in edges).
  - A new west horn, level, 7.7 m long and 0.7 m thick, from the upper shelf's west end
    over the front of the column, its underside 1.2 m over the last crossing's end.
  - **Not tried with a climber.** The whole climb (a reach, three rides, two changes, the
    horn) is untested by play. Every number is a first try.
  - Stand-ins: the spikes are plain crystal studs.
  - `74_la_columna_before.jpg` (the rings), `74_la_columna_after*.jpg`, `74_la_columna_close_*`.
- **Note 26, Primer Destello's slanted shafts (3.1).** The six hexagon pods are slanted
  pointed shafts: five 1.1 m thick, leaning 30 degrees with their points high and west, a
  2 m sloping top and a 0.9 m point (both grip), the under-face glass; from each point the
  next top's low end is 2.2 m across and 1.3 m up (the flings re-laid). The sixth is
  snapped: 1.4 m thick, 0.8 m up in 3.4 m, its west end a glassy break, and that end
  exactly where today's rest ends, so El Espejo's first reach is unchanged.
  - **Moved:** laid back from that fixed end, the first top starts 0.73 m above the floor
    (the page said 1 m), and the first shaft's low end is now at its EAST end (x -411.5),
    so the challenge starts east of it, at x -410.6 (it was -415.0).
  - Not tried by play: walking up a top, hanging from a point, the flings.
  - `26_primer_destello_before.jpg`, `26_primer_destello_after.jpg`, `26_primer_destello_start_*`.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-13, group 3: the temple's pits and altars (notes 52, 54)

- **Note 52, all eight more pits lined.** `A.line_pit(x0, x1, top)` (new in peaklib): each
  inside face of a slot is lined slick from 0.6 m under the lip to 7 cm under it, as the
  gallery's two were, so a hand on the floor's top at the lip still holds. The eight the
  check listed: a1 x -201.0..-200.4 (y 14.2) and -232.2..-231.8 (52.3); a2's three catwalk
  gaps at y 153 (-405.3..-404.0, -412.8..-411.5, -419.8..-418.5); a7 -213.0..-211.6 (672.0),
  -229.5..-228.9 and -221.0..-220.4 (663.0). `python tools/peak/checks.py pits` marks the
  wide ones lined; the narrow ones no longer count as open slots (their liners fill part
  of the shaft). Not watched by a drop into each.
- **Note 54, Pay Your Respects.** F is the keyboard's fart (`DEFAULT_KBM` in
  `core/players.gd`; the pad keeps the right bumper). This is for the party game too. The
  game's first achievement: `Peak.award(id)` keeps it for good in the Peak's save
  (`achievements`, written even on a warped run) and tells main.gd (`achieved`), which
  shows it on the HUD's tool-tip card for 4.5 s with a chime. A fart pressed within
  2.5 m (plus half the altar's width) of either altar (the one at 5.10's start and the
  sacrifice stone by the well: every `altar` deco on the course) earns it; the altar puffs.
  - Watched (`g3fart`): F pressed at the first altar: earned, the card showed, the altar
    puffed (`54_pay_your_respects.jpg`). The second altar was not tried (the same code).
  - **Not built:** Steam (the game has no Steam app of its own yet), a page to see what you
    have earned, and the lucha ribbon the note asks for (the UI director's).
- **Checks:** lint; `--peak`; `--peakride`; `--input --devices --settings`. All clean.

## The fix run of 11-13, group 3: the chimney (a6: notes 58, 62)

- **Note 58, the dynamite rung.** The second rung from the top of 6.4's four (y 523.1) is a
  hold of the new type `dynamite`: a red stick with paper bands and a fuse (a plain
  stand-in), the same size and place, held like a rung. Touched, its fuse lights (a sizzle,
  a spark running along it, the stick shaking) and burns 1 s whether you let go or not.
  Then it blows: smoke, dust and sparks, the lightning's flash, a bang and a jolt of the
  camera. If any part of the climber is within 1.3 m it is knocked out; within 2.6 m the
  whole climber is thrown away from the stick through its middle (7 m/s at the stick,
  less further off). The stick is gone and back 10 s later. `blasts` counts them.
  - Watched (`g3boom`, `g3boom2`): the fuse and the blast as above; with the chest 0.5 m
    from the stick: knocked out and thrown (2.9 m/s at the chest a tick after); the stick
    gone, and back 10 s later.
  - **Found on the way:** thrown part by part, the parts on either side of the stick
    cancelled each other out (1 m/s); the climber is now thrown as one.
  - Not checked: where the blast can send a climber (the bellows' top board is under
    it); a real hand on the stick (the probe's weld would not hold the hand on it).
  - First guesses: the 1 s fuse, the 1.3 m and 2.6 m, 7 m/s.
  - `58_dynamite_lit.jpg`, `58_dynamite_blows.jpg`, `58_after_the_blast.jpg`.
- **Note 62, the high red block.** It is vent 2's grate and can be held. Every vent now seeps
  a little steam between its blasts, so a grate reads as a vent, and a lantern hangs right
  over grates 2 and 3. The fat steam pipes the note asks for are the dress's.
  (`62_the_grates_lit.jpg`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-13, group 3: the wind cliffs (a7: note 70)

- **Note 70:** 7.8's tail wind now runs east to the fang's west face (x -172.2, measured
  from the mountain's own body file across the box's height; it was -177.0), so there is no
  still strip between the horn and the rock. Push, rhythm and whistle unchanged. With
  group 1's drawn wind the lines now reach the rock (`70_wind_to_the_fang_before.jpg`,
  `_after.jpg`, both mid-gust). The fling from the bough to the porch is inside the old box
  and unchanged; not flown.

## The fix run of 11-13, group 3: the cableway (a8: notes 79 to 82)

- **Note 79, El Cable out.** Its five stretches (grease and all), the frayed end and the
  clamp plate are gone; the scenery wire up onto the sheave went with them. 8.3 is one
  fling from line 2's boom tip (-206.7, 698.3) to the west end of pylon 2's landing
  (-196.0, 703.0): 10.7 m across, 4.7 m up, about 6.8 m/s, an F4; rated 5. Not flown.
  Where a miss lands (La Garganta, as before) was not looked at again.
  (`79_el_cable_before.jpg`, `_after.jpg`)
- **Note 80, the chairs' poles.** `A.pendulum(..., rod_solid=False)`: the four chairs'
  hangers have no collision; only the seats can be touched. The chair model still draws its
  pole where it was (its re-made look, behind the climb, is the modelling run's). The
  gondolas' hangers stay solid, as settled.
- **Note 81, El Pilón's brace and rung out.** The climb is the landing, the lower sheave, a
  throw to the upper sheave, a throw to the head (both rated F3 by the course's own check:
  the lower one needs about 5.1 m/s). Rated 4 (was 3). Whether 9 rpm throws far enough
  is untried. (`81_el_pilon_before.jpg`, `_after.jpg`)
- **Note 82, the zip line goes all the way.** It runs on to over the middle of the
  maintenance deck (-193.0, 722.9) and slows to a stop there (a new `decel` on paths,
  6 m/s2), its handle 2 m over the planks: let go and stand. No timed release; rated 3 (was
  4). The scenery cable now runs to the new end and its "broken end" is gone.
  - Watched (`g3zip`): the ride takes 3.9 s and stops over the deck, the climber's feet
    just over the planks. Letting go was not shown (the probe's hand re-gripped at once).
  - `82_zip_riding_*`, `82_zip_at_the_end_*`, `82_zip_let_go_*` (before: the old stop, 4 m
    short).
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-13, group 3: the lower crevasse's small moves (a9: 9.3)

- **9.3 Puente de Nieve,** as the redesigned lower crevasse's page lays it (read off its
  to-scale sketch, 30 px a metre): nine pieces of snow lid 1.1 m long and 0.45 m thick (they
  were 1.25 m), each bridge sagging 0.15 m in the middle, the two wedged stones moved 0.75 m
  and 1.2 m east to suit, and 1.2 m of open air between the shelf's broken end (x -319.0)
  and the first piece: the step across is now the leg's first move. The last bridge still
  ends at the door's sill. In a frame the pieces' drawn snow caps overhang, so the step
  looks narrower than it is. Not played. (`93_puente_de_nieve_before.jpg`, `_after.jpg`)
- Notes 86, 88, 91, 93 of the glacier were group 1's.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-13, group 3: the storm ridge and the summit (a10: notes 92, 96; a11: notes 99, 100)

- **Note 92, the storm clouds.** The six flat grey cloud cards in front of the towers' feet
  are gone (a10.py). Nothing stands in front of the climb there now; the top of the glacier
  no longer ends blind. Cloud painted as cloud, behind the towers, is the area's design and
  not built. (`92_storm_ridge_foot_before.jpg` / `_after`, `92_storm_ridge_towers_before.jpg` / `_after`)
- **Note 96, the balloon's one rope.** `globo_rope`: one rope, 12 m, from the middle of the
  basket (x -321.5) where there were two 0.6 m apart. 10.7's last reach and 10.8's fling
  start move 0.3 m east onto it.
  - Measured: the note's worry was that the ridge's wind carries a light rope far out. On
    the branch the wind does not act on ropes at all (peak_zones.gd pushes climbers, not rope
    pieces), so no weight was added. Over 10 s at the balloon the one rope's foot did not
    stray sideways (0.00 m); the two ropes before strayed 2.1 m (the warp's hand took one).
  - Not checked: a climb up it and the pumped swing and fling west from the one rope.
  - (`96_globo_rope_before.jpg` / `_after`)
- **Note 99, El Último Salto.** The rotten plank is gone. The iron ring is 1.9 m higher, at
  998.2 (WTOP + 3.0, the corner post's top), and still 3.7 m west of the post (x -335.7).
  11.4's moves now: climb the post (two reaches), jump 3.7 m level to the ring (F2), then
  the last leap, 20.0 m across and 2.7 m down (F4). The battery's move checks pass.
  - Not checked: the jump from the post's top to the ring, the last leap from the higher
    ring, and where a miss of the first jump lands.
  - (`99_post_and_ring_before.jpg` / `_after`)
- **Note 100, the bell rope rings the bell.** A rope may name a `bell` deco (a11.py:
  `bell_rope["bell"] = "summit_bell"`; decos now carry their model's name as meta `deco`).
  peak_things.gd `_tick_bells`: the bell swings on its hanging point, led by the rope's swing
  (0.7 of its angle, at most 29 degrees, never past 34: its yoke), on a soft spring so it
  lags and rocks to rest. A clapper hangs under it (a plain iron rod and ball until the
  bell's model has one), showing under the lip. Each time the swing turns, if it swung at
  least 5 degrees each side, the clapper is thrown on and strikes: the bell tolls, louder
  the harder. A climber's weight coming onto the rope tips the bell and tolls it at once,
  loudest for a fast catch (up to +4 dB; the last leap's). The three tolls at the belt
  stay the finish.
  - Watched (`g3bell`): the catch tolled (the warp's own grab and a re-grab, 2 tolls); in
    12 s of pumping (four 2 m/s shoves in time with the swing) 3 tolls; the bell tipped
    14 degrees; let go, it rocked to rest in 3.3 s.
  - **Found on the way:** a 10 m rope at the climber's gravity swings once in about 7 s,
    too slowly for a clapper on a spring to lag and strike on its own (0 tolls in 12 s), so
    the turn of each swing throws it.
  - Not checked: a real catch from the last leap (the probe hand is put on the rope); how
    loud the catch is against the finish tolls; whether the town answers the first toll
    (note 100's open call; not built).
  - First guesses: follow 0.7, 29 and 34 degrees, the springs (bell 10/s2 damped 3/s,
    clapper 45/s2 damped 4/s), 5 degrees to toll, the volumes.
  - (`100_bell_still_after.jpg`, `100_bell_swinging_after.jpg`, `100_bell_after_after.jpg`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a0's dress file wired in (the modelling run's a0_dress.py)

- `a0.py` calls `a0_dress.dress(A)` after the station's dress. Out: the tunnel's back-wall
  card (z -3), the mouth's `mine_frame`, the seven `lantern_mine` decos. The seven lights
  stay, each moved into its lantern (the hook's x, its y - 0.27). The rail loop leaves out
  the three torn-stretch pieces at x -91.75, -98.75, -102.25 (the dress's torn, landing and
  banked rails take their places). The cave's slabs wear `dsc_bed_a`..`d` and
  `dsc_roof_a`..`d` by stretch, the corner fillers going with the stretch the list names;
  the buffer wears `dsc_buffer_stop`.
- **The scree slab in the tunnel mouth (st.py), from the dress's designer:** the outer
  slope's last slab had its inner corner at (-38.5, 3.3), inside the tunnel's air: at x -36
  it filled y 4.5 to 7.2, a rider's head height over the cart's floor (2.2). The corner is
  lifted to (-36.0, 7.4), the roof's underside, so the slab's foot runs above the mouth.
  Not watched by a ride (the ride battery passes).
- **Checks:** lint; `--peak`; `--peakride`. Clean. Frames of the stand-ins are the
  modelling run's.

## The fix run of 11-14: the Controls board's LOOK AROUND pad cell (note 28, the Director's look)

- LOOK AROUND (HOLD) showed "-" in the PAD column. A pad looks with its right stick, always
  (`Players.look_stick`; the pad's `look` bind is empty on purpose), so the cell now reads
  RS while that bind is empty (`lucha_settings.gd` `_refresh_cells`). A button bound there
  shows as itself. (`28_controls_page_2_rs.jpg`)
- **Checks:** lint; `--settings --input`. Clean.

## The fix run of 11-14: the cart room reworked (note 103) and a1's dress file wired in

- **Note 103, El Carrito Loco (1.7), from its redone page.** Both chains on Las Vigas's first
  beam are gone. The cart's road now runs on from the stub's end (-213.2, 40.0): over a
  crest of 2.2 m radius, down at 72 degrees, round a dip of 2.5 m radius (low point
  (-220.51, 28.0)), up at 45 degrees to the lip (-223.0, 29.45): the page's own line. It
  is solid, 0.4 m of timber under the rail (wood: held and stood on), one piece per stretch,
  each wearing `mine_cart_road` (landed: it sits on the road exactly). The cart's line runs
  0.45 m over the rail.
  - **New in the game: a speed for each stretch** (`speeds` on a path mover, one per point;
    `_speed_along` in peak_things.gd). The cart gathers to 5 m/s on the level at its old 2
    m/s2, then takes the road's speed: as if by 4.96 m/s2 of fall to 12 in the dip, losing
    on the rise to 10 at the lip. It leans with the road quicker (`tilt_rate` 30), and is
    let loose at the lip and falls for real (as before, at a faller's 5.4 m/s2).
  - One chain, 9 m, from an iron ring at (-230.6, 44.2), its tail at 35.2; rings at
    (-226.2, 46.2) and (-221.8, 48.2), stand-in holds 0.5 across, each wearing
    `iron_ring_pin_long` (landed; its deco placed at the pin's root, z -1.6). 1.7's moves:
    the ride, then ring to ring (4.4 across, 2 up) and the last ring to the first beam's
    underside (3.7 across, 1.9 up), all F2.
  - The cart's camera zone now covers x -234 .. -200, y 26 .. 50 (half height 12.5).
  - The chock under the cart's west wheel (`mine_chock`, landed) is on the cart: it jumps
    out tumbling when the cart starts and is back when the cart is.
  - **Measured** (`g103`, the rider standing in the cart, one hand on it): over the crest
    5.0, in the dip 12.0, at the lip 10.2 m/s; let loose at (-222.74, 29.83) going 10.0 m/s
    at 45 degrees; the rider never more than 1.1 m from the cart. The cart crossed the
    chain's line (x -230.6) at y 34.1 to 34.5 in three runs, the top of its arc right there;
    the chain's tail at 35.2, so 0.7 to 1.1 m over the cart's floor: the nearest hand came
    within 0.14 to 0.29 m of the chain. **The page's numbers work as drawn.**
  - **The catch** (`g103:catch`, the hand put on the chain when within 0.35 m): it held
    (0.1, 0.4, 1.0 s and 2 s later), the cart flew on into the fall. **Found:** the catch
    swings the climber west on the chain to x -237.8 at the far end, 0.2 m short of the
    fall's wind (x -238, 6 m/s2 down). A limb may brush it at the end of the first swing.
    Not tried: a catch by a player's own reach; climbing the chain and the three ring flings;
    the first beam's underside from the last ring.
  - First guesses: the speeds between the page's three (the 4.96 m/s2 drop curve and the
    straight fall-off on the rise), tilt 30, the chock's flight.
  - (`103_cart_room_before.jpg` / `103_cart_room_after.jpg`, `103_cart_in_the_dip_after.jpg`,
    `103_cart_at_the_chain_after_catch.jpg`, `103_on_the_chain_after.jpg`)
- **Note 103, Las Vigas (1.8).** Beams 2 to 4 are 0.3 m of wood over a 0.1 m slick (wet)
  underside, the whole length; the staging the same (0.2 plank, 0.1 wet). Flings 2 and 3
  start from the splintered west ends: (-222.8, 51.8) and (-227.3, 50.6). The posts on the
  beams are the dress's, at the back. Not watched.
- **a1_dress.py, FOR THE AREA FILE:** 1, the call (after the course; the 21 lantern
  lights from `LANTERN_LIGHTS`); 2, the LANTERNS loop places no lanterns; 3, the decos it
  lists out (the gallery's five posts, the camp's four things, the catwalk's six braces,
  the pulley, the two braces at the hoist, the warning sign, the stub's broken rail, the
  trestle, Las Vigas's four posts, the staging's brace, the ore crate, the stalactite at
  -224, two buntings, the upper gallery's frame, the pit's cart, the pickaxe, the arrow
  sign); 4, the three cards out; 5, the skins: every carved slab whose middle is in a
  `SKIN_REGIONS` polygon, the eight ribs, the eight stubs, the road; 6, the frog's cave
  (air, a grip floor at -27.5, a rock doorstep) and the chimney carved as air (a sliver
  point the chimney left in one slab is dropped); 7, as above.
  - **Not done yet:** 8, the holds' looks (La Cortina's staples): their wet holds show
    their wet by their own colour, and a skinned solid is not drawn, so a staple skin would
    hide the wet. That needs the wet look moved onto the skin first. 9, the water wheel and
    the pulley turning (they are decos). a0_dress item 9 (`mine_frame_broken` at the door)
    waits for the model: a missing model would draw a stand-in box across the doorway.
- **Checks:** lint; `--peak`; `--peakride`. Clean.

## The fix run of 11-14: a2's dress file wired in (the modelling run's a2_dress.py)

- 1, the call (at the end, after the course). 2, the works' lanterns are the dress's: one
  steady TEAL light per `LANTERN_LIGHTS` (23), no flicker (note 17), and the join's two
  (violet down the exit shaft, white at the bright crystal: their range and energy are my
  first guesses). 3, out: the aqueduct's twelve hanger chains (note 18), the cove's arch
  and its dark card, the three flume pillars, the Tuberia's pipe pieces, the wheel's frame,
  P1's bracket, the dam's stamp, the boiler, the bunting; a second valve wheel on the last
  cool joint. 4, out: the far wall, the tunnel's brick strips, the aqueduct's pier cards
  and arches, El Desague's card and window, the well's slot and dot, the pool hall's
  arches, the dam's flank. 5, skins: `build_rock` cuts the rock by `SKIN_REGIONS` in order
  (the regions cover all of it), every slab wearing its region's piece; the pier's peaked
  top, the four aqueduct crowns, the five brick slabs' bodies and the shaft's east wall
  wear theirs. **The seam with a1:** the strip under y 89.4 from x -252 to -223 is a1's
  roof alone now (a2's rock there is cut away). The two dress files' pieces still both
  draw over it.
- 6a, the copings: Q1 to Q5 and the slabs' tops are `stone`. 6d, the frog's room: cut as
  air (x -284 .. -281, a round vault to 120.0) with a stone sill floor at 117.4, Q6's
  coping running on. 6f, three drowned rungs under the ladder (y 109.5, 109.1, 108.7),
  held, wearing `rung_iron_rusted`. 6i, the cage wears `aguas_winch_cage`: the lift still
  winds to the crest (167.0 in 22 s) and sinks when let go (`25_winding_cage_model.jpg`).
- **Left out, for the Director:** 6b (the weir's coping at the waterfall's lip) and 6c (the
  pool's sill at the cascade's lip). Both would be a hold at the very edge of a fall,
  where a swimmer swept to the lip could catch it and the fall stops being one. Their
  decos are in the dress file and still draw. 6g (the gates as pistons, housings and
  rams): not done tonight. 7 and 8 (the holds' and movers' looks, the grey wheel and the
  gate leaves moving): not done.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the stations' roofs made real (note 77; pages 8.1, 8.3, 8.9, 8.11)

- **The low station (8.1):** a solid roof, tin on timber (`iron`: held and stood on), 0.3 m
  thick, x -251.0 .. -237.6, its top 692.8. Its peaked card is gone (the station model's own
  roof is the modelling run's). **Measured** (`g77`, over a lap): the cars come within 1.00 m
  of its east end, and that is their steps: the page's 1.0 m. From the gangway's rail post
  top to the roof's underside is 2.6 m.
- **The high station (8.11):** a solid roof, x -281.4 .. -268.0, its top 790.8, under the
  glacier's lip west of -271.5; a glaze of black ice on it from x -271.5 to -269.6 (0.15 m
  thick, not held), so the standing roof is its last 1.6 m. Its card and the icicle row are
  gone. **Measured:** the fourth car's roof comes within 2.15 m of the eave's corner
  (-268.0, 790.5) when it stops (the page: 0.7 across, 2.0 up); the deck is 4.5 m under the
  roof. Not tried: a climber reaching the eave from the car's roof; the drop from the roof
  onto the deck.
- **8.3's start mark** moves off the gone clamp plate to pylon 1's perch, its east end
  (-227.4, 702.0).
- **8.9:** the crossarm over the dead car is not solid now (the tower's), a card 2.5 m back.
- Nothing else in the pages' notes changes the course: the hangers stay solid; the rung an
  earlier design pass had under the perch was never in the course. The scenery moves (the
  houses back, the wheels, the pennants, the lanterns going cold) are the area's dress.
  8.9's check of the grate's headroom under the express car's step: not done.
- (`77_low_roof_car_passing_before.jpg` / `_after`, `77_high_roof_car_below_before.jpg` / `_after`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the frogs' hot spring, west of the peak (note 102; page 11.0)

- **The way there.** The dome block's west corner gets an eave of black ice, its lip at
  (-369.6, 983.0) (a convex piece of its own). Whatever slides down the summit's west face is
  thrown off it into a sink in the shoulder: a hole from x -372.9 to -368.4, then a shaft
  3 m wide down to a cave (x -379.6 .. -364.0, roof 974.9 to 974.0). The shoulder is carved
  into convex slabs round the cave, shaft and slide (a1's way). In the cave: a pool (x -377.0
  .. -368.2, surface 970.6, floor 969.8), a grip bank (to x -364.0, top 971) and a grip rim
  before the slide (top 970.9). A stand-in glow light. Two camera zones.
- **The way out, up:** an iron ring in the shaft's east wall at (-368.75, 977.4) with a rope
  4.5 m long and a toll handle; a grip doorstep at 978.3 (x -368.4 .. -366.5); the frost
  wall (x -366.5 .. -365.6, the tunnel's floor to its roof), rime that breaks 3 s after it is
  taken and is back 12 s later. Through it, today's slick tunnel.
- **The way out, down: the slide.** A 2.2 m slick pipe (st.py `FROG_SLIDE`) from the cave's
  west end, down through the shoulder's floor at 962, down the mountain's west side, east at
  887.4 m through the storm ridge's foot (a10 cuts its two masses there, y 886.2 .. 888.7),
  out onto the ridge's first ledge (a9's, top 886), where 10.1 starts. **I ended it at the
  gap at 886 m** (the Director's choice of two): the glacier's slide is the far side of the
  glacier from here.
- **The east horn's outer face** is 1.6 m further east (a box to x -318.6, its top 998.5);
  the west post's outer foot loses a 0.6 m corner (page 11.3).
- **The snow card on the shoulder** stood in front of the play space (z 2) and would have
  covered the whole cave: it is cut round the cave, sink and slide.
- **Reachable tonight without the open question** (whether the game goes on after the TOP
  DOG card): yes. Any slide off the summit's west flank goes into the sink, and so does a
  body flung over the bell. Neither passes the belt.
- **Measured** (`g102`):
  - drop: the climber, set down on the west flank by the apex (-361.9, 999.2), slid off the
    eave and down the sink. **Found:** on the way down a free hand took the stair's rope (a
    rope takes any free hand or foot within 0.17 m), and the climber hangs on it over the
    pool rather than landing in it. Harmless (let go and you are in the pool), but the
    page has the fall end in the water.
  - out: a hand on the frost wall from the doorstep: broken 3.6 s later. With the feet let
    go and a step east, the tunnel slid the climber out onto the alcove's slab
    (-347.4, 965.2).
  - slide: dropped into the cave's slide: out at (-305.6, 886.3) on 10.1's ledge, 13.5 m/s
    at the fastest, stopped by the ice lip at the ledge's east end.
  - Before: the same slide off the west flank went into the tunnel and out at the alcove.
  - Not tried: swimming the pool to the bank; climbing the rope to the doorstep; a throw
    over the bell; how the slide's fall reads.
- (`102_off_the_eave_before.jpg` / `_after`, `102_in_the_spring_after.jpg`,
  `102_on_the_frost_wall_after.jpg`, `102_out_by_the_tunnel_after.jpg`, `102_out_of_the_slide_after.jpg`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a3's dress file wired in (the modelling run's a3_dress.py)

- 1, the call (at the end). 2, lights: one steady white light (range 8) at each of the
  dress's 10 `BRIGHT_LIGHTS`; the old loop's eight white lights out, its violet and cyan ones
  kept; the soft green `GARDEN_LIGHT` through the far door. 3 and 4, out: the column, the
  eleven mirror facets, the six clusters, the five far chandeliers, the five stalactites, the
  three spires; all sixty cards (`root()` draws nothing now; the far card, the air card, the
  fourteen prisms, the ten dark shards). Kept: the statue's crystal shell.
- 5, skins: `A.cave` takes a skin per edge now (peaklib: `skins={edge: model}`, each edge's
  slab and the corner filler at its start); the shell wears `SHELL_SKINS`, and every named
  crystal its piece, by the list (shafts, the snapped sixth, the mirror, nubs, R2 to R9, the
  sockets, the spar, the needles, the leaves, the plate, the pivot, the fin, the ceiling,
  its tooth and crusts, the landing, the west horn, the sill, the horn, the six roof prisms
  a b c d e d). The kerb wears `aguas_shaft_rim`. **None of the cave's own models has landed
  yet**, so nothing looks different until they do.
- **New in the game: a held solid wears its skin.** A solid with a behaviour (a breaking
  leaf, a wet hold, a tag) drew its own piece and ignored its skin, so a leaf's skin deco
  would have stayed when the leaf broke. Now, once the skin's model has landed, the nearest
  deco of that model (within 3 m) is moved into the hold's piece (`_wear_skins`,
  peak.gd), so it shakes, breaks and comes back with it. Not tried: no held skin has landed
  anywhere yet. (A wet hold that wears a skin shows no wet tint on it.)
- 6a, the frog's room: cut into the west wall's glass (the page's hollow, open at the face
  176 .. 178.2), a frosted floor at 176.0. 6b, the three chains are grown threads (a new rope
  kind, `thread`: a chain's weight, lilac) on worn sockets; the chandeliers wear
  `gruta_chandelier` at 1.0. 6c, the geode turns at 3 rpm (note 29; a first guess). 6d, the
  stump is the bonsai's outline. 6e, 3.9's camera sees 1.5 m further west. 6f, the hall's
  east wall from the landing to the door (edge 6) is the shared well's alone, and the roof
  slab carried on over the door is gone.
- 7: the geode, the raft and the pendulum wear `gruta_geode`, `gruta_raft`,
  `gruta_quartz_pendulum`; the 24 spikes `gruta_collar_spike`. The threads' knuckle model is
  not used (the rope code takes no segment model). 8, the effects: not done.
- Also: a2.json regenerated for the modelling run's own change to a2_dress (the weir's
  coping and the pool's sill out).
- **Checks:** lint; `--peak`. Clean. Frames of the stand-ins are the modelling run's.

## The fix run of 11-14: the gates as pistons (a2_dress 6g) and the decos that move (a1 item 9, a2 item 8)

- **The gates (2.5, note 19):** each mover wears `aguas_ram_head` (the head and its ram); a
  fixed housing, 1 m tall, slick (`grease`), stands on each step where the block rested,
  wearing `aguas_ram_housing` (its skin deco placed in a2.py). The ram rises out of it and
  slams back as before. **Found:** the ram model is 3.4 m (head and ram), the travel 3.2, so
  raised it leaves 2.2 m of air over the housing: the page's "a ram that fills the space
  between the housing and the head as it rises" would need a longer ram or a shorter travel.
  Left as it is. (`19_gate_pistons.jpg`)
- **Decos that move with a mover** (new: `A.follow(model, near, mover, how)` in peaklib; the
  game's `followers`, moved each frame): "spin" turns a deco with its mover's angle, "ride"
  carries it by the mover's offset, "roll" turns it as a wheel rolling along the mover's
  travel. a1: the water wheel turns with La Polea Grande; the hoistway's pulley rolls with
  the counterweight (r 0.4). a2: the grey mill wheel turns with La Rueda; each gate's leaf
  rides with its ram. **Watched** (`gfollow`): every one matches its mover (the leaves 3.2 m
  up with a ram at the top of its stroke).
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the holds' looks (a1_dress item 8, a2_dress item 7)

- **La Cortina's 28 holds** wear their staples: `iron_staple` (18), `iron_staple_bent` (5:
  rows 2, 5, 8, 11 and 12, alternate sides, my pick) and `mine_staple_bound` (the five dry
  rests), each placed at its hold with its feet on the throat's back wall (z -1.6). The wet
  holds wear theirs as their own piece (peak.gd `_wear_skins`), and **the wet look now
  reaches a worn skin's meshes** (peak_things.gd), so a staple goes dark and shiny when the
  drip reaches it. Watched (`cortina`): the drips and the wet timings are as before (each
  hold wet 5.0 to 6.3 s in 15; never both of a row). (`13_cortina_staples.jpg`)
- **a2:** the six aqueduct rings wear `aguas_ring_eyebolt` (placed at the bolt's root, z
  -1.25); the eight barrels `aguas_barrel`; 2.10's seven wet holds name `aguas_tread_end`
  (not landed yet: placed, drawn when it lands); each of the five chains has an
  `aguas_chain_shackle` at its top.
- **Not done:** El Cubo's rungs as `rung_iron` (that model is a rung seen front-on, these stick
  out of the face side-on) and the lift's weight as `lift_counterweight` (1.0 x 1.6 m against
  the weight's 1.6 x 1.2 collision): both were "could", and neither would match what is touched.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the spring's rope out of the drop's line; the window behind 0.3c's gap

- **The spring's rope (note 102, the Director's word: the drop ends in the warm water).** The
  ring and rope are out of the shaft: a recess is cut in the shaft's east wall under the
  doorstep (x -368.5 .. -366.8, from the cave's roof 973.8 to the doorstep's underside 977.9).
  The ring is at (-367.6, 977.5) and the rope, 4.6 m, hangs 0.8 m east of the shaft's line,
  its toll handle over the bank (about 1.7 m over it, 0.6 m in from its edge).
  - Measured (`g102:drop:0..2`, three drops, the last two arriving faster): none took the
    rope. Two ended in the pool; the fastest ended on the bank's lip at the pool's east
    edge (-368.06, 971.54): the shaft comes down at the pool's east end.
  - The climb back: from the rope's top to the doorstep's lip (-368.4, 978.3) is 0.8 m west
    and 0.8 up, 1.1 m (the course's reach is 1.9). **Not climbed by a player:** the probe
    cannot climb a rope.
  - **Found:** the drop into the spring counts as a fall on the HUD ("FELL 36 m, NOTED."), a
    reward that is scored as a loss. Not changed.
  - (`102_rope_in_its_recess.jpg`)
- **The far cavern behind 0.3c's gap** (a0; the Director: `dsc_cavern_far` did not show). What
  hid it was the course's own mountain card: st.py's body card at z -9, one flat grey-brown
  polygon behind the whole mountain, in front of the cavern at -16. It is cut away behind the
  gap (x -134 .. -122.5, y -13 .. -4); a card has no holes, so the body is two cards split at x
  -128, flush. (`gap_03c_before.jpg` / `gap_03c_after.jpg`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a4's dress file wired in (the modelling run's a4_dress.py)

- 1, the call. 2, lights: the glow stays; the two orange lights that lit the gone orange
  mushroom and the giant are green; steady lights for the lantern pods, the hut's lantern
  (the one warm light), the snail eggs and the web's three knots. 3 and 4: the props loop
  and every card out (the stalk and tree helpers with them); the great cap's skin stays.
- 5, skins (none of the garden's models has landed yet): the shell by edge
  (`SHELL_SKINS`); the knee and stump, the mound, L1 to L3, the island and terrace, the
  vine's knot, the wall cap's elbow, the root arm, the giant's cap (cap, brim, gills, strand,
  knob), its crown, the two shoulder mushrooms, both 4.7 masses (L7 with the west), the
  diving board, sill and post, the hut's roof.
- 6, the course: **a, the hut's roof is a solid** (moss, kind "rock": it grips, it does not
  throw; the page's dome, hollow under, eaves at 320.1). **b**, the mound under the frozen
  climber is moss (kind "rock", no longer orange), with the moss blanket placed by his
  legs. **c**, two shoulder mushrooms, not five (WARTS 1 and 3 stay); 4.6's moves run brim,
  WARTS 1, WARTS 3, crown (gaps 2.8, 3.0, 2.8); the crown is dry cream (kind "gill"). **d**,
  the bridge's planks can wear a model (new in the game: a rope's `plank_model`); it names
  `jardin_bridge_tread` (boards until it lands). **e, a5:** the temple's beam is 2.6 m
  longer (to x -300.9: both chains now hang from it; the 4.10 throw passes 1.8 m under its
  end), and its two banners are just behind the play space (z -1.3, -1.5).
- 7, found by the designer: **a**, the garden's west wall (edge 17) is the shared well's alone
  now; st.py's east wall stops at x -291 beside the garden (it stood 1 m into the hall); the
  open notch over the exit door (x -294 .. -291, y 378 .. 380) is filled. The exit's sill
  still runs 0.8 m into the top of the well's wall (one solid inside another; left). **c**, 4.7's
  wall caps poking 0.19 m into the west mass: not changed, not watched.
- Not done: 8 (the caps squashing, the vine leaves and knots, the cords) and 9 (the effects).
- (`4_1_mound_before.jpg` / `_after`, `41_hut_and_giant_before.jpg` / `_after`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the spring is a ride; every drop ends in the water (note 102)

- **A ride, not a fall** (the Director; Parker: "the little cozy reward for climbing the
  summit"). New: `A.ride(rect)` (a zone): a drop that passes through one is not a fall when it
  ends: no card, no fall counted, no cry, no landing sting (peak.gd `_tick_fall`, `_riding`
  until the climber next holds on). Rides: a11, from the bell frame's west end down the west
  face, the eave and the sink (x -381 .. -361, y 962 .. 1008); st.py, the whole slide (down the
  west side, and east through the storm ridge's foot). Measured: nine drops into the spring
  and the slide to 886 m: 0 falls counted, 0 cards.
- **Every drop ends in the water.** Tried first: the pool 0.8 m further east, under the
  stair's recess: a falling climber then passed close enough to the rope's foot to take it
  (a free hand takes a rope within 0.17 m), and one ended on the bank. Then: the bank's lip a
  slick slope, the rope still in the recess: one drop took the rope near its top from inside
  the sink, one lay on the lip with its feet on the grip. **Now:** the stair has its own
  chimney (x -367.7 .. -366.8, from the cave's roof up through the doorstep), walled off from
  the sink by 0.7 m of rock; the ring 1 m down it at (-367.25, 977.3), the rope 4.4 m, its
  handle over the bank's lip; the lip a slick slope 1.4 m wide from under the surface up to
  the bank (grip from x -366.8). The doorstep is the 0.7 m west of the chimney and 0.3 m east
  of it, against the frost wall.
  - Measured: six drops (three starts, twice): **all six in the water, none on the rope**, 0
    falls counted. The way out: the frost wall broken from the doorstep's west piece, out
    through the tunnel onto the alcove's slab.
  - The climb back: from the ring up the chimney to the doorstep is 1.0 m; from the bank's grip
    to the handle 0.45 m across and about 1.65 up. **Not climbed by a player.**
  - (`102_stair_chimney_and_lip.jpg`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a4's looks and effects (a4_dress items 8, 9); a3's effects

- **The caps squash** (note 36): each of a4's ten throwing caps is its own drawn piece now (a
  tag), and its bounce names it (`squash`, new in peaklib; the game's `_bounce_squash`): when
  it throws, the cap flattens and springs about its face, as Del Mar's floats do. Every cap
  that throws puffs spores from under its rim. Watched (`g4fx`): 10 of 10 ready; squashed in
  the frame (`36_caps_squashed_after.jpg`). The great cap does not squash (it is re-made).
- **The vines** hang leaves (the kit's `vine_leaf`, every other piece, turned by turns); the
  lift's three are furred gold on their last metre (`gold_end`). Their knots (`jardin_vine_knot`)
  are not placed: the model has not landed and its stand-in would be a box on the rock.
  (`4_3_lift_vines_after.jpg`)
- **The bridge** has two white mycelium cords along its treads (a rope's `cords`; the cord
  model is not used: drawn bars). (`4_8_bridge_after.jpg`)
- **Effects can name a colour and a speed** now (`tone`, `speed`: the game ignored both; a3's
  white dust and a4's faster spores were written with them and now get them). a4: the lift's
  column pale gold, dense and fast below 285, thin and slow above; a thin thread of smoke from
  the hut's chimney; spores drifting out of the west door; a few spores close to the camera.
  a3: the mist at the well violet on the cave's side and green on the garden's, the garden's
  spores across the well, glitter in the frog's room, the drip off the nest's lip.
- **Found, 4.6:** with two shoulder mushrooms the climb to the crown is three lunges of 2.6,
  3.0 and 3.0 m: past the course's 1.9 m reach. As flings they need 3.5 to 3.8 m/s (F2). The
  moves say so now; 4.6 is harder than the page meant.
- **Not done** (they need new effects or decide play): a4, the pod bed's pods swelling in turn,
  the gusts' bursts and the curtain bellying, the treads lifting, leaves falling, the slime's
  sheen, the web's knots pulsing, the puffballs' pores turning, a croak; a3, the cave's breath
  (a gust that would push climbers, the pendulum and the raft: a change of play), the rainbow
  fan, the water down the nest, drops down the chandeliers' threads, the crack's drip (its place
  is not in the list).
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a5's dress file wired in (the temple)

- 1, the call (before the phase loop). 2, lights: every torch light stays where it is; the
  altar's fire moves into the altar's bowl and the sacrifice stone's bowl burns too; the
  censers' coals of the gone censers out; the frog's two lamps. 3 and 4: torch()'s deco, the
  seven pug masks, the great mask, the serpent's head, both altars, the eleven banners, both
  strings, the two counterweight chains, the drum and every card but the pistons' sockets out
  (the dress places what the pages keep). Kept: the two banners on the chains.
- 5, skins: the shell (with the frog's room: `SHELL_ROOM`, `SHELL_SKINS_ROOM`) and about forty
  solids by the list. Only one temple model has landed so far.
- 6: **a, one censer** (note 50): censers 1 and 3 and their coals are gone; 5.6's moves are F3's
  fist to censer 2 (a 7.3 m fling to a moving chain) and censer 2 to the balcony (both to be
  tried). **b, the champions** (note 75): the ghost forearms are gone from all three; the second's
  west arm is a 1.2 m stump to (-348.95, 437.63), its stone hand where it was; 5.5's moves run
  F1's fist to that hand, the hand to the stump's end (1.83 m) and onto the shoulders (to be
  tried). The champions name their new skins (broken, handless). **c, the frog's room** (note
  60): cut into the west wall at the exit ledge, its floor level with it (stone; only the
  floor holds).
- 7a: the well's west wall beside the temple (st, x -310 .. -306, y 382 .. 474) is gone from
  st.py: it reached 1 m into the temple's air and lay on the temple's own east slab, which is
  that wall now.
- 8: the moving stone names the jade re-makes (`temple_step_jade`, `mask_jaw_jade`,
  `temple_plunger_jade`, `temple_piston_jade`, `temple_gear_jade`, `temple_slab_jade`,
  `serpent_segment_jade`, `temple_block_jade`, `altar_cross_jade`, `censer_l78_jade`,
  `censer_jade`). **New in the game:** a `_jade` model not landed yet falls back to its stem
  without `_jade` (peak.gd `kit`), so the originals show till then. The bridge's six pieces wear
  `templo_bridge_slab` and the five cracked pegs `templo_peg_cracked` (placed here at their
  centres; they break with their pieces). The two pan hangers ride their pans (`follow`).
  **Also new:** a held solid whose skin has landed but has no deco of it near draws its own
  shape (it would have been invisible).
- Checked (the designer's question): only the two altars are named `altar` anywhere on the
  mountain, so Pay Your Respects counts nothing else.
- Not done: 9, the effects; the beam, the gullet's counterweight and the drum's mallet still.
- (`75_champions_before.jpg` / `_after`, `60_temple_frog_room_before.jpg` / `_after`)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the temple's moving decos and effects; 4.6 ruled; the effects still to build

- **4.6, ruled by the Director:** two shoulder mushrooms; the three lunges are meant. They need
  3.5, 3.8 and 3.8 m/s, inside F2 (4.8): no hold had to move.
- **New follow kinds** (peak_things.gd `_frame_followers`; peaklib `follow(..., **params)`):
  "tip" (a balance beam over two linked pans: `rise`, `span`), "hang" (a chain from a fixed top
  that stretches as its weight drops: `len`), "ride" with a `scale` (-1: the other way),
  "mallet" (lifts before each count of a bar and strikes on it, hardest on the first: `period`,
  `count`, `lift`). Fixed on the way: a follower's rest turn was taken before its deco's own
  `rot` was set (a deco with a rot lost it).
- **a5:** the scale's beam tips with the pans (watched: 26.8 degrees east up at rest, level as
  they pass, 26.8 west up with slab A down); the gullet's counterweight goes down 4.5 m as the
  jaw comes up and its chain stretches (watched: 381.9 with the jaw up, chain 3.05 long); the
  drum's mallet rests at 12.5 degrees and lifts before each count (watched to 30 degrees on the
  first count, 24 on others).
- **a5's effects that the kinds can show:** spores drifting in at the door, a drip from the
  upper teeth into the gullet, grit down the piston throat, grease off the lowest wheel, a
  drip off each fang.
- **Checks:** lint; `--peak`. Clean.

### The effects not yet built (for a later pass)

- **a0** (a0_dress item 8): cold light and mist at the gap, drips past the wet wall, water
  over the door's sill.
- **a3** (item 8): the cave's breath (a gust that pushes climbers, the pendulum and the raft:
  a change of play); the rainbow fan on the wall behind the leaves; the water down the nest's
  west side; a drop down each chandelier's thread; a drip from the crack (3.1).
- **a4** (item 9): a spore puff under every cap (done for all caps; the great cap's biggest is
  not distinct); the pod bed's five pods swelling in turn; the bridge's gusts as bursts from
  the pod nest, a puff before each, the curtain bellying, the treads lifting; leaves falling
  from the creeper, slime drips between the vines; drips off each snail's foot; the giant's wet
  sheen; the web's knots pulsing; each puffball's pore turning to face you, its burst of spores,
  spores lit passing a puffball; the frog's croak; drips down the well lit at each door.
- **a5** (item 9): a false tier shaking and dropping dust before it goes; a puff on the dish
  when anything lands from the drain; the jade eyes dimming and brightening; dust from the
  jaw's slots before it starts; a grind and puff at a socket before its piston goes back; dust
  from a track's stop; clanks and sparks at the gears' meshes, dust onto the bronze jaws; bars
  of torchlight through the gallery's slots; grit from the second champion's shoulders; a
  scrape and hiss down the ramp; the censer's smoke trail and embers at its swing's ends; the
  beam's groan and axle dust, light up through the slots, the first pan shaking; the frog's
  croak; a grind from the serpent's bed, dust from a slot as a ram tops out; dust off the drum
  skin, a puff from each block's socket; grit off each crumbling slab, a rush of air as a
  cross arm passes; both great censers' smoke trails, embers drifting east, torch gold and red
  on the sills.

## The fix run of 11-14: a6's dress file wired in (the chimney and forge)

- 1, the call. 2, lights: the loop and the grates' lanterns stay; its (-246.0, 481.5) became a
  furnace mouth; added the hut's lamp and hearth, the three furnace mouths (red from below) and
  the steady daylight column into the shaft. 3: lines 301-318 out (mask, grates, standpipe,
  great bellows 0.25 m in front of the climb, anvils, pan chains, the hood's ribs 6.25 m too
  high, tongs, bunting, both torches); the statues stay. 4: the far walls, furnace face, slag
  glow and drip, hammer guides, light shaft, soot and floor lip out; the burnt strip and the
  sky slit stay; the dark at -6 and the sky at -5 stop round the door, so **the Peak's real far
  layers show through it** (`6_9_door_before.jpg` / `_after`).
- 5, skins: the shell (`SHELL_SKINS`) and the named solids; every ring wears
  `iron_ring_pin_long` (rooted 1.58 m back, the ring 0.22 under its root) but the shaft's two
  wall rings, which wear `forja_ring_side_pin`; the rungs `forja_staple_long` (and the snapped
  rung's stubs, which stay); the cool bosses, the flint knobs and the chockstone theirs (placed
  here); the dynamite stick wears `forja_dynamite_stick` when it lands (the stand-in until then).
- 6: **a, the bucket** under the sitting climber: a new iron solid, held and stood on
  (`59_bucket_after.jpg`). **b, the chockstone** is a cracked block of chalk: its look, worn as its
  own piece, breaks with it (its 1.2 s and 8 s unchanged; the split it comes back from is the
  dress's). **d, the crunch checks:** hammer 3 rises to 0.98 m under the hood, but a climber set
  on its greased, peaked top (standing, and laid on it) slid off onto L6 before it rose: no
  crunch, no knock-out. The rafts stop 0.3 m from the crusts: only a hand or foot fits there,
  and the crunch rule looks at the head, chest and pelvis only. Not watched. **e:**
  `forja_drive_rod` is in peak.gd's STRETCH, and a STRETCH model is no longer rescaled by its
  drawn size (its width was being multiplied by its length's ratio). A follower now keeps its
  deco's own length too (the gullet's chain).
- 7: **a**, the well's east wall above the forge's door (st, y 488 .. 498) is gone and the cap over
  the well room stops at x -291: both lay in the forge's air. **c**, a7's card behind the flue starts
  at 590, over the crack's roof (it covered the top of the flue and its sky).
- Not done: 7h (the stepping bellows' base staying still while its pleats stretch: an engine
  change); the moving wheels, rods, flap and chain stub; item 9's effects (listed in the
  effects list above, a6 to add: the breathing mouths, the hearth's smoke, the frog's sparks
  and croak, the nostril wisps, the slag's drops 3 m back, the bellows' jet, the slag rope, the
  hammers' sparks, the shaft's steam and soot, white dust at the opening, the chockstone's grit).
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: 8.9's grate checked (page 8.9)

- The page: "a climber standing on the grate has 2 cm of headroom under the express car's step
  when it stops ... if a standing head can be caught, the grate goes down 0.2 m." Measured
  (`g89`, a climber set standing on the grate as line 1's car came back to its stop): the head
  settled at 748.18 before the car came and went no lower under the stop; its top clears the
  step's underside (748.35) by about 2 cm. No crunch, no knock-out: **not caught, so the grate
  stays where it is.** (A first reading took the climber's settling after being set down, 0.12
  m, for the step pressing it; measured against the settled height it is nothing.)
  (`8_9_grate_under_the_step.jpg`)

## The fix run of 11-14: a7's dress file wired in (the wind cliffs)

- 1, the call. 2, lights: the tea cave's lantern and brazier (the only warm light on the cliffs)
  and the station's gold on the house's west wall. 3: the seven streamer poles (one stood on
  nothing), the two nests (one hung inside the alcove's roof), the tree's crown and lines 399-408
  (the fence frame, scaffold, pylon head, station house, pennants, arrow, lantern, piles) out;
  the lip's shrub stays. 4: all seven cards and the clouds effect out. **st.py's ten clouds over
  the cliffs (y 560 .. 695) are gone too** ("no cloud of our own"); the others along the mountain stay.
- 5, skins: El Balcon; the tower's pieces by their bottoms (`cut()` takes a skin now); the face
  by edge (`wall()` takes `skins` now, as `cave()`); the tree, fin, deck stubs, cornice, nose,
  gully, counter-slope, R6's roof, needle tops, horn, snag, brace lengths, chalk plug.
- 6: **a, the tea cave** (note 68): cut out of every solid it crosses (the gully's mass, the
  face's slab, R6's block, the mountain behind), 2.4 m tall, a 2.2 m doorway from the upper
  pocket, a grip floor level with the pocket's. Watched: pushed west from the pocket, the climber
  walks in (it first stopped on a 3 mm sliver of the pocket's back wall the cut had left;
  the cut now runs 0.14 m into the pocket's air) (`68_tea_cave_after.jpg`). **b, the bridge
  halves** (note 66): a rope can be taken across a width (`wide`, new); each half is 0.3 m wide
  to a hand. Watched: a hand 0.25 m off the half's line takes it (`66_bridge_halves_after.jpg`).
  **c, the burros**: their solid 1.8 m long to match the kit's model, the extra 0.5 m on the
  west, the way they face (`model_flip`). **d**: the wheel keeps model_scale 1.52 until the
  7.6 m wheel lands (the kit's is still 5 m). **e**: the sitting climber is left out, as the list asks.
- 7c: a6's dark back card stops at the face's line (x -230): past it, it stood in front of the
  shoulder seen from El Balcon.
- 8: the knobs wear `forja_flint_knob`, the pegs the kit's `iron_peg`, the scar's stubs
  `riscos_tree_stub`, the two breaking branches and the brace's rotten length theirs (worn as
  their pieces: they break with them); the drum turns with the wheel (`follow`).
- **Not done:** the bridge halves' look (`riscos_bridge_half`: a rope takes no segment model) and
  the board model (`riscos_bridge_board` hangs by one end; the bob is a level board: they do
  not match); the haul cable running, the sign swinging, the flags and socks; item 9's effects
  (for the effects list: dust out of the door, tufts leaning in the gust, a vulture's shadow and
  a feather, a branch's creak and dust, the frayed ends swaying, chalk dust and a leaf in the
  crosswind, the pile shaking before each wave, the pot's steam and the brazier's smoke, a
  burro's ear and stamp and its kick's puff, feathers and chalk dust).
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: 7.4's bridge halves look like halves of a bridge (the Director's rulings)

- A hanging rope can be drawn as a ladder (`ladder` on a rope, new): two side ropes 0.3 m apart
  as the camera sees them and a plain honey board across every piece but the missing ones. Each
  half has three boards gone (`66_bridge_halves_ladder.jpg`); `riscos_bridge_half` replaces it when
  it lands, if a rope ever takes a segment model.
- Each half's bob names `riscos_bridge_board` (to be re-made as a level board, its origin its top
  face's middle, as the bob); the plain board shows until it lands.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: a8's dress file wired in (the cableway)

- 1, the call (after the cameras). 2, lights: the five lit lanterns and their lights out; the
  frog's lantern in (the one warm light for 100 m); the fang's last sun stays. 3: the four wheels,
  two signs, two crests, toolbox, oil can, ticket booth and seven pennant lines out; the frozen
  glove stays (its made size now). 4: every tower card and every wire out (`tower()` and `wire()`
  draw nothing now: the dress's lattice bays and cables 2 m back); the cloud floor out (and
  **st.py's six clouds in this sky**: none from 560 to 785 now); the gold dust and snow stay.
- 5, skins: the gangway and its post, both roofs (the high one's glaze too), the perch, pylon 2's
  legs, landing and head, the tarred roof, El Colmillo (its foot ledge and rib), the thirteen
  chalk holds, the anchor plate and post, the maintenance deck, pylon 3's head and post, the
  grate, the face by edge, the plug behind the high deck.
- 6: **a**, the fang's east side takes its designed outline (leaning, notched 0.9 m at 705.6 ..
  707.3). **b**, the zip trolley's body is not solid; only its bar and stem (watched: the ride
  ends at (-193.0, 722.9), let go onto the deck). **c**, the high deck's three dry patches are all
  plank. **d**, the express cars name `tele_gondola_express` (the old car shows till it lands:
  `KIT_FALLBACK`), the line 1 and 2 cars `gondola`; `drawn=` stays till both land. **e**, the sitting
  climber left out. **f** (the weights' 10 s against the express cars' 10.25 s) and **g** (the
  grate: done, not caught) noted.
- 8: the bull wheels, guide wheels, saddles, the winding drum, the frosted wheel, the top wheel, the
  three wind engines and the shaft pulley roll or spin with their movers (`follow`).
- Not done: item 9's effects (to the effects list: gold dust between the towers, a car's long
  shadow, and the rest of the page's list); the belts, the chair line's guide wheels, the frozen
  engine, the pennants and socks moving. Pylon 3 behind 8.3's fling (7j) is for the frames to judge.
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the mountain's body card out of the crystal cave

- st.py's body card (z -9, flat grey-tan behind the whole mountain) stood in front of the cave's
  own far wall (a3_dress's `gruta_far_wall`, z -10.25) and showed through the gaps behind the
  giants, behind La Columna and at 3.10's west edge (the Director). It is cut away over the far
  wall's span (x -466 .. -300, y 168 .. 284), as it was behind 0.3c's gap: the body is now three
  cards, split through each window so none has a hole. (`a3_gruta_3_9_before.jpg` / `_after`:
  the grey-tan strips either side of the column are the cave's violet now; `a3_gruta_3_1_after.jpg`.)
- **Checks:** lint; `--peak`. Clean.

## The fix run of 11-14: the weights' time; re-makes under new stems

- **8.8 (a8_dress 6f, the Director's ruling):** the counterweights take 10.25 s a round, the
  express cars' run, so the two read as one machine: 7 m at 1.697 m/s (4.125 s) and 1 s at
  each end (they were 1.75 m/s, 10 s). All four keep their places in the round, so the two
  tops still stand level twice a round. **A first guess for Parker.**
- **Re-makes under new stems** (the modelling run lands them beside the originals): a6's
  stepping bellows, slag rafts and drop hammers name `bellows_forja`, `slag_raft_forja`,
  `drop_hammer_forja`, the anvils' skins `anvil_great_forja` (a6.json regenerated for the
  dress's own anvil switch too); a7's bull wheel names `bull_wheel_76`, the 7.6 m wheel, with no
  scale now. `KIT_FALLBACK` (peak.gd) shows each original until its re-make is there.
- **Checks:** lint; `--peak`. Clean.

## To do: every note of 12 to 57 not done yet

Kept here so nothing is lost (Parker 11-13). The page has the same list.

**In hand:** nothing. Notes 20, 21, 22, 28, 43 and 35 are done (each has its entry above).

**Parked until Parker says** (his design job comes first). Since then the night's run (11-13/14)
built most of them from the redone pages; what each now is:

- 12: the chimney in the cave-in's roof: carved (a1's dress wiring).
- 18: the aqueduct's twelve hanger chains out (a2's dress wiring); the rings wear eye bolts.
- 19: the gates as pistons (a2's dress wiring); the ram model wants lengthening (the Director).
- 25: done (the dam's one winch lift, group 3).
- 26, 30, 33: the crystal cave's skins named (a3's dress wiring); its models not landed yet.
- 29: the geode at 3 rpm (a3's dress wiring).
- 32: the bonsai's outline (a3's dress wiring); its model not landed yet.
- 34: done (La Columna's spikes, group 3).
- 36: the caps squash and spring (a4's looks).
- 37: the scenery mushrooms out of the play space (a4's dress); the spotted caps are a re-make.
- 38: the spore column pale gold, dense below and thin above (a4's effects).
- 41: the hut's solid moss roof (a4's dress wiring); the hut and frog are the dress's.
- 42, 46: the giant and the great cap: re-makes (the modelling run's).
- 44: done: two shoulder mushrooms; the three lunges F2, 3.5 to 3.8 m/s (ruled by the Director).
- 49: done earlier (the gears at 5 rpm, a crunch knocks out).
- 50: done: one censer (a5's dress wiring).
- 54: done: the achievements list, "Pay Your Respects" first.
- 57: the great bellows and the three small ones breathing: not done (an engine change: a
  bellows' base kept still while its pleats stretch).
- The model requests still to be written into `MODEL_REQUESTS.md`: 19, 26/30/33, 32,
  37, 41, 42, 46, and the four cracked pieces of group E.
