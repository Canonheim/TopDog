# Las Aguas Negras: the models to make

The model list for biome 2, from its dress file `tools/peak/areas/a2_dress.py` (296 decos, 23
lanterns lit). Every stem here is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`, nor
on the a0 or a1 lists. Make each at exactly its size (metres, w x h x d; +z faces the camera).
The game rescales a landed model that is more than a quarter off.

Makers: **A** buildings, walls and rock masses, far cards, ground slabs. **B** props, plants,
signs, small dressing. **C** timber structures, iron fittings, rails, machines.

The works' look (the sheet `docs/peak/playtest/design/data/a2_biome.py`): brick in slate-grey
courses with round arches, buttresses and piers under pale stone copings, cast iron (pipes on
brackets, flanged joints, valve wheels, riveted plate, chain). What you hold is rust-orange
iron, pale stone copings, dry pale brick; what you can't is black wet brick with slime and
white drips, wet rock, greased pipe; scenery pipe and brick behind the play space is dark
blue-grey and mostly verdigris green. Light is cold teal; the far background blue-black; the
only warm colour is hot things (the boiler's door). The company's pug is cast into the iron.
Timber only as left-overs from the mine. Brick and stone are PAINT (BRIEF.md "Walls and
masses"; the sheet's `built`): a few large planes, the courses long slightly wavy lines of flat
colour in three or four slate tones, water stains level bands where the black water stood, a
band of green growth at the waterline, nothing that tapers to a point, no dark recess cut into
a face; the few real breaks are an arch's ring standing proud, a hole where a handful of bricks
have gone, a coping overhanging with its shadow painted under it, a buttress with a corner gone;
the outline leans and is notched away from the holds and tops. No square panel repeated.

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Skin" means the model is
the look of a course solid (`skin=` in a2.py, its FOR THE AREA FILE item 5): it fills the solid,
z -1.2 .. 1.2, and its outline is the rock's outline there (`SKIN_REGIONS` in the dress file;
the sizes are the rock's own). "Drawn" means a thin piece on a course solid's front face, z 1.2.
"Wall" means a back wall: its size's depth runs back from the face z the row gives.

## 1. Walls, masses and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `aguas_far_wall` | 244.0 x 106.0 x 0.3 | foot (x -344, y 82), z -10.25 | The far background behind the whole biome: one flat painted card, blue-black, a few long faint bands, behind everything (the sheet's light). Mid values: the game lifts lit faces | 1 | A |
| `aguas_borde_back_wall` | 62.0 x 10.0 x 0.6 | foot (x -257, y 86), face z -2.6 | 2.1 El Borde, the river tunnel's back wall from x -288 to the east wall: slate brick in painted courses; a brick rib standing proud every 6 m (x -258.6, -252.6, -246.6, -240.6, -232.6 and on west); two round culvert mouths open at the waterline (91) upstream of the weir (x -257.3 .. -254.3, -251.3 .. -248.3, black water going back under them); on the lip ledge one arch bricked up (-231.3 .. -228.7). Below the river (y 86 .. 90) it is seen only behind the slot, with the weir's sheet on it | 1 | A |
| `aguas_mill_back_wall` | 29.4 x 10.6 x 1.25 | foot (x -240.7, y 96.8), z -2.55 .. -1.3 | 2.2 and 2.3: the mill's back wall, face at z -1.95, brick to the roof (107.4). The wheel's round arch 5.4 m wide OPEN in it (x -254.0 .. -248.6, springing 100.0) with the second wheel behind; then the aqueduct's back half: four brick piers standing proud to z -1.3 under the four pier tops (x -247.6, -241.6, -234.95, -227.25), three round arches still whole between them (-246.6 .. -242.6 springing 98.9; -240.6 .. -235.95, 98.95; -233.95 .. -228.25, 98.85), open, the race going back under them; plain brick above to the roof (the ring pads stand on it) | 1 | A |
| `aguas_mill_far_arcade` | 29.4 x 7.0 x 0.5 | foot, z -6.25 | Far behind the mill's arches: the race going back under a second arcade of small arches in the dark (2 to 3 m), and the dark of the wheel's arch; blue-black, lit only by a pale shimmer under the arches | 1 | A |
| `aguas_brazo_back_wall` | 23.2 x 7.2 x 0.6 | foot (x -237.6, y 108.4), face z -4.4 | 2.4, the wash house's back wall: brick with two round arches barred with iron (x -243.2 .. -240.6 and -239.4 .. -236.8, springing 111.6), open (the far wall shows through the bars) | 1 | A |
| `aguas_compuertas_back_wall` | 6.4 x 20.2 x 0.6 | foot (x -252.4, y 108.4), face z -2.4 | 2.5, the gate hall's back wall: brick 20 m tall, black and wet low down where the gates leak, paler above | 1 | A |
| `aguas_cadenas_back_wall` | 16.4 x 32.6 x 0.6 | foot (x -263.8, y 96), face z -3.6 | 2.6, the catch chamber's back wall, outline the chamber's (x -272 .. -255.6 down to 120.7, carried on down behind the hopper and the lower pipe, x -265.5 .. -258.2, to the river's roof at 96): brick, one round arch barred with iron high on the west side (x -271.4 .. -268.6, springing 124.0) | 1 | A |
| `aguas_gallery_back_wall` | 12.0 x 4.9 x 0.6 | foot (x -278, y 120.7), face z -2.8 | The fitters' gallery's back wall (2.6, 2.0), brick, drier; the lifted plates lean on it | 1 | A |
| `aguas_charco_flank_west`, `aguas_charco_flank_east` | 14.0 / 9.5 x 15.0 x 1.0 | foot (x -313.5 / -288.75, y 113), face z -5.5 | 2.7, the pool hall's two brick flanks, 15 m tall, each ending in a pale brick pier 0.6 wide against the well's rock (x -307.1 .. -306.5; -293.5 .. -292.9). The east flank has a bricked-up round arch (x -292.3 .. -287.1, springing 119.4) | 1, 1 | A |
| `aguas_throat` | 13.0 x 10.5 x 6.0 | foot (x -300, y 117.5), z -8 .. -2 | 2.7, the look up El Pozo del Diablo, built the way a paper diorama builds a tunnel: five rings of black rock cut out of card, each smaller, further back and higher (12 m across centred y 122 at z -2; 8.4 at y 123.2; 5.6 at 124.2; 3.4 at 125.0; 1.8 at 125.5 at z -8), each with a thin pale edge on its upper side as if lit from above; behind the last, one small pale dot 0.4 across at y 125.9 (colour, not glow). The rings stop at y 117.5, over the shelf of fallen things | 1 | A |
| `aguas_well_back` | 13.0 x 48.0 x 5.25 | foot (x -300, y 128), z -6.5 .. -1.25 | 2.7: the back half of the well's round shaft (12 m across), black wet rock, from the hall's roof up to where the mountain's well takes over at y 176; a few long pale bands, nothing pointed | 1 | A |
| `aguas_well_collar` | 13.6 x 0.8 x 5.6 | foot (x -300, y 127.5), z -6.85 .. -1.25 | 2.7: the pale stone collar round the well's mouth, the back half of a 12 m ring in 1.2 m dressed sections, at the hall's roof line | 1 | A |
| `aguas_fallen_shelf` | 9.3 x 2.2 x 1.6 | foot (x -300.85, y 115), z -5 .. -3.4 | 2.7, "what has fallen": a shelf of rock at the back of the pool just above the water, and on it, west to east, a broken crystal point (1.2 wide, 1.7 tall), a rotted mushroom cap as big as a table, a carved stone block with a pug's face, a coil of rope; all grey-blue and dim (shapes after the kit's `crystal_cluster_c`, `mushroom_cap_m`, `temple_block`, `rope_coil`) | 1 | A |
| `aguas_flume_back_wall` | 25.5 x 8.0 x 0.6 | foot (x -333.25, y 114.5), face z -2.2 | 2.8, the flume's back wall: brick, black and wet to a level tide line 1 m over the water (117), three round culvert mouths at the waterline, open (x -328.0 .. -325.2, -333.5 .. -330.7, -339.0 .. -336.2, springing 116.6) | 1 | A |
| `aguas_tuberia_back_wall` | 34.0 x 27.5 x 0.8 | foot (x -363, y 114.5), face z -5.2 | 2.9, the boiler house's back wall: brick 27 m tall, sooty above the boiler (east), wet and streaming at the west end where the pool above spills down it | 1 | A |
| `aguas_boiler_pier_low`, `_mid`, `_high` | 7.2 x 9.6 / 6.8 x 15.1 / 5.2 x 20.4, all 3.0 deep | foot (x -355.8 / -366.0 / -375.1, y 114.5), face z -2.2 | 2.9, the three brick piers standing in the tail pool, a storey taller each: a pale stone coping on top (124.1, 129.6, 134.9), a round arch 3.2 wide through each at the waterline (springing 116.4), open; the lagged steam pipe crosses their faces | 1, 1, 1 | A |
| `aguas_cascada_back_wall` | 12.0 x 23.5 x 1.0 | foot (x -386, y 134.5), face z -2.6 | 2.10, the weir hall's back wall: brick 23 m tall, black and streaming at the west end by the fall, drier east; a round culvert mouth at the pool (x -388.6 .. -385.8, springing 136.2) and a round barred eye 2.2 across high up at (-383.4, 153.6), both open | 1 | A |
| `aguas_reach_back_wall` | 33.5 x 8.5 x 0.6 | foot (x -408.75, y 149.5), face z -2.2 | 2.10b, the upper reach's back wall: brick, a round culvert mouth 2.8 across at the waterline every 6 or 7 m (x -396.5, -402.3, -408.6, -415.6, -422.4; springing 150.8), open, black water going back | 1 | A |
| `aguas_presa_back_wall` | 14.5 x 18.1 x 1.0 | foot (x -432.75, y 151.9), face z -6.0 | 2.11, the dam hall's back wall over the spillway, far back, blue-black brick | 1 | A |
| `aguas_spillway_back` | 11.9 x 10.9 x 4.6 | foot (x -431.45, y 151.9), z -6 .. -1.4 | 2.11, the spillway carried on behind: the course's steps (treads 2.6, risers 2.9: 152.2, 155.1, 158.0, 160.9) running back for the dam's whole width as stone-coped surfaces (a shell, not solid under: the inspection gallery runs under the first tread), the gallery's mouth open through its lowest riser, and at their head far back a round spill arch 1.4 wide. The water on them is the game's | 1 | A |
| `aguas_inspection_gallery` | 8.2 x 3.0 x 1.35 | foot (x -433.5, y 151.9), z -2.6 .. -1.25 | 2.11 (note 25), the dam's inspection gallery: a round barrel vault 7.8 long, its crown at 154.8 (a2.py cuts it 151.9 .. 154.8), floor, back wall and vault, no front; its back wall brick streaked white where the dam seeps; its mouth on the apron (x -429.6) a round arch with the pug cast on its keystone | 1 | A |
| `aguas_lift_shaft` | 3.0 x 18.1 x 1.1 | foot (x -438.7, y 151.9), z -2.6 .. -1.5 | 2.11: the lift shaft, brick 2.6 wide, straight up 18 m from the gallery to the hall's roof; its back wall (face z -1.5) dry and pale near the top, black and wet at the foot | 1 | A |
| `aguas_lake_vault` | 19.0 x 10.0 x 1.0 | foot (x -449.5, y 163), face z -4.0 | 2 to 3: slate brick over the lake in round-arched bays, two bricked up (x -458.2 .. -454.6, -453.6 .. -450.0, springing 168.2); its top three courses cracked, pale violet light painted in the cracks | 1 | A |
| `aguas_exit_shaft_lining` | 7.0 x 3.1 x 1.2 | foot (x -452.5, y 172.9), z -2.45 .. -1.25 | 2 to 3: the exit shaft's brick lining, a round shaft cut in half, sound at the bottom, split open by crystal at the top (two courses painted at 174.4 and 175.6) | 1 | A |
| `aguas_frog_room` | 3.4 x 2.9 x 1.35 | foot (x -282.5, y 117.4), z -2.6 .. -1.25 | 2.0, the frog's valve chamber: a round brick vault 3 m wide and 2.6 tall, its back wall, vault and the back of its floor, no front wall; dry pale brick, the only dry room in the biome; the cast ring frame of its door round its mouth at x -284; a hook in the vault at (-282.6, 119.3) for the lantern | 1 | A |
| `aguas_barrel_cove` | 3.6 x 3.7 x 4.2 | foot (x -312.7, y 114.4), z -5.5 .. -1.3 | 2.7 (note 21): the barrels' cove, a round brick arch at the waterline in the west flank (opening x -314.12 .. -311.28, springing 116.3), its ring standing proud, black inside, its vault running back to the flank; the barrels float forward out of it from z -3 | 1 | A |
| `aguas_culvert_barred` | 3.0 x 3.1 x 3.15 | foot (x -245.1, y 108.4), z -4.4 .. -1.25 | 2.4, the inlet culvert: a round arch at the waterline at the wash channel's west end (opening x -246.3 .. -243.9, springing 109.9) with a rack of iron bars across it, its short vault running back to the wall | 1 | A |
| `aguas_far_bank` | 12.8 x 1.55 x 2.6 | foot (x -237.2, y 108.4), z -4.2 .. -1.6 | 2.4, the far bank: a stone-coped bank just above the channel's water (its coping 109.75 .. 109.95), wet brick under; the tanks stand on it | 1 | A |
| `aguas_hatch_lining` | 1.8 x 2.6 x 0.75 | foot (x -226.9, y 107.4), z -2 .. -1.25 | 2.3, the brick-lined hatch the east ladder goes through, with a cast iron rim | 1 | A |
| `aguas_well_lining` | 1.8 x 11.5 x 0.75 | foot (x -256.3, y 95.9), z -2 .. -1.25 | 2.2, the ladder well: a round brick well cut in half, the iron rungs let into it (the rungs are the course's), a cast ring where it opens at the landing (98.6) | 1 | A |
| `aguas_brick_heap`, `aguas_brick_heap_big` | 3.0 x 0.8 x 0.9; 4.0 x 0.9 x 0.9 | foot, z -2.2 .. -1.3 | 2.3, the fallen spans: heaps of loose brick under the water at the foot of each gap (one placed at 0.8). Painted bricks in a few big lumps, a low broken outline | 2, 1 | A |
| `aguas_ring_pad` | 0.8 x 0.8 x 0.7 | foot, z -1.95 .. -1.25 | 2.3 (note 18): a short brick pad built out from the arcade's wall behind each ring, a riveted iron plate 0.8 across on its face (the ring's eye bolt meets it, at z -1.25), like a mooring ring's on a quay | 6 | A |
| `aguas_weir_lip_back` | 0.8 x 0.45 x 1.35 | foot, z -2.6 .. -1.25 | The weir's pale stone coping carried on behind the play space to the back wall (2.1 at x -244.2; 2.10 at x -392.0); the water's sheet is the game's | 2 | A |
| `aguas_stair_string_low`, `aguas_stair_string_high` | 4.2 x 4.3 x 0.3; 4.0 x 3.6 x 0.3 | foot (bounding box), on the wall z -2.6 .. -2.3 | 2.10, the keepers' stair: the stone string of each flight, a band 0.4 deep climbing west at about 45 degrees ((-385.15, 139.15) to (-389.05, 143.15); (-387.35, 149.55) to (-391.05, 152.85)), each tread's root let into it | 1, 1 | A |
| `aguas_tread_root` | 0.55 x 0.4 x 1.35 | foot, z -2.6 .. -1.25 | 2.10: the back of each stone tread you hold, from the play space into the string; pale stone, square | 7 | A |
| `aguas_crystal_point`, `aguas_crystal_point_small` | 1.2 x 3.6 x 1.2; 0.9 x 2.4 x 0.9 | the middle of its root, at the TOP (it hangs down) | 2 to 3: a rough point of the cave's crystal grown down through the brick, deep blue-violet (it is scenery), with a collar of split, shouldered-aside brick round its root. One placed slanting (rot 55) at 0.8 out of the shaft's lining | 2, 2 | A |
| `aguas_crystal_point_bright` | 0.8 x 1.6 x 0.8 | the same | 2 to 3: the same, bright white, over the crest's east end: the first of the cave's lights (colour; a2.py adds the light) | 1 | A |
| `aguas_outcrop_brick` | 0.9 x 0.4 x 0.35 | foot, its back on the wall | A small knob of loose brick standing out of a works wall, a flat top for a plant (the sheet's walls line; BRIEF "little outcrops") | 10 | A |
| `aguas_bank_lip_borde`, `aguas_bank_lip_brazo`, `aguas_bank_lip_flume` | 15.3 x 1.15 x 0.7; 13.7 x 0.65 x 0.5; 25.5 x 1.05 x 0.5 | foot, z 1.3 .. 2.0 / 1.3 .. 1.8 | Foreground: the near bank's low broken run of brick along the bottom of the frame, below the water's bed, in front of solid rock (KIT_MORE): 2.1 (x -260 .. -244.7, stopping short of the weir), 2.4 (the channel's near wall cut down), 2.8 (the flume's, a full 3 m under the water). A wavy, notched top | 1, 1, 1 | A |

Skins (all 2.4 deep, origin foot, z 0; the rock's outline as `SKIN_REGIONS` cuts it):

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `aguas_borde_pier` | 2.0 x 6.2 | x -237, y 86 | Skin. The pier between the weir's slot and the dry shaft, with its peaked top (to 92.2): black wet brick, the peak black and wet (2.1; a1's brick-and-timber post stands in front of it) | 1 | A |
| `aguas_borde_bed` | 40.0 x 4.0 | x -264, y 86 | Skin. The bed under the lower river, x -284 .. -244: black wet rock, brick facing at its east end, the green band at the waterline (91) | 1 | A |
| `aguas_weir_coping` (DROPPED 11-14: no solid at the weir's lip) | 0.45 x 0.3 | x -244.22, y 90.7 | Skin of the new stone solid (a2.py item 6b): the pale stone coping on the weir's lip, white water breaking on it | 1 | A |
| `aguas_east_wall` | 9.0 x 29.6 | x -227.5, y 86 | Skin. The lip ledge's body (x -232 .. -226, under the coping a1 draws on its face) and the works' east wall up to the wash house's roof (x -226 .. -223): black wet brick, the race's drain's stain down it | 1 | A |
| `aguas_race_bed` | 26.4 x 2.3 | x -242.2, y 96 | Skin. The tunnel's roof, which is the race's bed (y 96 .. 96.8), and under the landing Q1 its brick pier (x -255.4 .. -253.5, to 98.3) | 1 | A |
| `aguas_mill_core` | 25.6 x 24.7 | x -245.4, y 96 | Skin. The mill's west column beside the ladder well (x -258.2 .. -257.2), the floor between the wheel pit and the wash house (107.4 .. 108.4), the west landing's pier, the gate hall's three stepped sills and the landing Q4's column (to 120.7); on its west face (x -258.2, y 114 .. 120.7) the hopper's cut edge, a line of rivets and a plate seam, black and greased | 1 | A |
| `aguas_brazo_pier` | 3.0 x 2.6 | x -229.3, y 107.4 | Skin. The brick pier under the wash house's east landing Q2, between the channel's drain and the hatch | 1 | A |
| `aguas_works_roof` | 36.5 x 60.4 | x -241.25, y 115.6 | Skin. The rock and brick over the wash house and the gate hall up to 176: the roofs' undersides black and dripping, the gate hall's east wall | 1 | A |
| `aguas_cadenas_foot` | 18.5 x 24.7 | x -274.75, y 96 | Skin. The mass under the fitters' gallery, from the river's roof to the gallery's floor (120.7): along its slope (-271.2, 120.7 to -265.5, 114) the drain's iron hopper cut through, a line of rivets and a plate seam, black and greased; the frog's room cut in it (x -284 .. -281, y 117.4 .. 120, a round vault: a2.py item 6d), its cut faces dry pale brick | 1 | A |
| `aguas_desague_mass` | 29.5 x 50.4 | x -279.25, y 125.6 | Skin. Over the gallery and the catch chamber, from the well's side (x -294) to the upper pipe (x -264.5): brick under the roof, the pipe's hole edged in iron | 1 | A |
| `aguas_charco_bed` | 36.5 x 30.0 | x -302.25, y 83 | Skin. The bed under the pool and the first cascade's west wall (x -288, 96 .. 113): black wet rock, the pool's lip at its east end | 1 | A |
| `aguas_pool_sill` (DROPPED 11-14: no solid at the pool's lip) | 0.4 x 2.0 | x -288.05, y 113 | Skin of the new stone sill (a2.py item 6c): a worn stone sill, its top (114.7 .. 115.0) pale, where the pool goes over into the fall | 1 | A |
| `aguas_charco_roof` | 14.5 x 48.0 | x -313.25, y 128 | Skin. The pool hall's roof west of the well (x -320.5 .. -306), its well side edged with the collar's stone | 1 | A |
| `aguas_tail_bed` | 59.5 x 31.5 | x -350.25, y 83 | Skin. The bed under the flume and the tail pool (114.5): black wet rock with brick facing, a level green band at the waterline (116) | 1 | A |
| `aguas_flume_roof` | 25.5 x 53.5 | x -333.25, y 122.5 | Skin. The flume's vault and the boiler house's east wall over it (the riser stands in front of it) | 1 | A |
| `aguas_tuberia_roof` | 34.0 x 34.0 | x -363, y 142 | Skin. The boiler house's roof, sooty | 1 | A |
| `aguas_weir_pool_mass` | 12.0 x 51.5 | x -386, y 83 | Skin. Under the weir's pool: seen as the boiler house's west wall (x -380, 114.5 .. 134.5) with the spill streaming down it, and as the pool's bed | 1 | A |
| `aguas_reach_bed` | 33.5 x 66.5 | x -408.75, y 83 | Skin. Under the upper reach: seen as the weir hall's west wall (x -392, 134.5 .. 149.5) beside the fall, black and streaming, and as the reach's bed | 1 | A |
| `aguas_reach_roof` | 45.5 x 18.0 | x -402.75, y 158 | Skin. The roof over the weir hall and the upper reach | 1 | A |
| `aguas_presa_dam` | 23.5 x 83.7 | x -437.25, y 83 | Skin. The dam: its downstream steps as black wet stone with a film of water (risers 2.9), the crest's body, and on its cut face between the lake and the shaft the brick in drawn courses round the cast pug (placed). Made with note 25's cuts in it: the inspection gallery (x -437.4 .. -429.6, 151.9 .. 154.8) and the shaft (x -440 .. -437.4, 151.9 up); the top step gone | 1 | A |
| `aguas_presa_lake` | 16.0 x 90.0 | x -457, y 83 | Skin. The lake's bed and west wall, clear water over it: the bed paler, a little crystal showing | 1 | A |
| `aguas_presa_roof` | 39.5 x 6.0 | x -445.25, y 170 | Skin. The roof over the dam and the lake, the exit shaft's hole through it (x -456 .. -449): its top courses split by crystal | 1 | A |
| `aguas_shaft_wall` | 0.6 x 9.1 | x -437.1, y 160.9 | Skin of note 25's new slick wall closing the shaft's east side, black wet brick | 1 | A |
| `aguas_trough_stump_1` .. `_4` | 3.0 / 3.0 / 2.7 / 2.5 x 0.9 | each crown's middle, its foot | Skins of the aqueduct's four pier tops (2.3), each made for its place: the trough's stump in brick with a pale stone coping along its top (the part you land on) and, at each end that faces a gap, the trough's section and the first bricks of the arch that sprang from it (stump 1: east end; 2 and 3: both ends; 4: west end) | 1 each | A |
| `aguas_borde_landing`, `aguas_charco_landing_east`, `aguas_charco_landing_west`, `aguas_flume_landing`, `aguas_cascada_landing` | 5.7 x 0.2; 7.0 x 0.5; 6.5 x 0.5; 4.5 x 0.3; 7.0 x 0.3 | foot | Skins of the brick bodies under the hanging landings P1, Q6, Q7, Q8, Q10 (under their stone copings): wet brick, an overhang's shadow painted under the coping | 1 each | A |
| `aguas_shaft_rim` | 0.5 x 0.6 | x -448.7, y 176 | Skin of a3.py's kerb by the exit hole: half a ring of the works' pale stone, the other half already crystal | 1 | A |

## 2. Props, plants, signs and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `aguas_works_lantern` | 0.3 x 0.5 x 0.3 | THE HOOK (it hangs below), as `lantern_hang` | The works' lantern: `lantern_hang` re-made greenish, cold iron and pale green glass (colour, not glow; the game adds the steady teal light 0.27 under the hook) | 23 | B |
| `aguas_fern_wet` | 0.55 x 0.45 x 0.04 | foot | The works' wall plant: one flat painted card, a few dark green tongue-shaped fronds from a wet brick joint, flush colours, only its outline inked | 6 | B |
| `aguas_weed_tuft` | 0.7 x 0.3 x 0.04 | foot | A low tuft of pale green waterweed on a wet outcrop, one flat painted card, flush colours | 4 | B |
| `aguas_warn_plate_hot` | 0.6 x 0.6 x 0.05 | the middle of its foot | 2.9 (note 23): a cast iron plate strapped to the flue's side by the first hot joint: an open hand over a flame, the design of `sign_hot_hand`'s diamond, cast | 1 | B |
| `aguas_depth_gauge` | 0.5 x 3.4 x 0.03 | the middle of its foot | 2.8: a painted board on the middle pillar, marked in half metres, the company's red line under the water (the water stands at 116, the line lower) | 1 | B |
| `aguas_coping_crack_face` | 0.35 x 0.6 x 0.02 | the middle of its foot line, drawn | 2 to 3: drawn on the crest's coping, a crack with a thin seam of lilac crystal in it; nothing sticks up | 2 | B |
| `aguas_rung_crust_face` | 0.5 x 2.2 x 0.05 | the middle of its foot line, drawn | 2 to 3: drawn on the rungs' last 2.2 m (176 .. 178.2), a crust of rough pale lilac crystal over the rust-orange iron | 1 | B |

## 3. Timber, iron, pipes and machines (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `aguas_lantern_arm` | 0.12 x 0.35 x 0.55 | the middle of its wall plate's back, on the wall, at the hook's height | A cast iron wall arm for the works' lantern, a scroll under it, its hook 0.5 out from the wall | 20 | C |
| `aguas_main_bracket`, `aguas_main_bracket_big` | 0.25 x 1.3 x 1.35; 0.4 x 1.7 x 1.35 | foot (the plate on the wall at z -2.6, it runs forward to z -1.25) | 2.1: a cast bracket from the tunnel's wall under the main, stopping at the play space; the big one is where the old boom chain hangs | 5, 1 | C |
| `aguas_main_riser_west` | 0.3 x 1.65 x 1.35 | foot | 2.1: the main's west end as scenery: from the play space's back edge an elbow back to the wall, then up through the roof at x -253 (to 96), flanged, verdigris | 1 | C |
| `aguas_main_far_run` | 4.8 x 2.65 x 1.35 | foot (x -231.75, y 89.5) | 2.1: the main's east end as scenery, one bent run of 0.3 pipe made for its place: from (-229.5, 92.0) at the play space's back edge straight back to the wall (z -2.45), down to 91.1, west along the wall to x -234, and down the dry shaft behind the mine's lining (it ends hidden at 89.5). Flanged joints, verdigris | 1 | C |
| `aguas_flange_face` | 0.16 x 0.44 x 0.02 | the middle of its foot line, drawn | 2.1: a bolted flange ring drawn on the main every 3 m and at each end of a rusted length, rust orange with bolt heads | 8 | C |
| `aguas_beam_end`, `aguas_beam_end_long` | 0.3 x 0.4 x 0.95; 0.3 x 0.4 x 4.2 | foot (from the wall toward the play space) | An iron I-beam out of a back wall under a ledge, its end showing (2.1, 2.8; the long ones from the pool hall's flanks, 2.7) | 7, 4 | C |
| `aguas_mill_wheel_grey` | 4.0 x 3.61 x 1.87 | the hub | 2.2: the second water wheel, `mill_wheel` again (six timber arms, paddles, the pug on the hub) greyer and wetter, as scenery; it turns with yours (a2.py item 8) | 1 | C |
| `aguas_wheel_axle` | 0.3 x 0.3 x 2.0 | its middle, on the axle line | 2.2: the iron axle from the wheel you ride back to the second wheel through the frame's bearing | 1 | C |
| `aguas_tank` | 2.5 x 2.2 x 2.5 | foot | A round iron tank, riveted, dull blue-grey (2.4's settling tanks on the far bank; 2.9's feed tank on the middle pier, the cold feed pipe into its foot) | 3 | C |
| `aguas_tank_pipe` | 0.22 x 3.45 x 0.22 | foot (the tank's top) | 2.4: a green verdigris pipe from a tank's top up into the roof, flanged at both ends | 2 | C |
| `aguas_filler_turn` | 0.4 x 0.4 x 3.15 | foot | 2.4: the filler pipe's wall end: from the play space's back edge it turns straight back to the wall (z -4.4) over the landing; the kit's teal `valve_wheel` sits on it | 1 | C |
| `aguas_pipe_hanger` | 0.2 x 3.3 x 0.25 | foot (its cradle under the pipe's height) | 2.4: a cast hanger on a rod from the roof down to the filler pipe, standing just behind it | 2 | C |
| `aguas_spout_face` | 0.4 x 0.5 x 0.02 | the middle of its foot line, drawn | 2.4: drawn on the filler pipe's west end: a flared open mouth turned down, dull green inside | 1 | C |
| `aguas_sluice_gate` | 2.0 x 8.0 x 1.1 | foot | 2.5: a sluice gate's cast-iron frame, narrow: two guides with a slot for the leaf, a head with a seized rack and gear (the gear 0.6 across at the head's east side); the cast pug (kit `pug_stamp`) is placed on the head | 3 | C |
| `aguas_gate_leaf` | 1.7 x 4.3 x 0.15 | foot | 2.5: the gate's leaf, riveted plank-and-iron, black and wet low, yoked to the ram's head; it rides with the ram (a2.py item 8). While up, black water shows behind it | 3 | C |
| `aguas_regulator` | 4.7 x 8.6 x 0.8 | foot (x -252.5, y 116.6) | 2.5: the regulator, flat on the back wall: a riveted valve chest (x -253.3 .. -251.5, y 123.9 .. 125.2) and fat 0.5 pipes from it, along at 124.5 and down to each ram's gate (x -250.4 to 116.6; -252.4 to 119.6; -254.6 to 122.6) | 1 | C |
| `aguas_riser` | 0.35 x 14.5 x 0.35 | foot | Foreground: one riser pipe, verdigris, flanged at both ends, in front of solid rock at a frame's edge (2.1; 2.5; 2.9 in two lengths) | 4 | C |
| `aguas_hopper_back` | 13.0 x 6.7 x 2.34 | foot (x -264.7, y 114) | 2.6: the drain's iron hopper's back half, behind the play space: riveted plates, dull green-black and wet, sloping from the gallery's edge (-271.2, 120.7) down to the lower pipe (114); two plates missing (x -263.4 .. -261.6, 116.2 .. 118.0; -260.6 .. -259.0, 118.4 .. 120.0), the back wall's brick showing through | 1 | C |
| `aguas_pipe_mouth` | 5.8 x 4.4 x 1.65 | foot (x -262, y 128.2) | 2.6: the upper pipe's mouth: the back half of a heavy bolted flange round the hole in the roof, the pug cast in it, and the riveted pipe 5 m across going on up | 1 | C |
| `aguas_crane_beam` | 16.4 x 0.4 x 0.3 | the middle of its underside | 2.6: the iron crane beam under the roof, wall to wall, riveted; a trolley over each chain | 1 | C |
| `aguas_hoist_block` | 0.7 x 0.9 x 0.35 | foot | 2.6: an iron chain hoist block hanging from the beam's trolley (the chain you hold comes down past it) | 3 | C |
| `aguas_hopper_plate` | 0.6 x 2.3 x 0.6 | foot | 2.6: a curved hopper plate lifted out by the fitters, leaning on the gallery's wall, riveted edge | 3 | C |
| `aguas_frog_door` | 1.9 x 1.9 x 1.1 | foot | 2.0: the valve chamber's round iron door, riveted, the pug cast in its middle, a hand wheel; hinged on the back jamb and standing half open against the hall side, out of the way | 1 | C |
| `aguas_outlet_pipe` | 0.9 x 2.3 x 0.6 | foot | 2.0: the outlet valve's fat pipe up through the room's floor and into its east wall, with a round gauge 0.3 across above the wheel (the kit's `valve_wheel` sits on it) | 1 | C |
| `aguas_boiler_end` | 3.4 x 6.7 x 3.0 | foot (x -349.6, y 114.5) | 2.9: the boiler, end on, 3 m across (centre y 119.7), on its brick setting (114.5 .. 118.3) behind the stoker's grating; its fire door orange with the pug cast on it, the warmest colour in the biome (not glowing); the stop valve on its top is the first cool joint (the course's) | 1 | C |
| `aguas_flue` | 0.7 x 21.4 x 0.7 | foot | 2.9: the boiler's flue up the east wall to the roof, sooty iron, banded | 1 | C |
| `aguas_steam_pipe` | 29.2 x 18.5 x 0.5 | foot (x -363.65, y 119.75), z -2.2 .. -1.7 | 2.9: the steam pipe, 0.5 across, wrapped in lagging with wire bands, made to its route: from the boiler's stop valve (-349.3, 120.0) up the first flight through the hot joints (-350.2, 121.2), (-351.0, 122.4), (-351.9, 123.6); a straight sloping stretch across pier 1 to (-360.0, 125.6), (-360.7, 126.9), (-361.6, 128.1), (-362.3, 129.3); across pier 2 to (-370.0, 131.1), (-370.7, 132.4), (-371.6, 133.6), (-372.3, 134.7); across pier 3 to the engine's valve (-377.6, 136.6) and into the engine. At each of the eleven hot joints a bare stub comes straight forward off it to z -1.25 (the flange you hold is the course's) | 1 | C |
| `aguas_pump_engine` | 4.0 x 4.6 x 2.4 | foot | 2.9: the pump engine on the top pier, stopped: a bed, a cylinder and a flywheel 3.2 across (hub at y 137.8) | 1 | C |
| `aguas_run_arm` | 0.15 x 0.65 x 0.95 | foot (on the pier's coping) | 2.9: the arm that goes straight back from a cold run's strap to its pier's coping, behind the run | 6 | C |
| `aguas_run_strap_face` | 0.3 x 0.4 x 0.02 | the middle of its foot line, drawn | 2.9: drawn on a cold run: the iron strap round it, rust orange (part of the run: you hold it) | 6 | C |
| `aguas_dead_ladder` | 0.75 x 6.1 x 0.3 | foot | 2.10: the dead iron ladder between the two flights: two rails 0.45 apart, rusted, a stump where every rung was | 1 | C |
| `aguas_lifting_beam` | 4.4 x 0.5 x 0.3 | foot | 2.10: an iron beam under the roof with a ring on it (at x -386.6) that the climber's pale rope is tied to | 1 | C |
| `aguas_catwalk_bracket`, `aguas_catwalk_bracket_bent` | 0.16 x 0.75 x 0.95 | foot | 2.10b: a cast catwalk bracket out of the wall: straight (two under each sound plate, one standing empty at each gap); bent down and rusted (under each rusted length) | 11, 11 | C |
| `aguas_hand_rail`, `aguas_hand_rail_bent` | 2.0 x 0.3 x 0.45; 2.6 x 0.7 x 0.45 | foot (its brackets run back to the wall) | 2.10b: the back hand rail on the wall side, 1.1 m over the deck, on short wall brackets: whole, rust orange; bent and sagging | 4, 4 | C |
| `aguas_dam_main` | 33.5 x 0.5 x 0.5 | foot | 2.10b: the dam's main, a fat verdigris pipe flat on the back wall under the roof, flanged every 3 m, into the wall at both ends | 1 | C |
| `aguas_lift_rails` | 2.0 x 17.3 x 0.25 | foot | 2.11: the lift's two iron guide rails (x -439.6, -437.8) and the toothed rack between them that the winch's pinion climbs, flat on the shaft's back wall | 1 | C |
| `aguas_buffer_beam`, `aguas_spring_buffer` | 2.6 x 0.3 x 0.25; 1.0 x 0.3 x 0.25 | foot | 2.11: the buffer beam across the shaft's head; the spring buffer in a shallow pit at its foot | 1, 1 | C |
| `aguas_sluice_wheel_crusted` | 1.0 x 1.55 x 0.4 | foot | 2 to 3: the dam's sluice wheel on its spindle on the crest, teal, the pug cast in its hub, a crust of crystal on its rim | 1 | C |

## 4. Made for a2.py, not placed by the dress file (its FOR THE AREA FILE items 6 and 7)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `aguas_ram_head` | 2.05 x 3.4 x 2.0 | as `mill_gate` (the mover's) | 2.5 (note 19): the mover's model in place of `mill_gate`: the head (a thick riveted plate in rust orange with a raised rim, 0.24, the part you hold) on a broad ram as wide as it, black with oil and running wet | 3 (by a2.py) | C |
| `aguas_ram_housing` | 2.05 x 1.0 x 2.0 | foot | 2.5 (note 19): the fixed iron housing on each step the ram comes up out of, black with oil, slick | 3 (by a2.py) | C |
| `aguas_winch_cage` | 2.0 x 2.6 x 2.0 | the middle of its deck's top | 2.11 (note 25): the dam keeper's lift: a level deck 2 m wide, an open iron cage 2.2 tall (no front, no sides at deck height), a hand winch on its back frame with its crank facing the camera 1.5 above the deck, its shaft straight back to the pinion | 1 (by a2.py) | C |
| `aguas_ring_eyebolt` | 0.45 x 0.45 x 1.25 | where the bolt meets the plate (z -1.25) | 2.3 (note 18): a ring 0.4 across facing the camera on a short eye bolt that runs straight back to its plate; from the side the bolt hides behind its ring | 6 (by a2.py) | C |
| `aguas_chain_shackle` | 0.3 x 0.4 x 0.3 | its top | A big shackle on a hook at a chain's top (the three Cadenas chains at the roof, the flume's chain on the grating's edge, El Borde's on its bracket) | 5 (by a2.py) | C |
| `aguas_barrel` | 1.81 x 1.17 x 1.15 | its centre, as `barrel_float` | 2.7: the mine's barrel with two iron hoops and the company's pug branded on its end, in place of `barrel_float` | 8 (by a2.py) | C |
| `aguas_tread_end` | 0.55 x 0.4 x 0.3 | the hold's centre | 2.10: the free end of a stone stair tread, squared, pale, a worn nosing (it goes dark and shines when the spray is on it: the game's wet look) | 7 (by a2.py) | A |
