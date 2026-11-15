# The sweeps

Written by `python tools/peak/sweeps.py` (the five sweeps of QUALITY_TO_9_PLAN part 4) over the course as built. A hit is a place to look; the frame decides. The tool's docstring says what each sweep means.

## Phase 0, 11-15: what was found, fixed and removed

**The tool.** `tools/peak/sweeps.py` (five sweeps; its docstring says what each means). It runs on every course build:
`peaklib.Area.save` applies the build's own fixes, then prints that area's counts. By hand, `python tools/peak/sweeps.py`
writes this page. Z-fighting is read from the models' own meshes (their flat faces toward the camera and up, plane by plane);
the other sweeps use a model's bounds, so their hits are places to look.

**Before the fixes** (first run, the same order ZFIGHT, DEPTH, SKIN, STANDIN, CARD; STANDIN then counted solids under big
shared skins as invisible, which they are not): a0 11, 3, 3, 7, 1; a1 10, 64, 22, 29, 10; a2 5, 23, 21, 3, 1; a3 17, 0, 10, 24, 1; a4 11, 1, 6, 14, 1; a5 19, 31, 30, 36, 1; a6 9, 11, 5, 10, 6; a7 8, 8, 22, 38, 0; a8 10, 16, 13, 3, 0; a9 5, 11, 45, 3, 0; a10 3, 1, 22, 21, 0; a11 5, 3, 3, 6, 3.
The table below is after.

