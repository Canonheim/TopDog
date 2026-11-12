# Writing an area of the Peak

Read `PEAK_DESIGN.md` and your area's table in `CHALLENGES.md` first. An area is ONE
Python file, `tools/peak/areas/<id>.py`, that builds an `Area` (see
`tools/peak/peaklib.py`: every method has a docstring) and calls `save()`. The worked
example is `tools/peak/areas/a0.py`.

```bash
python tools/peak/areas/a3.py                     # writes stages/peak/course/a3.json, prints errors
python tools/peak/preview.py a3 --leak            # docs/peak/preview/a3.png, and where the air leaks
python tools/peak/preview.py a3 --challenge 3.5   # a 30 m window on one challenge (--span 45 for more)
python tools/peak/preview.py a3 --at -380,220 --span 40
```

Look at your pictures (the Read tool shows PNGs). Nobody can play your area tonight,
so the picture and the numbers are the only test: draw every challenge's window and
check it against the rules below before you call it done.

**You write only your own area file.** Never edit peaklib, another area, or the game.
If the library can't say what you need, build it from what exists and say so in your
report. Do not run Godot.

## The world

- Metres. y up. **x is negative into the mountain** (west is left, more negative).
- Your area's region, entry and exit are in `peaklib.FRAME`. Stay inside your region.
- The climber: 1.8 m tall, reaches 2.1 m up from its feet, arm 0.7 m, 22 kg, gravity
  2.79 m/s² (falls are slow and long). Hands and feet stick to any grip surface they
  touch and never to slick. Spinning round one grip builds speed without limit; the
  release sets the flight.
- A body hanging by one hand sweeps a circle of radius 2.1 m round the grip.

## Hard rules (the lint and the leak check enforce some; you enforce the rest)

1. **Dark and wet means no.** Grip only where the route or a designed mercy needs it.
   Walls default to slick (`cave(..., default="wet")`). A wall of grip is a ladder: it
   deletes your challenge.
2. **No flat slick.** A climber on a slick surface cannot move at all (limbs only work
   while something grips). Every slick surface must be steeper than 30 degrees and
   pour onto grip, into water, or out through a declared opening. Every place a body
   can come to rest must be grip or water. This is the softlock rule: check every pit,
   shelf and corner in your picture.
3. **Sealed.** Inside the mountain (A1 to A6) your air must not leak: `--leak` must
   report 0 cells, with your doors declared by `A.opening(...)`. Outside (A7 to A11)
   build your stretch of the east face and say where falls go.
4. **Room to move.** Passages at least 3.5 m clear. A launch hold for a fling needs a
   clear circle of 2.3 m radius round it (the body goes right round). Ceilings 4 m
   over rest ledges.
5. **Rest ledges** between challenges: grip on top, at least 2.5 m wide. And law 4 of
   the design: give each one a small unease (a drip of slick on its lip, a creak).
6. **A fling's landing sets its difficulty:** D2 at least 4 m of grip to hit, D3 2.5 m,
   D4 1.5 m or a rope, D5 1 m or a moving thing. Its flight path must be clear.
7. **Say the route.** Every challenge gets `A.challenge(id, name, anchor, d, miss,
   moves=[...])`. `anchor` is where a climber stands to start it (on grip, 2 m of
   headroom). `moves` lists the intended moves so the lint can check them:
   `["reach", [x, y], [x, y]]` (hold to hold, at most 1.9 m) and
   `["fling", [x, y] launch, [x, y] landing, "F2"]` (tiers in PEAK_DESIGN §2;
   `peaklib.fling_speed(dx, dy)` gives the release speed a gap needs). Rides, swims and
   bounces need no move line.
8. **The cost of a miss is the design** (the `Miss` column). Build the catch that
   gives it: a shelf for `S`, a chute back to your start for `A`. Slick walls keep a
   faller from clawing out early. `P` and `X` leave through the Pozo or down the face.
9. **Show the drop.** Add `A.cam(rect, half_h)` over every fling so the launch, the
   landing and the fall under it are in frame (half_h up to 14).
10. **Keep it lean:** an area is about 150 to 400 solids. Don't tile walls with
    hundreds of little boxes; a wall is one slab.

