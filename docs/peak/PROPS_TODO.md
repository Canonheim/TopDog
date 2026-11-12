# The Peak's props still without a model (TD Prop Maker's list)

**State, 11-12 afternoon.** Sections 1 and 2 are LANDED and synced (TD Prop Maker, 37 files;
slick parts in the one brown). Of section 3, `cable_sheave` (Carpenter) and `snail_wall`
(Environment Maker) are landed and named in the course; the Building Maker's nine are still
to come. What is left to make is section 3's Building Maker rows only.

36 names the course uses that have no model yet. The game draws a plain card (or, for
moving things, the bare collider shapes) until `kit/models/<name>.glb` exists. Land
each in `Top Dog Kit\models` under its exact name and it goes live at the next sync
(`tools/peak/sync_parts.py`): no code change.

Rules: `PARTS.md` ("Rules for every part"). The two that matter most here:
- **The colour law.** Anything a climber can grip is pale, matte, dry. Dark and glossy
  means "can't hold this". Moving things' grip and slick parts are listed below: paint
  the grip parts pale and the slick parts dark and wet.
- **Moving things must cover their collider.** The collider is fixed by the course
  file (`tools/peak/areas/<area>.py`: search the model's name). Sizes below are the
  collider's box about the model's origin; read the file for the exact shapes.
- A deco that is far from its drawn size is scaled to it by the game (over 30% out),
  so hit the size and nothing is stretched.

Each area's map is `docs/peak/preview/<area>.png`; a game frame of every challenge is
`docs/peak/shots/<id>.jpg` (for example `3_4.jpg` is the geode).

## 1. Moving things (they are climbed on: do these first)

| Name | Area | Collider about the origin (m) | What it is |
|---|---|---|---|
| `geode_wheel` | a3 (3.4) | x -2.77..3.20, y -3.20..3.20; turns | A hollow geode seen in section: a ring 6.4 m across with one 60 degree gap. Its inside lining grips (pale frosted crystal), its outer rind is slick (dark glass). Origin: its centre |
| `crystal_ring_4`, `crystal_ring_3` | a3 (3.9) | ring 6.0 across, studs out to 3.45; turn | Rings round a crystal column: a slick glass band with 4 (or 3) pale crystal studs standing out of it. The studs are the only holds. Origin: the centre |
| `quartz_pendulum` | a3 (3.7) | x -0.70..0.70, y -13.30..0; swings | A 13 m slick glass rod with a pale quartz bob (1.4 x 0.6) at its end. Origin: the pivot at the top |
| `crystal_raft` | a3 (3.6) | x -2.55..2.15, y -0.40..3.30; sinks under you | A raft of crystal: a floor and a back wall, grip. Origin as the collider (see a3.py) |
| `mill_wheel` | a2 (2.2) | 4.0 across; turns | A small water wheel, six spokes, paddles at the rim (the kit's `water_wheel` is the 8 m one: same family). All grip (timber). Origin: the hub |
| `crank_small` | a2 (2.11) | x -0.34..0.55, y -0.34..0.34; a free body on a hinge | A 0.7 m iron hand wheel with one handle standing out at its rim (the handle is at +x). Five of them up the dam. Origin: the hub |
| `dam_lift` | a2 (2.11) | x -1.20..1.20, y -0.30..0; rises as its crank turns | A plank deck 2.4 m wide, 0.3 thick, on two iron guide shoes. Origin: the middle of its TOP |
| `barrel_float` | a2 (2.7) | x -0.90..0.90, y -0.55..0.55; drifts | A barrel lying on its side in the water, 1.8 long, 1.1 across, half sunk. Thirteen drift down the pool. Grip (dry staves on top). Origin: its centre |
| `serac` | a9 (9.5) | x -2.50..0.34, y 0..7.61; topples east when climbed | An ice tower 7.6 m tall: snow (white, grip) up its WEST side, blue-black ice (slick) elsewhere, a rock foot. Origin: its downhill foot, the pivot (see a9.py) |

## 2. Scenery

| Name | Area | Size w x h x d (m) | What it is |
|---|---|---|---|
| `crystal_column` | a3 | 2.6 x 38 x 2.6 | The tall column 3.9's rings turn round. Slick: deep indigo glass, hexagonal |
| `mirror_facet` | a3 | 4 x 7 x 0.1 | A great flat reflecting facet standing behind the route (11 placed, scaled 0.9 to 1.3): pale violet glass with a bright edge and two or three reflection streaks |
| `crystal_shell_clear` | a3 | 2.4 x 3.6 x 1.6 | Clear crystal grown over a frozen climber, drawn in FRONT of him (z 0.4): a hollow pale shell, thin, so he shows through its gaps |
| `shelf_fungus` | a4 | 3.0 x 0.8 x 2.0 | A bracket fungus growing out of a wall: tangerine top, cream underside. Origin: the middle of its wall edge at the base |
| `spore_lantern` | a4 | 0.6 x 0.8 x 0.6 | A glowing spore pod on a short stalk (no emissive: the game adds the light). Pale green and cream |
| `hanger_chain` | a2 | 0.08 x 2.9 to 3.7 | An iron chain a ledge hangs from. Make it 3.3 long; the game scales. Origin: the bottom |
| `counterweight_chain` | a5 | 0.15 x 12 to 14 | A heavy temple chain. Make it 12 long. Origin: the bottom |
| `iron_bracket` | a2 | 5.7 x 0.5 x 0.4 | A riveted wall bracket carrying a pipe |
| `water_wheel_frame` | a2 | 4.6 x 6 x 0.6 | The timber A-frame the mill wheel's axle sits in |
| `balloon_tether` | a10 | 0.08 x 24 | The weather balloon's mooring line. Origin: the bottom |
| `rung_stub` | a10 | 0.35 x 0.12 x 0.3 | The broken-off stub of an iron rung in the rock |
| `icicle_row` | a8, a9 | 12 x 1.2 x 0.3 | A row of icicles hanging from an edge, uneven lengths. Origin: the middle of the TOP |
| `frozen_climber_deep` | a9 | 0.9 x 1.9 x 0.4 | A climber deep in the ice, far behind the route: a blurred blue silhouette, one arm up |
| `ice_axe`, `rope_coil_frozen`, `tally_marks_ice` | a9 | 0.25 x 0.7; 0.6 x 0.25 x 0.6; 0.8 x 0.5 card | One climber's last things in the ice cave: an axe stuck in the wall, a coil of rope under rime, tally marks scratched in ice (as the kit's `tally_marks`, paler) |
| `lantern_cold` | a7 | 0.3 x 0.5 x 0.3 | A miner's lantern, dead and dented (the kit has `cold_lantern` and `lantern_mine`: this is the same thing under a second name; a copy is fine) |
| `bone_pile`, `rubble_pile` | a7 | 1.0 x 0.4 x 0.6; 3.0 x 1.6 x 1.0 | Under the vultures' nest; at a gully's foot |
| `shrub_dry`, `vulture_nest` | a7 | 0.9 x 0.7 x 0.6; 1.6 x 0.6 x 1.2 | The one shrub on El Balcón's lip (it is a hold: pale, dry); a stick nest (the kit has `shrub` and `nest`: these are second names; a dry variant and a copy are fine) |
| `dead_tree_crown` | a7 | 5 x 4 x 0.3 | The bare top branches of the dead tree, a flat cut-out |
| `rock_fence_frame` | a7 | 19 x 3 x 0.3 | A timber rockfall fence along a gully: posts, rails, torn mesh |
| `scaffold_frame` | a7 | 24 x 25 x 0.5 | The low cable station's great scaffold, a lattice seen flat, behind the route (the kit's `station_scaffold` is the 4 x 6 unit: this is the whole frame) |
| `pylon_head_low`, `cable_station_low` | a7 | 8 x 5 x 1; 14 x 6 x 3 | The cableway's first pylon head; the low station's shed (the kit's `pylon_top` and `station_roof` are the same family) |

## 3. Machines and set pieces still drawn as plain blocks (Parker 11-12: "making models for everything that is still just block outs")

These move or are climbed, and the game draws them from their bare collider shapes. Each
needs a model made TO ITS COLLIDER: open the area file, find the id, and build over
exactly those shapes (origin = the mover's `at` point; for a spinning thing the hub).
Grip parts pale and matte, slick parts muddy dark brown and glossy (see below). When a
model lands under the name given here, tell Top Dog: the course file needs one word
(`model="..."`) per piece, which Top Dog adds.

**Slick is wet mud now (Parker 11-12): one colour everywhere, muddy dark brown `#3A2616`,
polished and glossy.** Not black, not blue, not green: in every area, on every model, the
parts that can't be held are that brown and shiny. Earlier models' slick parts should be
re-landed in it when their maker next touches them.

| Model name to land | Area, ids in the file | Collider about the origin (m) | What it is | For |
|---|---|---|---|---|
| `statue_champion_reach` | a5 `champion()` | trunk 1.8 x 5.8, shoulders, head, a west arm up to a fist at (-3.4, 7.75), an east arm to a gold fist at (+4.02, 8.19) | A stone luchador champion, 9 m, made to EXACTLY the shapes of `champion()` in a5.py (origin between the feet). The west forearm and fist are a catch, the east fist (gilded) is the launch. The game hides its flat shapes the moment this lands | Building Maker |
| `temple_step` | a5 `step1..3` | x ±1.5, y ±0.5 | A stone stair tread that slides away under you | Building Maker |
| `temple_plunger` | a5 `plunger` | x ±1.1, y ±2.0 | A stone ram that lifts you into the piston shaft | Building Maker |
| `temple_piston` | a5 `piston1..9` | x ±1.7, y ±0.5 | A carved stone piston, a pug's flat face on its end (the kit's `piston_head` is this family, another size) | Building Maker |
| `temple_gear` | a5 `gear1..4` | 6.2 across the teeth | A greased stone disc (slick) with twelve pale stone teeth (the holds), to the teeth of a5.py | Building Maker |
| `temple_slab` | a5 `cw_a`, `cw_b` | x ±1.2, y ±0.4 | The two linked counterweight slabs | Building Maker |
| `temple_block` | a5 `phantom1..5` | x ±1.1, y ±0.6 | A block that slides out of the wall on the drum beat | Building Maker |
| `altar_cross` | a5 `altar_cross` | 10 across | The great turning cross of the altar, four arms | Building Maker |
| `slag_raft` | a6 `balsa1..3` | x ±1.1, y ±0.2 | An iron raft riding the slag | Building Maker |
| `cable_sheave` | a8 `sheave1..2` | 2.2 across | A pylon's turning sheave wheel | Carpenter |
| `snail_wall` | a4 `snail1..5` | x -0.2..1.2, y -1.0..1.1 | A giant snail crawling up a leaning slime wall: its pale shell is the hold and must sit exactly on the collider's shell shape; its body is slick | Environment Maker |
