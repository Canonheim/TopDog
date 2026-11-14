# Biome 0, La Estación: the models for the ride and the join

The contract is `tools/peak/areas/a0_dress.py`. These are the stems that file places that are not yet
in `kit/models/`: the cart ride into the mountain (pages 0.3a the mouth, 0.3b the dip, 0.3c the gap)
and the join to the mine (page "0 to 1"). The first screen's models are in `Top Dog Kit\docs\PARTS.md`.

Rules for all of them: the house atlas, one material, no glow, transforms applied. Sizes are
width x height x depth in metres, the size the model is MADE at. The origin is the middle of the base
(x and z) at its foot (y) unless the row says otherwise. Walls and rock are painted (BRIEF.md, "Walls
and masses"): a few large planes, long wavy painted lines and bands, nothing that tapers to a point,
no dark slot or recess cut into a face, one piece made for its place. Things you can grip are pale,
matte and dry; the bed grips, so it stays pale and dry however wet the wall behind it is.

Makers: A = buildings, walls and rock masses, far cards, ground slabs. B = props, plants, signs, small
dressing. C = timber structures, iron fittings, rails, machines.

## Walls, rock and the big pieces

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `dsc_back_wall_a` | 26.0 x 11.45 x 1.6 | middle of its x span (x -49.0), the bottom of its box (y -3.85), middle of its depth (face at z -1.9, back at -3.5) | The tunnel's back wall from the mouth (x -36) to the second lantern (x -62), page 0.3a. Plank lining limewashed white, the planks laid level while the floor falls away, so the painted plank bands show the grade; the wash a little thinner going in. The bricked-up side passage (x -56.4 to -54.6, 1.8 by 2.9, its foot on the bed) is whitewashed brick painted flush on it. Bounded by the bed and the roof, tucked 0.4 under and over | 1 | A |
| `dsc_back_wall_b` | 43.0 x 10.29 x 1.6 | as above (x -83.5, y -7.54) | x -62 to -105, page 0.3b. Bare lining, dull and dry, pale with old dust behind the landing (x -97 to -100). Over the crest the lining stops for the hard rib: a slanting band of bluer, harder rock 3 m wide, from x -94.6 to -91.8 at the bed to -90 to -87.2 at the roof, its old drill holes painted dots; a lantern hangs on a spike in it at x -90. Down the drop two patches of planks are gone and wet rock shows (x -102.3 and -104.6, 1.3 to 2.6 m over the bed), flush paint | 1 | A |
| `dsc_back_wall_c` | 19.3 x 9.14 x 1.6 | as above (x -114.65, y -10.88) | x -105 to the gap, page 0.3c. Grey wet lining, planks missing, wet rock behind. Between sets 29 and 30 (x -112.7) a seep of glossy black mud, an even band 1.6 m wide from the roof to the bed with wavy edges and pale drips as short round-ended lines, in the kit's mud colour so the game's wet shading takes it. Its west end is the gap's ragged broken edge (x -124.0 at the bed, -124.3 higher), where the rock's thickness shows: a real break | 1 | A |
| `dsc_back_wall_d` | 19.7 x 6.52 x 1.6 | as above (x -142.15, y -12.4) | The gap's west edge (x -132.3, ragged, the rock's thickness showing) to the door (x -152), pages 0.3c and "0 to 1". The lining smashed, wet rock behind; it meets the mine's own back wall at the door | 1 | A |
| `dsc_bed_a` | 26.47 x 8.62 x 4.0 | middle of its x span (x -48.78), bottom of its box (y -6.42), z 0 | SKIN of the cave's bed slabs from the mouth to x -62 (and the corner filler at -62), page 0.3a. Pale dry grip rock: a few large planes, the grain as long wavy painted lines. Must match the slabs' outline exactly (see a0.json; the top is the rail bed). 4 m deep, so the back wall's foot and the front posts stand on it | 1 | A |
| `dsc_bed_b` | 42.73 x 7.27 x 4.0 | as above (x -83.12, y -9.91) | The bed slabs x -62 to -104 and the filler at -104, page 0.3b: the dip, the crest and the drop. Dry and pale even at the low point; pale dust thick at the landing (x -97 to -100) | 1 | A |
| `dsc_bed_c` | 32.61 x 7.69 x 4.0 | as above (x -119.72, y -14.64) | The bed slabs x -104 to -136, page 0.3c. Drawn dry: pale rock, nothing dark or glossy on the floor (it grips) | 1 | A |
| `dsc_bed_d` | 16.11 x 3.35 x 4.0 | as above (x -143.97, y -15.0) | The bed slab x -136 to -152, the join: the nearly level foot of the haulage way, ending in the 0.6 m step at the door | 1 | A |
| `dsc_roof_a` | 26.8 x 8.63 x 4.0 | middle of its x span (x -49.38), bottom of its box (y 1.54), z 0 | SKIN of the cave's roof slabs from the mouth to x -62 (and the fillers at -46 and -62), page 0.3a. Rock painted in planes and wavy lines; limewashed for its first 10 m, the wash fading out (paint on dry rock: pale and matte) | 1 | A |
| `dsc_roof_b` | 42.92 x 7.27 x 4.0 | as above (x -83.44, y -1.96) | Roof slabs x -62 to -104 and the fillers at -90 and -104, page 0.3b. Bare rock over the rib, where two sets are left out | 1 | A |
| `dsc_roof_c` | 32.34 x 7.65 x 4.0 | as above (x -120.15, y -6.65) | Roof slabs x -104 to -136 and the filler at -120, page 0.3c. Bare over the gap, where a set went with the wall | 1 | A |
| `dsc_roof_d` | 16.11 x 3.35 x 4.0 | as above (x -144.03, y -7.0) | Roof slab x -136 to -152, the join | 1 | A |
| `dsc_hill_foot` | 6.5 x 9.7 x 4.1 | middle of its footprint (x -32.75, z -3.95), on the road | The mountain's foot behind the dock's last 6 m, page 0.3a: pale dry rock coming down to the road, painted in planes and wavy bands. Outline (-29.5, 0), (-31.2, 2.8), (-34, 5.5), (-36, 9.7). Its face leans forward as it rises: behind z -4.9 at the road, behind -3.9 at the deck, at -1.9 where it meets the mouth above y 5.5. Two small outcrops stand out of its face with their tops at (-35.4, 7.9, z -2.1) and (-34.4, 6.2, z -2.4), where the two plants stand | 1 | A |
| `dsc_cavern_far` | 40.0 x 14.0 x 1.0 | middle of its foot; the painted face at z 0, facing the camera | The waterfall cavern seen through the gap, page 0.3c: ONE flat painted card standing 16 m back (BRIEF, "Far backgrounds"). The cold grey-violet far wall of a very big room, the fall as one long pale line from above the frame to below it, mist at its foot, five small lantern specks on the workings beside it. Mid-value colours; the only cool light on the ride. 40 m wide so every view through the gap lands on it | 1 | A |
| `dsc_gap_sill` | 8.4 x 1.0 x 1.2 | middle of its footprint, on the bed (laid at the bed's 5.7 degree slope) | The low sill of rubble where the back wall fell out into the cavern, page 0.3c: broken rock and lining 0.35 to 0.9 m high along x -124 to -132.3. Rock painted like the walls; a few big blocks, not a heap of small bricks | 1 | A |

## Timber, iron, rails

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `dsc_set_white` | 0.44 x 5.0 x 3.5 | the BACK POST's foot; the cap runs forward from it to +3.35 m (the back post's back face is 0.15 behind the origin) | A tunnel timber set's back piece, whitewashed, page 0.3a (the mouth is set 0): a back post 0.3 m square, 4.7 m tall, and the cap across the roof, 0.44 wide and 0.3 thick, level, its top at 5.0. The wash is the town's paint, worn at the edges | 11 | C |
| `dsc_set_bare` | 0.44 x 5.0 x 3.5 | as above | The same set in bare wood, dull and dry, greyer than anything you can hold, page 0.3b; past the crest the wood starts to go grey | 11 | C |
| `dsc_set_bare_stained` | 0.44 x 5.0 x 3.5 | as above | The bare set at the low point of the dip, its post's foot stained dark to knee height where the water gathers, page 0.3b | 3 | C |
| `dsc_set_grey` | 0.44 x 5.0 x 3.5 | as above | The set grey and wet, page 0.3c and the join: "from here on these are the mine's sets". Some are placed leaning a little (by rot) | 14 | C |
| `dsc_set_grey_cracked` | 0.94 x 5.0 x 3.5 | as above (the back post's foot); the extra prop stands 0.5 m west of it | The grey set with its cap cracked and held up by an extra prop, pages 0.3c and "0 to 1" | 2 | C |
| `dsc_front_post_white` | 0.3 x 4.7 x 0.3 | its foot | The front post of a set, whitewashed, page 0.3a. Plain; it stands under the cap's front end, in front of the play space | 3 | C |
| `dsc_front_post_bare` | 0.3 x 4.7 x 0.3 | its foot | The same in bare wood, page 0.3b | 4 | C |
| `dsc_front_post_grey` | 0.3 x 4.7 x 0.3 | its foot | The same, grey and wet, page 0.3c and the join | 3 | C |
| `dsc_front_post_stump` | 0.3 x 0.5 x 0.3 | its foot | The front post that stood in front of the gap, broken off when the wall went: a 0.5 m stump with a splintered top, grey, page 0.3c | 1 | C |
| `dsc_rail_torn` | 3.66 x 0.45 x 1.2 | the middle of its base, as `rail_straight` (rails at z ±0.55) | The torn-out track over the crest, page 0.3b: both rails gone, only the sleepers left; at its east end the near rail's stub bent up like the lip of a ramp (0.45 high); the far rail lying loose in the ballast beside the sleepers. Rust-orange iron, pale sleepers | 1 | C |
| `dsc_rail_landing` | 3.66 x 0.25 x 1.2 | as above | The landing, page 0.3b: track with its rails scraped bright, the sleepers doubled two side by side, pale dust thick between them | 1 | C |
| `dsc_rail_banked` | 3.66 x 0.45 x 1.2 | as above | The banked drop below the landing, page 0.3b: the far rail laid 0.2 m higher than the near one, so the sleepers' tops show | 1 | C |
| `dsc_buffer_stop` | 1.7 x 0.8 x 3.4 | the middle of the baulk's foot; the braces reach 1.3 m west of it, behind | SKIN of the course's buffer box (0.6 x 0.8), page "0 to 1": a timber baulk laid right across the track, its near end faced with an iron plate dented where carts hit it; its far end held by two braces raking back to the floor against the back wall | 1 | C |
| `dsc_mouth_sill` | 0.4 x 0.45 x 2.4 | middle of its base | Where the dock's deck meets the rock, page 0.3a: a timber sill shod with iron, worn hollow in the middle by wheels, across the track | 1 | C |
| `dsc_door_sill` | 0.32 x 0.22 x 2.4 | middle of its base | A worn timber sill along the edge of the 0.6 m step at the door, page "0 to 1", so it reads as the end of a loading floor | 1 | C |
| `dsc_ore_hopper` | 2.8 x 2.4 x 2.0 | middle of its footprint, on the deck | The timber ore hopper on legs against the hill where carts were tipped, page 0.3a: a box wider at the top (2.8) than its spout, on four legs 0.8 tall, its spout at the back-bottom feeding the chute. Honey timber gone grey, iron corners | 1 | C |
| `ore_chute` | 4.0 x 3.2 x 1.0 | middle of its footprint, on the road | A plank ore chute 1 m wide on legs, page 0.3a (and the mine's kit). Here its high end is WEST, under the hopper's spout at y 3.0, and its lip rests at y 0.75 at its east end, where the wagons stood | 1 | C |
| `dsc_trough` | 2.0 x 0.2 x 0.2 | middle of its base | One 2 m length of the water trough along the wall's foot (pages 0.3b, 0.3c, "0 to 1"): an open plank trough on small iron brackets nailed to the posts' fronts. Laid end to end along the bed by rot and a scale near 1, so its ends must butt cleanly | 31 | C |
| `dsc_trough_spout` | 2.0 x 0.25 x 0.2 | middle of its base | The trough's last length at the door, page "0 to 1": the same, with a spout lip at its west end where the water runs over the sill | 1 | C |
| `dsc_hand_pump` | 1.0 x 1.7 x 0.4 | the column's foot (the handle reaches 0.9 m west) | An iron hand pump 1.4 m tall at the low point of the dip, its handle up, its spout feeding the trough, page 0.3b. Rust-red iron | 1 | C |
| `mine_boarded_passage` | 1.8 x 2.9 x 0.3 | middle of its base, on the bed | A closed side passage in the mine's way, page 0.3c (and the mine's kit): grey planks nailed right across an arched opening, flush, the boards' joints and two cross planks painted. No dark opening shows | 1 | C |

## Props, signs, plants, small dressing

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `dsc_mouth_pug_board` | 1.4 x 1.35 x 0.15 | the bracket's foot on the rock (its west end, its underside); the board's middle is 0.8 east and 0.7 up | The pug over the tunnel mouth, page 0.3a: a round painted board 1.2 m across with the pug, on an iron bracket out of the rock above the cap, turned to face the camera like a shop sign | 1 | B |
| `dsc_bunting_to_mouth` | 4.9 x 2.8 x 2.1 | its EAST fixing (a lashing on the pole); the far fixing is at x -4.9, y +2.14, z +2.1 | A torn string of papel picado through the air in real depth, page 0.3a, from the last pole on the dock up to the pug board's bracket. Made as `stn_bunting_run`: a round cord that sags, `papel_tatters`' flags at two thirds size, a fixing at each end | 1 | B |
| `dsc_bunting_in` | 10.0 x 1.8 x 0.1 | its EAST fixing, on the mouth cap's west face; the far fixing (set 4's cap) is at x -10.0, y -1.5 | The last string, inside the mountain, from the mouth's cap to the cap by the first lantern, page 0.3a: there it stops. Same make as above, one depth; its lowest flag 1.8 under the east fixing | 1 | B |
| `dsc_poster_board` | 0.7 x 0.9 x 0.04 | middle of its back face | A plank board nailed by its west edge to the mouth's back post and turned to face you, page 0.3a | 1 | B |
| `missing_poster_b_old` | 0.5 x 0.47 x 0.02 | middle of its back face (of what is left) | The fifth Missing poster, page 0.3a: an old copy of the fangs (`missing_poster_b`), sun-bleached as `missing_poster_a_old` is, its lower third torn away ragged. The last face from the town before the dark | 1 | B |
| `dsc_mule_trough` | 1.4 x 0.4 x 0.4 | middle of its footprint, on the deck | The mules' water trough beside the hopper, page 0.3a: a plank trough on two low trestles, for the mules that hauled the full carts up | 1 | B |
| `dsc_shrine` | 1.6 x 2.1 x 0.3 | middle of its base; its foot is 0.7 m over the bed, on the wall | The shrine at the bottom of the dip, page 0.3b: a small whitewashed arch standing proud of the wall, its shallow niche painted warm (not dark), candle stubs on its sill, a scrap of papel picado over it. The last thing in the town's paint | 1 | B |
| `dsc_peg_board` | 1.8 x 0.6 x 0.3 | middle of its foot line (the hat's lowest point), on the wall's face | The miners' pegs, page "0 to 1": a board of six pegs where the men hung their lamps and coats; five empty, one with a miner's hat. The dead lamp is the kit's `lantern_cold`, hung on the last peg | 1 | B |
| `dsc_ledge_agave` | 0.6 x 0.45 x 0.05 | middle of its foot | A small dry-country agave on an outcrop of the mountain's foot, page 0.3a: ONE flat painted card facing the camera, its blades flush colours on one plane, only its outline inked, in the style of the station's foreground plants (new for this biome's walls) | 1 | B |
| `dsc_ledge_grass` | 0.5 x 0.4 x 0.05 | middle of its foot | A tuft of dry grass on the other outcrop, page 0.3a, made the same way | 1 | B |

## Not placed here

- `mine_frame_broken`, 0.6 x 5.0 x 2.6, origin as `mine_frame` (C): the door set at x -152 with its front
  post broken in the middle, a 1.5 m length hanging from the cap and a 0.4 m stump on the floor (page
  "0 to 1"), so nothing covers you where the cart throws you. a1.py places the door set; it swaps
  `mine_frame` for this.
- Kit pieces this file reuses as they are: `dock_back_rail`, `bunting_pole`, `papel_tatters`,
  `lantern_hang`, `lantern_cold`, `sign_pug_skull`.