## The doors between areas (who builds what)

| Door | Where | Rule |
|---|---|---|
| A0 to A1 | A1's east wall, x -152, y -12.6 to -7.5 | A0 builds east of x -152. A1's floor (grip) starts at (-152, -12.6) |
| A1 to A2 | A1's roof: the dry shaft x -236 to -232 at y 86 to 90; the waterfall's slot x -244 to -238 | A1 tops out through the shaft. A2 builds the lip ledge (top y 90, x -232 to -226), the pier between slot and shaft, and the river bed that ends at the lip (x -240) |
| A2 to A3 | A2's roof, x -456 to -449 at y 176 | A2 builds iron rungs up through the hole to y 178. A3's floor (grip, top y 176) surrounds it |
| A2's roof, two holes | the Pozo's foot, x -306 to -294 at y 176; El Tobogán's outlet, x -266 to -258 at y 176 | A2 leaves its roof open at both: what falls down the well or the slide tube drops into A2's river |
| A3 to A4 (Pozo I) | A3's east wall, y 264 to 278; A4's west wall, y 262 to 280 | A3's launch horn may reach x -304.5. A4's root curtain may reach x -296 |
| A4 to A5 (Pozo II) | A4's west wall, y 364 to 380; A5's east wall, y 362 to 382 | A4's cap may reach x -296. A5's banner chains may reach x -303 |
| A5 to A6 (the well mouth) | A5's east wall, y 474 to 488; A6's west wall, y 474 to 488 | A5 hangs its censers in the well room (x -306 to -294, y 474 to 494; the structure caps it at 494) |
| A6 to A7 | the east face at x -231, y 580 to 586 | A6 builds west of x -231. A7 builds El Balcón (top y 578, x -232 to -204) and the face |
| A7 to A8 | the low station's deck, top y 688, x -250 to -236 | A7 builds it. A8 builds above y 688.5 |
| A8 to A9 | the high station's iced deck, top y 786, x -282 to -268 | A8 builds it |
| A9 to A10 | a rock ledge, top y 886, x -312 to -302 | A9 builds it |
| A10 to A11 | a rock ledge, top y 964, x -340 to -332 | A10 builds it |

**Beside the Pozo your AIR stops 3 m short of it:** at x -309 on the west side (A3, A5)
and x -291 on the east (A4, A6), so your 3 m wall slab ends flush with the well. The
door is the gap you leave in that slab (an edge of your `cave` with kind `None`); give
it a grip sill, because the slab ends above and below it are slick.

The Pozo itself (x -306 to -294, y 176 to 480), the east face below y 578, El Colmillo
below y 684, La Garganta, La Boca and El Tobogán are the structure's
(`areas/st.py`): don't build them.

**The east face** (outside areas end their wall on these points): y 578 at x -230,
y 684 at x -251, y 784 at x -281, y 884 at x -307, y 962 at x -334. El Colmillo at
y 684 spans x -172 to -158; A8 builds it from there to its top (-165, 725).
Outside, things fall in from the area above, down the face: keep that fall line slick
and open on your east side, and never let it end in a pocket.

## Motions for movers (`A.mover(id, at, shapes, motion)`)

`shapes` are `[(points relative to at, kind), ...]`; `peaklib.box_pts(cx, cy, w, h, rot)`
and `ngon(...)` make them.

