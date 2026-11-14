# La Mina Vieja: the models to make

The model list for biome 1, from its dress file `tools/peak/areas/a1_dress.py` (486 decos, 21
lanterns lit). Every stem here is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`.
Make each at exactly its size (metres, w x h x d; +z faces the camera). The game rescales a
landed model that is more than a quarter off. Where the dress file stretches a stock length
with `scale` (the timbers), it is said.

Makers: **A** buildings, walls and rock masses, far cards, ground slabs. **B** props, plants,
signs, small dressing. **C** timber structures, iron fittings, rails, machines.

The mine's look (the sheet `docs/peak/playtest/design/data/a1_biome.py`): what you hold is
honey timber, pale chalky rock, rust-orange iron; what you can't is black, wet and glossy
with even pale drips; scenery timber is greyer, darker and cooler, never honey. Rock and
lining are paint (BRIEF.md "Walls and masses"): long wavy flat bands, nothing that tapers to a
point, no dark recess cut into a face, a few big real breaks, a designed outline.

"Origin: foot" means the middle of its base (x and z) at its lowest point. "Skin" means the
model is the look of a course solid (`skin=` in a1.py): it fills the solid, z -1.2 .. 1.2.

## 1. Walls, masses and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `mine_el_diente` | 11.0 x 65.2 x 2.4 | foot (x -203.4, y -25.5) | Skin. El Diente, the pillar left to hold up the roof, outline as `SKIN_REGIONS` (wider below its shoulder at y 5.7). Painted beds of grey-violet rock; on its east face, black glossy clay with even drips, and the eight pale ore seams of Vetas de Lodo running back across it from each rib's root as slanting bands 0.4 thick (1.6) | 1 | A |
| `mine_east_mass` | 44.0 x 58.3 x 2.4 | foot (x -170, y -37) | Skin. The east mass the gallery (1.1) and the ladder shaft (1.2) are bored through, and the beach slope. Painted beds; the shaft's east wall glossy black with even pale drips and nothing pale on it (1.2) | 1 | A |
| `mine_chamber_roof` | 66.5 x 37.7 x 2.4 | foot (x -181.25, y 21.3) | Skin. The cavern's flat roof over Las Vigas and the east wall's slope down to the shaft's head. Painted beds, darker underneath; plain where the bolt plates go (1.8) | 1 | A |
| `mine_upper_works_mass` | 23.5 x 35.0 x 2.4 | foot (x -226.25, y 55) | Skin. The rock of the upper works: the rock between the two levels (1.10), the throat's east wall, the roof round the dry shaft. On the rock between the levels, a slanting band of gold ore and a few old drill holes (1.10, "the biggest thing on the screen") | 1 | A |
| `mine_throat_west` | 8.0 x 127.0 x 2.4 | foot (x -248, y -37) | Skin. The west wall from the Sump's floor to the throat's roof, black and running with the fall's spray; the frog's cave doorway at the water line (1.0); the pier's rock foot (the lip) | 1 | A |
| `mine_cavern_far_wall` | 110.0 x 134.0 x 0.3 | foot, z -6.25 | The cavern's far wall: one flat painted card, cold grey-violet, a few long bands, behind everything ("The cavern, first seen", 1.1b; 1.2). Mid values: the game lifts lit faces | 1 | A |
| `mine_cavern_wall_low` | 25.9 x 27.0 x 0.7 | foot | The cavern's hand-cut wall behind the landing stage (1.0b): flat, pick-marked, black and wet down here, the lower walk's row of sockets far overhead. Meets `_mid` along y -6 | 1 | A |
| `mine_cavern_wall_mid` | 30.9 x 24.0 x 0.7 | foot | The same wall behind Los Tablones and La Cuerda (1.3, 1.4), 1.7 m behind the walk: dry above the planks, dark with wet below, painted, no recesses | 1 | A |
| `mine_cavern_wall_high` | 17.9 x 26.0 x 0.7 | foot | The same wall behind El Cubo and Vetas de Lodo (1.5, 1.6). Eight faint seams climbing east at the pillar's slant (0.179 per metre), greyer than the rock so none reads as a ledge; two old workings painted as darker bands 1.1 m wide along the seams at 32.15 and 37.3 (no recess) | 1 | A |
| `mine_chain_rib` | 20.1 x 13.2 x 1.8 | foot (x -224.85, y 40.2) | The chain rib (1.7, 1.8): a rib of the back wall slanting up from the fall to under the beams, its outline `_RIB`. Beds of three grey-violets along its slant, one band of ore under the rings, an overhang along its lower edge with a painted shadow; no ink inside its face | 1 | A |
| `mine_chain_rib_body` | 24.0 x 17.0 x 1.0 | foot, z -4.9 | The back wall carried on 3 m behind the rib: two or three slanted planes, duller and cooler, its beds thin lines, an uneven skyline (1.7) | 1 | A |
| `mine_el_diente_body` | 11.0 x 65.5 x 1.95 | foot, z -2.225 | El Diente's own body behind its face, from the tunnel's roof up; its top flat at y 40, the ground the second cart and the back rail stand on (1.7). Replaces today's flat card | 1 | A |
| `mine_upper_works_body` | 15.5 x 35.0 x 1.0 | foot, z -3.0 (face at -2.5) | The upper works' rock behind the upper gallery and the top drift: their back wall, plain hand-cut rock (1.9, 1.10, 1.11) | 1 | A |
| `mine_incline_bench` | 20.5 x 4.9 x 2.1 | foot (x -219.15, y 21.5) | The bench under the incline (1.7): the same painted rock as the rib, darker and wetter, an uneven top at y 25.5 to 26.4; the incline's posts stand on it | 1 | A |
| `mine_cortina_wall` | 18.0 x 26.0 x 0.4 | foot, face at z -1.6 | The throat's back wall the staples are hammered into (1.11, the lip): black polished rock running with water, its drips lines of one even width | 1 | A |
| `mine_cave_rock` | 8.0 x 18.0 x 2.45 | foot, z -2.775 | The rock the frog's cave is cut in, carried on west and back, black and running with spray, the room's mouth open in it (1.0) | 1 | A |
| `mine_frog_cave` | 5.4 x 2.7 x 2.35 | foot (x -250.7, y -27.5) | The watchman's room, 4.2 m wide with a doorway 1.2 deep and 2.1 high: back wall, roof and side walls, its front cut away, dry and warm-lit. Its floor is the course's (1.0, note 71) | 1 | A |
| `mine_tunnel_back` | 11.0 x 7.5 x 0.3 | foot | The back wall of the bottom level's tunnel through the pillar's foot, hand-cut rock, wet; the sets stand in front of it in the water (1.0b) | 1 | A |
| `mine_lining_gallery` | 24.0 x 5.1 x 0.15 | foot (x -164) | The gallery's back wall, door to mouth (1.1, 1.1b): plank lining as long flat bands in bays. Over the pit a black burst painted on it, and by the door the ore chute's dark hole painted on it. Two real openings, for the waiting room (x -170.1 .. -167.95) and the winch's cut (x -175.7 .. -173.9) | 1 | A |
| `mine_lining_escalera` | 4.0 x 13.4 x 0.3 | foot | The ladder shaft's back wall (1.2): lining with its frames every 1.3 m as real shape, planks painted, black with wet and green at the seams, two bays painted as wet rock | 1 | A |
| `mine_lining_derrumbe` | 3.6 x 15.3 x 0.3 | foot | El Derrumbe's back wall (1.10): lining with frames at the page's 12 set heights, two bays gone to dark rock, two pale scars down its middle 0.2 apart (where the rocks fall) | 1 | A |
| `mine_lining_dry_shaft` | 4.0 x 4.0 x 0.3 | foot | The dry shaft at the top of La Cortina (1.11, the lip): lining on three frames (86.3, 87.6, 88.9) | 1 | A |
| `mine_rib_short`, `mine_rib`, `mine_rib_wide` | 0.9 / 1.2 / 1.5 x 0.42 x 2.4 | foot (its lowest point, x middle) | Skins of Vetas de Lodo's ribs: a bed of the pillar in the pale chalky hold colour, standing proud 0.6 / 0.9 / 1.2 from the face, square ends, a broken edge. The wide ones carry a row of old drill holes (1.6) | 4, 2, 2 | A |
| `mine_waiting_room` | 2.15 x 2.1 x 1.2 | foot | The miners' waiting room cut in the gallery wall, with a plank bench and a rail of wooden pegs (1.1b) | 1 | A |
| `mine_winch_cut` | 1.8 x 1.7 x 1.6 | foot | The shallow cut by the gallery's mouth the winch stands in, its floor timbered (1.1b) | 1 | A |
| `mine_mud_tongue` | 10.0 x 4.5 x 1.7 | foot | Black glossy mud coming down out of the gallery's burst wall into the pit, with slide marks (1.1) | 1 | A |
| `mine_rubble_heap_big` | 5.0 x 2.5 x 2.4 | foot | The rubble at the foot of El Derrumbe, carried on back behind the slope (1.10) | 1 | A |
| `mine_rubble_lip` | 10.0 x 1.0 x 0.7 | foot | The foreground's low lip of mud-caked rubble along the bottom of a frame, a wavy top (1.1, 1.1b, 1.10). Placed at 0.42 and 1.07 too | 5 | A |
| `mine_outcrop`, `mine_outcrop_small` | 1.0 x 0.5 x 0.45; 0.6 x 0.35 x 0.3 | the middle of its back edge's foot, on the wall | A small knob of the wall's rock standing out of it, a flat top for a plant (the sheet's kit; the rib's outcrop, 1.7) | 3, 8 | A |
| `mine_dark_hole` | 2.0 x 4.2 x 0.1 | foot | Black inside the chimney the rocks fall from (1.10, note 12) | 1 | A |
| `works_arch_low` | 3.9 x 1.95 x 0.4 | foot, on the timber set's cap | The works' first arch, springing straight off the mine's last timber cap, lower than the works' others, in flat courses of slate brick colour (not brick by brick), a cast iron pug in its middle (the lip) | 1 | A |
| `works_brick_pier_post` | 0.55 x 2.0 x 0.35 | foot | Foreground: a brick pier half a metre wide on top of a grey timber post, in front of the pier's rock (the lip) | 1 | A |
| `works_coping_face`, `works_brick_courses_face` | 6.0 x 0.3 x 0.02; 0.5 x 0.5 x 0.02 | the middle of its foot line, on the ledge's face | Drawn on the lip ledge: a course of pale stone coping; five courses of dry pale brick at its west end (the lip) | 1, 1 | A |

## 2. Props, plants and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `mine_fern_pale` | 0.6 x 0.5 x 0.04 | foot | The mine's fern: one flat painted card, pale green fronds as flush colours, only its outline inked; near the fall and the drips (sheet's kit; 1.7) | 5 | B |
| `mine_moss` | 0.9 x 0.18 x 0.3 | foot | A pad of moss on an outcrop's top, flush colours, low | 6 | B |
| `mine_mushrooms_pale` | 0.35 x 0.22 x 0.05 | the middle of its back's foot, on the timber | A clump of little pale mushrooms on old timber, one flat painted card | 5 | B |
| `mine_frog_stove` | 0.6 x 0.7 x 0.5 | foot | The frog's little iron stove; the kettle (`tea_kettle`) stands on it (1.0) | 1 | B |
| `mine_frog_shelf` | 2.2 x 0.45 x 0.3 | the middle of its back's foot, on the wall | A shelf of lost boots and climbers' masks the water brought in (1.0) | 1 | B |
| `mine_towel_peg` | 0.4 x 0.6 x 0.1 | the middle of its back's foot, on the wall | A towel on a peg (note 4: on a peg, never a line) (1.0) | 1 | B |
| `mine_bucket_upturned` | 0.6 x 0.45 x 0.6 | foot | A small ore bucket upside down; the frog sits on it (1.0) | 1 | B |
| `mine_bucket_side` | 1.0 x 0.9 x 0.9 | foot | A spare ore bucket on its side on the station deck, grey (1.5) | 1 | B |
| `mine_bucket_crushed` | 1.0 x 0.7 x 1.0 | foot | The hoist's bucket, crushed, half buried in the rubble (1.10) | 1 | B |
| `mine_bunting_torn` | 3.5 x 0.8 x 0.1 | its west hook | The miners' bunting from town, torn and faded, 3.5 m, a hook at each end so it is fixed to something (1.1b) | 1 | B |
| `mine_water_marks` | 0.3 x 0.9 x 0.02 | the middle of its foot line | The watchman's scratched marks of the water rising, up the door post; the last level with the doorstep (1.0) | 1 | B |
| `mine_socket_empty` | 0.3 x 0.3 x 0.02 | the middle of its foot line, on the face | Drawn on rock: the square socket a beam sat in, painted dark with a broken pale rim, not cut (1.2, 1.3, 1.4, 1.10) | 15 | B |
| `mine_socket_scarred` | 0.3 x 0.7 x 0.02 | the same | The same socket with a pale scar under it where the strut tore off (1.3) | 4 | B |
| `mine_socket_stump` | 0.3 x 0.3 x 0.08 | the same | A socket with the stump of its bearer in it (1.4) | 1 | B |
| `mine_end_splintered` | 0.36 x 0.36 x 0.02 | the same | Drawn on a beam's end, seen end-on: end grain splintered where the front post tore away (1.1) | 5 | B |
| `mine_side_splintered` | 0.3 x 0.36 x 0.02 | the same | Drawn on a timber's front face at a broken end: splinters (1.4, 1.8, 1.10). Placed at 0.61 to 1.11 | 15 | B |
| `mine_post_tongue` | 0.45 x 0.15 x 0.02 | the same | Drawn on a sunk post's head: the cut tongue a beam sat on (1.1) | 4 | B |
| `mine_mud_tideline` | 0.45 x 1.5 x 0.02 | the same | Drawn on a sunk post: black with mud up to a wavy tide line (1.1) | 4 | B |
| `mine_pile_band` | 0.42 x 0.8 x 0.02 | the same | Drawn on a pile: a dark stain to the old high water and a rusted band round its head (1.0) | 4 | B |
| `mine_rust_stain` | 0.6 x 0.3 x 0.01 | the same, on the wall | A small square rust stain on the rock round a staple's feet, painted (1.11) | 28 | B |
| `mine_rust_lines` | 20.5 x 0.12 x 0.02 | its middle | Drawn up the incline: two faint rust lines where the rails were (1.0b) | 1 | B |
| `mine_trimmer_end` | 0.25 x 0.3 x 0.02 | the middle of its foot line | Drawn on the station deck's west end: a trimmer across it, a finished edge, not a break (1.5) | 1 | B |
| `mine_worn_path` | 3.4 x 0.01 x 0.35 | foot | Painted on the gallery floor: a track one boot wide worn pale (1.1b) | 1 | B |

## 3. Timber, iron, rails and machines (maker C)

The mine's timber is one family, 0.35 m square, chamfered, grey scenery tone, sawn ends,
built like `mine_post`. The dress file lays any of them at any angle and stretches the
nearest stock by up to a quarter.

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `mine_post_stub` | 0.35 x 0.9 x 0.35 | foot | Timber stock 0.9 m; the gallery's two stubs left under the roof (1.1) | 2 | C |
| `mine_post_mid` | 0.35 x 2.0 x 0.35 | foot | Timber stock 2.0 m | 3 | C |
| `mine_post_tall` | 0.35 x 4.75 x 0.35 | foot | Timber stock 4.75 m: the gallery's back posts, full height (1.1, 1.1b), drowned sets, hangers | 24 | C |
| `mine_post_long` | 0.35 x 6.5 x 0.35 | foot | Timber stock 6.5 m: drowned sets, the tunnel's sets, braces | 13 | C |
| `mine_timber_long` | 0.35 x 8.5 x 0.35 | foot | Timber stock 8.5 m: the arm's twin (1.4), bearers, caps, the long strut (1.7) | 6 | C |
| `mine_post_broken_short`, `mine_post_broken`, `mine_post_broken_long` | 0.3 x 1.6 / 2.6 / 3.8 x 0.3 | foot | The front post of a timber set in broken lengths, splintered at both ends, grey and wet: the foreground of every shaft (1.2, 1.5, 1.7, 1.9, 1.10, 1.11), also the gallery's upper halves and the landing's stumps. One placed at 1.45 (El Cubo, 5.5 m) | 8, 12, 9 | C |
| `mine_prop_short` | 0.18 x 1.15 x 0.18 | foot | A short timber prop standing in an old working (1.6) | 6 | C |
| `mine_beam_roof` | 18.5 x 0.35 x 0.35 | the middle of its underside | Las Vigas's back beam, whole, under the roof, with three iron rollers the haul chain ran over; nothing hangs from them (1.7, 1.8) | 1 | C |
| `mine_walk_bearer` | 0.4 x 1.3 x 1.65 | the middle of the bearer's top | A square timber out of a wall socket to a walk or deck, seen end-on, with a strut under it (the pages' "walk bearer"; 1.3, 1.5) | 13 | C |
| `mine_bearer_snapped` | 0.3 x 0.3 x 0.5 | the middle of its back's foot, on the wall | A bearer snapped off short in its socket (1.4) | 1 | C |
| `mine_deck_back` | 7.9 x 0.3 x 1.65 | foot | El Cubo's station deck carried on back to the wall, planks (1.5) | 1 | C |
| `mine_gangway_stub` | 1.0 x 0.2 x 0.9 | foot | The stub of a gangway at the boarded tunnel's foot (1.3) | 1 | C |
| `mine_boarded_tunnel` | 1.8 x 2.9 x 0.4 | foot | A side tunnel's timber mouth, its dark painted flush, two planks nailed across (1.0, 1.3, 1.10) | 3 | C |
| `mine_half_landing` | 1.6 x 0.14 x 1.0 | foot | A half landing in the ladder way, planks on a frame (flip for the other side) (1.10) | 8 | C |
| `mine_landing_rotted` | 2.5 x 0.76 x 1.1 | the middle of its width, at the deck's top | A rotted landing: east half in place, west half hanging 0.62 down (1.2) | 3 | C |
| `mine_ladder` | 0.5 x 2.0 x 0.08 | foot | A short wooden ladder of the ladder way, grey (1.10). Placed at 0.9 and 1.2 | 2 | C |
| `mine_ladder_snapped` | 0.5 x 1.0 x 0.08 | foot | The same, snapped, ending in the air (1.10) | 2 | C |
| `mine_incline_bent_tall`, `mine_incline_bent`, `mine_incline_bent_low` | 0.35 x 7.8 / 2.95 / 1.9 x 1.55 | the post's foot, the middle of the bent's depth | The incline's bent: a post at the back (z -2.8) whose cap comes forward under the rails to the play space's edge (1.7) | 1, 1, 1 | C |
| `mine_frame_open` | 0.6 x 4.5 x 3.2 | foot (z middle) | The upper gallery's mouth set: the back post (z -1.6 .. -1.25) and the cap across, the front post gone (1.9) | 1 | C |
| `mine_pile_twin` | 0.95 x 5.7 x 0.4 | the post's foot | A staging pile 0.4 square with the stub of the deck beam that joined it to its twin (1.0) | 2 | C |
| `mine_lamp_post` | 0.55 x 3.5 x 0.2 | the post's foot | A thin timber post with an iron crook; its hook is 0.35 east, 3.45 up (1.7, 1.0b) | 3 | C |
| `mine_wall_bracket` | 0.1 x 0.3 x 0.25 | the middle of its plate's back, on the wall | An iron bracket out of a wall, its hook 0.2 out at its own height (1.3, 1.4, 1.6, 1.7, 1.11) | 6 | C |
| `mine_lantern_bracket` | 0.48 x 0.15 x 0.06 | its fixed end | An iron strap bracket in the wall's plane, its hook 0.42 along it, 0.03 down; turned down from a roof timber or out from a post (1.1, 1.8, 1.9, the lip) | 6 | C |
| `mine_iron_strap` | 0.4 x 0.3 x 0.05 | the middle of its back | A rust-orange strap where timber meets timber or the rope's bracket meets the last set (1.1, 1.4, 1.11) | 7 | C |
| `mine_iron_eye` | 0.3 x 0.3 x 0.02 | the middle of its foot line | Drawn on the greased rod's foot: the iron eye the rope is knotted through (1.4) | 1 | C |
| `mine_stirrup`, `mine_stirrup_wet` | 0.5 x 0.5 x 0.03 | the same | Drawn on a Vigas piece where its hanger takes it: a rust-orange stirrup on the dry first; black as the wet timber on the other three (1.8) | 1, 3 | C |
| `mine_bolt_plate` | 0.7 x 0.18 x 0.02 | the same | Drawn on the roof over each hanger: an iron plate with four bolt heads (1.8) | 4 | C |
| `mine_spike_plate` | 0.3 x 0.12 x 0.02 | the same | Drawn on an incline sleeper: the iron plate the rail was spiked through (1.0b) | 12 | C |
| `mine_nail_row` | 0.08 x 0.08 x 0.01 | the same | Drawn on a sound plank: a row of iron nail heads over its bearer (1.3, 1.9) | 12 | C |
| `mine_rail_single` | 2.0 x 0.15 x 0.15 | the middle of its underside | One rail length, spiked; the incline's back rail (1.0b) and the siding's back rail (1.7) | 14 | C |
| `mine_rail_bent_end` | 2.0 x 0.9 x 1.2 | foot | A rail pair bent down over a brink, the track stopping there (1.1) | 3 | C |
| `mine_rail_end_torn` | 0.1 x 0.25 x 0.1 | where it joins the rail | A torn, rusted end of the iron ladder's rail (1.2) | 12 | C |
| `mine_sleeper` | 1.1 x 0.2 x 0.25 | foot | One sleeper left on the pit's floor (1.1) | 1 | C |
| `mine_ore_chute` | 2.5 x 0.45 x 0.22 | the middle of its underside | The timber ore chute on two wall brackets, flat against the gallery wall (1.1) | 1 | C |
| `mine_water_trough` | 5.0 x 0.5 x 0.5 | the middle of its underside | A timber trough running with water from the fall to the water wheel, cut from the ore chute (1.9) | 1 | C |
| `mine_hand_winch` | 1.6 x 1.4 x 0.8 | foot | The hand winch on its timber frame, a bare drum, its handle up (1.1b, 1.10, 1.11) | 2 | C |
| `mine_hoist_wheel_bent` | 1.4 x 1.4 x 0.3 | the hub | A hoist wheel 1.1 across on a bent bracket, knocked crooked, no cable (1.10) | 1 | C |
| `mine_chimney_mouth` | 3.6 x 2.0 x 1.3 | the middle under its lowest timber | Snapped roof timbers and torn planking hanging round the chimney's mouth (1.10) | 1 | C |
| `mine_stub`, `mine_stub_short` | 0.95 / 0.8 x 0.3 x 2.4 | its middle, at its underside | Skins of El Derrumbe's stubs (0.75 and 0.6 long): a broken cross-beam out of the wall, honey, splintered tip (flip for the west wall) (1.10) | 6, 2 | C |
| `mine_cart_road` | 10.1 x 12.4 x 1.3 | foot (x -218.1, y 27.6) | Skin of the cart's new road (note 103): rails on two stringers with sleepers, made to the curve (crest, 72-degree drop, dip, 45-degree rise), honey; at the lip, two snapped boards and the rail ends bent up (1.7) | 1 | C |
| `mine_drip_board` | 0.85 x 0.1 x 0.08 | its middle | A short grey board nailed to the wet wall at a slant over a dry staple (1.11) | 4 | C |
| `mine_flat_boat` | 3.5 x 0.8 x 1.0 | foot | The miners' flat boat, 3 m, sunk at its mooring, one end out of the water (1.0b) | 1 | C |

## 4. Made for a1.py, not placed by the dress file (its FOR THE AREA FILE items 7 and 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `iron_ring_pin_long` | 0.5 x 0.55 x 1.65 | where the pin meets the rock | `iron_ring_pin` with a pin as thick as a wrist that comes 1.6 m out of the rib, so the ring 0.5 across hangs in the play space (1.7, 1.8) | 3 (by a1.py) | C |
| `mine_staple_bound` | 0.4 x 0.1 x 0.25 | as `iron_staple` | `iron_staple` bound round and round with pale cord, the always-dry rests (1.11) | 5 (by a1.py) | C |
| `mine_chock` | 0.45 x 0.32 x 0.3 | foot | The wooden wedge under the cart's west wheel, on the cart mover (1.7) | 1 (by a1.py) | B |