**Fixed, on every build, everywhere but the mine's scenery:** two pieces flickering in one plane are parted (the smaller deco
1.5 cm toward the camera or up; a card 2 cm back); a solid whose landed skin covers it nowhere draws its own shape again
(note 104's kind). Z-fighting went from 113 hits to 15, 7 of them the mine's scenery (listed, not moved).
**Fixed by hand:** note 113, the rams' solids 5.6 m long as drawn (a2; nothing can get under or inside a raised ram);
note 109, the mine frog cave's two plain floor solids wear the throat's skin (a1); La Esclusa's backstop and the pier's
coping off the mine's planes (a1); the lift's spores (4.3) a glowing curtain: small faint motes, 2.5 times as many, and two warm lights of their own (a4;
effects can now take `size` and `alpha`). **The flat yellow column itself is not the spores:** it is painted in a model
behind the lift (no deco, solid, card or mover draws it: one of `jardin_pocket_back_wall`, `jardin_ramp_back`,
`jardin_island_back`): a model job, for the garden's maker.
**Removed (part 5's blank and flat cards):** the flat lilac hexagon cards through the crystal cave (`gruta_mirror_wide` x6,
`mirror_facet` x4, a3); the storm ridge's flat orange under-lit cloud card (a10); the summit's white snow cards (a11: the cap
models have landed, and the cards stood in their plane); the glacier's unlit white window box (`glaciar_window`, a9).
**Removed (the worst 30, nothing needs them):** `gruta_floor_back`, `gruta_landing_back`, `gruta_rampa_back`, `gruta_well_back`,
`gruta_leaf_stump` x8 (a3); `aguas_beam_end` x7 and `aguas_beam_end_long` x4 (a2); `jardin_outcrop` x6 (a4).
**Part 5's not found in the data** (to point at in a frame): the olive slab at 2.3 and 2.4, the beige band in the cableway's
sky, the glowing white panels at 5.2 and 9.4 / 9.6, the white void shapes at 10.5 to 10.7, the floating spray balls and squares.
(The white bars at 11.1, 11.2 and 11.5 are the rime's brittle collars and nose, plain until `cumbre_rime_*` land.)

**The worst 30 that wait for a maker** (each a maker session's job; by the biome it waits for):
- 0, La Estación: `dsc_set_grey` x14, `dsc_set_bare` x11, `dsc_set_white` x11 (the tunnel's posts as timber sets with caps and braces).
- 1, La Mina Vieja (the Director's): `mine_throat_west`, `mine_el_diente_body`, `mine_rust_lines`, `mine_tunnel_back`,
  `mine_worn_path`, `mine_upper_works_mass`, `mine_nail_row`, `mine_rail_end_torn`, `mine_east_mass`.
- 2, Las Aguas Negras: `aguas_borde_landing`, `aguas_cascada_landing`, `aguas_charco_landing_east` (Q6 is 13 m now) and `_west`,
  `aguas_flume_landing` (the landings as stone ledges with faces), `aguas_tread_end` x14.
- 8, El Teleférico: `tele_cable_short` x28 (real cable with clamps), `tele_chalk_block` x26 (carved chalk knobs).
- 9, El Glaciar: `glaciar_niche_back`, `glaciar_niche_back_short`, `glaciar_climber_back` x6.

**The mine's hits, for the Director** (a1_dress's decos are listed here and not moved): see `## a1` below: 7 z-fights,
64 depth, 22 skin, 8 cards (its course solids are fixed; note 109's floor too). Also for its scenery: the frog cave room's
floor (`mine_frog_cave`) a hair below the play floor (note 109's plan).

**Cross-area, not faults:** a10's `tormenta_porch` is the skin of a9's porch ledge (the sweep sees one area at a time).

**Not done:** the depth (note 115's kind) and skin hits beyond the notes fixed above are listed, not moved: each wants a
judgement (a model re-cut by its maker, or the solid re-cut to the drawing: "solids are free"); notes 124 (the
chandeliers), 129 (the crust lips) and 133 (the caps) among them. The mine's design pages (design/a1/) keep today's numbers:
hand-written pages, not quick, and the design folder is outside this session's files.


| Biome | ZFIGHT | DEPTH | SKIN | STANDIN | CARD |
|---|---|---|---|---|---|
| a0 La Estación | 0 | 3 | 3 | 0 | 1 |
| a1 La Mina Vieja | 7 | 64 | 22 | 0 | 8 |
| a2 Las Aguas Negras | 0 | 23 | 18 | 1 | 0 |
| a3 La Gruta de Cristal | 3 | 0 | 10 | 0 | 0 |
| a4 El Jardín de Hongos | 1 | 2 | 6 | 0 | 0 |
| a5 El Templo del Primer Perro | 1 | 31 | 30 | 0 | 0 |
| a6 La Chimenea | 0 | 11 | 5 | 0 | 5 |
| a7 Los Riscos del Viento | 2 | 8 | 22 | 0 | 0 |
| a8 El Teleférico | 1 | 16 | 13 | 0 | 0 |
| a9 El Glaciar | 0 | 12 | 45 | 0 | 0 |
| a10 La Cresta de la Tormenta | 0 | 1 | 22 | 1 | 0 |
| a11 La Cumbre | 1 | 3 | 3 | 0 | 0 |

## a0 La Estación

### DEPTH (3)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a0 deco 252 | deco `dsc_trough` with deco `dsc_back_wall_d` (a0 deco 170) | -139.0, -11.2 (z -1.6 .. -1.4) | 0.32 m apart in depth, overlapping on screen |
| a0 deco 257 | deco `dsc_trough` with deco `dsc_back_wall_d` (a0 deco 170) | -148.8, -11.4 (z -1.6 .. -1.4) | 0.32 m apart in depth, overlapping on screen |
| a0 deco 258 | deco `dsc_trough_spout` with deco `dsc_back_wall_d` (a0 deco 170) | -150.8, -11.4 (z -1.6 .. -1.4) | 0.32 m apart in depth, overlapping on screen |

### SKIN (3)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a0 deco 174 | deco `dsc_bed_d` | -144.0, -13.2 (z -2.0 .. 2.0) | drawn -152.0 .. -135.9 x -14.7 .. -11.7, its solid -152.0 .. -135.9 x -15.3 .. -11.6 (0.60 m off) |
| a0 deco 178 | deco `dsc_roof_d` | -144.0, -5.2 (z -2.0 .. 2.0) | drawn -152.0 .. -136.0 x -6.8 .. -3.6, its solid -152.3 .. -136.0 x -7.3 .. -3.7 (0.49 m off) |
| a0 deco 270 | deco `dsc_buffer_stop` | -209.8, -28.6 (z -1.7 .. 1.7) | drawn -210.7 .. -209.0 x -29.0 .. -28.2, its solid -209.6 .. -209.0 x -29.0 .. -28.2 (1.10 m off) |

### CARD (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a0 card 0 | card `#33291F` | -179.7, -18.0 (z -2.7 .. -2.7) | a flat card of one tone, 388 m2, at z -2.7 |

## a1 La Mina Vieja

### ZFIGHT (7)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a1 deco 392 | deco `mine_post_tall` with deco `mine_post_tall` (a1 deco 394) | -290.8, 38.6 (z -1.7 .. -1.3) | front faces both at z -1.33, overlapping 0.08 m2 |
| a1 deco 336 | deco `mine_incline_bench` with deco `mine_incline_bent` (a1 deco 339) | -278.1, 7.0 (z -3.4 .. -1.3) | tops both at y 8.90, overlapping 0.11 m2 |
| a1 deco 336 | deco `mine_incline_bench` with deco `mine_incline_bent_low` (a1 deco 338) | -278.1, 7.0 (z -3.4 .. -1.3) | tops both at y 8.70, overlapping 0.11 m2 |
| a1 deco 336 | deco `mine_incline_bench` with deco `mine_incline_bent_tall` (a1 deco 337) | -278.1, 7.0 (z -3.4 .. -1.3) | tops both at y 8.90, overlapping 0.11 m2 |
| a1 deco 56 | deco `mine_el_diente_body` with deco `mine_lamp_post` (a1 deco 357) | -262.4, -9.8 (z -3.2 .. -1.3) | tops both at y 23.00, overlapping 0.04 m2 |
| a1 deco 59 | deco `mine_cavern_wall_mid` with deco `mina_drift_portal` (a1 deco 256) | -245.4, -11.0 (z -3.6 .. -2.9) | front faces both at z -2.91, overlapping 0.09 m2 |
| a1 deco 263 | deco `plank` with deco `plank` (a1 deco 264) | -249.6, -16.8 (z -2.8 .. -2.0) | tops both at y -16.73, overlapping 0.40 m2 |

### DEPTH (64)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a1 deco 39 | deco `stalactite_a` with deco `mine_chamber_roof` (a1 deco 53) | -268.0, 36.5 (z -2.1 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a1 deco 41 | deco `stalactite_a` with deco `mine_chamber_roof` (a1 deco 53) | -249.0, 32.4 (z -2.1 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a1 deco 43 | deco `stalactite_a` with deco `mine_chamber_roof` (a1 deco 53) | -219.0, 15.5 (z -2.1 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a1 deco 64 | deco `mine_fern_pale` with deco `mine_cave_rock` (a1 deco 61) | -313.2, -38.4 (z -1.4 .. -1.4) | 0.13 m apart in depth, overlapping on screen |
| a1 deco 86 | deco `mine_pile_twin` with solid `wood` (a1 solid 43) | -287.0, -47.2 (z -2.5 .. -2.1) | 0.90 m apart in depth, overlapping on screen |
| a1 deco 98 | deco `mine_post_long` with deco `mine_tunnel_back` (a1 deco 97) | -266.6, -46.5 (z -1.9 .. -1.4) | 0.18 m apart in depth, overlapping on screen |
| a1 deco 99 | deco `mine_post_long` with deco `mine_tunnel_back` (a1 deco 97) | -264.0, -46.5 (z -1.9 .. -1.4) | 0.18 m apart in depth, overlapping on screen |
| a1 deco 100 | deco `mine_post_long` with deco `mine_tunnel_back` (a1 deco 97) | -261.4, -46.5 (z -1.9 .. -1.4) | 0.18 m apart in depth, overlapping on screen |
| a1 deco 102 | deco `mine_post_long` with deco `mine_tunnel_back` (a1 deco 97) | -264.4, -42.7 (z -1.9 .. -1.4) | 0.19 m apart in depth, overlapping on screen |
| a1 deco 103 | deco `mine_beam` with deco `mine_tunnel_back` (a1 deco 97) | -258.9, -42.7 (z -1.8 .. -1.5) | 0.21 m apart in depth, overlapping on screen |
| a1 deco 110 | deco `mine_rail_single` with deco `mine_east_mass` (a1 deco 52) | -240.8, -36.8 (z -1.6 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a1 deco 111 | deco `mine_rail_single` with deco `mine_east_mass` (a1 deco 52) | -239.6, -35.2 (z -1.6 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a1 deco 112 | deco `mine_rail_single` with deco `mine_east_mass` (a1 deco 52) | -238.3, -33.6 (z -1.6 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a1 deco 113 | deco `mine_rail_single` with deco `mine_east_mass` (a1 deco 52) | -237.1, -32.0 (z -1.6 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a1 deco 114 | deco `mine_rail_single` with deco `mine_east_mass` (a1 deco 52) | -235.9, -30.4 (z -1.6 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a1 deco 213 | deco `lantern_mine` with deco `mine_east_mass` (a1 deco 52) | -228.0, -17.2 (z -1.7 .. -1.5) | 0.26 m apart in depth, overlapping on screen |
| a1 deco 214 | deco `mine_post_mid` with deco `mine_east_mass` (a1 deco 52) | -231.2, -9.8 (z -1.7 .. -1.3) | 0.06 m apart in depth, overlapping on screen |
| a1 deco 215 | deco `mine_post` with deco `mine_east_mass` (a1 deco 52) | -226.8, -9.8 (z -1.7 .. -1.3) | 0.14 m apart in depth, overlapping on screen |
| a1 deco 216 | deco `mine_post_tall` with deco `mine_east_mass` (a1 deco 52) | -229.0, -8.4 (z -1.7 .. -1.3) | 0.09 m apart in depth, overlapping on screen |
| a1 deco 217 | deco `pickaxe` with deco `mine_east_mass` (a1 deco 52) | -231.9, -10.9 (z -1.5 .. -1.3) | 0.14 m apart in depth, overlapping on screen |
| a1 deco 218 | deco `sign_pug_arrow_west` with deco `mine_east_mass` (a1 deco 52) | -233.2, -10.2 (z -1.4 .. -1.3) | 0.06 m apart in depth, overlapping on screen |
| a1 deco 265 | deco `mine_mushrooms_pale` with deco `mine_east_mass` (a1 deco 52) | -248.6, -16.6 (z -2.0 .. -1.9) | 0.75 m apart in depth, overlapping on screen |
| a1 deco 290 | deco `sign_pug_skull` with deco `mine_east_mass` (a1 deco 52) | -250.4, -9.9 (z -1.4 .. -1.3) | 0.09 m apart in depth, overlapping on screen |
| a1 deco 334 | deco `mine_fern_pale` with deco `mine_chain_rib` (a1 deco 332) | -285.2, 28.5 (z -1.5 .. -1.4) | 0.13 m apart in depth, overlapping on screen |
| a1 deco 353 | deco `mine_rail_single` with deco `mine_chamber_roof` (a1 deco 53) | -267.0, 23.1 (z -1.5 .. -1.4) | 0.18 m apart in depth, overlapping on screen |
| a1 deco 354 | deco `mine_rail_single` with deco `mine_chamber_roof` (a1 deco 53) | -265.3, 23.1 (z -1.5 .. -1.4) | 0.18 m apart in depth, overlapping on screen |
| a1 deco 372 | deco `stalactite_a` with deco `mine_chamber_roof` (a1 deco 53) | -271.0, 36.5 (z -2.1 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a1 deco 373 | deco `stalactite_a` with deco `mine_chamber_roof` (a1 deco 53) | -269.8, 37.2 (z -1.9 .. -1.5) | 0.29 m apart in depth, overlapping on screen |
| a1 deco 381 | deco `mine_bolt_plate` with deco `mine_upper_works_mass` (a1 deco 54) | -275.1, 38.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 383 | deco `mine_bolt_plate` with deco `mine_upper_works_mass` (a1 deco 54) | -280.8, 38.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 385 | deco `mine_bolt_plate` with deco `mine_upper_works_mass` (a1 deco 54) | -285.3, 38.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 387 | deco `mine_bolt_plate` with deco `mine_upper_works_mass` (a1 deco 54) | -289.8, 38.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 393 | deco `mine_post_tall` with deco `mine_upper_works_mass` (a1 deco 54) | -295.9, 37.7 (z -1.7 .. -1.3) | 0.11 m apart in depth, overlapping on screen |
| a1 deco 398 | deco `mine_lantern_bracket` with deco `mine_upper_works_mass` (a1 deco 54) | -288.5, 43.9 (z -1.4 .. -1.4) | 0.16 m apart in depth, overlapping on screen |
| a1 deco 399 | deco `lantern_hang` with deco `mine_upper_works_mass` (a1 deco 54) | -288.3, 43.6 (z -1.6 .. -1.3) | 0.08 m apart in depth, overlapping on screen |
| a1 deco 400 | deco `crate_ore` with deco `mine_upper_works_mass` (a1 deco 54) | -289.9, 40.9 (z -2.4 .. -1.3) | 0.12 m apart in depth, overlapping on screen |
| a1 deco 419 | deco `mine_ladder_snapped` with deco `mine_lining_derrumbe` (a1 deco 408) | -278.0, 51.9 (z -2.1 .. -2.1) | 0.27 m apart in depth, overlapping on screen |
| a1 deco 420 | deco `mine_ladder_snapped` with deco `mine_lining_derrumbe` (a1 deco 408) | -280.6, 54.3 (z -2.1 .. -2.1) | 0.26 m apart in depth, overlapping on screen |
| a1 deco 421 | deco `lantern_mine` with deco `mine_upper_works_mass` (a1 deco 54) | -280.8, 50.8 (z -1.9 .. -1.6) | 0.41 m apart in depth, overlapping on screen |
| a1 deco 435 | deco `mine_hand_winch` with deco `mine_upper_works_body` (a1 deco 57) | -282.5, 55.7 (z -2.4 .. -1.6) | 0.12 m apart in depth, overlapping on screen |
| a1 deco 436 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 45.9 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 439 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 47.1 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 442 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -281.7, 48.0 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 445 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -281.7, 49.4 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 448 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -281.7, 50.6 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 451 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 51.5 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 454 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 52.9 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 457 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -281.7, 53.8 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 460 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 55.0 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 461 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 56.4 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 462 | deco `sawn_end` with deco `mine_upper_works_mass` (a1 deco 54) | -276.9, 57.6 (z 1.2 .. 1.3) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 463 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -281.4, 48.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 464 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -277.2, 48.1 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 465 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -281.4, 51.6 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 466 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -277.2, 51.6 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 467 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -281.4, 53.8 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 468 | deco `mine_socket_empty` with deco `mine_upper_works_mass` (a1 deco 54) | -277.2, 53.8 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a1 deco 481 | deco `mine_fern_pale` with deco `mine_cortina_wall` (a1 deco 478) | -305.5, 48.1 (z -1.5 .. -1.4) | 0.13 m apart in depth, overlapping on screen |
| a1 deco 483 | deco `mine_fern_pale` with deco `mine_cortina_wall` (a1 deco 478) | -305.9, 58.6 (z -1.5 .. -1.4) | 0.13 m apart in depth, overlapping on screen |
| a1 deco 518 | deco `sign_pug_arrow` with deco `mine_upper_works_mass` (a1 deco 54) | -283.6, 56.1 (z -1.5 .. -1.3) | 0.11 m apart in depth, overlapping on screen |
| a1 deco 519 | deco `camp_bedroll` with deco `mine_upper_works_body` (a1 deco 57) | -286.7, 55.2 (z -2.2 .. -1.6) | 0.31 m apart in depth, overlapping on screen |
| a1 deco 520 | deco `cold_lantern` with deco `mine_upper_works_body` (a1 deco 57) | -285.2, 55.2 (z -2.0 .. -1.8) | 0.48 m apart in depth, overlapping on screen |
| a1 deco 521 | deco `pickaxe` with deco `mine_upper_works_body` (a1 deco 57) | -288.0, 55.1 (z -2.3 .. -2.1) | 0.26 m apart in depth, overlapping on screen |
| a1 deco 532 | deco `works_coping_face` with deco `mine_upper_works_mass` (a1 deco 54) | -288.0, 72.9 (z 1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |

### SKIN (22)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a1 deco 55 | deco `mine_throat_west` | -307.0, 9.5 (z -1.2 .. 1.2) | drawn -311.0 .. -303.0 x -54.0 .. 73.0, its solid -312.4 .. -303.0 x -54.0 .. 73.0 (1.40 m off) |
| a1 deco 53 | deco `mine_chamber_roof` | -240.2, 23.2 (z -1.2 .. 1.2) | drawn -273.5 .. -207.0 x 4.3 .. 42.0, its solid -273.5 .. -211.0 x 13.0 .. 42.0 (8.70 m off) |
| a1 deco 52 | deco `mine_east_mass` | -229.0, -24.9 (z -1.2 .. 1.2) | drawn -251.0 .. -207.0 x -54.0 .. 4.3, its solid -251.0 .. -207.0 x -54.0 .. 17.5 (13.17 m off) |
| a1 deco 438 | deco `mine_stub` | -277.8, 45.9 (z -1.2 .. 1.2) | drawn -278.2 .. -277.3 x 45.7 .. 46.0, its solid -278.2 .. -277.3 x 45.7 .. 47.3 (1.30 m off) |
| a1 deco 9 | deco `iron_staple` | -294.6, 56.3 (z -1.6 .. -1.4) | drawn -294.8 .. -294.4 x 56.3 .. 56.3, its solid -294.8 .. -293.1 x 56.1 .. 56.5 (1.31 m off) |
| a1 deco 11 | deco `iron_staple` | -294.4, 58.8 (z -1.6 .. -1.4) | drawn -294.6 .. -294.2 x 58.8 .. 58.8, its solid -294.6 .. -293.0 x 57.3 .. 60.3 (1.44 m off) |
| a1 deco 12 | deco `iron_staple` | -294.3, 60.0 (z -1.6 .. -1.4) | drawn -294.5 .. -294.1 x 60.0 .. 60.1, its solid -294.6 .. -292.8 x 58.6 .. 61.5 (1.44 m off) |
| a1 deco 13 | deco `iron_staple` | -294.2, 61.3 (z -1.6 .. -1.4) | drawn -294.4 .. -294.0 x 61.3 .. 61.3, its solid -294.5 .. -292.8 x 59.8 .. 61.5 (1.44 m off) |
| a1 deco 15 | deco `iron_staple` | -293.9, 63.8 (z -1.6 .. -1.4) | drawn -294.1 .. -293.7 x 63.8 .. 63.8, its solid -294.1 .. -292.4 x 62.3 .. 64.0 (1.44 m off) |
| a1 deco 17 | deco `iron_staple` | -293.7, 66.3 (z -1.6 .. -1.4) | drawn -293.9 .. -293.5 x 66.3 .. 66.3, its solid -293.9 .. -292.3 x 64.8 .. 67.8 (1.44 m off) |
| a1 deco 18 | deco `iron_staple` | -293.6, 67.5 (z -1.6 .. -1.4) | drawn -293.8 .. -293.4 x 67.5 .. 67.6, its solid -293.9 .. -292.1 x 66.1 .. 69.0 (1.44 m off) |
| a1 deco 19 | deco `iron_staple` | -293.5, 68.8 (z -1.6 .. -1.4) | drawn -293.7 .. -293.3 x 68.8 .. 68.8, its solid -293.8 .. -292.1 x 67.3 .. 69.0 (1.44 m off) |
| a1 deco 21 | deco `iron_staple` | -293.3, 71.3 (z -1.6 .. -1.4) | drawn -293.5 .. -293.1 x 71.3 .. 71.3, its solid -293.5 .. -291.9 x 69.8 .. 71.5 (1.44 m off) |
| a1 deco 23 | deco `iron_staple` | -293.3, 56.3 (z -1.6 .. -1.4) | drawn -293.5 .. -293.1 x 56.3 .. 56.3, its solid -294.8 .. -293.0 x 56.1 .. 57.8 (1.44 m off) |
| a1 deco 24 | deco `iron_staple` | -293.2, 57.5 (z -1.6 .. -1.4) | drawn -293.4 .. -293.0 x 57.5 .. 57.6, its solid -294.6 .. -293.0 x 56.1 .. 59.0 (1.44 m off) |
| a1 deco 26 | deco `iron_staple` | -293.0, 60.0 (z -1.6 .. -1.4) | drawn -293.2 .. -292.8 x 60.0 .. 60.1, its solid -294.5 .. -292.8 x 59.8 .. 61.5 (1.44 m off) |
| a1 deco 28 | deco `iron_staple` | -292.8, 62.5 (z -1.6 .. -1.4) | drawn -293.0 .. -292.5 x 62.5 .. 62.6, its solid -294.1 .. -292.4 x 62.3 .. 64.0 (1.44 m off) |
| a1 deco 29 | deco `iron_staple` | -292.6, 63.8 (z -1.6 .. -1.4) | drawn -292.8 .. -292.4 x 63.8 .. 63.8, its solid -294.1 .. -292.3 x 62.3 .. 65.3 (1.44 m off) |
| a1 deco 30 | deco `iron_staple` | -292.5, 65.0 (z -1.6 .. -1.4) | drawn -292.7 .. -292.3 x 65.0 .. 65.1, its solid -293.9 .. -292.3 x 63.6 .. 66.5 (1.44 m off) |
| a1 deco 32 | deco `iron_staple` | -292.3, 67.5 (z -1.6 .. -1.4) | drawn -292.5 .. -292.1 x 67.5 .. 67.6, its solid -293.8 .. -292.1 x 67.3 .. 69.0 (1.44 m off) |
| a1 deco 34 | deco `iron_staple` | -292.1, 70.0 (z -1.6 .. -1.4) | drawn -292.3 .. -291.9 x 70.0 .. 70.1, its solid -293.5 .. -291.9 x 69.8 .. 71.5 (1.44 m off) |
| a1 deco 20 | deco `iron_staple_bent` | -293.4, 70.1 (z -1.6 .. -1.3) | drawn -293.6 .. -293.1 x 70.0 .. 70.2, its solid -293.6 .. -291.8 x 69.8 .. 71.5 (1.37 m off) |

### CARD (8)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a1 card 1 | card `back3` | -247.0, 43.0 (z -10.0 .. -10.0) | a flat card of one tone, 3592 m2, at z -10.0 |
| a1 card 2 | card `back` | -310.5, 40.0 (z -4.0 .. -4.0) | a flat card of one tone, 509 m2, at z -4.0 |
| a1 card 3 | card `back` | -223.0, -17.0 (z -3.0 .. -3.0) | a flat card of one tone, 418 m2, at z -3.0 |
| a1 card 4 | card `slick` | -232.0, 28.0 (z 3.0 .. 3.0) | a flat card of one tone, 842 m2, at z 3.0 |
| a1 card 6 | card `back` | -218.0, 1.0 (z -4.0 .. -4.0) | a flat card of one tone, 252 m2, at z -4.0 |
| a1 card 8 | card `back` | -264.5, 81.2 (z -2.4 .. -2.4) | a flat card of one tone, 1162 m2, at z -2.4 |
| a1 card 9 | card `back3` | -288.9, 80.4 (z -2.3 .. -2.3) | a flat card of one tone, 18 m2, at z -2.3 |
| a1 card 10 | card `back3` | -261.8, 78.8 (z -2.3 .. -2.3) | a flat card of one tone, 17 m2, at z -2.3 |

## a2 Las Aguas Negras

### DEPTH (23)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a2 deco 62 | deco `aguas_works_lantern` with deco `aguas_borde_back_wall` (a2 deco 51) | -227.6, 93.4 (z -2.2 .. -2.0) | 0.11 m apart in depth, overlapping on screen |
| a2 deco 113 | deco `aguas_pipe_hanger` with deco `aguas_mill_core` (a2 deco 31) | -234.9, 113.9 (z -1.5 .. -1.3) | 0.07 m apart in depth, overlapping on screen |
| a2 deco 118 | deco `aguas_spout_face` with deco `aguas_mill_core` (a2 deco 31) | -236.8, 112.2 (z 1.2 .. 1.2) | 0.07 m apart in depth, overlapping on screen |
| a2 deco 137 | deco `aguas_crane_beam` with deco `aguas_desague_mass` (a2 deco 35) | -263.8, 127.9 (z -1.7 .. -1.3) | 0.15 m apart in depth, overlapping on screen |
| a2 deco 138 | deco `aguas_hoist_block` with deco `aguas_works_roof` (a2 deco 32) | -258.9, 127.2 (z -1.7 .. -1.3) | 0.12 m apart in depth, overlapping on screen |
| a2 deco 139 | deco `aguas_hoist_block` with deco `aguas_desague_mass` (a2 deco 35) | -265.3, 127.2 (z -1.7 .. -1.3) | 0.12 m apart in depth, overlapping on screen |
| a2 deco 140 | deco `aguas_hoist_block` with deco `aguas_desague_mass` (a2 deco 35) | -269.3, 127.2 (z -1.7 .. -1.3) | 0.12 m apart in depth, overlapping on screen |
| a2 deco 176 | deco `mine_lantern_bracket` with deco `aguas_flume_back_wall` (a2 deco 168) | -334.8, 121.2 (z -1.8 .. -1.7) | 0.37 m apart in depth, overlapping on screen |
| a2 deco 177 | deco `aguas_works_lantern` with deco `aguas_flume_back_wall` (a2 deco 168) | -334.6, 120.9 (z -1.9 .. -1.7) | 0.23 m apart in depth, overlapping on screen |
| a2 deco 178 | deco `mine_lantern_bracket` with deco `aguas_flume_back_wall` (a2 deco 168) | -323.8, 121.5 (z -1.8 .. -1.7) | 0.37 m apart in depth, overlapping on screen |
| a2 deco 179 | deco `aguas_works_lantern` with deco `aguas_flume_back_wall` (a2 deco 168) | -323.6, 121.2 (z -1.9 .. -1.7) | 0.23 m apart in depth, overlapping on screen |
| a2 deco 181 | deco `aguas_fern_wet` with deco `aguas_flume_back_wall` (a2 deco 168) | -342.6, 121.2 (z -2.0 .. -2.0) | 0.15 m apart in depth, overlapping on screen |
| a2 deco 226 | deco `aguas_lifting_beam` with deco `aguas_cascada_back_wall` (a2 deco 214) | -386.6, 157.6 (z -1.6 .. -1.2) | 0.97 m apart in depth, overlapping on screen |
| a2 deco 228 | deco `aguas_works_lantern` with deco `aguas_cascada_back_wall` (a2 deco 214) | -381.0, 141.3 (z -2.2 .. -2.0) | 0.28 m apart in depth, overlapping on screen |
| a2 deco 230 | deco `aguas_works_lantern` with deco `aguas_cascada_back_wall` (a2 deco 214) | -381.3, 156.0 (z -2.2 .. -2.0) | 0.28 m apart in depth, overlapping on screen |
| a2 deco 232 | deco `aguas_fern_wet` with deco `aguas_cascada_back_wall` (a2 deco 214) | -390.9, 147.0 (z -2.4 .. -2.4) | 0.10 m apart in depth, overlapping on screen |
| a2 deco 234 | deco `aguas_weed_tuft` with deco `aguas_cascada_back_wall` (a2 deco 214) | -383.2, 147.8 (z -2.4 .. -2.4) | 0.10 m apart in depth, overlapping on screen |
| a2 deco 237 | deco `aguas_catwalk_bracket` with deco `aguas_cascada_back_wall` (a2 deco 214) | -391.8, 152.3 (z -2.2 .. -1.3) | 0.32 m apart in depth, overlapping on screen |
| a2 deco 268 | deco `aguas_works_lantern` with deco `aguas_reach_back_wall` (a2 deco 235) | -406.3, 155.3 (z -1.8 .. -1.6) | 0.34 m apart in depth, overlapping on screen |
| a2 deco 270 | deco `aguas_works_lantern` with deco `aguas_reach_back_wall` (a2 deco 235) | -413.8, 155.3 (z -1.8 .. -1.6) | 0.34 m apart in depth, overlapping on screen |
| a2 deco 272 | deco `aguas_fern_wet` with deco `aguas_reach_back_wall` (a2 deco 235) | -419.6, 155.8 (z -2.0 .. -2.0) | 0.16 m apart in depth, overlapping on screen |
| a2 deco 294 | deco `aguas_crystal_point_small` with deco `aguas_presa_roof` (a2 deco 46) | -443.9, 172.8 (z -2.6 .. -1.7) | 0.50 m apart in depth, overlapping on screen |
| a2 deco 296 | deco `aguas_crystal_point_bright` with deco `aguas_presa_roof` (a2 deco 46) | -442.0, 172.8 (z -2.6 .. -1.7) | 0.55 m apart in depth, overlapping on screen |

### SKIN (18)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a2 deco 27 | deco `aguas_borde_pier` | -237.0, 89.1 (z -1.2 .. 1.1) | drawn -238.0 .. -236.0 x 86.0 .. 92.2, its solid -238.0 .. -236.0 x 89.4 .. 92.2 (3.40 m off) |
| a2 deco 0 | deco `aguas_ring_eyebolt` | -245.8, 103.4 (z -1.3 .. -0.0) | drawn -246.0 .. -245.5 x 103.1 .. 103.6, its solid -245.9 .. -244.3 x 103.2 .. 103.9 (1.22 m off) |
| a2 deco 1 | deco `aguas_ring_eyebolt` | -244.5, 103.7 (z -1.3 .. -0.0) | drawn -244.7 .. -244.3 x 103.5 .. 103.9, its solid -245.9 .. -244.3 x 103.2 .. 103.9 (1.20 m off) |
| a2 deco 2 | deco `aguas_ring_eyebolt` | -239.8, 103.8 (z -1.3 .. -0.0) | drawn -240.0 .. -239.5 x 103.5 .. 104.0, its solid -239.9 .. -238.3 x 103.5 .. 104.3 (1.22 m off) |
| a2 deco 3 | deco `aguas_ring_eyebolt` | -238.5, 104.1 (z -1.3 .. -0.0) | drawn -238.7 .. -238.3 x 103.9 .. 104.3, its solid -239.9 .. -238.3 x 103.5 .. 104.3 (1.20 m off) |
| a2 deco 4 | deco `aguas_ring_eyebolt` | -233.2, 104.2 (z -1.3 .. -0.0) | drawn -233.5 .. -233.0 x 103.9 .. 104.4, its solid -233.4 .. -232.1 x 104.0 .. 104.7 (0.92 m off) |
| a2 deco 5 | deco `aguas_ring_eyebolt` | -232.3, 104.5 (z -1.3 .. -0.0) | drawn -232.5 .. -232.1 x 104.3 .. 104.7, its solid -233.4 .. -232.1 x 104.0 .. 104.7 (0.90 m off) |
| a2 deco 6 | deco `rung_iron_rusted` | -246.5, 109.3 (z 0.0 .. 0.3) | drawn -246.9 .. -246.0 x 109.0 .. 109.6, its solid -246.6 .. -246.3 x 108.6 .. 109.5 (0.42 m off) |
| a2 deco 7 | deco `rung_iron_rusted` | -246.5, 108.9 (z 0.0 .. 0.3) | drawn -246.9 .. -246.0 x 108.6 .. 109.2, its solid -246.6 .. -246.3 x 108.6 .. 109.5 (0.31 m off) |
| a2 deco 8 | deco `rung_iron_rusted` | -246.5, 108.5 (z 0.0 .. 0.3) | drawn -246.9 .. -246.0 x 108.2 .. 108.8, its solid -246.6 .. -246.3 x 108.6 .. 109.5 (0.71 m off) |
| a2 deco 12 | deco `aguas_tread_end` | -385.6, 139.4 (z -0.2 .. 0.2) | drawn -385.9 .. -385.3 x 139.2 .. 139.6, its solid -386.9 .. -385.4 x 139.2 .. 140.7 (1.14 m off) |
| a2 deco 13 | deco `aguas_tread_end` | -386.7, 140.5 (z -0.2 .. 0.2) | drawn -387.0 .. -386.4 x 140.3 .. 140.7, its solid -388.1 .. -385.4 x 139.2 .. 141.7 (1.14 m off) |
| a2 deco 14 | deco `aguas_tread_end` | -387.9, 141.5 (z -0.2 .. 0.2) | drawn -388.2 .. -387.6 x 141.3 .. 141.7, its solid -389.0 .. -386.5 x 140.3 .. 143.0 (1.34 m off) |
| a2 deco 15 | deco `aguas_tread_end` | -388.8, 142.8 (z -0.2 .. 0.2) | drawn -389.1 .. -388.5 x 142.6 .. 143.0, its solid -389.0 .. -387.7 x 141.3 .. 143.0 (1.34 m off) |
| a2 deco 16 | deco `aguas_tread_end` | -388.0, 150.0 (z -0.2 .. 0.2) | drawn -388.3 .. -387.7 x 149.8 .. 150.2, its solid -389.4 .. -387.8 x 149.8 .. 151.3 (1.14 m off) |
| a2 deco 17 | deco `aguas_tread_end` | -389.2, 151.1 (z -0.2 .. 0.2) | drawn -389.5 .. -388.9 x 150.9 .. 151.3, its solid -390.6 .. -387.8 x 149.8 .. 152.4 (1.14 m off) |
| a2 deco 18 | deco `aguas_tread_end` | -390.4, 152.2 (z -0.2 .. 0.2) | drawn -390.7 .. -390.1 x 152.0 .. 152.4, its solid -390.6 .. -389.0 x 150.9 .. 152.4 (1.14 m off) |
| a2 deco 28 | deco `aguas_east_wall` | -227.5, 100.8 (z -1.2 .. 1.1) | drawn -232.0 .. -223.0 x 86.0 .. 115.6, its solid -232.0 .. -223.0 x 89.4 .. 115.6 (3.40 m off) |

### STANDIN (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a2 deco 306 | deco `aguas_shaft_rim` | -448.7, 176.3 (z -1.2 .. 1.2) | DRAWN, NOT SOLID: a skin with no solid of it under it (it looks like something to hold) |

## a3 La Gruta de Cristal

### ZFIGHT (3)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a3 deco 10 | deco `gruta_west_wall` with deco `gruta_floor_west` (a3 deco 2) | -460.5, 190.4 (z -1.2 .. 1.2) | front faces both at z 1.11, overlapping 0.04 m2 |
| a3 deco 8 | deco `gruta_roof_agujas` with deco `gruta_roof_pendulo` (a3 deco 7) | -401.8, 231.8 (z -1.2 .. 1.1) | front faces both at z 1.12, overlapping 0.05 m2 |
| a3 deco 7 | deco `gruta_roof_pendulo` with deco `gruta_roof_east` (a3 deco 6) | -360.2, 251.8 (z -1.2 .. 1.2) | front faces both at z 1.08, overlapping 0.44 m2 |

### SKIN (10)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a3 deco 59 | deco `gruta_nub` | -441.6, 190.8 (z -1.2 .. 1.2) | drawn -441.7 .. -441.4 x 190.6 .. 191.0, its solid -441.7 .. -440.3 x 190.0 .. 191.0 (1.03 m off) |
| a3 deco 64 | deco `gruta_nub` | -440.5, 190.2 (z -1.2 .. 1.2) | drawn -440.7 .. -440.3 x 190.0 .. 190.4, its solid -441.7 .. -440.3 x 190.0 .. 191.0 (1.03 m off) |
| a3 deco 119 | deco `gruta_crazed_plate` | -382.1, 223.2 (z -1.2 .. 1.2) | drawn -382.6 .. -381.6 x 223.1 .. 223.4, its solid -382.8 .. -381.6 x 223.1 .. 224.4 (1.05 m off) |
| a3 deco 120 | deco `gruta_crazed_plate` | -382.3, 224.3 (z -1.2 .. 1.2) | drawn -382.8 .. -381.8 x 224.2 .. 224.4, its solid -382.8 .. -380.3 x 223.1 .. 225.5 (1.47 m off) |
| a3 deco 121 | deco `gruta_crazed_plate` | -380.8, 225.3 (z -1.2 .. 1.2) | drawn -381.3 .. -380.3 x 225.2 .. 225.5, its solid -382.8 .. -380.3 x 224.2 .. 226.5 (1.47 m off) |
| a3 deco 122 | deco `gruta_crazed_plate` | -380.9, 226.4 (z -1.2 .. 1.2) | drawn -381.4 .. -380.4 x 226.3 .. 226.5, its solid -381.4 .. -379.0 x 225.2 .. 227.6 (1.46 m off) |
| a3 deco 123 | deco `gruta_crazed_plate` | -379.5, 227.5 (z -1.2 .. 1.2) | drawn -380.0 .. -379.0 x 227.3 .. 227.6, its solid -381.4 .. -379.0 x 226.3 .. 228.6 (1.46 m off) |
| a3 deco 124 | deco `gruta_crazed_plate` | -379.6, 228.5 (z -1.2 .. 1.2) | drawn -380.1 .. -379.1 x 228.4 .. 228.6, its solid -380.1 .. -377.6 x 227.3 .. 229.7 (1.47 m off) |
| a3 deco 125 | deco `gruta_crazed_plate` | -378.1, 229.6 (z -1.2 .. 1.2) | drawn -378.6 .. -377.6 x 229.4 .. 229.7, its solid -380.1 .. -377.6 x 228.4 .. 230.7 (1.47 m off) |
| a3 deco 126 | deco `gruta_crazed_plate` | -378.3, 230.6 (z -1.2 .. 1.2) | drawn -378.8 .. -377.8 x 230.5 .. 230.7, its solid -378.8 .. -377.6 x 229.4 .. 230.7 (1.05 m off) |

## a4 El Jardín de Hongos

### ZFIGHT (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a4 deco 6 | deco `jardin_floor_garden` with deco `jardin_pocket_wall` (a4 deco 5) | -202.6, 316.5 (z -1.2 .. 1.2) | front faces both at z 1.12, overlapping 0.66 m2 |

### DEPTH (2)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a4 deco 0 | deco `jardin_moss_blanket` with deco `jardin_stalk_4` (a4 deco 38) | -278.6, 265.6 (z -0.1 .. 0.7) | 0.61 m apart in depth, overlapping on screen |
| a4 deco 102 | deco `jardin_root_knee` with solid `rock` (a4 solid 45) | -213.9, 319.2 (z -2.5 .. -1.3) | 0.05 m apart in depth, overlapping on screen |

### SKIN (6)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a4 deco 17 | deco `jardin_terrace` | -245.3, 333.1 (z -1.2 .. 1.2) | drawn -266.0 .. -224.6 x 332.7 .. 333.6, its solid -266.0 .. -225.0 x 333.0 .. 333.6 (0.40 m off) |
| a4 mover snail1 | mover `snail_wall` | -228.8, 313.0 (z -0.4 .. 0.4) | model -0.2 .. 1.2 x -1.0 .. 1.6 against its shapes -0.2 .. 1.2 x -1.0 .. 1.1 (0.46 m off) |
| a4 mover snail2 | mover `snail_wall` | -227.8, 317.5 (z -0.4 .. 0.4) | model -0.2 .. 1.2 x -1.0 .. 1.6 against its shapes -0.2 .. 1.2 x -1.0 .. 1.1 (0.46 m off) |
| a4 mover snail3 | mover `snail_wall` | -226.9, 321.9 (z -0.4 .. 0.4) | model -0.2 .. 1.2 x -1.0 .. 1.6 against its shapes -0.2 .. 1.2 x -1.0 .. 1.1 (0.46 m off) |
| a4 mover snail4 | mover `snail_wall` | -226.0, 326.3 (z -0.4 .. 0.4) | model -0.2 .. 1.2 x -1.0 .. 1.6 against its shapes -0.2 .. 1.2 x -1.0 .. 1.1 (0.46 m off) |
| a4 mover snail5 | mover `snail_wall` | -225.1, 330.7 (z -0.4 .. 0.4) | model -0.2 .. 1.2 x -1.0 .. 1.6 against its shapes -0.2 .. 1.2 x -1.0 .. 1.1 (0.46 m off) |

## a5 El Templo del Primer Perro

### ZFIGHT (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a5 deco 262 | deco `templo_sill` with deco `templo_exit_door` (a5 deco 264) | -309.1, 479.6 (z -1.2 .. 1.2) | front faces both at z 1.17, overlapping 0.24 m2 |

### DEPTH (31)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a5 deco 40 | deco `templo_tier_true` with deco `templo_platform` (a5 deco 36) | -333.5, 368.0 (z -1.2 .. 1.1) | 0.08 m apart in depth, overlapping on screen |
| a5 deco 41 | deco `templo_tier_true` with deco `templo_platform` (a5 deco 36) | -339.5, 373.0 (z -1.2 .. 1.1) | 0.08 m apart in depth, overlapping on screen |
| a5 deco 99 | deco `torch_wall` with deco `templo_gear_back_wall` (a5 deco 100) | -370.6, 413.3 (z -2.2 .. -1.8) | 0.57 m apart in depth, overlapping on screen |
| a5 deco 108 | deco `templo_grease_trough` with deco `templo_gear_back_wall` (a5 deco 100) | -372.1, 414.0 (z -2.5 .. -1.9) | 0.27 m apart in depth, overlapping on screen |
| a5 deco 112 | deco `templo_ledge_block` with deco `templo_gear_back_wall` (a5 deco 100) | -373.2, 419.2 (z -2.6 .. -2.2) | 0.17 m apart in depth, overlapping on screen |
| a5 deco 113 | deco `templo_offering_sprig` with deco `templo_gear_back_wall` (a5 deco 100) | -373.2, 419.7 (z -2.6 .. -2.5) | 0.20 m apart in depth, overlapping on screen |
| a5 deco 118 | deco `templo_balcony` with deco `templo_balcony_back` (a5 deco 117) | -359.0, 429.5 (z -1.2 .. 1.2) | 0.05 m apart in depth, overlapping on screen |
| a5 deco 139 | deco `templo_plinth` with deco `templo_pilaster_short` (a5 deco 137) | -347.0, 430.4 (z -1.2 .. 1.1) | 0.10 m apart in depth, overlapping on screen |
| a5 deco 174 | deco `templo_arch_door` with deco `templo_upper_back_wall` (a5 deco 159) | -346.0, 455.0 (z -2.2 .. -1.3) | 0.41 m apart in depth, overlapping on screen |
| a5 deco 175 | deco `templo_arch_door` with deco `templo_upper_back_wall` (a5 deco 159) | -339.9, 455.0 (z -2.2 .. -1.3) | 0.41 m apart in depth, overlapping on screen |
| a5 deco 176 | deco `templo_arch_door` with deco `templo_upper_back_wall` (a5 deco 159) | -328.8, 455.0 (z -2.2 .. -1.3) | 0.41 m apart in depth, overlapping on screen |
| a5 deco 198 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -362.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 199 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -360.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 200 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -358.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 201 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -356.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 202 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -354.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 203 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -352.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 204 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -350.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 205 | deco `templo_ram_slot` with deco `templo_upper_back_wall` (a5 deco 159) | -348.0, 461.1 (z -2.4 .. -1.4) | 0.22 m apart in depth, overlapping on screen |
| a5 deco 215 | deco `templo_chain_boss` with deco `templo_west_wall` (a5 deco 18) | -363.5, 460.1 (z -2.0 .. -1.5) | 0.28 m apart in depth, overlapping on screen |
| a5 deco 229 | deco `templo_ledge_block` with deco `templo_upper_back_wall` (a5 deco 159) | -338.6, 470.2 (z -2.4 .. -2.0) | 0.17 m apart in depth, overlapping on screen |
| a5 deco 230 | deco `templo_offering_sprig` with deco `templo_upper_back_wall` (a5 deco 159) | -338.6, 470.7 (z -2.4 .. -2.3) | 0.20 m apart in depth, overlapping on screen |
| a5 deco 233 | deco `templo_axle_cheeks` with deco `templo_sun_stone` (a5 deco 232) | -318.0, 474.4 (z -2.5 .. -1.3) | 0.07 m apart in depth, overlapping on screen |
| a5 deco 236 | deco `templo_column` with deco `templo_upper_back_wall` (a5 deco 159) | -331.0, 470.9 (z -2.5 .. -1.4) | 0.07 m apart in depth, overlapping on screen |
| a5 deco 237 | deco `templo_column` with deco `templo_upper_back_wall` (a5 deco 159) | -324.2, 470.9 (z -2.5 .. -1.4) | 0.07 m apart in depth, overlapping on screen |
| a5 deco 239 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -322.0, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |
| a5 deco 240 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -320.5, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |
| a5 deco 241 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -318.9, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |
| a5 deco 242 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -317.4, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |
| a5 deco 243 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -315.9, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |
| a5 deco 244 | deco `templo_bracket` with deco `templo_altar_back_wall` (a5 deco 231) | -314.4, 468.1 (z -2.4 .. -1.3) | 0.97 m apart in depth, overlapping on screen |

### SKIN (30)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a5 deco 16 | deco `templo_gear_wall_west` | -374.8, 422.5 (z -1.2 .. 1.1) | drawn -377.5 .. -372.0 x 411.0 .. 434.0, its solid -377.5 .. -372.0 x 409.2 .. 434.0 (1.78 m off) |
| a5 deco 18 | deco `templo_west_wall` | -367.4, 451.7 (z -1.2 .. 1.1) | drawn -371.8 .. -363.0 x 434.0 .. 469.5, its solid -371.8 .. -366.0 x 434.0 .. 469.5 (2.98 m off) |
| a5 deco 69 | deco `templo_mask_tooth` | -359.3, 388.1 (z -1.3 .. 1.1) | drawn -359.6 .. -359.1 x 387.6 .. 388.6, its solid -359.6 .. -357.9 x 387.6 .. 388.6 (1.10 m off) |
| a5 deco 70 | deco `templo_mask_tooth` | -358.2, 388.1 (z -1.3 .. 1.1) | drawn -358.4 .. -357.9 x 387.6 .. 388.6, its solid -359.6 .. -356.9 x 387.6 .. 388.6 (1.10 m off) |
| a5 deco 71 | deco `templo_mask_tooth` | -357.1, 388.1 (z -1.3 .. 1.1) | drawn -357.4 .. -356.9 x 387.6 .. 388.6, its solid -358.4 .. -356.9 x 387.6 .. 388.6 (1.10 m off) |
| a5 deco 72 | deco `templo_mask_ring` | -358.9, 391.1 (z -1.3 .. 1.1) | drawn -359.1 .. -358.7 x 390.9 .. 391.4, its solid -359.1 .. -357.3 x 390.9 .. 391.4 (1.40 m off) |
| a5 deco 73 | deco `templo_mask_ring` | -357.5, 391.1 (z -1.3 .. 1.1) | drawn -357.7 .. -357.3 x 390.9 .. 391.4, its solid -359.1 .. -357.3 x 390.9 .. 391.4 (1.40 m off) |
| a5 deco 2 | deco `templo_bridge_slab` | -322.7, 468.6 (z -1.2 .. 1.2) | drawn -323.5 .. -322.0 x 468.4 .. 468.9, its solid -323.5 .. -320.5 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 3 | deco `templo_bridge_slab` | -321.2, 468.6 (z -1.2 .. 1.2) | drawn -322.0 .. -320.5 x 468.4 .. 468.9, its solid -323.5 .. -318.9 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 4 | deco `templo_bridge_slab` | -319.7, 468.6 (z -1.2 .. 1.2) | drawn -320.5 .. -318.9 x 468.4 .. 468.9, its solid -322.0 .. -317.4 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 5 | deco `templo_bridge_slab` | -318.2, 468.6 (z -1.2 .. 1.2) | drawn -319.0 .. -317.4 x 468.4 .. 468.9, its solid -320.5 .. -315.9 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 6 | deco `templo_bridge_slab` | -316.7, 468.6 (z -1.2 .. 1.2) | drawn -317.4 .. -315.9 x 468.4 .. 468.9, its solid -318.9 .. -314.4 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 7 | deco `templo_bridge_slab` | -315.2, 468.6 (z -1.2 .. 1.2) | drawn -315.9 .. -314.4 x 468.4 .. 468.9, its solid -317.4 .. -314.4 x 468.4 .. 468.9 (1.52 m off) |
| a5 deco 246 | deco `templo_peg` | -312.7, 469.4 (z -1.3 .. 1.1) | drawn -312.9 .. -312.5 x 469.1 .. 469.6, its solid -312.9 .. -312.5 x 469.1 .. 471.1 (1.40 m off) |
| a5 deco 247 | deco `templo_peg` | -312.7, 470.8 (z -1.3 .. 1.1) | drawn -312.9 .. -312.5 x 470.6 .. 471.1, its solid -312.9 .. -312.5 x 469.1 .. 472.4 (1.40 m off) |
| a5 deco 248 | deco `templo_peg` | -312.7, 472.2 (z -1.3 .. 1.1) | drawn -312.9 .. -312.5 x 471.9 .. 472.4, its solid -312.9 .. -312.5 x 470.6 .. 472.4 (1.40 m off) |
| a5 deco 8 | deco `templo_peg_cracked` | -312.7, 473.6 (z -1.2 .. 1.2) | drawn -312.9 .. -312.5 x 473.4 .. 473.8, its solid -312.9 .. -312.5 x 473.4 .. 475.1 (1.30 m off) |
| a5 deco 9 | deco `templo_peg_cracked` | -312.7, 474.9 (z -1.2 .. 1.2) | drawn -312.9 .. -312.5 x 474.7 .. 475.1, its solid -312.9 .. -312.5 x 473.4 .. 476.4 (1.30 m off) |
| a5 deco 10 | deco `templo_peg_cracked` | -312.7, 476.2 (z -1.2 .. 1.2) | drawn -312.9 .. -312.5 x 476.0 .. 476.4, its solid -312.9 .. -312.5 x 474.7 .. 477.7 (1.30 m off) |
| a5 deco 11 | deco `templo_peg_cracked` | -312.7, 477.5 (z -1.2 .. 1.2) | drawn -312.9 .. -312.5 x 477.3 .. 477.7, its solid -312.9 .. -312.5 x 476.0 .. 479.0 (1.30 m off) |
| a5 deco 12 | deco `templo_peg_cracked` | -312.7, 478.8 (z -1.2 .. 1.2) | drawn -312.9 .. -312.5 x 478.6 .. 479.0, its solid -312.9 .. -312.5 x 477.3 .. 479.0 (1.30 m off) |
| a5 mover vertebra1 | mover `serpent_segment_jade` | -362.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra2 | mover `serpent_segment_jade` | -360.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra3 | mover `serpent_segment_jade` | -358.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra4 | mover `serpent_segment_jade` | -356.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra5 | mover `serpent_segment_jade` | -354.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra6 | mover `serpent_segment_jade` | -352.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra7 | mover `serpent_segment_jade` | -350.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra8 | mover `serpent_segment_jade` | -348.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |
| a5 mover vertebra9 | mover `serpent_segment_jade` | -346.0, 459.8 (z -0.8 .. 0.8) | model -1.0 .. 1.0 x -0.6 .. 1.0 against its shapes -0.9 .. 0.9 x -0.6 .. 0.6 (0.39 m off) |

## a6 La Chimenea

### DEPTH (11)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a6 deco 12 | deco `iron_ring_pin_long` with deco `forja_grille_bar` (a6 deco 151) | -237.6, 548.2 (z -1.6 .. 0.1) | 0.19 m apart in depth, overlapping on screen |
| a6 deco 13 | deco `iron_ring_pin_long` with deco `forja_grille_bar` (a6 deco 151) | -240.1, 549.3 (z -1.6 .. 0.1) | 0.19 m apart in depth, overlapping on screen |
| a6 deco 60 | deco `forja_quench_trough` with deco `forja_floor` (a6 deco 21) | -243.2, 479.2 (z -2.2 .. -1.5) | 0.30 m apart in depth, overlapping on screen |
| a6 deco 61 | deco `forja_coal_heap` with deco `forja_floor` (a6 deco 21) | -248.7, 479.1 (z -2.4 .. -1.4) | 0.20 m apart in depth, overlapping on screen |
| a6 deco 68 | deco `forja_mask_tongue` with deco `forja_great_mask` (a6 deco 67) | -278.4, 485.8 (z -1.2 .. 1.2) | 0.10 m apart in depth, overlapping on screen |
| a6 deco 72 | deco `anvil_forja` with deco `forja_floor` (a6 deco 21) | -286.5, 480.1 (z -1.9 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a6 deco 103 | deco `forja_drive_rod` with deco `forja_cam_wheel` (a6 deco 100) | -272.9, 512.3 (z -1.5 .. -1.4) | 0.10 m apart in depth, overlapping on screen |
| a6 deco 133 | deco `forja_pier_landing` with deco `forja_hammer_pier` (a6 deco 129) | -257.7, 522.7 (z -1.2 .. 1.1) | 0.51 m apart in depth, overlapping on screen |
| a6 deco 148 | deco `forja_flap` with deco `forja_baffle` (a6 deco 147) | -242.0, 544.9 (z -2.2 .. -1.3) | 0.10 m apart in depth, overlapping on screen |
| a6 deco 158 | deco `steam_grate` with deco `forja_flue_pipe` (a6 deco 157) | -246.6, 557.1 (z -0.4 .. 0.4) | 0.94 m apart in depth, overlapping on screen |
| a6 deco 159 | deco `steam_grate` with deco `forja_flue_pipe` (a6 deco 157) | -248.4, 565.3 (z -0.4 .. 0.4) | 0.94 m apart in depth, overlapping on screen |

### SKIN (5)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a6 deco 5 | deco `forja_staple_long` | -286.0, 520.9 (z -1.4 .. -0.0) | drawn -286.4 .. -285.6 x 520.8 .. 521.0, its solid -286.4 .. -285.6 x 520.8 .. 522.1 (1.16 m off) |
| a6 deco 6 | deco `forja_staple_long` | -286.0, 522.0 (z -1.4 .. -0.0) | drawn -286.4 .. -285.6 x 521.9 .. 522.1, its solid -286.4 .. -285.6 x 520.8 .. 522.1 (1.16 m off) |
| a6 deco 18 | deco `forja_flint_knob` | -239.5, 577.2 (z -0.2 .. 0.2) | drawn -239.7 .. -239.3 x 577.0 .. 577.4, its solid -239.7 .. -238.2 x 577.0 .. 578.3 (1.07 m off) |
| a6 deco 19 | deco `forja_flint_knob` | -238.4, 578.1 (z -0.2 .. 0.2) | drawn -238.6 .. -238.2 x 577.9 .. 578.3, its solid -239.7 .. -237.3 x 577.0 .. 579.1 (1.07 m off) |
| a6 deco 20 | deco `forja_flint_knob` | -237.4, 578.9 (z -0.2 .. 0.2) | drawn -237.7 .. -237.2 x 578.7 .. 579.1, its solid -238.6 .. -237.3 x 577.9 .. 579.1 (0.92 m off) |

### CARD (5)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a6 card 0 | card `#2B1512` | -274.2, 492.2 (z -1.4 .. -1.4) | a flat card of one tone, 33 m2, at z -1.4 |
| a6 card 1 | card `back2` | -263.5, 531.0 (z -6.0 .. -6.0) | a flat card of one tone, 8148 m2, at z -6.0 |
| a6 card 3 | card `#58A8F0` | -240.8, 576.0 (z -5.0 .. -5.0) | a flat card of one tone, 10 m2, at z -5.0 |
| a6 card 4 | card `#58A8F0` | -237.2, 582.5 (z -5.0 .. -5.0) | a flat card of one tone, 32 m2, at z -5.0 |
| a6 card 5 | card `#CFC6B4` | -238.2, 557.6 (z -3.1 .. -3.1) | a flat card of one tone, 57 m2, at z -3.1 |

## a7 Los Riscos del Viento

### ZFIGHT (2)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a7 deco 133 | deco `riscos_face_body` with deco `riscos_arch_body` (a7 deco 134) | -249.8, 650.5 (z -3.0 .. -1.2) | front faces both at z -1.58, overlapping 0.45 m2 |
| a7 deco 134 | deco `riscos_arch_body` with deco `rock_fence_frame` (a7 deco 139) | -227.8, 638.1 (z -3.0 .. -1.2) | front faces both at z -1.66, overlapping 0.03 m2 |

### DEPTH (8)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a7 deco 80 | deco `dead_tree_crown` with deco `riscos_dead_tree` (a7 deco 79) | -228.5, 621.0 (z -1.7 .. -1.6) | 0.38 m apart in depth, overlapping on screen |
| a7 deco 85 | deco `riscos_far_bough` with deco `riscos_dead_tree` (a7 deco 79) | -234.9, 612.2 (z -1.9 .. -1.7) | 0.51 m apart in depth, overlapping on screen |
| a7 deco 86 | deco `riscos_far_bough` with deco `riscos_dead_tree` (a7 deco 79) | -232.0, 612.1 (z -2.0 .. -1.6) | 0.44 m apart in depth, overlapping on screen |
| a7 deco 87 | deco `riscos_far_bough` with deco `riscos_dead_tree` (a7 deco 79) | -233.3, 614.7 (z -1.9 .. -1.7) | 0.48 m apart in depth, overlapping on screen |
| a7 deco 88 | deco `riscos_far_bough` with deco `riscos_dead_tree` (a7 deco 79) | -230.4, 614.4 (z -1.9 .. -1.7) | 0.46 m apart in depth, overlapping on screen |
| a7 deco 91 | deco `riscos_deck_stub` with deco `riscos_bearer_strut` (a7 deco 95) | -219.2, 623.7 (z -0.5 .. 0.5) | 0.75 m apart in depth, overlapping on screen |
| a7 deco 190 | deco `riscos_snag` with deco `streamer_pole` (a7 deco 205) | -183.6, 656.9 (z -1.2 .. 1.1) | 0.16 m apart in depth, overlapping on screen |
| a7 deco 205 | deco `streamer_pole` with deco `riscos_snag` (a7 deco 190) | -185.1, 654.8 (z -1.4 .. -1.4) | 0.16 m apart in depth, overlapping on screen |

### SKIN (22)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a7 deco 208 | deco `ex_riscos_tower_top` | -206.8, 667.2 (z -3.6 .. 1.2) | drawn -211.8 .. -201.9 x 656.0 .. 678.4, its solid -210.0 .. -202.5 x 658.0 .. 676.5 (2.00 m off) |
| a7 deco 91 | deco `riscos_deck_stub` | -219.2, 623.7 (z -0.5 .. 0.5) | drawn -220.0 .. -218.5 x 623.4 .. 624.0, its solid -220.0 .. -218.5 x 623.8 .. 624.0 (0.30 m off) |
| a7 deco 92 | deco `riscos_deck_stub` | -210.8, 623.7 (z -0.5 .. 0.5) | drawn -211.5 .. -210.0 x 623.4 .. 624.0, its solid -211.5 .. -210.0 x 623.8 .. 624.0 (0.30 m off) |
| a7 deco 16 | deco `forja_flint_knob` | -196.8, 627.2 (z -0.2 .. 0.2) | drawn -197.0 .. -196.6 x 627.0 .. 627.4, its solid -197.0 .. -195.4 x 627.0 .. 627.6 (1.19 m off) |
| a7 deco 17 | deco `forja_flint_knob` | -195.6, 627.3 (z -0.2 .. 0.2) | drawn -195.8 .. -195.4 x 627.1 .. 627.5, its solid -197.0 .. -195.4 x 627.0 .. 627.6 (1.19 m off) |
| a7 deco 24 | deco `forja_flint_knob` | -233.3, 637.1 (z -0.2 .. 0.2) | drawn -233.5 .. -233.1 x 636.9 .. 637.3, its solid -234.7 .. -233.1 x 636.9 .. 638.7 (1.36 m off) |
| a7 deco 25 | deco `forja_flint_knob` | -238.6, 643.5 (z -0.2 .. 0.2) | drawn -238.8 .. -238.4 x 643.3 .. 643.7, its solid -240.1 .. -238.4 x 643.3 .. 645.0 (1.36 m off) |
| a7 deco 26 | deco `forja_flint_knob` | -229.2, 632.1 (z -0.2 .. 0.2) | drawn -229.4 .. -229.0 x 631.9 .. 632.3, its solid -230.7 .. -229.0 x 631.9 .. 633.3 (1.29 m off) |
| a7 deco 27 | deco `forja_flint_knob` | -230.5, 633.0 (z -0.2 .. 0.2) | drawn -230.7 .. -230.3 x 632.8 .. 633.2, its solid -232.0 .. -229.0 x 631.9 .. 634.2 (1.29 m off) |
| a7 deco 28 | deco `forja_flint_knob` | -231.8, 633.9 (z -0.2 .. 0.2) | drawn -232.0 .. -231.6 x 633.7 .. 634.1, its solid -232.0 .. -230.3 x 632.8 .. 634.2 (1.29 m off) |
| a7 deco 29 | deco `forja_flint_knob` | -234.5, 638.5 (z -0.2 .. 0.2) | drawn -234.7 .. -234.3 x 638.3 .. 638.7, its solid -236.0 .. -233.1 x 636.9 .. 639.6 (1.32 m off) |
| a7 deco 30 | deco `forja_flint_knob` | -235.8, 639.4 (z -0.2 .. 0.2) | drawn -236.0 .. -235.6 x 639.2 .. 639.6, its solid -237.3 .. -234.3 x 638.3 .. 640.5 (1.29 m off) |
| a7 deco 31 | deco `forja_flint_knob` | -237.1, 640.3 (z -0.2 .. 0.2) | drawn -237.3 .. -236.9 x 640.1 .. 640.5, its solid -237.3 .. -235.6 x 639.2 .. 640.5 (1.29 m off) |
| a7 deco 32 | deco `forja_flint_knob` | -239.9, 644.8 (z -0.2 .. 0.2) | drawn -240.1 .. -239.7 x 644.6 .. 645.0, its solid -241.4 .. -238.4 x 643.3 .. 645.9 (1.32 m off) |
| a7 deco 33 | deco `forja_flint_knob` | -241.2, 645.7 (z -0.2 .. 0.2) | drawn -241.4 .. -241.0 x 645.5 .. 645.9, its solid -242.7 .. -239.7 x 644.6 .. 646.8 (1.29 m off) |
| a7 deco 34 | deco `forja_flint_knob` | -242.5, 646.6 (z -0.2 .. 0.2) | drawn -242.7 .. -242.3 x 646.4 .. 646.8, its solid -242.7 .. -241.0 x 645.5 .. 646.8 (1.29 m off) |
| a7 mover vulture1 | mover `vulture_flying` | -211.0, 592.2 (z -0.2 .. 0.4) | model -1.4 .. 1.4 x -0.5 .. 1.0 against its shapes -0.6 .. 0.6 x -0.5 .. 0.7 (0.89 m off) |
| a7 mover vulture2 | mover `vulture_flying` | -211.0, 592.2 (z -0.2 .. 0.4) | model -1.4 .. 1.4 x -0.5 .. 1.0 against its shapes -0.6 .. 0.6 x -0.5 .. 0.7 (0.89 m off) |
| a7 mover burro1 | mover `burro` | -247.6, 648.4 (z -0.3 .. 0.3) | model -0.9 .. 0.9 x 0.0 .. 1.5 against its shapes -1.1 .. 0.7 x 0.0 .. 1.2 (0.30 m off) |
| a7 mover burro2 | mover `burro` | -233.3, 650.8 (z -0.3 .. 0.3) | model -0.9 .. 0.9 x 0.0 .. 1.5 against its shapes -1.1 .. 0.7 x 0.0 .. 1.2 (0.30 m off) |
| a7 mover burro3 | mover `burro` | -223.3, 653.0 (z -0.3 .. 0.3) | model -0.9 .. 0.9 x 0.0 .. 1.5 against its shapes -1.1 .. 0.7 x 0.0 .. 1.2 (0.30 m off) |
| a7 mover vulture3 | mover `vulture_flying` | -203.2, 656.2 (z -0.2 .. 0.4) | model -1.4 .. 1.4 x -0.5 .. 1.0 against its shapes -0.6 .. 0.6 x -0.5 .. 0.7 (0.89 m off) |

## a8 El Teleférico

### ZFIGHT (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a8 deco 6 | deco `tele_face_b` with deco `tele_face_a` (a8 deco 5) | -263.9, 714.3 (z -1.2 .. 1.2) | front faces both at z 1.15, overlapping 0.39 m2 |

### DEPTH (16)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a8 deco 21 | deco `tele_cable_short` with deco `tele_lattice_bay` (a8 deco 72) | -228.4, 697.7 (z -2.1 .. -1.9) | 0.43 m apart in depth, overlapping on screen |
| a8 deco 24 | deco `tele_cable_short` with deco `tele_belt` (a8 deco 35) | -231.4, 699.9 (z -2.1 .. -1.9) | 0.50 m apart in depth, overlapping on screen |
| a8 deco 36 | deco `tele_guide_wheel` with deco `tele_end_frame` (a8 deco 15) | -233.0, 688.6 (z -2.4 .. -2.2) | 0.14 m apart in depth, overlapping on screen |
| a8 deco 63 | deco `pennant_line` with deco `tele_lattice_bay` (a8 deco 40) | -239.2, 703.8 (z -2.3 .. -2.3) | 0.19 m apart in depth, overlapping on screen |
| a8 deco 116 | deco `tele_cable_short` with deco `tele_lattice_bay` (a8 deco 108) | -210.4, 699.1 (z -2.1 .. -1.9) | 0.43 m apart in depth, overlapping on screen |
| a8 deco 119 | deco `tele_cable_short` with deco `tele_belt_crossed` (a8 deco 129) | -213.4, 701.3 (z -2.1 .. -1.9) | 0.27 m apart in depth, overlapping on screen |
| a8 deco 135 | deco `tele_cable_snapped` with deco `tele_span_arm` (a8 deco 134) | -207.1, 710.3 (z -2.2 .. -2.0) | 0.15 m apart in depth, overlapping on screen |
| a8 deco 152 | deco `tele_landing` with deco `tele_lattice_bay` (a8 deco 145) | -193.3, 702.9 (z -1.8 .. 1.2) | 0.71 m apart in depth, overlapping on screen |
| a8 deco 153 | deco `oil_can` with deco `tele_lattice_bay` (a8 deco 145) | -191.6, 703.2 (z -1.5 .. -1.3) | 0.95 m apart in depth, overlapping on screen |
| a8 deco 154 | deco `tele_grease_pot` with deco `tele_lattice_bay` (a8 deco 145) | -192.2, 703.2 (z -1.7 .. -1.3) | 0.85 m apart in depth, overlapping on screen |
| a8 deco 160 | deco `tele_belt` with deco `tele_cable` (a8 deco 205) | -192.5, 725.9 (z -2.5 .. -2.4) | 0.36 m apart in depth, overlapping on screen |
| a8 deco 202 | deco `tele_cable_short` with deco `streamer_pole` (a8 deco 201) | -165.2, 728.1 (z -2.1 .. -1.9) | 0.36 m apart in depth, overlapping on screen |
| a8 deco 205 | deco `tele_cable` with deco `tele_belt` (a8 deco 160) | -188.5, 723.9 (z -2.1 .. -1.9) | 0.36 m apart in depth, overlapping on screen |
| a8 deco 222 | deco `tele_cable` with deco `tele_lattice_bay` (a8 deco 211) | -197.1, 725.5 (z -2.1 .. -1.9) | 0.44 m apart in depth, overlapping on screen |
| a8 deco 223 | deco `tele_cable` with deco `tele_lattice_bay` (a8 deco 213) | -197.1, 734.6 (z -2.1 .. -1.9) | 0.44 m apart in depth, overlapping on screen |
| a8 deco 224 | deco `tele_cable` with deco `tele_lattice_bay` (a8 deco 216) | -197.1, 743.8 (z -2.1 .. -1.9) | 0.44 m apart in depth, overlapping on screen |

### SKIN (13)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a8 deco 5 | deco `tele_face_a` | -257.7, 694.0 (z -1.2 .. 1.2) | drawn -264.3 .. -251.0 x 684.0 .. 704.0, its solid -264.3 .. -251.0 x 681.8 .. 704.0 (2.20 m off) |
| a8 deco 11 | deco `tele_gangway` | -238.0, 688.9 (z -1.2 .. 1.2) | drawn -240.0 .. -236.0 x 688.0 .. 689.9, its solid -240.0 .. -236.7 x 688.0 .. 689.9 (0.70 m off) |
| a8 deco 12 | deco `tele_roof_low` | -244.3, 693.4 (z -5.5 .. 1.2) | drawn -251.0 .. -237.6 x 692.5 .. 694.3, its solid -251.0 .. -237.6 x 692.5 .. 692.8 (1.50 m off) |
| a8 deco 186 | deco `tele_chalk_block` | -175.8, 713.7 (z -1.2 .. 1.2) | drawn -176.1 .. -175.6 x 713.5 .. 713.9, its solid -176.3 .. -175.7 x 713.5 .. 715.1 (1.27 m off) |
| a8 deco 187 | deco `tele_chalk_block` | -176.2, 715.0 (z -1.2 .. 1.2) | drawn -176.4 .. -175.9 x 714.8 .. 715.2, its solid -176.3 .. -175.7 x 713.5 .. 715.1 (1.27 m off) |
| a8 deco 194 | deco `tele_chalk_block` | -167.5, 723.5 (z -1.2 .. 1.2) | drawn -167.7 .. -167.3 x 723.3 .. 723.7, its solid -167.7 .. -166.1 x 723.3 .. 724.8 (1.28 m off) |
| a8 deco 195 | deco `tele_chalk_block` | -166.2, 724.6 (z -1.2 .. 1.2) | drawn -166.4 .. -166.0 x 724.4 .. 724.8, its solid -167.7 .. -166.1 x 723.3 .. 724.8 (1.28 m off) |
| a8 deco 333 | deco `tele_roof_high` | -274.7, 791.4 (z -5.5 .. 1.2) | drawn -281.4 .. -268.0 x 790.5 .. 792.3, its solid -281.4 .. -268.0 x 790.5 .. 791.0 (1.35 m off) |
| a8 mover chair1 | mover `chair_tele` | -188.5, 714.9 (z -2.1 .. 0.4) | model -0.6 .. 0.6 x -3.3 .. 0.1 against its shapes -0.6 .. 0.6 x -3.3 .. -3.1 (3.19 m off) |
| a8 mover chair2 | mover `chair_tele` | -184.6, 712.3 (z -2.1 .. 0.4) | model -0.6 .. 0.6 x -3.3 .. 0.1 against its shapes -0.6 .. 0.6 x -3.3 .. -3.1 (3.19 m off) |
| a8 mover chair3 | mover `chair_tele` | -180.7, 709.7 (z -2.1 .. 0.4) | model -0.6 .. 0.6 x -3.3 .. 0.1 against its shapes -0.6 .. 0.6 x -3.3 .. -3.1 (3.19 m off) |
| a8 mover chair4 | mover `chair_tele` | -176.8, 707.1 (z -2.1 .. 0.4) | model -0.6 .. 0.6 x -3.3 .. 0.1 against its shapes -0.6 .. 0.6 x -3.3 .. -3.1 (3.19 m off) |
| a8 mover zip | mover `zip_trolley_tele` | -166.2, 727.8 (z -2.1 .. 0.1) | model -0.3 .. 0.3 x -1.0 .. 0.4 against its shapes -0.3 .. 0.3 x -1.0 .. 0.0 (0.38 m off) |

## a9 El Glaciar

### DEPTH (12)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a9 deco 7 | deco `icicle_row` with deco `glaciar_tunnel_back_wall` (a9 deco 5) | -275.4, 789.9 (z -1.7 .. -1.4) | 0.67 m apart in depth, overlapping on screen |
| a9 deco 9 | deco `glaciar_lantern_hook` with deco `glaciar_tunnel_back_wall` (a9 deco 5) | -286.1, 789.8 (z -1.9 .. -0.7) | 0.51 m apart in depth, overlapping on screen |
| a9 deco 29 | deco `sign_pug_arrow_east` with deco `glaciar_crack_back_wall` (a9 deco 12) | -330.0, 799.3 (z -1.6 .. -1.4) | 0.87 m apart in depth, overlapping on screen |
| a9 deco 31 | deco `glaciar_shelf_fallen` with deco `glaciar_crack_back_wall` (a9 deco 12) | -315.1, 786.9 (z -2.3 .. -1.3) | 0.14 m apart in depth, overlapping on screen |
| a9 deco 56 | deco `glaciar_lantern_hook` with deco `glaciar_cave_back_wall` (a9 deco 57) | -301.3, 807.8 (z -1.9 .. -0.7) | 0.54 m apart in depth, overlapping on screen |
| a9 deco 72 | deco `glaciar_lantern_hook` with deco `glaciar_balcony_back_wall` (a9 deco 60) | -328.6, 814.7 (z -1.9 .. -0.7) | 0.53 m apart in depth, overlapping on screen |
| a9 deco 77 | deco `glove_frozen` with deco `glaciar_cave_back_wall` (a9 deco 57) | -300.3, 804.1 (z -1.5 .. -1.4) | 0.89 m apart in depth, overlapping on screen |
| a9 deco 91 | deco `glaciar_pit_funnel` with deco `glaciar_pit_jam` (a9 deco 93) | -322.1, 821.2 (z -1.2 .. 1.2) | 0.20 m apart in depth, overlapping on screen |
| a9 deco 94 | deco `ice_axe` with deco `glaciar_upper_back_wall` (a9 deco 87) | -326.9, 832.3 (z -1.5 .. -1.5) | 0.88 m apart in depth, overlapping on screen |
| a9 deco 95 | deco `rope_coil_frozen` with deco `glaciar_upper_back_wall` (a9 deco 87) | -326.2, 832.1 (z -1.9 .. -1.3) | 0.54 m apart in depth, overlapping on screen |
| a9 deco 102 | deco `ice_axe` with deco `glaciar_cave_back_wall` (a9 deco 57) | -285.8, 830.5 (z -1.5 .. -1.5) | 0.89 m apart in depth, overlapping on screen |
| a9 deco 103 | deco `rope_coil_frozen` with deco `glaciar_cave_back_wall` (a9 deco 57) | -285.1, 830.3 (z -1.9 .. -1.3) | 0.55 m apart in depth, overlapping on screen |

### SKIN (45)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a9 deco 13 | deco `glaciar_knuckle` | -308.2, 787.5 (z -0.3 .. 0.3) | drawn -308.5 .. -307.8 x 787.3 .. 787.8, its solid -309.6 .. -307.8 x 787.3 .. 789.1 (1.34 m off) |
| a9 deco 14 | deco `glaciar_knuckle` | -309.2, 788.8 (z -0.3 .. 0.3) | drawn -309.6 .. -308.8 x 788.6 .. 789.1, its solid -309.6 .. -307.8 x 787.3 .. 789.1 (1.31 m off) |
| a9 deco 16 | deco `glaciar_knuckle` | -311.9, 790.3 (z -0.3 .. 0.3) | drawn -312.3 .. -311.5 x 790.1 .. 790.6, its solid -313.9 .. -311.5 x 790.1 .. 790.7 (1.67 m off) |
| a9 deco 17 | deco `glaciar_knuckle` | -313.6, 790.5 (z -0.3 .. 0.3) | drawn -313.9 .. -313.2 x 790.2 .. 790.7, its solid -315.0 .. -311.5 x 790.1 .. 792.1 (1.68 m off) |
| a9 deco 18 | deco `glaciar_knuckle` | -314.6, 791.8 (z -0.3 .. 0.3) | drawn -315.0 .. -314.2 x 791.5 .. 792.1, its solid -315.0 .. -313.2 x 790.2 .. 792.1 (1.31 m off) |
| a9 deco 20 | deco `glaciar_knuckle` | -317.3, 793.3 (z -0.3 .. 0.3) | drawn -317.7 .. -317.0 x 793.0 .. 793.6, its solid -319.4 .. -317.0 x 793.0 .. 793.7 (1.67 m off) |
| a9 deco 21 | deco `glaciar_knuckle` | -319.0, 793.5 (z -0.3 .. 0.3) | drawn -319.4 .. -318.6 x 793.2 .. 793.7, its solid -320.4 .. -317.0 x 793.0 .. 795.0 (1.68 m off) |
| a9 deco 22 | deco `glaciar_knuckle` | -320.0, 794.8 (z -0.3 .. 0.3) | drawn -320.4 .. -319.7 x 794.5 .. 795.0, its solid -322.1 .. -318.6 x 793.2 .. 795.2 (1.67 m off) |
| a9 deco 23 | deco `glaciar_knuckle` | -321.7, 794.9 (z -0.3 .. 0.3) | drawn -322.1 .. -321.3 x 794.7 .. 795.2, its solid -322.1 .. -319.7 x 794.5 .. 795.2 (1.68 m off) |
| a9 deco 25 | deco `glaciar_knuckle` | -324.4, 796.4 (z -0.3 .. 0.3) | drawn -324.8 .. -324.0 x 796.2 .. 796.7, its solid -325.8 .. -324.0 x 796.2 .. 798.0 (1.34 m off) |
| a9 deco 26 | deco `glaciar_knuckle` | -325.4, 797.7 (z -0.3 .. 0.3) | drawn -325.8 .. -325.1 x 797.5 .. 798.0, its solid -327.5 .. -324.0 x 796.2 .. 798.2 (1.67 m off) |
| a9 deco 27 | deco `glaciar_knuckle` | -327.1, 797.9 (z -0.3 .. 0.3) | drawn -327.5 .. -326.8 x 797.7 .. 798.2, its solid -327.5 .. -325.1 x 797.5 .. 798.2 (1.68 m off) |
| a9 deco 44 | deco `glaciar_snow_bridge` | -317.2, 803.8 (z -2.4 .. 1.2) | drawn -317.8 .. -316.7 x 803.5 .. 804.0, its solid -317.8 .. -315.6 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 45 | deco `glaciar_snow_bridge` | -316.1, 803.6 (z -2.4 .. 1.2) | drawn -316.6 .. -315.6 x 803.4 .. 803.8, its solid -317.8 .. -314.4 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 46 | deco `glaciar_snow_bridge` | -315.0, 803.8 (z -2.4 .. 1.2) | drawn -315.5 .. -314.4 x 803.5 .. 804.0, its solid -316.6 .. -314.4 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 47 | deco `glaciar_snow_bridge` | -312.8, 803.8 (z -2.4 .. 1.2) | drawn -313.3 .. -312.2 x 803.5 .. 804.0, its solid -313.3 .. -311.1 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 48 | deco `glaciar_snow_bridge` | -311.6, 803.6 (z -2.4 .. 1.2) | drawn -312.1 .. -311.1 x 803.4 .. 803.8, its solid -313.3 .. -309.9 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 49 | deco `glaciar_snow_bridge` | -310.5, 803.8 (z -2.4 .. 1.2) | drawn -311.0 .. -309.9 x 803.5 .. 804.0, its solid -312.1 .. -309.9 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 50 | deco `glaciar_snow_bridge` | -308.2, 803.8 (z -2.4 .. 1.2) | drawn -308.8 .. -307.7 x 803.5 .. 804.0, its solid -308.8 .. -306.6 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 51 | deco `glaciar_snow_bridge` | -307.1, 803.6 (z -2.4 .. 1.2) | drawn -307.6 .. -306.6 x 803.4 .. 803.8, its solid -308.8 .. -305.4 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 52 | deco `glaciar_snow_bridge` | -306.0, 803.8 (z -2.4 .. 1.2) | drawn -306.5 .. -305.4 x 803.5 .. 804.0, its solid -307.6 .. -305.4 x 803.4 .. 804.0 (1.14 m off) |
| a9 deco 67 | deco `glaciar_knuckle_short` | -328.7, 816.9 (z -0.3 .. 0.3) | drawn -329.0 .. -328.4 x 816.7 .. 817.1, its solid -330.2 .. -328.4 x 816.7 .. 818.4 (1.31 m off) |
| a9 deco 68 | deco `glaciar_knuckle_short` | -329.9, 818.2 (z -0.3 .. 0.3) | drawn -330.2 .. -329.6 x 818.0 .. 818.4, its solid -330.2 .. -328.4 x 816.7 .. 818.4 (1.29 m off) |
| a9 deco 119 | deco `glaciar_nub` | -282.2, 843.8 (z -0.3 .. 0.3) | drawn -282.5 .. -282.0 x 843.6 .. 844.0, its solid -282.5 .. -282.0 x 843.6 .. 845.4 (1.40 m off) |
| a9 deco 120 | deco `glaciar_nub` | -282.2, 845.2 (z -0.3 .. 0.3) | drawn -282.5 .. -282.0 x 845.0 .. 845.4, its solid -282.5 .. -282.0 x 843.6 .. 845.4 (1.40 m off) |
| a9 deco 126 | deco `glaciar_nub` | -280.7, 849.9 (z -0.3 .. 0.3) | drawn -280.9 .. -280.5 x 849.6 .. 850.1, its solid -280.9 .. -279.4 x 849.6 .. 850.2 (1.10 m off) |
| a9 deco 127 | deco `glaciar_nub` | -279.6, 850.0 (z -0.3 .. 0.3) | drawn -279.8 .. -279.4 x 849.7 .. 850.2, its solid -280.9 .. -278.4 x 849.6 .. 850.6 (1.10 m off) |
| a9 deco 128 | deco `glaciar_nub` | -278.6, 850.4 (z -0.3 .. 0.3) | drawn -278.8 .. -278.4 x 850.2 .. 850.6, its solid -279.8 .. -278.4 x 849.7 .. 850.6 (0.98 m off) |
| a9 deco 151 | deco `glaciar_nub` | -295.2, 871.5 (z -0.3 .. 0.3) | drawn -295.4 .. -295.0 x 871.2 .. 871.8, its solid -296.4 .. -295.0 x 871.2 .. 872.9 (1.10 m off) |
| a9 deco 152 | deco `glaciar_nub` | -296.2, 872.6 (z -0.3 .. 0.3) | drawn -296.4 .. -296.0 x 872.4 .. 872.9, its solid -296.4 .. -295.0 x 871.2 .. 872.9 (1.10 m off) |
| a9 deco 159 | deco `glaciar_nub` | -296.2, 878.6 (z -0.3 .. 0.3) | drawn -296.4 .. -296.0 x 878.4 .. 878.8, its solid -296.4 .. -296.0 x 878.4 .. 880.1 (1.30 m off) |
| a9 deco 160 | deco `glaciar_nub` | -296.2, 879.9 (z -0.3 .. 0.3) | drawn -296.4 .. -296.0 x 879.7 .. 880.1, its solid -296.4 .. -296.0 x 878.4 .. 880.1 (1.30 m off) |
| a9 deco 112 | deco `glaciar_plate` | -279.9, 835.0 (z -0.2 .. 0.2) | drawn -280.3 .. -279.5 x 834.7 .. 835.3, its solid -281.6 .. -279.5 x 834.7 .. 836.2 (1.29 m off) |
| a9 deco 113 | deco `glaciar_plate` | -281.2, 835.9 (z -0.2 .. 0.2) | drawn -281.6 .. -280.8 x 835.6 .. 836.2, its solid -282.6 .. -279.5 x 834.7 .. 836.9 (1.29 m off) |
| a9 deco 114 | deco `glaciar_plate` | -282.2, 836.6 (z -0.2 .. 0.2) | drawn -282.6 .. -281.8 x 836.3 .. 836.9, its solid -282.6 .. -280.8 x 835.6 .. 836.9 (0.99 m off) |
| a9 deco 129 | deco `glaciar_plate` | -279.6, 851.6 (z -0.2 .. 0.2) | drawn -279.9 .. -279.2 x 851.2 .. 851.9, its solid -280.6 .. -279.2 x 851.2 .. 852.8 (0.92 m off) |
| a9 deco 130 | deco `glaciar_plate` | -280.3, 852.5 (z -0.2 .. 0.2) | drawn -280.6 .. -280.0 x 852.1 .. 852.8, its solid -280.6 .. -279.2 x 851.2 .. 852.8 (0.92 m off) |
| a9 deco 131 | deco `glaciar_plate` | -281.0, 854.4 (z -0.2 .. 0.2) | drawn -281.3 .. -280.6 x 854.1 .. 854.7, its solid -282.5 .. -280.6 x 854.1 .. 855.6 (1.17 m off) |
| a9 deco 132 | deco `glaciar_plate` | -282.1, 855.3 (z -0.2 .. 0.2) | drawn -282.5 .. -281.8 x 855.0 .. 855.6, its solid -283.6 .. -280.6 x 854.1 .. 856.4 (1.17 m off) |
| a9 deco 133 | deco `glaciar_plate` | -283.3, 856.1 (z -0.2 .. 0.2) | drawn -283.7 .. -282.9 x 855.8 .. 856.4, its solid -283.6 .. -281.8 x 855.0 .. 856.4 (1.16 m off) |
| a9 deco 134 | deco `glaciar_plate` | -284.1, 858.1 (z -0.2 .. 0.2) | drawn -284.4 .. -283.7 x 857.8 .. 858.4, its solid -285.6 .. -283.7 x 857.8 .. 859.3 (1.17 m off) |
| a9 deco 135 | deco `glaciar_plate` | -285.2, 859.0 (z -0.2 .. 0.2) | drawn -285.6 .. -284.9 x 858.6 .. 859.3, its solid -286.7 .. -283.7 x 857.8 .. 860.1 (1.17 m off) |
| a9 deco 136 | deco `glaciar_plate` | -286.4, 859.8 (z -0.2 .. 0.2) | drawn -286.7 .. -286.0 x 859.5 .. 860.1, its solid -286.7 .. -284.9 x 858.6 .. 860.1 (1.16 m off) |
| a9 deco 123 | deco `glaciar_long_stone` | -281.7, 854.6 (z -1.2 .. 1.1) | drawn -283.5 .. -279.8 x 853.1 .. 856.2, its solid -286.6 .. -279.8 x 853.1 .. 859.8 (3.68 m off) |
| a9 deco 124 | deco `glaciar_long_stone` | -284.7, 858.3 (z -1.2 .. 1.1) | drawn -286.6 .. -282.9 x 856.7 .. 859.8, its solid -286.6 .. -279.8 x 853.1 .. 859.8 (3.68 m off) |

## a10 La Cresta de la Tormenta

### DEPTH (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a10 deco 70 | deco `tormenta_nest_stage` with deco `tormenta_mast_timber` (a10 deco 53) | -310.0, 925.1 (z -2.5 .. -1.2) | 0.05 m apart in depth, overlapping on screen |

### SKIN (22)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a10 deco 23 | deco `tormenta_quartz_knob` | -295.6, 893.2 (z -0.3 .. 0.3) | drawn -295.8 .. -295.3 x 893.0 .. 893.4, its solid -297.1 .. -295.3 x 893.0 .. 894.6 (1.30 m off) |
| a10 deco 24 | deco `tormenta_quartz_knob` | -296.9, 894.4 (z -0.3 .. 0.3) | drawn -297.1 .. -296.6 x 894.2 .. 894.6, its solid -297.1 .. -295.3 x 893.0 .. 895.8 (1.30 m off) |
| a10 deco 25 | deco `tormenta_quartz_knob` | -295.6, 895.6 (z -0.3 .. 0.3) | drawn -295.8 .. -295.3 x 895.4 .. 895.8, its solid -297.1 .. -295.3 x 894.2 .. 897.0 (1.30 m off) |
| a10 deco 26 | deco `tormenta_quartz_knob` | -296.9, 896.8 (z -0.3 .. 0.3) | drawn -297.1 .. -296.6 x 896.6 .. 897.0, its solid -297.1 .. -295.3 x 895.4 .. 898.2 (1.30 m off) |
| a10 deco 27 | deco `tormenta_quartz_knob` | -295.6, 898.0 (z -0.3 .. 0.3) | drawn -295.8 .. -295.3 x 897.8 .. 898.2, its solid -297.1 .. -295.3 x 896.6 .. 899.4 (1.30 m off) |
| a10 deco 28 | deco `tormenta_quartz_knob` | -296.9, 899.2 (z -0.3 .. 0.3) | drawn -297.1 .. -296.6 x 899.0 .. 899.4, its solid -297.1 .. -295.3 x 897.8 .. 900.6 (1.30 m off) |
| a10 deco 29 | deco `tormenta_quartz_knob` | -295.6, 900.4 (z -0.3 .. 0.3) | drawn -295.8 .. -295.3 x 900.2 .. 900.6, its solid -297.1 .. -295.3 x 899.0 .. 901.8 (1.35 m off) |
| a10 deco 30 | deco `tormenta_quartz_knob` | -296.9, 901.5 (z -0.3 .. 0.3) | drawn -297.1 .. -296.7 x 901.3 .. 901.8, its solid -297.1 .. -295.3 x 900.2 .. 901.8 (1.35 m off) |
| a10 deco 83 | deco `tormenta_quartz_knob` | -287.6, 941.6 (z -0.3 .. 0.3) | drawn -287.9 .. -287.4 x 941.4 .. 941.8, its solid -287.9 .. -287.4 x 941.4 .. 942.9 (1.10 m off) |
| a10 deco 84 | deco `tormenta_quartz_knob` | -287.6, 942.7 (z -0.3 .. 0.3) | drawn -287.9 .. -287.4 x 942.5 .. 942.9, its solid -287.9 .. -287.4 x 941.4 .. 942.9 (1.10 m off) |
| a10 deco 111 | deco `tormenta_quartz_knob` | -325.6, 947.0 (z -0.4 .. 0.4) | drawn -325.8 .. -325.4 x 946.7 .. 947.3, its solid -325.8 .. -324.4 x 946.7 .. 948.3 (1.00 m off) |
| a10 deco 112 | deco `tormenta_quartz_knob` | -324.6, 948.0 (z -0.4 .. 0.4) | drawn -324.8 .. -324.4 x 947.7 .. 948.3, its solid -325.8 .. -323.4 x 946.7 .. 949.3 (1.00 m off) |
| a10 deco 113 | deco `tormenta_quartz_knob` | -323.6, 949.0 (z -0.4 .. 0.4) | drawn -323.8 .. -323.4 x 948.7 .. 949.3, its solid -324.8 .. -323.4 x 947.7 .. 949.3 (1.00 m off) |
| a10 deco 114 | deco `tormenta_quartz_knob` | -323.9, 950.6 (z -0.4 .. 0.4) | drawn -324.1 .. -323.7 x 950.3 .. 950.9, its solid -324.1 .. -322.7 x 950.3 .. 951.9 (1.00 m off) |
| a10 deco 115 | deco `tormenta_quartz_knob` | -322.9, 951.6 (z -0.4 .. 0.4) | drawn -323.1 .. -322.7 x 951.3 .. 951.9, its solid -324.1 .. -322.7 x 950.3 .. 951.9 (1.00 m off) |
| a10 deco 55 | deco `tormenta_mast_rung` | -310.0, 915.5 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 915.4 .. 915.6, its solid -310.8 .. -309.2 x 915.4 .. 916.7 (1.10 m off) |
| a10 deco 56 | deco `tormenta_mast_rung` | -310.0, 916.6 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 916.5 .. 916.7, its solid -310.8 .. -309.2 x 915.4 .. 916.7 (1.11 m off) |
| a10 deco 58 | deco `tormenta_mast_rung` | -310.0, 919.5 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 919.4 .. 919.6, its solid -310.8 .. -309.2 x 919.4 .. 920.7 (1.10 m off) |
| a10 deco 59 | deco `tormenta_mast_rung` | -310.0, 920.6 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 920.5 .. 920.7, its solid -310.8 .. -309.2 x 919.4 .. 920.7 (1.11 m off) |
| a10 deco 61 | deco `tormenta_mast_rung` | -310.0, 923.5 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 923.4 .. 923.6, its solid -310.8 .. -309.2 x 923.4 .. 924.7 (1.10 m off) |
| a10 deco 62 | deco `tormenta_mast_rung` | -310.0, 924.6 (z -0.2 .. 0.2) | drawn -310.8 .. -309.2 x 924.5 .. 924.7, its solid -310.8 .. -309.2 x 923.4 .. 924.7 (1.11 m off) |
| a10 deco 3 | deco `tormenta_ridge_mass` | -337.0, 921.0 (z -3.0 .. 0.6) | drawn -362.0 .. -312.0 x 880.0 .. 962.0, its solid -362.0 .. -314.0 x 880.0 .. 962.0 (2.00 m off) |

### STANDIN (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a10 deco 8 | deco `tormenta_porch` | -307.0, 885.3 (z -4.5 .. 0.0) | DRAWN, NOT SOLID: a skin with no solid of it under it (it looks like something to hold) |

## a11 La Cumbre

### ZFIGHT (1)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a11 deco 62 | deco `marigold_garland` with deco `marigold_garland` (a11 deco 60) | -336.9, 975.3 (z -1.8 .. -1.6) | front faces both at z -1.67, overlapping 0.19 m2 |

### DEPTH (3)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a11 deco 70 | deco `cumbre_grass_gold` with deco `cumbre_pillar_west` (a11 deco 68) | -326.3, 977.6 (z -1.7 .. -1.7) | 0.14 m apart in depth, overlapping on screen |
| a11 deco 72 | deco `cumbre_moss_pink` with deco `cumbre_pillar_east` (a11 deco 71) | -318.8, 984.4 (z -1.7 .. -1.7) | 0.14 m apart in depth, overlapping on screen |
| a11 deco 77 | deco `cumbre_rime_block` with deco `cumbre_tooth_e` (a11 deco 74) | -321.6, 979.6 (z -0.4 .. 0.4) | 0.85 m apart in depth, overlapping on screen |

### SKIN (3)

| Where | Pieces | Position | Why |
|---|---|---|---|
| a11 deco 10 | deco `cumbre_tea_floor` | -340.5, 963.5 (z -1.3 .. 1.2) | drawn -349.0 .. -332.0 x 962.0 .. 965.0, its solid -349.0 .. -340.0 x 962.0 .. 965.0 (8.00 m off) |
| a11 deco 66 | deco `cumbre_post_west` | -329.9, 989.5 (z -2.3 .. 1.2) | drawn -332.2 .. -327.5 x 984.1 .. 994.9, its solid -332.2 .. -327.5 x 984.1 .. 995.2 (0.31 m off) |
| a11 deco 91 | deco `cumbre_bell_frame` | -358.2, 1003.3 (z -1.3 .. 0.3) | drawn -361.6 .. -354.8 x 999.8 .. 1006.9, its solid -361.6 .. -354.8 x 999.8 .. 1006.4 (0.50 m off) |