| type | fields | what it does |
|---|---|---|
| `still` | | stays put (use it when a fixed thing needs an id, a tag or a hold behaviour) |
| `path` | `pts` (absolute, the first equals `at`), `speed` m/s, `mode` loop / pingpong / wrap / once, `wait` s at each end, `phase` s, `trigger` grab / board / none, `reset` s, `tilt` bool | travels the line. `wrap` jumps from the end back to the start (barrels, birds). `once` waits for its trigger, goes, then goes home `reset` s later |
| `spin` | `rpm` (+ is counter-clockwise), `phase` deg | turns about `at` |
| `swing` | `amp` deg, `period` s, `phase` 0..1 | swings about `at` like a pendulum (shapes hang below it) |
| `cycle` | `to` [dx, dy], `t_out`, `hold_out`, `t_in`, `hold_in`, `phase` s | slides out to `at + to` and back on a clock (pistons, gates, phantom blocks) |
| `sink` | `to` [dx, dy], `speed`, `back` | moves toward `at + to` while a climber is on it or holds it; goes home when left |
| `link` | `to` mover id, `scale` | moves `scale` x the other mover's offset (a counterweight is -1) |
| `tip` | `angle` deg, `time` s, `trigger`, `reset` s | falls over about `at` when triggered |
| `crank` | `to` [dx, dy], `body` (a free body's id), `per_turn` m, `fall` m/s | advances along `to` as that body is turned; sinks back when it isn't |

`A.wheel(...)` and `A.pendulum(...)` build the common ones. `ko=True` on a mover makes a
hard hit from it knock a climber out.

## Hold behaviours (`hold=` on a solid or mover, or built into a kind)

| | |
|---|---|
| `{"type": "crumble", "t": 1.2, "respawn": 8}` | breaks t seconds after it's taken (kinds `rotten`, `brittle`, `icicle`, `snowbridge` carry it) |
| `{"type": "timed", "t": 2.0, "rearm": 0.6}` | lets go of you after t seconds (kinds `hot`, `hotpipe`, `ice`) |
| `{"type": "wet", "on": 2.0, "off": 3.0, "phase": 0}` | slick for `on` seconds, grip for `off` (spray) |
| `{"type": "kick", "v": [vx, vy]}` | grabbing it throws you at that velocity (the burros) |

## Zones

`water`, `wind` (steady or gusting), `geyser`, `bounce`, `puff`, `strike`, `dark`,
`finish`.

- **Bounce is a line** from p0 to p1. It throws along the normal (-dy, dx) of p0 -> p1.
  For a flat cap that throws UP, p0 is the end with the smaller x and p1 the end with
  the larger x. The preview draws each bounce's arrow: check it points where you mean.

- **Water:** a climber floats at the surface and is carried by `flow`. A hand moving
  under the surface pushes the body the other way, so circling one arm swims. Design
  swims as: current speed 1.0 to 1.6 m/s for a first swim, up to 2.4 for a hard one;
  still eddies (a second `water` box with flow 0 laid over the first: the last zone a
  climber is in wins) behind pillars as rests; grip ladders or chains to get out.
  Banks are slick unless they're an exit.
- **Wind:** `accel` is m/s². 2.79 up cancels gravity. A 4 m/s² side gust is strong.
  Gusts: `{"on": 2.0, "off": 3.5, "phase": 0, "warn": 0.8}`.
- **Geyser:** carries a climber up at `speed` while it's on. To throw someone H metres
  above the column's top, speed = sqrt(2 x 2.79 x H).
- **Bounce power:** the body leaves at `power` m/s along the normal (plus `gain` x its
  speed in). A throw of `power` rises power² / 5.58 metres. A bounce line is not solid:
  lay it along the top of a solid (kind `cap`) so a slow arrival still lands.

## Looks

- `A.card(pts, z, tone)`: painted cardboard layers behind (z -2 to -30) and in front
  (z 2 to 6). Use them: far cavern walls, silhouettes, the story. Three or four layers
  of depth per room. A full-room back card (tone `back2`, z -6) hides the sky inside.
- `A.deco(model, x, y, z, size=(w, h, d), tone=...)`: props from the catalogue in
  `PARTS.md`. You may invent a prop: give it a clear name, a size and a tone, and list
  it in your report. Props are scenery: never needed to climb.
- `A.light(...)`: lanterns and torches inside (about one per 12 m of route).
- `A.effect(kind, rect)`: waterfall, mist, drips, spores, snow, steam, embers, dust,
  rain, clouds.
- `A.statue(x, y, pose)`: the ones who tried. Where the design names one, place it.
  They are solid grip.

## Your report (your final message)

1. What you built, challenge by challenge, in a line each, with anything you changed
   from `CHALLENGES.md` and why.
2. The checks: errors (must be none), leak cells (must be 0 inside), and any rule above
   you could not meet.
3. New prop names you invented, with sizes.
4. What you'd want tested first by a human.
