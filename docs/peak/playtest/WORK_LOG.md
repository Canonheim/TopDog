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
