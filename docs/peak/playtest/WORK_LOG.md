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
