# How we make Top Dog kit pieces (and how we make them look good)

For anyone, person or LLM, joining the art side of Top Dog. It's written for Astra, working on Dan's machine.
Read it once before making a piece.

The Building Maker wrote it from the houses, bell tower, church, ring, mountains and clouds it built on 2026-11-08.

Two companion docs:
- **`TopYourPals\docs\HOUSE_ATLAS_AND_3D_MODELS.md`** (in the game repo) has the exact atlas, shader and model laws.
  This doc doesn't repeat all of them; it's the working method and the taste.
- **`docs\PARTS.md`** (in this kit) is the live list of every piece: its name, size, origin, objects and status. Check
  it before making something, and add your line when you land.

---

## 1. The idea in one paragraph

Every model is a **program**: one Blender Python script per piece builds it from an empty scene, so it can be
re-run, diffed, fixed in one line and rebuilt. The script writes one colour per face. A converter then moves every
face onto **one shared colour atlas**, so the whole game uses one texture and one material (`PALETTE`). The game
draws it with a **cel shader** (hard light bands) and a **screen-space ink outline**. Nothing is hand-modelled,
textured or sculpted. The look comes from shape, a few broad colours and the ink.

## 2. Where things live

| What | Where |
|---|---|
| The kit (Parker's machine): finished models, build scripts, previews, docs | `Desktop\Clod Things\Top Dog Kit\` |
| Finished models (what the game loads) | `Top Dog Kit\models\<name>.glb` |
| Build scripts and the shared helpers | `Top Dog Kit\source\` (`tdk.py` is the one shared Blender helper) |
| Review sheets, game frames from Top Dog and the Environment Maker | `Top Dog Kit\previews\` |
| The parts list, briefs, rounds, notes | `Top Dog Kit\docs\` |
| The atlas the kit models point at | `Top Dog Kit\palette\house_atlas.png` (+ `house_atlas_map.json`) |
| Checking tools: z-fight, game-distance renders | `Top Dog Kit\tools\` |
| The UI creator's originals of pieces the Building Maker re-made | `Top Dog Kit\backup\ui_creator_originals\` |
| The game repo (github.com/Canonheim/TopDog) | `Desktop\Clod Things\TopYourPals\` (`main`) |
| The game's copies of the kit models | `TopYourPals\kit\models\`, copied by `python tools/sync_kit.py` |
| The house tools the close uses (converter, gates, checker) | `Desktop\House Style 3D Kit\tools\` (**not in the repo**) |

**On Dan's machine:** the repo has the game and its `kit\models\` copies, but not this kit folder or the House
Style kit. To build and land pieces there you need copies of both. Ask Parker; Top Dog can arrange it. Without them
you can still write a build script and export a per-colour GLB, but the close (step 5 of the road) needs the House
Style tools.

Software:
- Blender 5.2 (`C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`; change the path in `source\round.sh`
  and `source\land.sh` if yours differs);
- the system Python with `shapely`, `numpy` and `Pillow`;
- Git Bash for the `.sh` scripts.

## 3. Who does what (the team as of 11-08)

- **Top Dog** (the Top Dog game session) is the coordinator and Parker's voice. It syncs kit models into the game,
  commits, pushes and sends back game frames. Everything you land, tell Top Dog the file names.
- **The Environment Maker** is the architect. It writes specs (`docs\ENVIRONMENT_PLAN.md`), places pieces in the town
  in code (branch `env-pass`) and sends in-game frames with notes.
- **The UI creator** makes the 3D UI pieces (belts, cards, HUD, title).
- **The Building Maker** makes buildings, the ring, and backdrops (mountains, clouds).
- If you re-make someone else's piece: tell them, back up their originals, and keep the drop-in contract (section 6).

Rules that hold for everyone:
- No git writes and no Godot runs from the art side; ask Top Dog for in-game frames.
- No emissive colours. No reference-game names anywhere.

## 4. The road for one piece

```
(design step, optional)  source\<stem>_design.py   system Python + shapely  -> source\<stem>_shapes.json
build                    source\build_<stem>.py    Blender, headless        -> build\<stem>.glb (one material per colour)
a round                  bash source/round.sh <stem> <tag>                  -> previews\<stem>_sheet_<tag>.png
review, fix, repeat      (two or three rounds for a light pass; the full critic loop for hero pieces)
the close                bash source/land.sh <stem> [triangle_budget]       -> models\<stem>.glb, on the atlas
record                   a line in docs\PARTS.md; tell Top Dog the names; it syncs, sends game frames; fix what they show
```

### The design step (shapely, outside Blender)

Use it for anything drawn in 2D first: silhouettes, cut-outs, emblems, regions of colour on one face. Shapely
unions, differences and buffers are far easier than doing booleans in Blender. The step writes plain numbers to
`<stem>_shapes.json`, so the Blender build only reads numbers and two builds stay byte-identical.

`land.sh` and `round.sh` run `<stem>_design.py` automatically if it exists. For several pieces sharing one designer,
add a three-line wrapper per stem (see `mountain_cutout_a_design.py`, which calls `mountain_design.design('a')`).

### The build script

```python
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tdk
m = tdk.Mesh('house_walls')                      # one Mesh per named object
tdk.box(m, -2, 2, 0, 5, -2, 2, 'wall_d', 'wall')  # x0 x1 y0 y1 z0 z1, top colour, side colour
m.plate([[(x, y), ...]], z0, z1, 'front_col', 'side_col')   # a 2D outline (holes allowed) pushed along z
tdk.tube(m, a, b, r, 28, 'col')                  # a capped tube
palette = {'wall': dict(hex='#E8B14A'), 'wall_d': dict(hex='#B07E26'), 'gold': dict(hex='#F2BC36', metallic=1.0, roughness=0.4)}
tdk.export([m, ...], palette, tdk.out_path('<stem>'), 8000)   # asserts the triangle budget
```

- **File axes:** X right, Y up, +Z toward the game camera. `tdk` maps to Blender and exports Y-up with transforms
  applied.
- **Colours** are named keys with a hex value. Matte by default; `metallic=1, roughness=0.4` is satin metal (golds,
  bells). No `glow`: `tdk.export` refuses it.
- **Helpers worth reusing:**
  - `source\plaza_house_lib.py` has `lathe()` (turned forms: bells, domes, caps, posts), `arch()`, `ring_loop()`,
    `prism_x()`, a recessed door, a French balcony door, windows with shutters, quoins, string courses and eave
    tiles.
  - `source\mountain_lib.py` and `cloud_card_design.py` have the cardboard cut-out language.
- **Determinism:** no `random` without a fixed seed, no time, no dict-order surprises. The close fails if two builds
  differ by one byte.

### The close: `land.sh` (run once a piece passes review)

It runs these steps in order:
1. two fresh builds, which must be byte-identical;
2. the applied-transforms gate: every node identity;
3. the converter, onto the atlas: each colour goes to the named cell within 2 sRGB levels, or to the nearest picker
   pixel. It **fails above delta E 4.5**, so wild hexes can be refused. The kit's existing hexes all pass; reuse them
   (grep `dict(hex=` in `source\`);
4. the atlas gate;
5. the house checker: budget, names, renders.

The default triangle budget is 6,000; pass a second argument for bigger pieces (the church is 12,000, the ring
14,000). On success it writes `models\<stem>.glb`.

## 5. Reviewing: look at it from where the player will see it

- **`round.sh`** renders eight views (front, far, three-quarters, side, top, back, low) into a sheet. Good for form,
  but it **fits the piece to the frame**. Long pieces become tiny there, and thin parts turn into solid ink.
- **Game-distance cameras matter more.** The follow camera sits about 6.7 m in front of the play plane with a 34
  degree vertical lens. The plaza houses are 16-19 m away, the hill town 30-50 m, the mountains 200-260 m, the
  clouds 70-95 m. Use `tools\game_views_ring.py` / `game_views_house.py` (copies of the preview with fixed cameras;
  edit the `views` list) to render from there.
- **Judge at the real read distance** (the house rule says 3 m for UI parts; for the town, the distances above).
  Detail too small to read at that distance is noise. Detail that reads is what makes a piece "look finished".
- **In-game frames win.** The game's cel band and ink differ from the bench renders. Ask Top Dog or the Environment
  Maker for frames once the piece is synced, and fix what they show.

### Checks to run before you land

- **Z-fighting:** `python tools/zfight_check.py build/<stem>.glb` (or `build/land/<stem>_percolour.glb` after the
  close). It counts only visible fights between different colours. Aim for 0.000 m². Section 8 lists the usual
  causes.
- **Bounds:** read `previews\check\<stem>_check.json` (`measured`). Check nothing goes below the ground, past the
  footprint, or where the contract says it mustn't. The ring's first pug medallion dipped 6 cm below the plaza
  floor; the bounds caught it.
- **Names and origin** match the contract (section 6).

## 6. The drop-in contract (the game loads parts by file name)

`LuchaKit.kit_model("<stem>")` loads `res://kit/models/<stem>.glb` and falls back to a code stand-in if it's
missing. So a re-made piece must keep:
- **the file name** (and therefore the stem);
- **the origin** where the parts list says, usually the footprint centre on the ground, or the centre for cards;
- **the footprint and size** (the code places and sometimes scales by them; the clouds scale by
  `LuchaKit.CLOUDS` widths);
- **the object names the code looks up.** The ring's `ring_canvas` is repainted in code, and the side ropes are
  found by name for the rope bounce. Grep the repo for the stem before renaming anything:
  `grep -rn "<stem>\|<object name>" TopYourPals --include=*.gd`.

If you must break the contract, say so to Top Dog first. Once code is tied to an origin, don't move it.

## 7. Making things look good: the ideas we use

### The house look (fixed)

- Low-poly, flat-shaded, one colour per face from the shared atlas, a cel shader and a black ink outline.
- No textures, no vertex colours, no bloom, no fog, **no glow**.
- **Words** are the game's job (Label3D). Leave flat panels named `*_face` for them; don't model text unless asked.

### Top Dog's palette and mood

- **Lucha libre, cartoon, festive, a sunny Mexican plaza** (Parker's picture: `docs\parker_inspiration_main_scene.webp`).
- **Mexican colours:** rosa mexicano pink `#E0287A`, turquoise `#1FB8AE`, marigold `#F28A1E`, lime `#7CC83A`,
  purple `#8A3FC0` and yellow `#FFC928`, with satin gold `#F2BC36`. Parker said of the ring: "too much red white and
  blue, lets get more mexican colors going". Use red, white and blue sparingly.
- **Buildings:** stucco in cream `#E6D8B4`, ochre `#E8B14A`, rust `#C8604A` or rosa; terracotta roofs (`#D2643A` /
  `#9A4224` / `#E8834E`); cream trim; painted shutters in turquoise or blue.
- **Distance by colour, not fog:** far things go toward haze blues. Not too pale, though: the sunlit cel band lifts
  pale colours to near white at range. The mountains only read once their lit rock went from `#CCDBF3` to `#89B2E9`.

### Gameplay readability comes first

- **The climber is a bone-white skeleton** (luchadors later). Nothing pale or white should sit behind them at their
  heights: the ring's white middle rope swallowed the skeleton's hips and became turquoise. The ring canvas is
  repainted mid warm grey for the same reason.
- **The height line is a red rope.** Keep red off the back of the stage at climbing heights, so nothing is mistaken
  for it.
- **Nothing across the front of the ring:** the camera looks through that side.
- **Keep calm, mid-value surfaces in the column behind the climber** (the church facade, the mountains), so the
  silhouette reads.

### Colour craft

- **One hue per surface, in two or three steps**: a base, a light and a dark (`tile`, `tile_hi`, `tile_d`). Put the
  dark step on the sides of things and the light on the faces.
- **Broad masses first.** A mosaic of small colour faces reads as noise at range.
- **Flush colour regions on one plane draw no ink between them.** That's how you paint on a face (the mountains'
  snow and rock, a card's underside) without inking it. Regions stacked as thin layers must sit **0.2 mm or less**
  apart for pieces the game scales up: 1 mm and 0.5 mm steps both drew faint dotted ink at 240 m. Separate parts with
  real depth do get ink, which is how you outline something on purpose.
- **Gold is satin metal**: bells, knobs, caps. Everything else is matte.

### Shape craft

- **Depth makes a facade.** A flat wall with flat windows reads as a slab. What made the plaza houses read:
  - window frames proud 5 cm, glass set in them, glazing bars, sills, hoods with a cap;
  - corner quoins or pilasters, a string course between floors, a two-step cornice;
  - a base band, and round tile ends along the eave;
  - balconies with railings, flower boxes and pots, an awning, chimneys.
- **Recess openings.** A door or window that sits flush looks unfinished. Build the surround as a frame with a hole
  (`plate([outline, hole])`) 12 cm deep, with the door or glass at the back, so the reveal shows in the dark trim.
  Add impost blocks at the arch's spring and a keystone. That's what made the doors and the balcony French doors
  look complete.
- **Small parts must be big enough to read**, or leave them out:
  - six fine slats on a shutter inked to a dark smear at 17 m, so shutters became two broad raised panels;
  - ring pulls became solid gold knobs;
  - cacti at 16 % of a hill's height were dots; at 34 % they read.
- **Round forms:**
  - keep each facet turn under 15 degrees, or the ink draws every facet: 28 sides for posts, ropes and domes;
  - thin round parts need it most: 8-sided ropes and posts read black at play distance;
  - small knobs and balls can be 12-sided;
  - faceting on purpose is fine where it suits: octagonal turnbuckle pads read as padded panels.
- **Chamfers, not fillets.** One plane change catches a light step; a rounded fillet smears it.
- **Give every side the camera can see something.** House side walls show at the frame's edge, so each upper floor
  got a side window. Back faces the camera never sees can stay plain.
- **Variety without chaos:** a shared builder with per-variant parameters (colours, door colour, which floors get
  flower boxes, an awning or not). One look, different houses.

### The cardboard cut-out language (mountains, clouds)

Parker wanted the backdrops to look "like large cardboard cut outs".
- **A hand-cut outline:** densify the silhouette and nudge each point a little in or out. Keep it gentle: too much
  wobble reads as torn, not cut.
- **A thick card, about 2-2.5 % of its width,** built as three slabs (light kraft `#C98A4E`, a dark stripe
  `#7A4E26`, light kraft), so the cut edge reads as corrugated cardboard from the side. A kraft back.
- **The paint on the front:** flush regions in a few broad colours (section above).
- **Stage props behind:** triangular cardboard braces with tape and sandbags (mountains), a wooden dowel down from the
  bottom (clouds). Keep props inside the face's width and above y 0, because the game scales by the bounding box.
- **Stacked cards** give shape for free: each cloud is a white card in front of a pale blue-grey card offset down and
  to the right.

## 8. Mistakes we made, so you don't

- **Coplanar faces in different colours fight.** The usual suspects:
  - a band (string course) running behind a door or window, so break it at the opening;
  - the ends of a band flush with the side wall, so take them 5 cm past the corner;
  - a ledge top flush with a shaft top, so drop it 1 cm;
  - two neighbouring parts' end caps in different colours, so give both the same colour;
  - shutters overlapping a balcony's arched frame, so leave out the leaves that clash.
- **Faces pressed together are fine** when one faces the other (they're hidden). The checker ignores them.
- **Something under the ground** throws off placement and scale. Check the bounds.
- **An origin flip-flopped** while messages crossed. Once the game code is tied to an origin, keep it.
- **The fit-to-frame review sheet lied** about thin parts. Render from game distance.
- **Freestyle ink in the bench renders isn't the game's ink.** The bench outlines things the game won't, and the other
  way round. Trust in-game frames.
- **Pale colours at range go white** in the sunlit cel band.

## 9. Handing off a piece

1. `bash source/land.sh <stem>` passes; the z-fight check is 0; the bounds are right.
2. Update `docs\PARTS.md`: name, size, origin, objects, status ("delivered"), tris, where the sheets are, whether
   it's seen in game.
3. Put a sheet in `previews\` (and game-distance views if it's a town or backdrop piece).
4. Tell Top Dog the file names, what changed, and anything that touches the contract. It syncs, commits and sends
   frames. Tell the Environment Maker too if it places the piece.
5. Fix what the frames show, re-land, tell them again.

The app pauses a session's messages to others after ten in a row with nobody typing. If that happens, write your note
in `docs\` (the Building Maker uses `docs\BUILDING_MAKER_NOTES.md`) and tell Parker.

## 10. What exists (11-08), and where its source is

| Piece | Source | Notes |
|---|---|---|
| `plaza_house_a`, `_b`, `_c` | `plaza_house_lib.py` + `build_plaza_house_<x>.py` | variants are rows of `VARIANTS` |
| `bell_tower` | `build_bell_tower.py` (on `plaza_house_lib`) | not placed at the moment |
| `plaza_church` | `build_plaza_church.py` | twin towers, talavera dome; origin at the facade's foot |
| `ring` | `ring_design.py` (shapely) + `build_ring.py` | Mexican colours, green top rope |
| `mountain_cutout_a`, `_b`, `_c` | `mountain_design.py` (shapely) + `mountain_lib.py` | cardboard, 10 m unit, scaled to the slots in code |
| `cloud_a` .. `cloud_e` | `cloud_card_design.py` (shapely) + `build_cloud_<x>.py` | cardboard, on dowels |
| the UI pieces (title, belts, cards, HUD, online rows, confetti, palm, piñata...) | the UI creator's `build_*.py` / `*_design.py` | see PARTS.md and the `rounds_*.md` docs |
