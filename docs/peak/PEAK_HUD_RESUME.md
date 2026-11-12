# RESUME: the Peak's HUD (the Second Director)

State on 2026-11-12, for whoever picks this up (me after a break, or another session).

- **Done and committed on `luchador-ui`:** `ui3d/peak_hud.gd` (PeakHud, the whole
  PARTS.md interface), `tests/peak_hud_probe.tscn` (33 checks; `-- --shots=DIR` writes
  19 frames), `docs/peak/PEAK_HUD.md` (the interface, the pieces, the dry lines, the
  critic's round), frames in `docs/peak/preview/hud/` (JPEGs at two thirds size).
- **Checked:** lint clean; the probe passes; a fresh critic scored round 1 at 6/10 and
  its list was worked through (PEAK_HUD.md, the last section). Not re-scored after.
- **Not seen in the real mode.** Every frame is over the plaza through the probe. Once
  Top Dog's game code calls PeakHud on the mountain, look at: the altimeter against the
  cave walls' colours, the area card over the follow camera's framing, the receipt
  during a real fall (it prints 0.35 s after `fell()`), the summit card over the bell.
- **Waiting on the kit:** `peak_altimeter` and `peak_summit_card` (the UI creator, Top
  Dog Kit). Neither had landed when this was written. PeakHud does NOT take them yet:
  it was written against stand-ins. When they land, read their object names and sizes
  in the kit's PARTS.md, then swap them in inside `_build_altimeter()` (the drums are
  dressed by `_dress_drum`; the marker is `_marker`, moved along `TRAIL`) and
  `_build_summit_card()` (three `_row` plates, the stamp, the prompt).
- **Open calls I made without Parker (he was asleep):** the receipt idea itself; a stub
  with no joke under 30 m; the serial number; the lines' wording; BEST on the summit
  card is the best TIME, on the pause slate the best HEIGHT; the HUD plays no sound.
- **Rules that bit:** one Godot at a time (gate every run: wait until no Godot process
  is up); a Godot import in this worktree rewrites `palette/house_atlas.png.import`
  (restore it, never commit it); never push.
