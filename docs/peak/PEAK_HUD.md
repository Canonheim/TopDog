# The Peak's HUD: what it is, how to call it, where it stands

The Second Director's file for the solo mode's screens (`PARTS.md`, "The Second
Director"). Code: `ui3d/peak_hud.gd` (`class_name PeakHud`). Probe:
`tests/peak_hud_probe.tscn`. Branch: `luchador-ui`.

## The interface

```gdscript
static func make(lucha: LuchaUI) -> PeakHud                  # hung on the camera, in the UI_ROOT group
func set_altitude(metres: float, best: float) -> void         # every frame
func show_area(name: String, number: int) -> void             # 0 = the trailhead, 11 = the summit
func milestone(metres: int) -> void                           # every new best 100 m
func fell(metres: float) -> void                              # ignored under 15 m
func summit(time_s: float, falls: int, best_s: float) -> void # best_s <= 0: the first ascent
func set_paused(on: bool, time_s: float, falls: int, best_m: float) -> void   # safe every frame
```

Extras the game may use, none needed:

- `signal summit_closed`: the press that ends the summit card. `close_summit()` closes
  it from code. `summit_up` is true while it is on screen.
- `visible = false` hides the whole HUD (leaving the mode); `queue_free()` removes it.
- `PeakHud.clock(seconds, tenths := true)`: the clock string the plates use.
- The HUD plays no sounds: the chime, the yell, the trumpet and the donkey are the
  game's (`PEAK_DESIGN.md` §8).

## What is on screen

| Piece | Where | What |
|---|---|---|
| Altimeter | bottom left | Four rolling drums, whole metres above the trailhead (a minus lamp below it: the Sump reads −28). Beside them a cardboard cut-out of the Peak with your mask climbing its trail. The trail's dots are gold up to your best height, where a red pennant stands |
| Area card | top centre | The area's name on the red title card, with a chip under it ("AREA 3 OF 11", "THE TRAILHEAD", "THE SUMMIT"). Slams in, holds 3 s, flies out |
| Milestone | by the pennant | A gold seal ("NEW BEST 400 m"), a puff of paper, the pennant hops |
| The fall | out of the altimeter | The altimeter shudders, three stars circle your mask, and the drum box prints a small receipt in steps like a till roll: FELL, the metres, a dotted rule, one dry line. After 4.6 s the receipt tears off and falls out of the frame. A fall longer than any before it this session (60 m and up) is rubber-stamped LONGEST YET |
| Pause | right | A slate: TIME, FALLS, BEST |
| Summit | centre | The poster: TOP DOG, THE PEAK OF DEGAYO, plates for TIME, FALLS (with a dry note) and BEST (FIRST ASCENT the first time; a NEW BEST! stamp when you beat it), three waves of the house confetti, then PRESS ANY BUTTON |

**The fall's dry lines** (they rotate inside each band, so none repeats back to back;
`{b}` burros stacked at 1.5 m, `{l}` luchadors at 1.8 m):

| Fall | Lines |
|---|---|
| 15 to 40 m | NOTED. / A SMALL ONE. / THE MOUNTAIN SAW THAT. / {l} LUCHADORS TALL. / IT HAPPENS. |
| 40 to 120 m | THAT ONE COUNTED. / THE SCENIC ROUTE. / {b} BURROS, STACKED. / YOU KNOW THIS PART. / A FAIR DISTANCE. |
| 120 to 350 m | THE RIVER SAYS HELLO. / THE VIEW WAS NICE, THOUGH. / {b} BURROS. WE COUNTED. / THE MOUNTAIN KEEPS THE CHANGE. / WELL. THERE IT GOES. |
| 350 to 800 m | THE DONKEY HEARD. / TAKE A MOMENT. / {l} LUCHADORS, END TO END. / WE'LL SAY NO MORE. / A LOT OF MOUNTAIN, THAT. |
| 800 m and up | ALL OF IT, THEN. / THE BELL WILL WAIT. / THE WHOLE TOWN FELT THAT. / FROM THE TOP, AS THEY SAY. |

The voice is the mountain's clerk: dry, brief, on your side. Never a jeer.

## How it is built

- **Unshaded.** Every piece wears a flat material (kit models keep their atlas colours)
  with fog off, so the HUD reads the same in the mine's lantern dark as on the cliffs.
  The house ink still outlines it.
- **Near.** It hangs 1.25 m from the lens, sized to land where the match HUD would at
  6 m, so the mountain's near card layers never cover it.
- **Narrow windows.** The root is in `LuchaUI.UI_ROOT`; the pieces anchor each frame to
  `lucha.virtual_half_w / _h`.
- **Kit pieces by name.** `peak_altimeter` and `peak_summit_card` are taken when they
  land in `kit/models`; until then the drums are the kit's `hud_odometer` case and the
  rest is painted card built in code.
